function P = circleIntersectionV5(z1, Z2, r1, R2, tol)
% Vectorized version of V3: CLEANED UP
% circleIntersections  Intersection points of one circle z1, r1 with multiple circles z2,r2 stored in Z2,R2 in the complex plane
%   P = circleIntersections(z1,Z2,r1,R2)
%   - Z2 : array of complex centers
%   - R2 : array of nonnegative radii
%   - z1, z2 : complex centers
%   - r1, r2 : nonnegative radii (scalars)
%   Returns P as column vectors of complex points:
%     Coincident circles are treated outside the function, so dont have to
%     be adressed here (so no more outputting NaN).
%     Two circles not intersecting will just not add any more points to the
%     output vector P.
%   Only tangential intersection or two-point intersection will enlarge P.
        
%   Performance notes: uses minimal temporaries and complex arithmetic.

%Version 3: using only ONE square root


V = Z2 - z1;               % complex vector from z1 to z2
D = abs(V);

% Case 1: coincident centers
%   infinitely many intersections:
%       is already checked before calling this function
%           See: CHECK IF CIRCLE ALREADY EXISTS
%   concentric: no intersections (first part) and 
% Case 2: seperation/containment (second and third part)
      
keep = (D > tol) & ...
       (D <= r1 + R2 + tol) & ...
       (D >= abs(r1 - R2) - tol);
% Early exit
if ~any(keep)
    P = complex([]);
    return;
end

%eliminate non-intersecting circles:
%Z2(eliminateCircles) = []; %not needed
V = V(keep);
D = D(keep);
R2 = R2(keep);

%Case 3: tangency or two-point intersection
r1overD = r1./D;
aoverD = 0.5*(r1overD).^2 - 0.5*(R2./D).^2 + 0.5; % = a/d
radicant = (r1overD).^2 - aoverD.^2; %=h^2/d^2

p = z1 + aoverD .* V; %= z1 + (a/d)*v

tangentCircles = radicant <= tol;
two_pt_circles  = ~tangentCircles;

hperp = 1i .* V(two_pt_circles) .* sqrt(radicant(two_pt_circles)); %only computing where two-point-intersection is happening
p2    = p(two_pt_circles);

P = [p2 + hperp; p2 - hperp; p(tangentCircles)];
end