function P = CircleIntersectionSymbolic(z1,z2,r1,r2)
% CircleIntersectionSymbolic  Symbolic intersections using complex arithmetic
%   P = CircleIntersectionSymbolic(z1,z2,r1,r2)
%   Inputs:
%     z1, z2 - symbolic complex centers
%     r1, r2 - symbolic positive radii
%   Output:
%     P - column vector of symbolic complex intersection points
%         If no real intersection: sym([])
%         If infinite intersections (coincident circles): sym(NaN)

%Short Explanation of sym() and vpa():
%symbolic variables (sym()) save numbers in the exact form (e.g. sqrt(3), 1/3, ...)
%vpa(x,d) calculates an approximation from a symbolic x variable to d
%digits and returns it also as a symbolic variable. With double() we can
%than cast this to a casual double with a percision of 16 digits.

digits(25);
tolPointsEqual = 1e-20;

% Determine numerical values with 25 digits
z1num = vpa(z1,25);
z2num = vpa(z2,25);
r1num = vpa(r1,25);
r2num = vpa(r2,25);

% Checking if circles coincide
if abs(z1num-z2num) < tolPointsEqual
    if abs(r1num-r2num) < tolPointsEqual
        P = sym(NaN);
    else
        P = sym([]);
    end

    return;
end

% Vector from z1 to z2 and its magnitude
d = z2-z1;
D = abs(d);

% Law of cosines: distance from z1 to the foot point along line z1->z2
a = (r1^2-r2^2+D^2)/(2*D);

% Height squared of intersection relative to foot
h2 = r1^2-a^2;

% If h2 < 0 (no real intersections)
h2num = vpa(h2,25);

if h2num < -1e-20
    P = sym([]);
    return;
elseif h2num < 0
    h2 = sym(0);
end

% Unit direction from z1 to z2 (complex)
u = d/D;

% Foot point along the line
p = z1 + a*u;


% Perpendicular direction: multiply by 1i rotates by +90°
% Intersection points: p ± i*h*u
h = sqrt(h2);
p1 = p + 1i*h*u;
p2 = p - 1i*h*u;

% Assemble output
if abs(vpa(h,25)) < 1e-20
    % Tangent: single point
    P = p1;
else
    % Two intersection points; return unique column vector
    P = [p1; p2];
end

end