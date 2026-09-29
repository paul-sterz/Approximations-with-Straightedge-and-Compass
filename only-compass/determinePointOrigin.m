function V = determinePointOrigin(P,C)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine the origin of a point
    %
    % P:
    % complex point vector
    %
    % C:
    % circle matrix
    % each row = [centerPointIndex radiusPointIndex]
    %
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    V = zeros(size(P,1), 2);
    V(1,1) = -1;
    V(1,2) = -1;
    V(2,1) = -1;
    V(2,2) = -1;


     for i = 1:1:size(C,1)
         for j = i+1:1:size(C,1)
             intersections = singleCircleIntersection(P(C(i,1)), abs(P(C(i,1)) - P(C(i,2))),P(C(j,1)), abs(P(C(j,1)) - P(C(j,2))));
             for k = 1:1:size(intersections,1)
                 for l = 1:1:size(P,1)
                     if(V(l,1) == 0)
                        if abs(intersections(k) - P(l)) < 1e-10
                            V(l,1) = i;
                            V(l,2) = j;
                           disp("Point: " + l + " was created by intersecting circle " + i + " & " + j)
                        end
                     end
                 end
             end
         end
     end

end