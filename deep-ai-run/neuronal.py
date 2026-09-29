"""
NN Training Pipeline for Compass-Construction Search (v2)
===========================================================
Main changes compared to the first version:

  1. Split on FILE / CONSTRUCTION level instead of feature level.
     -> Prevents circles belonging to the same construction from
        ending up in both the train and validation set (data leakage).

  2. Feature [7] ("error to target") is now computed ONLY from the
     points that actually exist up to this construction step
     (causally correct). Previously the error was computed from ALL
     points of the finished construction, which effectively leaked
     the label (the network only had to learn "feature 7 small ->
     good"), and is not available in this form during live use in
     the randomizer anyway (the construction is not finished yet at
     that point).

  3. Weight decay + an additional dropout layer for more
     regularization.

  4. Diagnostic output: distribution comparison pos/neg per feature,
     so leakage / shortcut features can be spotted directly in the
     future.

USAGE:
    python3 train_nn_v2.py --data_folder "/path/to/good_mat_files" \
                            --neg_data_folder "/path/to/bad_mat_files" \
                            --target_idx 0 --output nn_weights_sqrtpi.npz

    target_idx: 0=sqrtpi, 1=cuberoot2, 2=heptagon
"""

import os
import glob
import argparse
import numpy as np
import scipy.io as sio
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, TensorDataset

# ══════════════════════════════════════════════════════════════
# 1. ARGUMENTS
# ══════════════════════════════════════════════════════════════

parser = argparse.ArgumentParser()
parser.add_argument("--data_folder", type=str, required=True,
                    help="Folder with good (positive) constructions (.mat)")
parser.add_argument("--neg_data_folder", type=str, default=None,
                    help="Folder with stored BAD constructions (.mat). "
                         "If not provided, random negatives are generated instead.")
parser.add_argument("--output",      type=str, default="nn_weights.npz")
parser.add_argument("--epochs",      type=int, default=150)
parser.add_argument("--target_idx",  type=int, default=0,
                    help="0=sqrtpi, 1=cuberoot2, 2=heptagon")
parser.add_argument("--val_frac",    type=float, default=0.2,
                    help="Fraction of FILES (not samples!) used for validation")
parser.add_argument("--weight_decay", type=float, default=1e-4)
parser.add_argument("--seed", type=int, default=42)
args = parser.parse_args()

TARGET_NAMES = ["sqrtpi", "cuberoot2", "heptagon"]
TARGETS      = [np.sqrt(np.pi), 2**(1/3), np.sin(np.pi/7)]

target_name = TARGET_NAMES[args.target_idx]
target_val  = TARGETS[args.target_idx]

print(f"\n{'='*55}")
print(f"  Training for target: {target_name}")
print(f"  Target value: {target_val:.10f}")
print(f"{'='*55}\n")


# ══════════════════════════════════════════════════════════════
# 2. FEATURE EXTRACTION
#
# Features per circle (9 values):
#   [0] Radius
#   [1] real(center)
#   [2] imag(center)
#   [3] real(radius point)
#   [4] imag(radius point)
#   [5] Number of points (up to this step) / 100
#   [6] Number of circles (up to this step) / 20
#   [7] Min. distance of all points EXISTING SO FAR to target
#       (causally correct: only points that exist at this point in
#        time of the construction!)
#   [8] Position in sequence (0=early, 1=late)
# ══════════════════════════════════════════════════════════════

def points_used_up_to(C, ci):
    """
    Largest point index referenced by circles 0..ci (inclusive),
    using 1-indexing as stored in the .mat files. Used to determine
    which points already exist at the time of step `ci` -- we assume
    that new points (circle intersections) can only be created by
    earlier circles, and approximate "points existing so far" via the
    highest referenced point index up to and including circle ci.
    """
    sub = C[:ci + 1]
    valid = sub[np.any(sub != 0, axis=1)]
    if len(valid) == 0:
        return 0
    return int(np.max(valid))  # 1-indexed max -> number of points (0-indexed bound)


