function results = evaluateTop50Symbolic(constructions,targetID)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT
%
% constructions:
%    constructions loaded from TOP50_*.mat
%
% targetID:
%    1 -> sqrt(pi)
%    2 -> 2^(1/3)
%    3 -> sin(pi/7)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

digits(25);

switch targetID
    case 1
        target = vpa(sqrt(sym(pi)),25);

    case 2
        target = vpa(sym(2)^(sym(1)/3),25);

    case 3
        target = vpa(sin(sym(pi)/7),25);

    otherwise
        error('Unknown targetID');
end

results = struct([]);

for k = 1:length(constructions)

    disp("Checking construction number " + k + " of " + length(constructions));

    try
        tic
        [data_sym,V] = symbolic_construction(constructions{k});
        disp("-> Took " + toc + " seconds");

        % Continue if NaN
        try
            double(vpa(data_sym.dist,10));
        catch
            continue;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Symbolic distance
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        distNumeric = data_sym.dist;

        errorVal = vpa(abs(distNumeric - target),25);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Saving
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        entry.index = k;

        entry.error = double(errorVal);
        entry.errorVPA = errorVal;

        entry.distanceVPA = distNumeric;

        entry.dataSym = data_sym;
        entry.V = V;

        results = [results; entry];

    catch ME

        fprintf('Construction %d failed: %s\n', k, ME.message);

        for s = 1:length(ME.stack)
        fprintf('%s line %d\n', ME.stack(s).name, ME.stack(s).line);
        end

    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sorting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(results)

    errors = [results.error];

    [~,idx] = sort(errors);

    results = results(idx);

end

end