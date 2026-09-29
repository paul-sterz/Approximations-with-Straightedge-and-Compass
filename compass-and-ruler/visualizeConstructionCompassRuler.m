function visualizeConstructionCompassRuler(P, C, LNormForm, pointA, pointB, target)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % VISUALIZE CONSTRUCTION
    %
    % P:
    % complex point vector
    %
    % C:
    % circle matrix
    % each row = [centerPointIndex radiusPointIndex]
    % (or [centerPointIndex radius] if the radius is stored directly)
    %
    % LNormForm:
    % line matrix
    % each row = [a,b,c] coefficients of the normal form
    %
    % pointA, pointB:
    % indices of interesting points
    %
    % target:
    % 1 = sqrt(pi), 2 = cuberoot(2), 3 = regular heptagon side length
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    figure;
    hold on;
    axis equal;
    grid on;

    title('Compass Construction');

    biggest = 0;

    for i = 1:length(P)
        val = norm(P(i));
        if biggest < val
            biggest = val;
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DETERMINE RELEVANT POINTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    relevantPoints = [pointA; pointB];

    if ~isempty(C)
        % Circle centers
        relevantPoints = [relevantPoints; C(:,1)];

        % Radius point indices (only if stored)
        if size(C,2) >= 3
            relevantPoints = [relevantPoints; C(:,3:end)];
        end
    end

    relevantPoints = unique(relevantPoints(:));
    relevantPoints(relevantPoints == 0) = [];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DRAW RELEVANT POINTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    scatter(real(P(relevantPoints)), imag(P(relevantPoints)), ...
            40, 'filled');

    for k = 1:length(relevantPoints)
        idx = relevantPoints(k);
        text(real(P(idx)), imag(P(idx)), ['  ' num2str(idx)]);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DRAW ALL CIRCLES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    theta = linspace(0,2*pi,400);

    for i = 1:size(C,1)

        centerIdx = C(i,1);

        center = P(centerIdx);
        radius = C(i,2);

        x = real(center) + radius*cos(theta);
        y = imag(center) + radius*sin(theta);

        plot(x,y);

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DRAW ALL LINES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for i = 1:size(LNormForm,1)

        a = LNormForm(i,1);
        b = LNormForm(i,2);
        c = LNormForm(i,3);

        f = @(x,y) a*x + b*y + c;
        fimplicit(f,[-biggest biggest -biggest biggest]);

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % HIGHLIGHT INTERESTING POINTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    A = P(pointA);
    B = P(pointB);

    scatter(real(A), imag(A),120,'filled');
    scatter(real(B), imag(B),120,'filled');

    plot([real(A) real(B)], [imag(A) imag(B)], ...
         'r','LineWidth',3);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTE DISTANCE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    dist = abs(A-B);

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
            disp(abs(dist-sqrt(pi)));

        case 2
            disp("2^(1/3):");
            disp(nthroot(2,3));
            disp("Absolute error:");
            disp(abs(dist-nthroot(2,3)));

        otherwise
            disp("sin(pi/7):");
            disp(sin(pi/7));
            disp("Absolute error:");
            disp(abs(dist-sin(pi/7)));

    end

    disp("======================================");

end