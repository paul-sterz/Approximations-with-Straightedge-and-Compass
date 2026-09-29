function [data_sym,V] = symbolic_construction(data_num)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Abstract: Takes a numerically determined construction saved as a structure 
% and outputs a structure with the smybolic value of the same construction.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input: data_num describing a numercially calcualted (class: double) construction consisting of
% - P: matrix of complex points
% - C: matrix of circle indeces 
%    [P(C(i,1)) is center of circle i with radius abs(P(C(i,1) - P(C(i,2))]
% - R: matrix of radii of the corresponding circles
% - complex points pointA, pointB and their distance dist
% 
% output: 
% - data_sym describing the same construction calculated with
%       symbolic values (class: sym except for C) with the same fields as before
%       [with values NaN, if the numerically constructed point exists only
%       due to rounding errors or they differ with the symbolic calcuated 
%       value by over DetectionTol]
% - matrix V detailing the construction of the points:
%      P(i) is the intercection of circle V(i,1) and V(i,2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%
% Parameters 
%%%%%%%%%%%%%%%%

tol = 1e-13;
DetectionTol = 1e-14; %discards point that are not within DetectionTol compared to the numerical value

%%%%%%%%%%%%%%%%%%
% Initiliazing 
%%%%%%%%%%%%%%%%%%

P_num = data_num.P;
C = data_num.C;
R_num = data_num.R;

P_sym = sym(zeros(size(P_num)));
R_sym = sym(zeros(size(R_num)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINE HOW A POINT WAS CREATED 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
V = zeros(length(P_num), 2);
V(1,1) = -1;
V(1,2) = -1;
V(2,1) = -1;
V(2,2) = -1;


for i = 1:1:size(C,1)
    for j = i+1:1:size(C,1)
        intersections = circleIntersectionV5(P_num(C(i,1)),P_num(C(j,1)),abs(P_num(C(i,1)) - P_num(C(i,2))), abs(P_num(C(j,1)) - P_num(C(j,2))),tol);
        for k = 1:1:size(intersections,1)
            for l = 1:1:size(P_num,1)
                if(V(l,1) == 0)
                    if abs(intersections(k) - P_num(l)) < 1e-10
                        V(l,1) = i;
                        V(l,2) = j;
                        %disp("Point: " + l + " was created by intersecting circle " + i + " & " + j)
                    end
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating symbolic values of the construction %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P_sym(1) = sym(complex(0));
P_sym(2) = sym(complex(1));

R_sym(1) = sym(1);
R_sym(2) = sym(1);

for i = 3:length(P_num)

    IndCircle1 = V(i,1);
    IndCircle2 = V(i,2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute radii if not known yet
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if isequal(R_sym(IndCircle1),sym(0))

        R_sym(IndCircle1) = abs(P_sym(C(IndCircle1,1)) - P_sym(C(IndCircle1,2)));

    end

    if isequal(R_sym(IndCircle2),sym(0))

        R_sym(IndCircle2) = abs(P_sym(C(IndCircle2,1)) - P_sym(C(IndCircle2,2)));

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Circle data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    z1 = P_sym(C(IndCircle1,1));
    z2 = P_sym(C(IndCircle2,1));

    r1 = R_sym(IndCircle1);
    r2 = R_sym(IndCircle2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute intersections
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    intersections = CircleIntersectionSymbolic(z1,z2,r1,r2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % No intersection
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if isempty(intersections)

        P_sym(i) = sym(NaN);
        continue;

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % One intersection
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if isscalar(intersections)

        try

            val = double(vpa(intersections,25));

            if isnan(val)
                P_sym(i) = sym(NaN);
            else
                P_sym(i) = intersections;
            end

        catch

            P_sym(i) = intersections;

        end

        continue;

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Two intersections
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Double precision is sufficient since P_num is a double
    error1 = abs(double(intersections(1))- P_num(i));
    error2 = abs(double(intersections(2))-P_num(i));

    if error1 < error2

        if error1 < DetectionTol

            P_sym(i) = intersections(1);

        else

            P_sym(i) = sym(NaN);

        end

    elseif error2 < error1

        if error2 < DetectionTol

            P_sym(i) = intersections(2);

        else

            P_sym(i) = sym(NaN);

        end

    else

        P_sym(i) = sym(NaN);

    end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Returning values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data_sym.P = P_sym;
data_sym.C = C;
data_sym.R = R_sym;

indA = find(abs(data_num.P-data_num.pointA) < 1e-12,1);
indB = find(abs(data_num.P-data_num.pointB) < 1e-12,1);

data_sym.pointA = P_sym(indA);
data_sym.pointB = P_sym(indB);

% intentionally NO simplify here
data_sym.dist = abs(data_sym.pointA-data_sym.pointB);