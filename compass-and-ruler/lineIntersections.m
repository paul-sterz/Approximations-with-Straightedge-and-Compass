function Z = lineIntersections(line, LNormalForm)
% line: [a b c]  -> feste Linie
% LNormalForm: Nx3 Matrix aller anderen Linien
% Z: Schnittpunkte als komplexe Zahlen

a1 = line(1);
b1 = line(2);
c1 = line(3);

N = size(LNormalForm,1);
Z = [];

for k = 1:N
    a2 = LNormalForm(k,1);
    b2 = LNormalForm(k,2);
    c2 = LNormalForm(k,3);

    % Determinante (Stabilitätscheck)
    D = a1*b2 - a2*b1;

    if abs(D) < 1e-12
        continue; % parallel oder numerisch instabil
    end

    % Lösung des 2x2 Systems:
    % a1 x + b1 y = -c1
    % a2 x + b2 y = -c2

    x = (b1*c2 - b2*c1) / D;
    y = (c1*a2 - c2*a1) / D;

    Z = [Z; x + 1i*y];
end
end