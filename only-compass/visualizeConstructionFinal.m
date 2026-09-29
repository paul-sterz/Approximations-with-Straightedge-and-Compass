function visualizeConstructionFinal(P, C, pointA, pointB, target)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % VISUALIZE CONSTRUCTION
    %
    % P:
    % complex point vector
    %
    % C:
    % circle matrix
    % each row = [centerPointIndex radiusPointIndex]
    %
    % pointA, pointB:
    % indices of interesting points
    %
    % target: 
    % integer value from 1,2,3 representing which target was approximated 
    % 1 = sqrt(pi), 2 = cuberoot(2), 3 = reuglar heptagon side length
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    figure;
    hold on;
    axis equal;
    grid on;

    title('Compass Construction');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DRAW ALL POINTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    scatter(real(P), imag(P), 40, 'filled');

    for i = 1:length(P)
        text(real(P(i)), imag(P(i)), ['  ' num2str(i)]);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DRAW ALL CIRCLES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    theta = linspace(0, 2*pi, 400);

    for i = 1:size(C,1)

        centerIdx = C(i,1);
        radiusIdx = C(i,2);

        center = P(centerIdx);
        radius = abs(P(centerIdx) - P(radiusIdx));

        x = real(center) + radius*cos(theta);
        y = imag(center) + radius*sin(theta);

        plot(x,y);

    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % HIGHLIGHT INTERESTING POINTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    A = P(pointA);
    B = P(pointB);

    scatter(real(A), imag(A), 120, 'filled');
    scatter(real(B), imag(B), 120, 'filled');

    plot([real(A) real(B)], [imag(A) imag(B)], 'r', 'LineWidth', 3);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTE DISTANCE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    dist = abs(A - B);

    disp("======================================");
    disp("Interesting point indices:");
    disp([pointA pointB]);
    format long
    disp("Distance:");
    disp(dist);


    switch target
        case 1
            disp("sqrt(pi):");
            disp(sqrt(pi));
            disp("Absolute error:");
            disp(abs(dist - sqrt(pi)));
        case 2
            disp("2^(1/3):");
            disp(nthroot(2,3));
            disp("Absolute error:");
            disp(abs(dist - nthroot(2,3)));
        otherwise
            disp("sin(pi/7):");
            disp(sin(pi/7));
            disp("Absolute error:");
            disp(abs(dist - sin(pi/7)));
    end
    disp("======================================");

end