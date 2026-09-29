function [constructionCounter, distancesCounter] = mainOnlyCompassRandomNN(maxDepth, timePerCore, solutionfolder, logfilepath, timestamp, coreID)
%VERSION: UNPARALLELIZED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT:
% maxDepth - maximum construction depth
% n        - which of the 10 symmetry reduced start configurations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL CONFIGURATION
% P = complex point vector
% C = circle matrix [centerPointIndex radiusPointIndex]
% R = radius vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

maxDepth_at_Start = maxDepth;

tol = 1e-10;
tolTarget = 1e-1; %Note currently a very low tolTarget because otherwise the bestSqrtPiErr handling which is needed for the AI does not work

bestSqrtPiErr = sqrt(pi) - 1;

n = randi(10); %branch now chosen randomly

targets = [sqrt(pi), nthroot(2,3), sin(pi/7)];
targetNames = ["sqrtpi","cuberoot2","heptagon"];

P = zeros(500,1);
C = zeros(20,2);
R = zeros(20,1);

maxStored = 50;

switch n
    case 1
        P(1:1:8) = [0; 1; 1/2+1i*sqrt(3)/2; 1/2-1i*sqrt(3)/2; -1/2+1i*sqrt(3)/2; 3/2+1i*sqrt(3)/2;-1;2];
        C(1:1:4, :) = [1 2; 2 1; 3 1; 3 4];
        R(1:1:4) = [1; 1; 1; sqrt(3)];
        lastIdxP = 8;
        lastIdxC = 4;
    case 2
        P(1:1:8) = [0; 1; 1/2+1i*sqrt(3)/2; 1/2-1i*sqrt(3)/2; -1/2+1i*sqrt(3)/2; 3/2+1i*sqrt(3)/2; -1/2-1i*sqrt(3)/2; 3/2-1i*sqrt(3)/2];
        C(1:1:4, :) = [1 2; 2 1; 3 1; 4 1];
        R(1:1:4) = [1; 1; 1; 1];
        lastIdxP = 8;
        lastIdxC = 4;
    case 3
        P(1:1:6) = [0; 1; 1/2+1i*sqrt(3)/2; 1/2-1i*sqrt(3)/2; -1/2+1i*sqrt(3)/2; 3/2+1i*sqrt(3)/2];
        C(1:1:4, :) = [1 2; 2 1; 3 1; 4 5];
        R(1:1:4) = [1; 1; 1; 2];
        lastIdxP = 6;
        lastIdxC = 4;
    case 4
        P(1:1:10) = [0; 1; 1/2+1i*sqrt(3)/2; 1/2-1i*sqrt(3)/2; -1/2+1i*sqrt(3)/2; 3/2+1i*sqrt(3)/2; -1; 2; -(sqrt(33)-3)/6+1i/sqrt(3); (sqrt(33)+3)/6+1i/sqrt(3)];
        C(1:1:4, :) = [1 2; 2 1; 3 1; 4 3];
        R(1:1:4) = [1; 1; 1; sqrt(3)];
        lastIdxP = 10;
        lastIdxC = 4;
    case 5
        P(1:1:10) = [0; 1; 1/2+1i*sqrt(3)/2; 1/2-1i*sqrt(3)/2; -1; 2; -3/4-sqrt(33)/12-1i*(sqrt(3)/12+sqrt(11)/4); -3/4+sqrt(33)/12-1i*(sqrt(3)/12-sqrt(11)/4); -1/2-1i*sqrt(3)/2; -1/2+1i*sqrt(3)/2];
        C(1:1:4, :) = [1 2; 2 1; 4 3; 5 1];
        R(1:1:4) = [1; 1;sqrt(3); 1];
        lastIdxP = 10;
        lastIdxC = 4;
    case 6
        P(1:1:10) = [0; 1; 1/2+1i*sqrt(3)/2; 1/2-1i*sqrt(3)/2; -1; 2; sqrt(2/3)+1i*(sqrt(2)-sqrt(3)/3); -sqrt(6)/3-1i*sqrt((7+2*sqrt(6))/3); 3/4+1i*sqrt(15)/4; 3/4-1i*sqrt(15)/4];
        C(1:1:4, :) = [1 2; 2 1; 4 3; 5 2];
        R(1:1:4) = [1; 1;sqrt(3); 2];
        lastIdxP = 10;
        lastIdxC = 4;
    case 7
        P(1:1:6) = [0; 1; 1/2+1i*sqrt(3)/2; 1/2-1i*sqrt(3)/2; -1; 2];
        C(1:1:4, :) = [1 2; 2 1; 4 3; 3 4];
        R(1:1:4) = [1; 1; sqrt(3); sqrt(3)];
        lastIdxP = 6;
        lastIdxC = 4;
    case 8
        P(1:1:7) = [0; 1; 1/2+1i*sqrt(3)/2; 1/2-1i*sqrt(3)/2; -1; 2; 1/2-3i*sqrt(3)/2];
        C(1:1:4, :) = [1 2; 2 1; 4 3; 5 6];
        R(1:1:4) = [1; 1; sqrt(3); 3];
        lastIdxP = 7;
        lastIdxC = 4;
    case 9
        P(1:1:7) = [0; 1; 1/2+1i*sqrt(3)/2; 1/2-1i*sqrt(3)/2; -1; 2; -1-1i*sqrt(3)];
        C(1:1:4, :) = [1 2; 2 1; 4 3; 5 3];
        R(1:1:4) = [1; 1; sqrt(3); sqrt(3)];
        lastIdxP = 7;
        lastIdxC = 4;
    case 10
        P(1:1:7) = [0; 1; 1/2+1i*sqrt(3)/2; 1/2-1i*sqrt(3)/2; -1; 2; -1-1i*sqrt(3)];
        C(1:1:4, :) = [1 2; 2 1; 4 3; 1 6];
        R(1:1:4) = [1; 1; sqrt(3); 2];
        lastIdxP = 7;
        lastIdxC = 4;
    otherwise
        error("Branch does not exist: " + int2str(n) + "!");
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

