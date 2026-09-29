function intersections = singleCircleIntersection(c1, r1, c2, r2)
% SINGLECIRCLEINTERSECTION
% Computes intersection points of two circles in the complex plane.
%
% INPUT:
%   c1, c2 : complex centers
%   r1, r2 : radii
%
% OUTPUT:
%   intersections : complex vector (0, 1 or 2 points)

    tol = 1e-12;

    %-----------------------------------------
    % Convert to real coordinates
    %-----------------------------------------
    x1 = real(c1);
    y1 = imag(c1);

    x2 = real(c2);
    y2 = imag(c2);

    dx = x2 - x1;
    dy = y2 - y1;

    d = sqrt(dx^2 + dy^2);

    %-----------------------------------------
    % No intersection cases
    %-----------------------------------------
    if d > r1 + r2 + tol
        intersections = [];
        return;
    end

    if d < abs(r1 - r2) - tol
        intersections = [];
        return;
    end

    % identical circles
    if d < tol && abs(r1-r2) < tol
        intersections = [];
        return;
    end

    %-----------------------------------------
    % Distance from c1 to midpoint line
    %-----------------------------------------
    a = (r1^2 - r2^2 + d^2) / (2*d);

    h2 = r1^2 - a^2;

    % numerical stabilization
    if h2 < 0 && abs(h2) < tol
        h2 = 0;
    end

    if h2 < 0
        intersections = [];
        return;
    end

    h = sqrt(h2);

    %-----------------------------------------
    % Base point
    %-----------------------------------------
    xm = x1 + a * dx / d;
    ym = y1 + a * dy / d;

    %-----------------------------------------
    % Perpendicular offset
    %-----------------------------------------
    rx = -dy * h / d;
    ry =  dx * h / d;

    %-----------------------------------------
    % Intersection points
    %-----------------------------------------
    p1 = (xm + rx) + 1i*(ym + ry);
    p2 = (xm - rx) + 1i*(ym - ry);

    %-----------------------------------------
    % Return result
    %-----------------------------------------
    if h < tol
        intersections = p1;
    else
        intersections = [p1; p2];
    end

end