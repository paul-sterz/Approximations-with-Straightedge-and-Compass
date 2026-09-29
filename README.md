# Approximations-with-Straightedge-and-Compass

This project investigates how classical geometric constructions can be used to approximate mathematical quantities that cannot be constructed exactly with straightedge and compass.

The project combines **computational geometry, numerical optimization, symbolic computation, and algorithmic search**. Starting from a small set of elementary geometric objects, the program systematically explores possible constructions and searches for configurations that produce highly accurate approximations of selected mathematical quantities.

The main targets are:

* $\sqrt{\pi}$ — related to the classical **squaring of the circle**
* $\sqrt[3]{2}$ — related to the classical **Delian problem**
* $\sin(\pi/7)$ — corresponding to the side length of a regular heptagon inscribed in a unit circle

Rather than using conventional numerical approximation methods such as Newton's method, the goal is to obtain the approximations **through geometric constructions themselves**.

---

## 🎥 Visualization

The following visualization shows one of the best constructions found by the computational search.

<img width="2252" height="798" alt="Image" src="https://github.com/user-attachments/assets/24f4f7d2-affd-4a58-92c6-d9a87afcbaba" />

---

# 🛠️ Technologies & Methods

## Programming & Tools

The project was primarily implemented in **MATLAB**, with **Python** used for machine-learning-based search guidance.

The main tools and techniques include:

* **MATLAB** for the numerical search, computational geometry, data management, and visualization
* **MATLAB Symbolic Math Toolbox** for exact symbolic evaluation and independent verification of promising constructions
* **Python** for developing a **neural network** that evaluates constructions and guides the search towards promising regions of the construction space
* **Git/GitLab** for version control and experiment management

---

## Mathematical & Algorithmic Foundations

The core of the project is a **depth-first search through a discrete geometric construction space**.

Each construction is represented by a collection of:

* points
* circles
* lines
* constructible distances
* intersections between geometric objects

In the compass-with-memory setting, previously constructed distances can be reused as radii independently of the location where they were originally constructed. The ruler additionally allows any two constructed points to be connected by an infinite line.

The algorithm recursively generates new geometric objects, computes their intersections, filters redundant constructions, and explores the resulting branches using **depth-first search with backtracking**.

The project combines several mathematical and algorithmic concepts:

* **Euclidean and computational geometry**
* **Circle–circle, circle–line, and line–line intersection algorithms**
* **Parallelized numerical computations and matrix operations**
* **Complex-number representation of planar geometry**
* **Combinatorial analysis of the construction space**
* **Symmetry reduction**
* **Numerical precision, tolerances, and stability**
* **Symbolic computation for independent verification**
* **Neural networks for construction evaluation and search guidance**
* **Depth-first search and recursive backtracking**
* **Combinatorial search-space reduction and pruning**

A major challenge is the rapid growth of the construction space with increasing construction depth. The number of possible constructions can become extremely large even after only a few steps. Therefore, a significant part of the algorithm is dedicated to **analyzing the growth of the search space and eliminating redundant or equivalent constructions as early as possible**.

In addition, the individual computational steps were extensively optimized for performance. This includes **vectorized and parallelized numerical computations, efficient intersection algorithms, preallocation of memory, and minimizing unnecessary calculations**. These optimizations are essential because even relatively small improvements in the runtime of an individual operation can have a substantial impact when the operation is executed millions of times throughout the search.

---

# 🔄 The Process

The computational pipeline can be summarized as follows.

### 1. Initialize the construction

The search starts from a small predefined configuration of points, circles, and/or lines.

Symmetries of the initial configuration are exploited to reduce the number of independent starting cases.

### 2. Generate Possible Geometric Objects and Evaluate with a Neural Network

At each construction depth, the algorithm generates possible new geometric objects based on the objects constructed so far.

For circles, different combinations of previously constructed points and distances are considered. In the compass-and-ruler extension, pairs of previously constructed points can additionally be connected to form infinite lines.

