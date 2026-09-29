function mainCompassRuler(maxDepth, n)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT:
% maxDepth - maximum construction depth
% n        - which of the 8 symmetry reduced start configurations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL CONFIGURATION
% P = complex point vector
% C = circle matrix [centerPointIndex radius]
% D = vector containing all distances for the current construction
% L = line matrix [firstPointIndex secondPointIndex]
% LNormalForm = line matrix with coefficents from Normalform [a b c]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
solutionfolder = fullfile(pwd,"solutions");
timestamp = datestr(now,'yyyy_mm_dd_HH_MM_SS'); %time of start of run
logfilepath = fullfile(solutionfolder,"logfile_branch_"+ int2str(n) + "_" + timestamp +".txt");
maxDepth_at_Start = maxDepth;

tol = 1e-10;
tolTarget = 1e-3;
tolDist = 1e-10;

constructionCounter = 0;
distancesCounter = 0;
counter = 0;

targets = [sqrt(pi), nthroot(2,3), sin(pi/7)];
targetNames = ["sqrtpi","cuberoot2","heptagon"];

maxStored = 50;
bestErrors = cell(length(targets),1);
bestData = cell(length(targets),1);

for t = 1:length(targets)
    bestErrors{t} = [];
    bestData{t} = {};
end

P = zeros(300,1);
C = zeros(20,2);
L = zeros(20,2);
LNormalForm = zeros(20,3);
D = zeros(3000,1);

maxDepth = maxDepth - 3; %Since we start already in the third level

%TO-DO anpassen der Cases für den Fall compass & ruler

switch n
    case 1
        C(1:1:3, :) = [1 1; 2 1; 3 1];
        P(1:6) = [0; 1; 1/2 + 1i * sqrt(3)/2; 1/2 - 1i * sqrt(3)/2; -1/2+1i*sqrt(3)/2; 3/2 + 1i*sqrt(3)/2];
        LNormalForm(1,:) = [0 0 0];
        L(1,:)= [0 0];
        D(1:3) = [1; sqrt(3); 2];
        lastIdxC = 3;
        lastIdxP = 6;
        lastIdxL = 0;
        lastIdxD = 3;
    case 2
        C(1:1:3, :) = [1 1; 2 1; 4 sqrt(3)];
        P(1:6) = [0; 1; 1/2 + 1i * sqrt(3)/2; 1/2 - 1i * sqrt(3)/2; -1; 2];
        LNormalForm(1,:) = [0 0 0];
        L(1,:)= [0 0];
        D(1:4) = [1; sqrt(3); 2; 3];
        lastIdxC = 3;
        lastIdxP = 6;
        lastIdxL = 0;
        lastIdxD = 4;
    case 3
        C(1:1:2, :) = [1 1; 2 1];
        P(1:5) = [0; 1; 1/2 + 1i * sqrt(3)/2; 1/2 - 1i * sqrt(3)/2; -1/2-1i*sqrt(3)/2];
        LNormalForm(1,:) = [-sqrt(3)/2 1/2 0];
        L(1,:)= [3 5];
        D(1:3) = [1; sqrt(3); 2];
        lastIdxC = 2;
        lastIdxP = 5;
        lastIdxL = 1;
        lastIdxD = 3;
    case 4
        C(1:1:2, :) = [1 1; 2 1];
        P(1:6) = [0; 1; 1/2 + 1i * sqrt(3)/2; 1/2 - 1i * sqrt(3)/2; 2; -1];
        LNormalForm(1,:) = [0 1 0];
        L(1,:)= [1 2];
        D(1:4) = [1; sqrt(3); 2; 3];
        lastIdxC = 2;
        lastIdxP = 6;
        lastIdxL = 1;
        lastIdxD = 4;
    case 5
        C(1:1:2, :) = [1 1; 2 1];
        P(1:4) = [0; 1; 1/2 + 1i * sqrt(3)/2; 1/2 - 1i * sqrt(3)/2];
        LNormalForm(1,:) = [-1 0 1/2];
        L(1,:)= [3 4];
        D(1:2) = [1; sqrt(3)];
        lastIdxC = 2;
        lastIdxP = 4;
        lastIdxL = 1;
        lastIdxD = 2;
    case 6
        C(1:1:3, :) = [1 1; 2 1; 1 sqrt(3)];
        P(1:6) = [0; 1; 1/2 + 1i * sqrt(3)/2; 1/2 - 1i * sqrt(3)/2; 3/2+1i*sqrt(3)/2;3/2-1i*sqrt(3)/2];
        LNormalForm(1,:) = [0 0 0];
        L(1,:)= [0 0];
        D(1:3) = [1; sqrt(3); 2];
        lastIdxC = 3;
        lastIdxP = 6;
        lastIdxL = 0;
        lastIdxD = 3;
    case 7
        C(1:1:2, :) = [1 1; 3 2];
        P(1:4) = [0; 1; -1; -3];
        LNormalForm(1,:) = [0 1 0];
        L(1,:)= [1 2];
        D(1:4) = [1; 2; 3; 4];
        lastIdxC = 2;
        lastIdxP = 4;
        lastIdxL = 1;
        lastIdxD = 4;
    case 8
        C(1:1:2, :) = [1 1; 1 2];
        P(1:5) = [0; 1; -1; -2; 2];
        LNormalForm(1,:) = [0 1 0];
        L(1,:)= [1 2];
        D(1:4) = [1; 2; 3; 4];
        lastIdxC = 2;
        lastIdxP = 5;
        lastIdxL = 1;
        lastIdxD = 4;
    otherwise
        error("Branch does not exist: " + int2str(n) + "!");
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START DFS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
disp("Starting computation...")
dfs(0);
runtime = toc;

