function score = nnScore(radius, mid_pt, rad_pt, n_points, n_circles, min_err, frac, weights)
%NNSCORE  Bewertet eine Kreisauswahl mit dem trainierten NN.
%
% INPUT:
%   radius    - Radius des neuen Kreises (real)
%   mid_pt    - Mittelpunkt (komplex)
%   rad_pt    - Radiuspunkt (komplex)
%   n_points  - Aktuelle Anzahl Punkte
%   n_circles - Aktuelle Anzahl Kreise
%   min_err   - Minimaler aktueller Fehler zum Target
%   frac      - Wie weit in der Konstruktion (0=Anfang, 1=Ende)
%   weights   - Struct aus loadNNWeights()
%
% OUTPUT:
%   score - Wert zwischen 0 und 1 (höher = vielversprechender)

% Feature-Vektor zusammenbauen (muss gleiche Reihenfolge wie Python haben!)
x = [
    radius;
    real(mid_pt);
    imag(mid_pt);
    real(rad_pt);
    imag(rad_pt);
    n_points / 100.0;
    n_circles / 20.0;
    min(min_err, 1.0);
    frac
];

% Normalisieren (mit gespeicherten Werten aus Training)
x = (x - weights.X_mean(:)) ./ weights.X_std(:);

% Forward Pass: Layer 1
h1 = weights.W1 * x + weights.b1(:);
h1 = max(0, h1);  % ReLU

% Forward Pass: Layer 2
h2 = weights.W2 * h1 + weights.b2(:);
h2 = max(0, h2);  % ReLU

% Forward Pass: Layer 3 + Sigmoid
out = weights.W3 * h2 + weights.b3(:);
score = 1.0 / (1.0 + exp(-out));

end