maxDepth = maxDepth - 4;

format short;

bestErrors = cell(length(targets),1);
bestData = cell(length(targets),1);

for t = 1:length(targets)
    bestErrors{t} = [];
    bestData{t} = {};
end

constructionCounter = 0;
distancesCounter = 0;

tic

nnWeights = loadNNWeights("nn_weights_sqrtpi.npz");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START DFS - SAVE RESULTS IF ERROR HAPPENS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    dfs(0);
catch ME

    % emergency save

    fileID = fopen(logfilepath, 'a'); %'a': append new lines to end of file, dont delete previous content!

    crashfilepath = fullfile(solutionfolder,"CRASH_SAVE_CORE_"+  int2str(coreID) + "_" + timestamp + ".mat");

    for id=[fileID]
        fprintf(id, "===============================================\n");
        fprintf(id, "FATAL ERROR in Core " + int2str(coreID) + "\n");

        fprintf(id, "Ran for %i seconds. \n", round(toc));
        fprintf(id, "Recieved the following error message: \n");
        fprintf(id, ME.getReport("extended"));
        fprintf(id, "\n===============================================\n");
        fprintf(id, "Crash state saved to: "+ crashfilepath + "\n");

        fprintf(id, "===============================================\n");
        fprintf(id, "Last state: Constructioncounter: %d, Distancescounter: %d \n", constructionCounter, distancesCounter);

        fprintf(id, "RUN PARAMETERS: maxDepth: %i, branch: %i, tolTarget: %d, tol: %d, maxStored: %d \n", maxDepth_at_Start, n, tolTarget, tol, maxStored);
        fprintf(id, "    targets: ");
        fprintf(id, "   %s   ", targetNames);
        fprintf(id, "\n===============================================\n");

    end
    fclose(fileID);

    save(crashfilepath, ...
        "bestErrors","bestData", ...
        "constructionCounter","distancesCounter", ...
        "P","C","R", "targets", "targetNames",...
        "tol", "tolTarget", "maxStored");
    return