Since the number of possible constructions grows rapidly, evaluating every possible option with the same computational effort would quickly become impractical. Instead, the **neural network evaluates a selected subset of promising construction options** and estimates their potential to lead to good approximations.

The search can then prioritize the most promising candidates, significantly reducing the amount of the construction space that needs to be explored in depth.

### 3. Compute intersections

Whenever a new circle or line is created, its intersections with existing geometric objects are calculated.

These intersections form the candidate points for the next construction step.

### 4. Remove redundant constructions

The search space contains a large number of equivalent possibilities.

The program therefore checks for:

* already existing circles
* already existing lines
* duplicate points
* duplicate distances
* geometrically equivalent constructions generated within the same search step

This significantly reduces the number of branches that have to be explored.

### 5. Add newly constructed points and distances

New points are added to the current construction.

All relevant distances between old and newly created points, as well as between newly created points themselves, are evaluated and stored.

These distances can subsequently be reused as geometric quantities, particularly in the compass-with-memory setting.

### 6. Evaluate target quantities

The program continuously compares newly generated distances with the target quantities:

$$
\sqrt{\pi}, \qquad \sqrt[3]{2}, \qquad \sin\left(\frac{\pi}{7}\right).
$$

For every sufficiently good approximation, the complete construction state is stored.

The search therefore does not only return the final numerical approximation, but preserves the complete geometric construction that produced it.

### 7. Symbolically verify promising constructions

The best numerical constructions can subsequently be reconstructed using symbolic mathematics.

Instead of relying exclusively on floating-point arithmetic, the symbolic verification represents quantities such as

$$
\sqrt{3}, \quad \frac{1}{2}, \quad \sqrt{\frac{5}{2}}
$$

in exact symbolic form.

This makes it possible to independently evaluate the final construction and distinguish genuine geometric approximations from numerical artifacts.

---

# 🧠 What I Learned

This project gave me practical experience at the intersection of **mathematics, algorithms, computational geometry, and machine learning**.

In particular, I gained experience with:

* Designing algorithms for large combinatorial search spaces
* Implementing geometric algorithms directly from mathematical definitions
* Representing Euclidean geometry using complex numbers
* Handling numerical precision, stability, and tolerance selection
* Efficient duplicate and equivalence detection
* Depth-first search and recursive backtracking
* Memory management for computationally intensive searches
* Designing and integrating a neural network for evaluating construction steps
* Symmetry reduction and search-space pruning
* Combining symbolic and numerical computation
* Profiling and optimizing computational bottlenecks
* Structuring and monitoring long-running numerical experiments
* Visualizing and interpreting computationally generated geometric constructions

One of the main lessons was that mathematically simple operations can become computationally expensive when embedded in a large search space. As a result, the efficiency of the **search strategy, pruning mechanisms, and individual computational operations** can be just as important as the underlying mathematical algorithms.

The project also taught me how to translate **abstract mathematical concepts into robust computational algorithms** and how to iteratively improve those algorithms based on profiling, performance measurements, and practical computational constraints.


---

# ▶️ Running the Project

## Requirements

* MATLAB
* MATLAB Symbolic Math Toolbox for symbolic verification

## Basic Usage

The numerical search can be started by calling the main function with a maximum construction depth and a starting configuration:

```matlab
mainOnlyCompass(maxDepth, n)
```

where:

* `maxDepth` specifies the maximum construction depth
* `n` selects one of the symmetry-reduced starting configurations

For the extended compass-and-ruler implementation, the corresponding main function is:

```matlab
mainCompassRuler(maxDepth, n)
```

The program performs a depth-first search and stores the best constructions found during the run.

The symbolic verification can then be applied to selected numerical constructions using:

```matlab
[data_sym, V] = symbolic_construction(data_num);
```

where `data_num` describes a numerically discovered construction.

The resulting symbolic representation can be used to independently evaluate the construction and verify the numerical approximation.