def extract_features(P, C, R, target_val):
    """
    P: complex128 array (n_points,)
    C: int array (n_circles, 2) - 1-indexed!
    R: float array (n_circles,)
    """
    features = []
    n_circles = C.shape[0]
    n_start   = 4  # the first 4 circles are always the starting configuration
    n_pts_total = len(P)

    for ci in range(n_start, n_circles):
        mid_idx = int(C[ci, 0]) - 1
        rad_idx = int(C[ci, 1]) - 1

        if mid_idx < 0 or mid_idx >= n_pts_total: continue
        if rad_idx < 0 or rad_idx >= n_pts_total: continue

        # --- causally correct subset of points that exist up to this
        #     step ---
        n_pts_so_far = points_used_up_to(C, ci)
        n_pts_so_far = max(n_pts_so_far, mid_idx + 1, rad_idx + 1)
        n_pts_so_far = min(n_pts_so_far, n_pts_total)

        if n_pts_so_far >= 2:
            P_sub = P[:n_pts_so_far]
            D_sub = np.abs(P_sub[:, None] - P_sub[None, :])
            np.fill_diagonal(D_sub, np.inf)
            err_so_far = float(np.min(np.abs(D_sub - target_val)))
        else:
            err_so_far = 1.0  # no meaningful estimate possible -> neutral default

        radius  = float(R[ci])
        mid_pt  = P[mid_idx]
        rad_pt  = P[rad_idx]
        frac    = (ci - n_start) / max(n_circles - n_start, 1)

        feat = np.array([
            radius,
            float(np.real(mid_pt)),
            float(np.imag(mid_pt)),
            float(np.real(rad_pt)),
            float(np.imag(rad_pt)),
            n_pts_so_far / 100.0,
            (ci + 1)     / 20.0,
            min(err_so_far, 1.0),
            frac
        ], dtype=np.float32)

        features.append(feat)

    return features


def load_mat_files(folder, target_name, label_name):
    pattern   = os.path.join(folder, "**", f"*{target_name}*.mat")
    mat_files = glob.glob(pattern, recursive=True)

    if len(mat_files) == 0:
        pattern   = os.path.join(folder, "**", "*.mat")
        mat_files = glob.glob(pattern, recursive=True)

    print(f"  [{label_name}] .mat files found: {len(mat_files)}")
    if len(mat_files) == 0:
        raise FileNotFoundError(f"No .mat files in: {folder}")
    return mat_files


def extract_features_from_file(fpath, target_val):
    """Returns (feats_list, errs_list) for ONE .mat file."""
    feats_out, errs_out = [], []
    try:
        mat = sio.loadmat(fpath)
    except Exception as e:
        print(f"    Error: {os.path.basename(fpath)}: {e}")
        return feats_out, errs_out

    if "errors" not in mat or "constructions" not in mat:
        return feats_out, errs_out

    errors_arr    = mat["errors"].flatten()
    constructions = mat["constructions"].flatten()

    for i, constr in enumerate(constructions):
        try:
            P = constr['P'][0, 0].flatten()
            C = constr['C'][0, 0]
            R = constr['R'][0, 0].flatten()
            err = float(errors_arr[i]) if i < len(errors_arr) else 1.0

            valid_C = np.any(C != 0, axis=1)
            C_clean = C[valid_C]
            R_clean = R[:len(C_clean)]

            if len(C_clean) <= 4:
                continue  # only the starting configuration, nothing to learn

            feats = extract_features(P, C_clean, R_clean, target_val)
            for f in feats:
                feats_out.append(f)
                errs_out.append(err)

        except Exception:
            continue

    return feats_out, errs_out


# ══════════════════════════════════════════════════════════════
# 3. READ FILES AND SPLIT ON FILE LEVEL
#    (prevents leakage between train/val)
# ══════════════════════════════════════════════════════════════

def build_split(folder, target_name, target_val, label_name, val_frac, rng):
    mat_files = load_mat_files(folder, target_name, label_name)
    mat_files = sorted(mat_files)  # deterministic order before shuffling
    perm = rng.permutation(len(mat_files))
    mat_files = [mat_files[i] for i in perm]

    n_val = max(1, int(round(len(mat_files) * val_frac))) if len(mat_files) > 1 else 0
    val_files   = mat_files[:n_val]
    train_files = mat_files[n_val:]

    def collect(files):
        feats, errs = [], []
        for fp in files:
            f, e = extract_features_from_file(fp, target_val)
            feats.extend(f)
            errs.extend(e)
        return feats, errs

    tr_feats, tr_errs = collect(train_files)
    va_feats, va_errs = collect(val_files)

    print(f"  [{label_name}] Files: {len(train_files)} train / {len(val_files)} val")
    print(f"  [{label_name}] Samples: {len(tr_feats)} train / {len(va_feats)} val")

    return tr_feats, va_feats


rng_files = np.random.default_rng(args.seed)

