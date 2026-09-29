function Z = circleLineIntersections2(line, centers, radii)
% line: [a b c]
% centers: complex vector
% radii: vector

a = line(1); b = line(2); c = line(3);

denom = a^2 + b^2;
if denom < eps
    Z = [];
    return;
end

vx = -b / sqrt(denom);
vy =  a / sqrt(denom);

Z = [];

for k = 1:length(centers)

    z0 = centers(k);
    r = radii(k);

    x0 = real(z0);
    y0 = imag(z0);

    d = (a*x0 + b*y0 + c) / denom;

    xh = x0 - a*d;
    yh = y0 - b*d;

    dist2 = (a*x0 + b*y0 + c)^2 / denom;

    if dist2 > r^2
        continue;
    end

    h = sqrt(max(r^2 - dist2,0));

    p1 = (xh + vx*h) + 1i*(yh + vy*h);
    p2 = (xh - vx*h) + 1i*(yh - vy*h);

    Z = [Z; p1; p2];
end
end