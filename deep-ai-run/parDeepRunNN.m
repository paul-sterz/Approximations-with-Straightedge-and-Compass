function parDeepRun(timePerCore)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT:
% timePerCore - the time limit how long each core should work. The program
% will terminate exactly after this time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    % Determine the number of usable cores and use all but one (Currently all but 3)
    numOfWorkers = feature('numcores') - 1;
    if isempty(gcp('nocreate'))
        parpool('local', numOfWorkers);
    end

    % Saving the counters over all workers
    constructionsChecked = zeros(1,numOfWorkers);
    distancesChecked = zeros(1,numOfWorkers);

    solutionfolder = fullfile(pwd,"solutions");
    timestamp = datestr(now,'yyyy_mm_dd_HH_MM_SS');
    logfilepath = fullfile(solutionfolder,"logfile_" + timestamp + ".txt");

    disp("Starting computation on " + int2str(numOfWorkers) + " cores");

    parfor i = 1:numOfWorkers
        % Each worker gets there one file
        workerLog = fullfile(solutionfolder, ...
            "logfile_" + timestamp + "_core" + int2str(i) + ".txt");

        [constructionsChecked(i), distancesChecked(i)] = ...
            mainOnlyCompassRandomNN(8, timePerCore, solutionfolder, workerLog, timestamp, i);
        disp("   Core " + int2str(i) + " finished");
    end

    % After parfor: Combine all worker logs into one main log file
    fileID = fopen(logfilepath, 'a');
    for i = 1:numOfWorkers
        workerLog = fullfile(solutionfolder, ...
            "logfile_" + timestamp + "_core" + int2str(i) + ".txt");
        if isfile(workerLog)
            content = fileread(workerLog);
            fprintf(fileID, '=== Core %d ===\n', i);
            fprintf(fileID, '%s', content);
            delete(workerLog);  % temporäre Datei löschen
        end
    end

    % General information
    for id = [1, fileID]
        fprintf(id, "=========================\n");
        fprintf(id, "Parallel run finished \n");
        fprintf(id, "Used " + int2str(numOfWorkers) + " cores each taking " + timePerCore + " seconds \n");
        fprintf(id, "Constructions checked: " + int2str(sum(constructionsChecked)) + "\n");
        fprintf(id, "Distances checked: " + int2str(sum(distancesChecked)) + "\n");
    end
    fclose(fileID);
end