end



for t = 1:length(targets)

    solfilename = "best_CORE_"+  int2str(coreID) + "_" + targetNames(t) + "_" + timestamp + ".mat";
    solfilepath = fullfile(solutionfolder, solfilename);

    errors = bestErrors{t};
    constructions = bestData{t};

    save(solfilepath,"errors","constructions");

end

runtime = toc;
fileID = fopen(logfilepath, 'a');


%Print run stats into logfile and into command line:
for id = [fileID]
    fprintf(id, "===============================================\n");

    fprintf(id, "CORE " + int2str(coreID) + " FINISHED IN TIME: \n");
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
% DEPTH FIRST SEARCH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function dfs(depth)

        constructionCounter = constructionCounter + 1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STOP CONDITION
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if depth >= maxDepth || toc > timePerCore
            return;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SAVE STATE FOR BACKTRACKING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        oldPointCount  = lastIdxP;
        oldBestSqrtPiErr = bestSqrtPiErr;


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % MAKE RANDOM CHOICES TILL LEVEL maxDepth-1 AND THEN CHECK ALL LEAFS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if depth == maxDepth -1 %Case we are at level madDepth-1 and want to check all leafs

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % TRY ALL POSSIBLE NEW CIRCLES
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            for midpoint = 1:oldPointCount
                 
                if toc > timePerCore
                    break;
                end

                for radiusPoint = 1:oldPointCount

                    if toc > timePerCore
                        break;
                    end

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % SAME POINT NOT ALLOWED
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    if midpoint == radiusPoint
                        continue;
                    end

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % COMPUTE RADIUS
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    r1 = abs(P(midpoint) - P(radiusPoint));

                    if r1 < 1e-2
                        continue;
                    end

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % CHECK IF CIRCLE ALREADY EXISTS
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    exists = false;

                    for i = 1:lastIdxC
                        if midpoint == C(i,1) && abs(r1 - R(i)) < tol
                            exists = true;
                            break;
                        end
                    end

                    if exists
                        continue;
                    end

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % CHECK DUPLICATES INSIDE THIS STEP
                    %
                    % Remark: Parallelization was tried here but was slower than iterating through it.
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    for l = 1:radiusPoint-1

                        if l == midpoint
                            continue;
                        end

                        if abs(r1 - abs(P(midpoint) - P(l))) < tol
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
                    C(lastIdxC,:) = [midpoint radiusPoint];
                    R(lastIdxC)   = r1;
                    c1 = C(lastIdxC,:);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % COMPUTE INTERSECTIONS
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    try
                        intersections = circleIntersectionV5(P(c1(1)), P(C(1:lastIdxC-1,1)), r1, R(1:lastIdxC-1), tol);
                    catch ME

                        fileID = fopen(logfilepath, 'a'); %'a': append new lines to end of file, dont delete previous content!

                        fprintf(fileID, "\n===============================================\n");
                        fprintf(fileID, "ERROR OCCURED IN INTERSECTION COMPUTATION \n");
                        fprintf(fileID, ME.getReport);
                        fprintf(fileID, "\n===============================================\n");

                        fclose(fileID);

                        intersections = [];

                    end

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
                            % 4) ADD NEW POINTS - TO-DO: Implement version
                            % where enough storage is allocated at the
                            % begining
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                            m = length(newPoints);
                            assert(lastIdxP + m <= length(P), 'Point storage exhausted');
                            P(lastIdxP+1:lastIdxP+m) = newPoints;
                            lastIdxP = lastIdxP + m;

                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %  Evaluate distances OLD ↔ NEW:
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                            for t = 1:length(targets)

                                target = targets(t);

                                % Error to this target
                                errors = abs(D_eval_old - target);

                                % All good finds
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

                                        if t == 1 && currentError < bestSqrtPiErr
                                            bestSqrtPiErr = currentError;
                                        end

                                        bestErrors{t}(end+1) = currentError;

                                        data.P = P(1:1:lastIdxP);
                                        data.C = C(1:1:lastIdxC, :);
                                        data.R = R(1:1:lastIdxC, :);
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

                                            if t == 1 && currentError < bestSqrtPiErr
                                                bestSqrtPiErr = currentError;
                                            end

                                            bestErrors{t}(worstIdx) = currentError;

                                            data.P = P(1:1:lastIdxP);
                                            data.C = C(1:1:lastIdxC, :);
                                            data.R = R(1:1:lastIdxC, :);
                                            data.pointA = pointA;
                                            data.pointB = pointB;
                                            data.dist = dist;

                                            bestData{t}{worstIdx} = data;

                                        end

                                    end

                                end

                            end

                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            % NEW ↔ NEW
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                            D_eval_new = abs(newPoints - newPoints.');
                            distancesCounter = distancesCounter + size(D_eval_new,1) * size(D_eval_new,2);

                            % remove diagonal
                            D_eval_new(1:end+1:end) = Inf;

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


                                        if t == 1 && currentError < bestSqrtPiErr
                                            bestSqrtPiErr = currentError;
                                        end

                                        bestErrors{t}(end+1) = currentError;

                                        data.P = P(1:1:lastIdxP);
                                        data.C = C(1:1:lastIdxC, :);
                                        data.R = R(1:1:lastIdxC, :);
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


                                            if t == 1 && currentError < bestSqrtPiErr
                                                bestSqrtPiErr = currentError;
                                            end

                                            bestErrors{t}(worstIdx) = currentError;

                                            data.P = P(1:1:lastIdxP);
                                            data.C = C(1:1:lastIdxC, :);
                                            data.R = R(1:1:lastIdxC, :);
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
                    % RECURSION NOT NEEDED SINCE WE ARE AT LEVEL MAXDEPTH
                    % -1
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    constructionCounter = constructionCounter +1;

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % BACKTRACKING
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    lastIdxP = oldPointCount;
                    lastIdxC = lastIdxC-1;
                    bestSqrtPiErr = oldBestSqrtPiErr;
                end
            end
        else % We want to chose a random path to level maxDepth-1
            
            counter = 0;
            possibilities = oldPointCount * oldPointCount;
            checks = possibilities;
            if depth > 5
                checks = possibilities/10;
            end
            %Do at most amount of possibilites random choices before you
            %backtrack to the level before
            while toc < timePerCore && counter < checks
                counter = counter + 1;

                % NN-GUIDED SELECTION: Test K random Options and choose the
                % one that get's the best Score from the NN

                K = possibilities;
                bestNNScore  = -1;
                midpoint     = -1;
                radiusPoint  = -1;
                r1           = -1;

                frac = depth / maxDepth;

                for kk = 1:K
                    foundValid = false;

                    while ~foundValid
                        %Create random mid and radiuspoint
                        mp_try = randi(oldPointCount);
                        rp_try = randi(oldPointCount);
                        
                        % Check if mid and radiuspoint are the same
                        if mp_try == rp_try
                            continue;
                        end
                        
                        %Check if Radius is too small
                        r_try = abs(P(mp_try) - P(rp_try));
                        if r_try < 1e-2
                            continue;
                        end
                        
                        %Check if circle already exists
                        ex = false;
                        for i = 1:lastIdxC
                            if mp_try == C(i,1) && abs(r_try - R(i)) < tol
                                ex = true; break;
                            end
                        end

                        if ex
                            continue
                        end

                        foundValid = true;
                    end
                    
                    % Calculate Score for the choosen step with the NN
                    s = nnScore(r_try, P(mp_try), P(rp_try), ...
                        lastIdxP, lastIdxC, bestSqrtPiErr, frac, nnWeights);
                    
                    % Keep Track of the best Score so far
                    if s > bestNNScore
                        bestNNScore = s;
                        midpoint    = mp_try;
                        radiusPoint = rp_try;
                        r1          = r_try;
                    end
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % ADD NEW CIRCLE - TO DO:
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                lastIdxC = lastIdxC + 1;
                assert(lastIdxC <= size(C,1), 'Circle storage exhausted');
                C(lastIdxC,:) = [midpoint radiusPoint];
                R(lastIdxC)   = r1;
                c1 = C(lastIdxC,:);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % COMPUTE INTERSECTIONS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                try
                    intersections = circleIntersectionV5(P(c1(1)), P(C(1:lastIdxC-1,1)), r1, R(1:lastIdxC-1), tol);
                catch ME

                    fileID = fopen(logfilepath, 'a'); %'a': append new lines to end of file, dont delete previous content!

                    fprintf(fileID, "\n===============================================\n");
                    fprintf(fileID, "ERROR OCCURED IN INTERSECTION COMPUTATION \n");
                    fprintf(fileID, ME.getReport);
                    fprintf(fileID, "\n===============================================\n");

                    fclose(fileID);

                    intersections = [];

                end

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
                        P(lastIdxP+1:lastIdxP+m) = newPoints;
                        lastIdxP = lastIdxP + m;

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %  Evaluate distances OLD ↔ NEW:
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        for t = 1:length(targets)

                            target = targets(t);

                            % Fehler zu diesem target
                            errors = abs(D_eval_old - target);

                            % alle guten Treffer
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


                                    if t == 1 && currentError < bestSqrtPiErr
                                        bestSqrtPiErr = currentError;
                                    end

                                    bestErrors{t}(end+1) = currentError;

                                    data.P = P(1:1:lastIdxP);
                                    data.C = C(1:1:lastIdxC, :);
                                    data.R = R(1:1:lastIdxC, :);
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


                                        if t == 1 && currentError < bestSqrtPiErr
                                            bestSqrtPiErr = currentError;
                                        end

                                        bestErrors{t}(worstIdx) = currentError;

                                        data.P = P(1:1:lastIdxP);
                                        data.C = C(1:1:lastIdxC, :);
                                        data.R = R(1:1:lastIdxC, :);
                                        data.pointA = pointA;
                                        data.pointB = pointB;
                                        data.dist = dist;

                                        bestData{t}{worstIdx} = data;

                                    end

                                end

                            end

                        end

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % NEW ↔ NEW
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        D_eval_new = abs(newPoints - newPoints.');
                        distancesCounter = distancesCounter + size(D_eval_new,1) * size(D_eval_new,2);

                        % remove diagonal
                        D_eval_new(1:end+1:end) = Inf;

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


                                    if t == 1 && currentError < bestSqrtPiErr
                                        bestSqrtPiErr = currentError;
                                    end

                                    bestErrors{t}(end+1) = currentError;

                                    data.P = P(1:1:lastIdxP);
                                    data.C = C(1:1:lastIdxC, :);
                                    data.R = R(1:1:lastIdxC, :);
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


                                        if t == 1 && currentError < bestSqrtPiErr
                                            bestSqrtPiErr = currentError;
                                        end

                                        bestErrors{t}(worstIdx) = currentError;

                                        data.P = P(1:1:lastIdxP);
                                        data.C = C(1:1:lastIdxC, :);
                                        data.R = R(1:1:lastIdxC, :);
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

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % BACKTRACKING
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                lastIdxP = oldPointCount;
                lastIdxC = lastIdxC-1;
                bestSqrtPiErr = oldBestSqrtPiErr;
            end
        end
    end
end