fileID = fopen(logfilepath, 'a');


%Print run stats into logfile and into command line:
for id = [1, fileID]
    fprintf(id, "===============================================\n");

    fprintf(id, "RUN FINISHED IN TIME: \n");
    fprintf(id, "%i seconds \n", round(runtime));
    fprintf(id, "    started at time: %s \n", timestamp);

    fprintf(id, "RUN DATA: \n Constructions evaluated: %d \n Unique distances computed: %d \n", constructionCounter, distancesCounter);
    fprintf(id, "===============================================\n");

    fprintf(id, "RUN PARAMETERS: \n maxDepth: %i \n branch: %i \n tolTarget: %d \n tol: %d \n maxStored: %d \n", maxDepth_at_Start, n, tolTarget, tol, maxStored);
    fprintf(id, " targets: \n ");
    for t=1:length(targets)
        fprintf(id, "        %s, promising constructions: %i \n ", targetNames(t), length(bestData{t}));
    end
    fprintf(id, "===============================================\n");

end
fclose(fileID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE FILE WHERE RESULTS ARE STORED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for t = 1:length(targets)

    solfilename = "best_branch" + int2str(n)+ "_" + targetNames(t) + "_" + timestamp + ".mat";
    solfilepath = fullfile(solutionfolder, solfilename);

    errors = bestErrors{t};
    constructions = bestData{t};

    save(solfilepath,"errors","constructions");

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEPTH FIRST SEARCH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function dfs(depth)
        
        constructionCounter = constructionCounter+1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STOP CONDITION
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if depth >= maxDepth
            return;
        end
           
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SAVE STATE FOR BACKTRACKING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        oldPointCount  = lastIdxP;
        oldDistCount = lastIdxD;
        oldLineCount = lastIdxL;
        oldCircleCount = lastIdxC;


        for midpoint = 1:oldPointCount

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % TRY ALL POSSIBLE NEW CIRCLES
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            for radiusIdx = 1:oldDistCount


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % CHECK RADIUS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                r1 = D(radiusIdx);

                if r1 < 1e-2 %No circles smaller than 10^-2
                    continue;
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % CHECK IF CIRCLE ALREADY EXISTS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                exists = false;

                for i = 1:lastIdxC
                    if midpoint == C(i,1) && abs(r1 - C(i,2)) < tol
                        exists = true;
                        break;
                    end
                end

                if exists
                    continue;
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % ADD NEW CIRCLE
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                lastIdxC = lastIdxC + 1;
                assert(lastIdxC <= size(C,1), 'Circle storage exhausted');
                C(lastIdxC,:) = [midpoint r1];
                c1 = C(lastIdxC,:);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % COMPUTE INTERSECTIONS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                if lastIdxL > 0 %Check if lines already exist
                    intersectionsLine = circleLineIntersections1(P(c1(1)),r1, LNormalForm(1:lastIdxL, :));
                else
                    intersectionsLine = [];
                end
                intersectionsCircle = circleIntersectionV5(P(c1(1)), P(C(1:lastIdxC-1,1)), r1, C(1:lastIdxC-1,2), tol);
                

                intersections = [intersectionsCircle; intersectionsLine];


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % PROCESS INTERSECTIONS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                if ~isempty(intersections)

                    newRaw = intersections(:);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % 1) FILTER EXISTING POINTS
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %Matrix with all pair distances
                    D_old = abs(P(1:1:lastIdxP) - newRaw.');

                    alreadyExists = any(D_old < tol, 1);

                    candidates = newRaw(~alreadyExists);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % 2) REMOVE DUPLICATES INSIDE CANDIDATES
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    duplicateMask = false(size(candidates));

                    for ii = 1:length(candidates)

                        if duplicateMask(ii)
                            continue;
                        end

                        for jj = ii+1:length(candidates)

                            if abs(candidates(ii) - candidates(jj)) < tol
                                duplicateMask(jj) = true;
                            end
                        end
                    end

                    newPoints = candidates(~duplicateMask);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % 3) EVALUATE DISTANCES
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    if ~isempty(newPoints)

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Calculate distances OLD ↔ NEW:
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        D_eval_old = abs(P(1:1:lastIdxP) - newPoints.');
                        distancesCounter = distancesCounter + size(D_eval_old,1) * size(D_eval_old,2);

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % 4) ADD NEW POINTS
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        m = length(newPoints);
                        assert(lastIdxP + m <= length(P), 'Point storage exhausted');
                        P(lastIdxP+1:1:lastIdxP+m) = newPoints;
                        lastIdxP = lastIdxP + m;


                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % ADD NEW DISTANCES FILTER OUT EXISTING ONES
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        allNewDists = D_eval_old(:);

                        for idx = 1:length(allNewDists)

                            d = allNewDists(idx);

                            %Does distance exist already?
                            if any(abs(D(1:lastIdxD) - d) < tolDist)
                                continue;
                            end

                            lastIdxD = lastIdxD + 1;

                            assert(lastIdxD <= size(D,1), 'Distance storage exhausted' )

                            D(lastIdxD) = d;

                        end

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Evaluate distances OLD ↔ NEW:
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        for t = 1:length(targets)

                            target = targets(t);

                            % Erros from this target
                            errors = abs(D_eval_old - target);

                            % All good distances
                            [rowIdx,colIdx] = find(errors < tolTarget);

                            for k = 1:length(rowIdx)

                                iOld = rowIdx(k);
                                iNew = colIdx(k);

                                currentError = errors(iOld,iNew);

                                pointA = P(iOld);
                                pointB = newPoints(iNew);

                                dist = abs(pointA - pointB);

                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                % FEWER THAN 50 -> DIRECTLY ADD
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                                if length(bestErrors{t}) < maxStored

                                    bestErrors{t}(end+1) = currentError;

                                    data.P = P(1:1:lastIdxP);
                                    data.C = C(1:1:lastIdxC, :);
                                    data.L = L(1:1:lastIdxL, :);
                                    data.LNormalForm = LNormalForm(1:1:lastIdxL, :);
                                    data.pointA = pointA;
                                    data.pointB = pointB;
                                    data.dist = dist;

                                    bestData{t}{end+1} = data;

                                else

                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                    % REPLACE WORST ENTRY IF BETTER
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                                    [worstError,worstIdx] = max(bestErrors{t});

                                    if currentError < worstError
                                        bestErrors{t}(worstIdx) = currentError;

                                        data.P = P(1:1:lastIdxP);
                                        data.C = C(1:1:lastIdxC, :);
                                        data.L = L(1:1:lastIdxL, :);
                                        data.LNormalForm = LNormalForm(1:1:lastIdxL, :);
                                        data.pointA = pointA;
                                        data.pointB = pointB;
                                        data.dist = dist;
    
                                        bestData{t}{worstIdx} = data;


                                    end

                                end

                            end

                        end

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Calculate distances NEW ↔ NEW
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        D_eval_new = abs(newPoints - newPoints.');
                        distancesCounter = distancesCounter + size(D_eval_new,1) * size(D_eval_new,2);

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % ADD NEW DISTANCES FILTER OUT EXISTING ONES
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        allNewDists = D_eval_new(triu(true(size(D_eval_new)),1));

                        for idx = 1:length(allNewDists)

                            d = allNewDists(idx);

                            %Does distance exist already?
                            if any(abs(D(1:lastIdxD) - d) < tolDist)
                                continue;
                            end

                            lastIdxD = lastIdxD + 1;

                            assert(lastIdxD <= size(D,1), 'Distance storage exhausted' )

                            D(lastIdxD) = d;

                        end

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % COMPARE TO TARGET
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        for t = 1:length(targets)

                            target = targets(t);

                            % errors to target
                            errors = abs(D_eval_new - target);

                            % only upper triangular part
                            [rowIdx,colIdx] = find(triu(errors < tolTarget,1));

                            for k = 1:length(rowIdx)

                                iA = rowIdx(k);
                                iB = colIdx(k);

                                currentError = errors(iA,iB);

                                pointA = newPoints(iA);
                                pointB = newPoints(iB);

                                dist = abs(pointA - pointB);


                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                % FEWER THAN 50 -> DIRECTLY ADD
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                                if length(bestErrors{t}) < maxStored

                                    bestErrors{t}(end+1) = currentError;

                                    data.P = P(1:1:lastIdxP);
                                    data.C = C(1:1:lastIdxC, :);
                                    data.L = L(1:1:lastIdxL, :);
                                    data.LNormalForm = LNormalForm(1:1:lastIdxL, :);
                                    data.pointA = pointA;
                                    data.pointB = pointB;
                                    data.dist = dist;

                                    bestData{t}{end+1} = data;

                                else

                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                    % REPLACE WORST ENTRY IF BETTER
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                                    [worstError,worstIdx] = max(bestErrors{t});
                                        
                                    if currentError < worstError
                                        bestErrors{t}(worstIdx) = currentError;

                                        data.P = P(1:1:lastIdxP);
                                        data.C = C(1:1:lastIdxC, :);
                                        data.L = L(1:1:lastIdxL, :);
                                        data.LNormalForm = LNormalForm(1:1:lastIdxL, :);
                                        data.pointA = pointA;
                                        data.pointB = pointB;
                                        data.dist = dist;
    
                                        bestData{t}{worstIdx} = data;

                                    end
                                end
                            end
                        end
                    end
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % RECURSION
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
                dfs(depth + 1);
                
                % Visualiz each Construction: (BE CAREFUL, DO IT ONLY FOR VERY LOW LEVELS!)
                %if depth == 2
                    %counter = counter +1;
                    %if counter == 18
                        %visualizeConstructionCompassRuler(P(1:lastIdxP), C(1:lastIdxC, :), LNormalForm(1:lastIdxL,:), 1,1,1)
                        %disp("P = " + P(1:lastIdxP));
                        %disp("C = " + C(1:lastIdxC, :));
                        %disp("L = " + LNormalForm(1:lastIdxL, :));
                        %disp("D = " + D(1:lastIdxD));
                    %end
                %end


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % BACKTRACKING
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                lastIdxP = oldPointCount;
                lastIdxC = oldCircleCount;
                lastIdxD = oldDistCount;
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % TRY ALL POSSIBLE NEW LINES
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            for secondPoint = midpoint+1:oldPointCount

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % CALCULATE NORMAL FORM
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                dx = real(P(secondPoint)) - real(P(midpoint));
                dy = imag(P(secondPoint)) - imag(P(midpoint));

                %Always take take normal vector with x <= 0
                if dy > 0
                    N = [-dy, dx];
                    N = N./norm(N);
                elseif dy < 0
                    N = [dy, -dx];
                    N = N./norm(N);
                else 
                    N = [0, abs(dx)];
                    N = N./norm(N);
                end

                cLine1 = -N(1) * real(P(midpoint)) - N(2) * imag(P(midpoint));

                nForm = [N(1), N(2), cLine1];

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % CHECK IF LINE ALREADY EXISTS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                exists = false;

                for i = 1:1:lastIdxL
                    if norm(nForm(1:2) - LNormalForm(i, 1:2)) < tol && abs(nForm(3) - LNormalForm(i,3)) < tol
                        exists = true;
                        break;
                    end
                end

                if exists
                    continue;
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % CHECK IF LINE IS ALREAY CREATED IN THIS STEP
                %
                % TO-Do: Think if this is better for runtime. Maybe only do
                % this until a certain step. But I don't think there is a
                % way to do this way faster since we can't save all
                % construction steps from a node because of memory limit.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for k = 1:1:midpoint-1
                    for i = 1:1:secondPoint-1

                        if k == i
                            continue;
                        end

                        dx2 = real(P(i)) - real(P((k)));
                        dy2 = imag(P(i)) - imag(P((k)));

                        %Always take take normal vector with x <= 0
                        if dy2 > 0
                            N2 = [-dy2, dx2];
                            N2 = N2./norm(N2);
                        elseif dy2 < 0
                            N2 = [dy2, -dx2];
                            N2 = N2./norm(N2);
                        else 
                            N2 = [0, abs(dx2)];
                            N2 = N2./norm(N2);
                        end

                        cLine2 = -N2(1) * real(P(k)) - N2(2) * imag(P(k));

                        nForm2 = [N2(1), N2(2), cLine2];

                        if norm(nForm(1:2) - nForm2(1:2)) < tol && abs(nForm(3) - nForm2(3)) < tol
                            exists = true;
                            break;
                        end
                    end
                end

                if exists
                    continue;
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % ADD NEW LINE
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                assert(lastIdxL +1 <= size(L,1), 'Line storage exhausted');
                L(lastIdxL+1, :) = [midpoint, secondPoint];
                LNormalForm(lastIdxL+1, :) = nForm;
                lastIdxL = lastIdxL +1;

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % CALCULATE INTERSECTIONS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if lastIdxL > 1
                    lineIntersecs = lineIntersections(LNormalForm(lastIdxL, :), LNormalForm(1:lastIdxL-1, :));
                else
                    lineIntersecs = [];
                end
                
                circleLineIntersections = circleLineIntersections2(LNormalForm(lastIdxL, :), P(C(1:lastIdxC,1)), C(1:lastIdxC,2));
                intersections = [lineIntersecs; circleLineIntersections];


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % PROCESS INTERSECTIONS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                if ~isempty(intersections)

                    newRaw = intersections(:);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % 1) FILTER EXISTING POINTS
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %Matrix with all pair distances
                    D_old = abs(P(1:1:lastIdxP) - newRaw.');

                    alreadyExists = any(D_old < tol, 1);

                    candidates = newRaw(~alreadyExists);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % 2) REMOVE DUPLICATES INSIDE CANDIDATES
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    duplicateMask = false(size(candidates));

                    for ii = 1:length(candidates)

                        if duplicateMask(ii)
                            continue;
                        end

                        for jj = ii+1:length(candidates)

                            if abs(candidates(ii) - candidates(jj)) < tol
                                duplicateMask(jj) = true;
                            end
                        end
                    end

                    newPoints = candidates(~duplicateMask);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % 3) EVALUATE DISTANCES
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    if ~isempty(newPoints)

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Calculate distances OLD ↔ NEW:
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        D_eval_old = abs(P(1:1:lastIdxP) - newPoints.');
                        distancesCounter = distancesCounter + size(D_eval_old,1) * size(D_eval_old,2);


                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % 4) ADD NEW POINTS
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        m = length(newPoints);
                        assert(lastIdxP + m <= length(P), 'Point storage exhausted');
                        P(lastIdxP+1:1:lastIdxP+m) = newPoints;
                        lastIdxP = lastIdxP + m;


                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % ADD NEW DISTANCES FILTER OUT EXISTING ONES
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        allNewDists = D_eval_old(:);

                        for idx = 1:length(allNewDists)

                            d = allNewDists(idx);

                            %Does distance exist already?
                            if any(abs(D(1:lastIdxD) - d) < tolDist)
                                continue;
                            end

                            lastIdxD = lastIdxD + 1;

                            assert(lastIdxD <= size(D,1), 'Distance storage exhausted' )

                            D(lastIdxD) = d;

                        end

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %  Evaluate distances OLD ↔ NEW:
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        for t = 1:length(targets)

                            target = targets(t);

                            % Erros from this target
                            errors = abs(D_eval_old - target);

                            % All good distances
                            [rowIdx,colIdx] = find(errors < tolTarget);

                            for k = 1:length(rowIdx)

                                iOld = rowIdx(k);
                                iNew = colIdx(k);

                                currentError = errors(iOld,iNew);

                                pointA = P(iOld);
                                pointB = newPoints(iNew);

                                dist = abs(pointA - pointB);

                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                % FEWER THAN 50 -> DIRECTLY ADD
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                                if length(bestErrors{t}) < maxStored
                                    bestErrors{t}(end+1) = currentError;

                                    data.P = P(1:1:lastIdxP);
                                    data.C = C(1:1:lastIdxC, :);
                                    data.L = L(1:1:lastIdxL, :);
                                    data.LNormalForm = LNormalForm(1:1:lastIdxL, :);
                                    data.pointA = pointA;
                                    data.pointB = pointB;
                                    data.dist = dist;

                                    bestData{t}{end+1} = data;

                                else

                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                    % REPLACE WORST ENTRY IF BETTER
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                                    [worstError,worstIdx] = max(bestErrors{t});

                                    if currentError < worstError

                                        bestErrors{t}(worstIdx) = currentError;

                                        data.P = P(1:1:lastIdxP);
                                        data.C = C(1:1:lastIdxC, :);
                                        data.L = L(1:1:lastIdxL, :);
                                        data.LNormalForm = LNormalForm(1:1:lastIdxL, :);
                                        data.pointA = pointA;
                                        data.pointB = pointB;
                                        data.dist = dist;
    
                                        bestData{t}{worstIdx} = data;
                                    end

                                end

                            end

                        end

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Calculate distances NEW ↔ NEW
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        D_eval_new = abs(newPoints - newPoints.');
                        distancesCounter = distancesCounter + size(D_eval_new,1) * size(D_eval_new,2);

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % ADD NEW DISTANCES FILTER OUT EXISTING ONES
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        allNewDists = D_eval_new(triu(true(size(D_eval_new)),1));

                        for idx = 1:length(allNewDists)

                            d = allNewDists(idx);

                            %Does distance exist already?
                            if any(abs(D(1:lastIdxD) - d) < tolDist)
                                continue;
                            end

                            lastIdxD = lastIdxD + 1;

                            assert(lastIdxD <= size(D,1), 'Distance storage exhausted' )

                            D(lastIdxD) = d;

                        end

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % COMPARE TO TARGET
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        for t = 1:length(targets)

                            target = targets(t);

                            % errors to target
                            errors = abs(D_eval_new - target);

                            % only upper triangular part
                            [rowIdx,colIdx] = find(triu(errors < tolTarget,1));

                            for k = 1:length(rowIdx)

                                iA = rowIdx(k);
                                iB = colIdx(k);

                                currentError = errors(iA,iB);

                                pointA = newPoints(iA);
                                pointB = newPoints(iB);

                                dist = abs(pointA - pointB);


                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                % FEWER THAN 50 -> DIRECTLY ADD
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                                if length(bestErrors{t}) < maxStored
                                    bestErrors{t}(end+1) = currentError;

                                    data.P = P(1:1:lastIdxP);
                                    data.C = C(1:1:lastIdxC, :);
                                    data.L = L(1:1:lastIdxL, :);
                                    data.LNormalForm = LNormalForm(1:1:lastIdxL, :);
                                    data.pointA = pointA;
                                    data.pointB = pointB;
                                    data.dist = dist;

                                    bestData{t}{end+1} = data;
                                    
                                else

                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                    % REPLACE WORST ENTRY IF BETTER
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                                    [worstError,worstIdx] = max(bestErrors{t});

                                    if currentError < worstError
                                        bestErrors{t}(worstIdx) = currentError;

                                        data.P = P(1:1:lastIdxP);
                                        data.C = C(1:1:lastIdxC, :);
                                        data.L = L(1:1:lastIdxL, :);
                                        data.LNormalForm = LNormalForm(1:1:lastIdxL, :);
                                        data.pointA = pointA;
                                        data.pointB = pointB;
                                        data.dist = dist;
    
                                        bestData{t}{worstIdx} = data;

                                    end
                                end
                            end
                        end
                    end
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % RECURSION
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                dfs(depth + 1);
                
                % Visualiz each Construction: (BE CAREFUL, DO IT ONLY FOR VERY LOW LEVELS!)
                %if depth == 2
                    %counter = counter +1;
                    %if counter == 18
                        %visualizeConstructionCompassRuler(P(1:lastIdxP), C(1:lastIdxC, :), LNormalForm(1:lastIdxL,:), 1,1,1)
                        %disp("P = " + P(1:lastIdxP));
                        %disp("C = " + C(1:lastIdxC, :));
                        %disp("L = " + LNormalForm(1:lastIdxL,:));
                        %disp("D = " + D(1:lastIdxD))
                    %end
                %end


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % BACKTRACKING
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                lastIdxP = oldPointCount;
                lastIdxL = oldLineCount;
                lastIdxD = oldDistCount;

            end
        end
    end
end