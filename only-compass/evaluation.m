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

digits(100);

switch targetID
    case 1
        target = vpa(sqrt(sym(pi)),100);

    case 2
        target = vpa(sym(2)^(sym(1)/3),100);

    case 3
        target = vpa(sin(sym(pi)/7),100);

    otherwise
        error('Unknown targetID');
end

results = struct([]);

for k = 1:length(constructions)

    fprintf('Checking construction %d/%d\n', ...
        k,length(constructions));

    try

        [data_sym,V] = symbolic_construction(constructions{k});

        if isnan(data_sym.dist)
            continue;
        end

        distExact = simplify(data_sym.dist);

        distNumeric = vpa(distExact,100);

        errorExact = abs(distNumeric - target);

        entry.index = k;
        entry.error = double(vpa(errorExact,30));
        entry.errorVPA = errorExact;

        entry.distanceVPA = distNumeric;
        entry.distanceExact = distExact;

        entry.dataSym = data_sym;
        entry.V = V;

        results = [results; entry];

    catch ME

        fprintf('Construction %d failed: %s\n', ...
            k,ME.message);

    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sort by symbolic error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(results)

    errors = [results.error];

    [~,idx] = sort(errors);

    results = results(idx);

end

end