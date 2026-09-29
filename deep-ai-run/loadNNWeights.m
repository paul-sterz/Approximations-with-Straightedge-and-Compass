function weights = loadNNWeights(npz_filepath)
%LOADNNWEIGHTS  Lädt die exportierten NN-Gewichte aus einer .npz Datei
%
% USAGE:
%   weights = loadNNWeights("nn_weights.npz")
%
% Das .npz Format ist ein ZIP-Archiv mit .npy Dateien darin.
% Diese Funktion entpackt es temporär und liest die Arrays.
%
% VORAUSSETZUNG: Python muss installiert sein (für den Entpack-Schritt),
%                ODER du nutzt den Python-Konverter (siehe unten).

% Temporären Ordner erstellen
tmpDir = tempname;
mkdir(tmpDir);

% .npz ist ein ZIP - einfach entpacken
unzip(npz_filepath, tmpDir);

% Jede .npy Datei lesen
weights.W1     = readNpy(fullfile(tmpDir, 'W1.npy'));
weights.b1     = readNpy(fullfile(tmpDir, 'b1.npy'));
weights.W2     = readNpy(fullfile(tmpDir, 'W2.npy'));
weights.b2     = readNpy(fullfile(tmpDir, 'b2.npy'));
weights.W3     = readNpy(fullfile(tmpDir, 'W3.npy'));
weights.b3     = readNpy(fullfile(tmpDir, 'b3.npy'));
weights.X_mean = readNpy(fullfile(tmpDir, 'X_mean.npy'));
weights.X_std  = readNpy(fullfile(tmpDir, 'X_std.npy'));

% Aufräumen
rmdir(tmpDir, 's');

end


function data = readNpy(filepath)
%READNPY  Liest eine .npy Datei (NumPy Format) in MATLAB
%
% Unterstützt float32 und float64 Arrays (1D und 2D)

fid = fopen(filepath, 'rb');
if fid == -1
    error('Kann Datei nicht öffnen: %s', filepath);
end

% Magic string prüfen (\x93NUMPY)
magic = fread(fid, 6, 'uint8')';
assert(magic(1) == 147, 'Keine gültige .npy Datei');

% Version
major = fread(fid, 1, 'uint8');
minor = fread(fid, 1, 'uint8');

% Header-Länge
if major == 1
    header_len = fread(fid, 1, 'uint16');
else
    header_len = fread(fid, 1, 'uint32');
end

% Header lesen
header = char(fread(fid, header_len, 'uint8')');

% dtype extrahieren
dtype_match = regexp(header, "'descr':\s*'([^']*)'", 'tokens');
dtype_str   = dtype_match{1}{1};

% Fortran-Order prüfen
fortran_order = ~isempty(regexp(header, "'fortran_order':\s*True", 'once'));

% Shape extrahieren
shape_match = regexp(header, "'shape':\s*\(([^)]*)\)", 'tokens');
shape_str   = shape_match{1}{1};
shape_parts = strsplit(strtrim(shape_str), ',');
shape = [];
for i = 1:length(shape_parts)
    s = strtrim(shape_parts{i});
    if ~isempty(s)
        shape(end+1) = str2double(s);
    end
end
if isempty(shape)
    shape = [1];
end

% Daten lesen
switch dtype_str
    case {'<f4', '=f4'}
        data = fread(fid, prod(shape), 'float32=>double');
    case {'<f8', '=f8'}
        data = fread(fid, prod(shape), 'float64=>double');
    otherwise
        error('Nicht unterstützter dtype: %s', dtype_str);
end

fclose(fid);

% Reshape
if length(shape) == 2
    data = reshape(data, shape(2), shape(1))';  % Row-major -> col-major
elseif isscalar(shape)
    data = data(:);
end

end