print("Loading good (positive) constructions...")
pos_tr_feats, pos_va_feats = build_split(
    args.data_folder, target_name, target_val, "POSITIVE", args.val_frac, rng_files)

if len(pos_tr_feats) == 0:
    raise ValueError("No positive training features extracted!")

if args.neg_data_folder:
    print("\nLoading bad (negative) constructions...")
    neg_tr_feats, neg_va_feats = build_split(
        args.neg_data_folder, target_name, target_val, "NEGATIVE", args.val_frac, rng_files)
    if len(neg_tr_feats) == 0:
        raise ValueError("No negative training features extracted!")
else:
    print("\nNo --neg_data_folder provided -> generating random negatives (fallback)...")

    def random_negs(n, rng):
        return np.column_stack([
            rng.uniform(0.01, 3.0,  n),
            rng.uniform(-2.0, 3.0,  n),
            rng.uniform(-2.0, 2.0,  n),
            rng.uniform(-2.0, 3.0,  n),
            rng.uniform(-2.0, 2.0,  n),
            rng.uniform(0.05, 0.5,  n),
            rng.uniform(0.2,  1.0,  n),
            rng.uniform(1e-4, 1.0,  n),
            rng.uniform(0.0,  1.0,  n),
        ]).astype(np.float32)

    rng_neg = np.random.default_rng(args.seed)
    neg_tr_feats = list(random_negs(len(pos_tr_feats), rng_neg))
    neg_va_feats = list(random_negs(max(len(pos_va_feats), 1), rng_neg))

X_pos_tr = np.stack(pos_tr_feats)
X_pos_va = np.stack(pos_va_feats) if len(pos_va_feats) > 0 else np.zeros((0, 9), dtype=np.float32)
X_neg_tr = np.stack(neg_tr_feats)
X_neg_va = np.stack(neg_va_feats) if len(neg_va_feats) > 0 else np.zeros((0, 9), dtype=np.float32)

# Balance negatives in the training set to the number of positives
# (this sampling happens strictly within the training set, so there
# is no leakage into the validation set)
rng_bal = np.random.default_rng(args.seed)
if len(X_neg_tr) > len(X_pos_tr):
    sel = rng_bal.choice(len(X_neg_tr), size=len(X_pos_tr), replace=False)
    X_neg_tr = X_neg_tr[sel]
elif len(X_neg_tr) < len(X_pos_tr):
    sel = rng_bal.choice(len(X_neg_tr), size=len(X_pos_tr), replace=True)
    X_neg_tr = X_neg_tr[sel]

# ══════════════════════════════════════════════════════════════
# 4. DIAGNOSTICS: do pos/neg distributions overlap per feature?
#    (Helps spot shortcut/leakage features like the old feature 7
#     BEFORE spending hours debugging.)
# ══════════════════════════════════════════════════════════════

FEATURE_NAMES = ["radius", "re(mid)", "im(mid)", "re(rad)", "im(rad)",
                  "n_pts/100", "n_circ/20", "min_err_so_far", "frac"]

print("\nFeature diagnostics (training data, pos vs neg):")
print(f"  {'Feature':16s} {'pos_mean':>10s} {'neg_mean':>10s} {'pos_std':>9s} {'neg_std':>9s}")
for j, name in enumerate(FEATURE_NAMES):
    pm, nm = X_pos_tr[:, j].mean(), X_neg_tr[:, j].mean()
    ps, ns = X_pos_tr[:, j].std(),  X_neg_tr[:, j].std()
    flag = "  <-- possible shortcut!" if abs(pm - nm) > 2 * (ps + ns + 1e-8) else ""
    print(f"  {name:16s} {pm:10.4f} {nm:10.4f} {ps:9.4f} {ns:9.4f}{flag}")
print()

# ══════════════════════════════════════════════════════════════
# 5. ASSEMBLE DATASET
# ══════════════════════════════════════════════════════════════

X_tr = np.vstack([X_pos_tr, X_neg_tr])
y_tr = np.array([1.0] * len(X_pos_tr) + [0.0] * len(X_neg_tr), dtype=np.float32)

X_va = np.vstack([X_pos_va, X_neg_va]) if len(X_pos_va) + len(X_neg_va) > 0 else X_tr[:0]
y_va = np.array([1.0] * len(X_pos_va) + [0.0] * len(X_neg_va), dtype=np.float32)

