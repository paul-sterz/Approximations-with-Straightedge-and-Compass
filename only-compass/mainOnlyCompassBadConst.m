function mainOnlyCompassBadConst(maxDepth, n)

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

solutionfolder = fullfile(pwd,"solutions");
timestamp = datestr(now,'yyyy_mm_dd_HH_MM_SS'); %time of start of run
logfilepath = fullfile(solutionfolder,"logfile_branch_"+ int2str(n) + "_" + timestamp +".txt");
maxDepth_at_Start = maxDepth;

tol = 1e-10;
tolTarget = 1e-8;

% NEW: threshold above which a construction's best error counts as "bad"
badErrorThreshold = 1e-2;

% NEW: cap on the number of bad constructions to collect, counted only
% for the sqrtpi target (targets(1) / targetNames(1))
maxBadConstructions = 50;
sqrtpiTargetIdx = 1;

targets = [sqrt(pi), nthroot(2,3), sin(pi/7)];
targetNames = ["sqrtpi","cuberoot2","heptagon"];

maxStored = 50;

P = zeros(300,1);
C = zeros(20,2);
R = zeros(20,1);

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

% NEW: bad-construction storage, one cell array per target
badErrors = cell(length(targets),1);
badData = cell(length(targets),1);

for t = 1:length(targets)
    badErrors{t} = [];
    badData{t} = {};
end

% NEW: counter of bad constructions found, counted only for sqrtpi
badConstructionCounter = 0;

% NEW: flag used to unwind the recursion once the cap is reached
stopSearch = false;

constructionCounter = 0;
distancesCounter = 0;

tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START DFS - SAVE RESULTS IF ERROR HAPPENS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp("Starting computation...")
try
    dfs(0);
catch ME

    % emergency save

    fileID = fopen(logfilepath, 'a'); %'a': append new lines to end of file, dont delete previous content!

    crashfilepath = fullfile(solutionfolder,"CRASH_SAVE_branch_" + int2str(n) + "_" + timestamp + ".mat");

    for id=[1, fileID]
        fprintf(id, "===============================================\n");
        fprintf(id, "FATAL ERROR \n");

        fprintf(id, "Ran for %i seconds. \n", round(toc));
        fprintf(id, "Recieved the following error message: \n");
        fprintf(id, ME.getReport("extended"));
        fprintf(id, "\n===============================================\n");
        fprintf(id, "Crash state saved to: "+ crashfilepath + "\n");

        fprintf(id, "===============================================\n");
        fprintf(id, "Last state: Constructioncounter: %d, Distancescounter: %d, Bad sqrtpi found: %d \n", constructionCounter, distancesCounter, badConstructionCounter);

        fprintf(id, "RUN PARAMETERS: maxDepth: %i, branch: %i, tolTarget: %d, tol: %d, maxStored: %d, badErrorThreshold: %g, maxBadConstructions: %d \n", maxDepth_at_Start, n, tolTarget, tol, maxStored, badErrorThreshold, maxBadConstructions);
        fprintf(id, "    targets: ");
        fprintf(id, "   %s   ", targetNames);
        fprintf(id, "\n===============================================\n");

    end
    fclose(fileID);


    save(crashfilepath, ...
        "badErrors","badData", ...
        "constructionCounter","distancesCounter","badConstructionCounter", ...
        "P","C","R", "targets", "targetNames",...
        "tol", "tolTarget", "maxStored", "badErrorThreshold", "maxBadConstructions");
    return
end



for t = 1:length(targets)

    solfilename = "bad_branch" + int2str(n)+ "_" + targetNames(t) + "_" + timestamp + ".mat";
    solfilepath = fullfile(solutionfolder, solfilename);

    errors = badErrors{t};
    constructions = badData{t};

    save(solfilepath,"errors","constructions");

end

runtime = toc;
fileID = fopen(logfilepath, 'a');


