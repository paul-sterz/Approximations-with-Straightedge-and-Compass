function Z = circleLineIntersections1(z0, r, LNormalForm)
% z0: komplexer Mittelpunkt
% r: Radius
% LNormalForm: Nx3 Matrix [a b c]

N = size(LNormalForm,1);
Z = [];

x0 = real(z0);
y0 = imag(z0);

for k = 1:N
    a = LNormalForm(k,1);
    b = LNormalForm(k,2);
    c = LNormalForm(k,3);

    denom = a^2 + b^2;
    if denom < eps
        continue; % degenerierte Gerade
    end

    % Abstand vom Mittelpunkt zur Gerade
    d = (a*x0 + b*y0 + c) / denom;

    % Fußpunkt der Projektion
    xh = x0 - a*d;
    yh = y0 - b*d;

    % Abstand Mittelpunkt–Gerade
    dist2 = (a*x0 + b*y0 + c)^2 / denom;

    if dist2 > r^2
        continue; % kein Schnitt
    end

    % halbe Sehnenlänge
    h = sqrt(max(r^2 - dist2, 0));

    % Richtungsvektor der Linie
    vx = -b / sqrt(denom);
    vy =  a / sqrt(denom);

    p1 = (xh + vx*h) + 1i*(yh + vy*h);
    p2 = (xh - vx*h) + 1i*(yh - vy*h);

    Z = [Z; p1; p2];
end
end