rng_shuffle = np.random.default_rng(args.seed)
idx_tr = rng_shuffle.permutation(len(X_tr))
X_tr, y_tr = X_tr[idx_tr], y_tr[idx_tr]
if len(X_va) > 0:
    idx_va = rng_shuffle.permutation(len(X_va))
    X_va, y_va = X_va[idx_va], y_va[idx_va]

# Normalization: statistics computed ONLY from training data (otherwise
# we would again leak a bit of information via the mean/std of the
# validation set)
X_mean = X_tr.mean(axis=0)
X_std  = X_tr.std(axis=0) + 1e-8
X_tr_norm = (X_tr - X_mean) / X_std
X_va_norm = (X_va - X_mean) / X_std if len(X_va) > 0 else X_va

print(f"Total train: {len(X_tr)} samples ({len(X_pos_tr)} pos, {len(X_neg_tr)} neg)")
print(f"Total val:   {len(X_va)} samples ({len(X_pos_va)} pos, {len(X_neg_va)} neg)")

train_loader = DataLoader(
    TensorDataset(torch.tensor(X_tr_norm).float(), torch.tensor(y_tr).float().unsqueeze(1)),
    batch_size=256, shuffle=True)

if len(X_va_norm) > 0:
    val_loader = DataLoader(
        TensorDataset(torch.tensor(X_va_norm).float(), torch.tensor(y_va).float().unsqueeze(1)),
        batch_size=256)
else:
    val_loader = None
    print("WARNING: no validation set available (too few files). "
          "Increase the number of .mat files or reduce --val_frac.")

# ══════════════════════════════════════════════════════════════
# 6. MODEL
# ══════════════════════════════════════════════════════════════

class CircleSelector(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(9, 32), nn.ReLU(), nn.Dropout(0.3),
            nn.Linear(32, 16), nn.ReLU(), nn.Dropout(0.2),
            nn.Linear(16, 1), nn.Sigmoid()
        )
    def forward(self, x):
        return self.net(x)

torch.manual_seed(args.seed)
model     = CircleSelector()
optimizer = torch.optim.Adam(model.parameters(), lr=1e-3, weight_decay=args.weight_decay)
loss_fn   = nn.BCELoss()

# ══════════════════════════════════════════════════════════════
# 7. TRAINING
# ══════════════════════════════════════════════════════════════

print(f"\nTraining ({args.epochs} epochs)...\n")
best_val = float('inf')
best_state = {k: v.clone() for k, v in model.state_dict().items()}

for epoch in range(args.epochs):
    model.train()
    tl = 0.0
    for Xb, yb in train_loader:
        optimizer.zero_grad()
        loss = loss_fn(model(Xb), yb)
        loss.backward()
        optimizer.step()
        tl += loss.item()
    tl /= len(train_loader)

    if val_loader is not None:
        model.eval()
        vl, correct = 0.0, 0
        with torch.no_grad():
            for Xb, yb in val_loader:
                pred = model(Xb)
                vl      += loss_fn(pred, yb).item()
                correct += ((pred > 0.5) == yb).sum().item()
        vl  /= len(val_loader)
        acc  = correct / len(X_va) * 100

        if vl < best_val:
            best_val   = vl
            best_state = {k: v.clone() for k, v in model.state_dict().items()}

        if epoch % 15 == 0 or epoch == args.epochs - 1:
            print(f"  Epoch {epoch:3d}/{args.epochs} | Train: {tl:.4f} | Val: {vl:.4f} | Acc: {acc:.1f}%")
    else:
        if epoch % 15 == 0 or epoch == args.epochs - 1:
            print(f"  Epoch {epoch:3d}/{args.epochs} | Train: {tl:.4f}")

model.load_state_dict(best_state)
if val_loader is not None:
    print(f"\nBest model: Val Loss = {best_val:.4f}")
else:
    print("\nNo validation set -> saving final training state.")

# ══════════════════════════════════════════════════════════════
# 8. EXPORT WEIGHTS
# Saves all hidden layer weights that define our trained NN
# ══════════════════════════════════════════════════════════════

np.savez(args.output,
    W1=model.net[0].weight.detach().numpy(),
    b1=model.net[0].bias.detach().numpy(),
    W2=model.net[3].weight.detach().numpy(),
    b2=model.net[3].bias.detach().numpy(),
    W3=model.net[6].weight.detach().numpy(),
    b3=model.net[6].bias.detach().numpy(),
    X_mean=X_mean,
    X_std=X_std)

print(f"\nWeights saved: {args.output}")
print("Done!")