%Print run stats into logfile and into command line:
for id = [1, fileID]
    fprintf(id, "===============================================\n");

    fprintf(id, "RUN FINISHED IN TIME: \n");
    fprintf(id, "%i seconds \n", round(runtime));
    fprintf(id, "    started at time: %s \n", timestamp);

    fprintf(id, "RUN DATA: \n Constructions evaluated: %d \n Unique distances computed: %d \n Bad sqrtpi constructions found: %d \n", constructionCounter, distancesCounter, badConstructionCounter);
    fprintf(id, "===============================================\n");

    fprintf(id, "RUN PARAMETERS: \n maxDepth: %i \n branch: %i \n tolTarget: %d \n tol: %d \n maxStored: %d \n badErrorThreshold: %g \n maxBadConstructions: %d \n", maxDepth_at_Start, n, tolTarget, tol, maxStored, badErrorThreshold, maxBadConstructions);
    fprintf(id, " targets: \n ");
    for t=1:length(targets)
        fprintf(id, "        %s, bad constructions: %i \n ", targetNames(t), length(badData{t}));
    end
    fprintf(id, "===============================================\n");

end
fclose(fileID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEPTH FIRST SEARCH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function dfs(depth)

        % NEW: if the global cap was already reached somewhere else in the
        % recursion tree, unwind immediately without doing further work
        if stopSearch
            return;
        end

        constructionCounter = constructionCounter + 1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STOP CONDITION
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if depth >= maxDepth

            % NEW: evaluate this fully-grown construction once it reached
            % maxDepth: find its single best (smallest) error to each
            % target over ALL point pairs, and if that best error is
            % still bad (> badErrorThreshold), store it as a bad example.

            n_pts = lastIdxP;
            Pall  = P(1:n_pts);

            D = abs(Pall - Pall.');
            D(1:n_pts+1:end) = Inf;   % ignore distance of a point to itself

            for t = 1:length(targets)

                target = targets(t);

                errorsToTarget = abs(D - target);

                % Kleinsten Fehler und zugehöriges Punktpaar bestimmen
                [bestErrorHere, linearIdx] = min(errorsToTarget(:));
                [idxA, idxB] = ind2sub(size(errorsToTarget), linearIdx);

                if bestErrorHere > badErrorThreshold

                    pointA = P(idxA);
                    pointB = P(idxB);

                    data.P = P(1:lastIdxP);
                    data.C = C(1:lastIdxC, :);
                    data.R = R(1:lastIdxC);
                    data.pointA = pointA;
                    data.pointB = pointB;
                    data.dist = D(idxA, idxB);
                    data.bestError = bestErrorHere;

                    badErrors{t}(end+1) = bestErrorHere;
                    badData{t}{end+1} = data;

                    % NEW: only the sqrtpi target advances the global stop
                    % counter - other targets are still stored but don't
                    % count towards the cap
                    if t == sqrtpiTargetIdx

                        badConstructionCounter = badConstructionCounter + 1;

                        if badConstructionCounter >= maxBadConstructions
                            stopSearch = true;
                            return;
                        end

                    end

                end

            end

            return;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % SAVE STATE FOR BACKTRACKING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        oldPointCount  = lastIdxP;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % TRY ALL POSSIBLE NEW CIRCLES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        for midpoint = 1:oldPointCount

            for radiusPoint = 1:oldPointCount

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
                % ADD NEW CIRCLE - TO DO: Implement version where enough
                % storage is allocated in the begining
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
                    % 3) ADD NEW POINTS - TO-DO: Implement version
                    % where enough storage is allocated at the
                    % begining
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    if ~isempty(newPoints)

                        m = length(newPoints);
                        assert(lastIdxP + m <= length(P), 'Point storage exhausted');
                        P(lastIdxP+1:lastIdxP+m) = newPoints;
                        lastIdxP = lastIdxP + m;

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

                % NEW: stop trying further branches as soon as the global
                % cap was hit anywhere below this point in the recursion
                if stopSearch
                    return;
                end
            end

            % NEW: also break out of the outer midpoint loop
            if stopSearch
                return;
            end
        end
    end
end