%%PFIZER EDIT HERE
%Reads all the chromatogram data in the given format

function data = importAgilent2(varargin)
% ------------------------------------------------------------------------
% Method      : importAgilent
% Description : Read Agilent data files (.D, .MS, .CH, .UV)
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   data = importAgilent()
%   data = importAgilent( __ , Name, Value)
%
% ------------------------------------------------------------------------
% Input (Name, Value)
% ------------------------------------------------------------------------
%   'file' -- name of file or folder path
%       empty (default) | cell array of strings
%
%   'depth' -- subfolder search depth
%       1 (default) | integer
%
%   'content' -- read all data, header only, or signal data only
%       'all' (default) | 'header', 'data'
%
%   'verbose' -- show progress in command window
%       'on' (default) | 'off' | 'waitbar'
%
% ------------------------------------------------------------------------
% Examples
% ------------------------------------------------------------------------
%   data = importAgilent()
%   data = importAgilent('file', '00159F.D')
%   data = importAgilent('file', {'/Data/2016/04/', '00201B.D'})
%   data = importAgilent('file', {'/Data/2016/'}, 'depth', 4)
%   data = importAgilent('content', 'header', 'depth', 8)
%   data = importAgilent('verbose', 'off')

% ---------------------------------------
% Data
% ---------------------------------------
data.file_path       = [];
data.file_name       = [];
data.file_size       = [];
data.file_info       = [];
data.file_version    = [];
data.sample_name     = [];
data.sample_info     = [];
data.operator        = [];
data.datetime        = [];
data.instrument      = [];
data.instmodel       = [];
data.inlet           = [];
data.method_name     = [];
data.seqindex        = [];
data.vial            = [];
data.replicate       = [];
data.injvol          = [];
data.glp_flag        = [];
data.data_source     = [];
data.firmware_rev    = [];
data.software_rev    = [];
data.sampling_rate   = [];
data.time            = [];
data.intensity       = [];
data.channel         = [];
data.time_units      = [];
data.intensity_units = [];
data.channel_units   = [];
data.baseline        = [];
data.peaks           = [];

% ---------------------------------------
% Defaults
% ---------------------------------------
default.file    = [];
default.depth   = 1;
default.content = 'all';
default.verbose = 'on';
default.formats = {'.MS', '.CH', '.UV'};

% ---------------------------------------
% Platform
% ---------------------------------------
if exist('OCTAVE_VERSION', 'builtin')
    more('off');
end

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addParameter(p, 'file',    default.file);
addParameter(p, 'depth',   default.depth);
addParameter(p, 'content', default.content, @ischar);
addParameter(p, 'verbose', default.verbose, @ischar);

parse(p, varargin{:});

% ---------------------------------------
% Options
% ---------------------------------------
option.file    = p.Results.file;
option.depth   = p.Results.depth;
option.content = p.Results.content;
option.verbose = p.Results.verbose;
option.waitbar = false;

% ---------------------------------------
% Validate
% ---------------------------------------

% Parameter: 'file'
if ~isempty(option.file)
    if iscell(option.file)
        option.file(~cellfun(@ischar, option.file)) = [];
    elseif ischar(option.file)
        option.file = {option.file};
    end
end

% Parameter: 'depth'
if ischar(option.depth) && ~isnan(str2double(option.depth))
    option.depth = round(str2double(default.depth));
elseif ~isnumeric(option.depth)
    option.depth = default.depth;
elseif option.depth < 0 || isnan(option.depth) || isinf(option.depth)
    option.depth = default.depth;
else
    option.depth = round(option.depth);
end

% Parameter: 'content'
option.content = lower(option.content);

switch option.content
    case {'all', 'default'}
        option.content = 'all';
    case {'data', 'signal'}
        option.content = 'data';
    case {'metadata', 'header', 'info'}
        option.content = 'header';
    otherwise
        option.content = default.content;
end

% Parameter: 'verbose'
option.verbose = lower(option.verbose);

switch option.verbose
    case {'on', 'true', '1', 'yes', 'y'}
        option.verbose = true;
    case {'off', 'false', '0', 'no', 'n'}
        option.verbose = false;
    case {'waitbar'}
        option.verbose = false;
        option.waitbar = true;
    otherwise
        option.verbose = default.verbose;
end

% ---------------------------------------
% File selection
% ---------------------------------------
status(option.verbose, 'import');

if isempty(option.file)
    [file, fileError] = FileUI([]);
else
    file = FileVerify(option.file, []);
end

% ---------------------------------------
% Status
% ---------------------------------------
if exist('fileError', 'var') && fileError == 1
    status(option.verbose, 'selection_cancel');
    status(option.verbose, 'exit');
    return
    
elseif exist('fileError', 'var') && fileError == 2
    status(option.verbose, 'java_error');
    status(option.verbose, 'exit');
    return
    
elseif isempty(file)
    status(option.verbose, 'file_error');
    status(option.verbose, 'exit');
    return
end

% ---------------------------------------
% Search subfolders
% ---------------------------------------
if sum([file.directory]) == 0
    option.depth = 0;
else
    status(option.verbose, 'subfolder_search');
    file = parsesubfolder(file, option.depth, default.formats);
end

% ---------------------------------------
% Filter unsupported files
% ---------------------------------------
[~,~,ext] = cellfun(@(x) fileparts(x), {file.Name}, 'uniformoutput', 0);

file(cellfun(@(x) ~any(strcmpi(x, default.formats)), ext)) = [];

% ---------------------------------------
% Status
% ---------------------------------------
if isempty(file)
    status(option.verbose, 'selection_error');
    status(option.verbose, 'exit');
    return
else
    status(option.verbose, 'file_count', length(file));
end

% ---------------------------------------
% Import
% ---------------------------------------
tic;

for i = 1:length(file)
    
    % ---------------------------------------
    % Permissions
    % ---------------------------------------
    if ~file(i).UserRead
        continue
    end
    
    % ---------------------------------------
    % Properties
    % ---------------------------------------
    [filePath, fileName, fileExt] = fileparts(file(i).Name);
    [parentPath, parentName, parentExt] = fileparts(filePath);
    
    if strcmpi(parentExt, '.D')
        data(i,1).file_path = parentPath;
        data(i,1).file_name = [parentName, parentExt, filesep, fileName, fileExt];
    else
        data(i,1).file_path = filePath;
        data(i,1).file_name = [fileName, fileExt];
    end
    
    data(i,1).file_size = subsref(dir(file(i).Name), substruct('.', 'bytes'));


    % ---------------------------------------
    % Waitbar
    % ---------------------------------------
    if i == 1
        if option.waitbar
            h = initializeWaitbar(length(file), data(i,1).file_name);
        else
            h = [];
        end
    end
    
    if option.waitbar && ~ishandle(h)
        data(i,:) = [];
        status(option.verbose, 'abort', i, length(file));
        break
    elseif option.waitbar
        updateWaitbar(h, i, length(file), data(i,1).file_name);
    end    
    
    % ---------------------------------------
    % Status
    % ---------------------------------------
    [~, statusPath] = fileparts(data(i,1).file_path);
    statusPath = ['..', filesep, statusPath, filesep, data(i,1).file_name];
    
    status(option.verbose, 'loading_file', i, length(file));
    status(option.verbose, 'file_name', statusPath);
    status(option.verbose, 'loading_stats', data(i,1).file_size);
    
    % ---------------------------------------
    % Read
    % ---------------------------------------
    if data(i,1).file_size ~= 0
        
        f = fopen(file(i).Name, 'r');
        
        switch option.content
            
            case {'all', 'default'}
                data(i,1) = parseinfo(f, data(i,1));
                data(i,1) = parsedata(f, data(i,1));
                
            case {'header'}
                data(i,1) = parseinfo(f, data(i,1));
                
            case {'data'}
                data(i,1) = parsedata(f, data(i,1));
                   
        end
        
        fclose(f);
        
    end
    
end

% ---------------------------------------
% Exit
% ---------------------------------------
if option.waitbar && ishandle(h)
    close(h);
end

status(option.verbose, 'stats', length(data), toc, sum([data.file_size]));
status(option.verbose, 'exit');

end

% ---------------------------------------
% Initialize Waitbar
% ---------------------------------------
function h = initializeWaitbar(n, filename)

m = num2str('0');
n = num2str(n);
msg = ['(', repmat('0', 1, length(n) - 1), m, '/', n, ')'];
           
x = fileparts(filename);

if isempty(x)
    x = filename;
end

h = waitbar(0, ['Loading ../', x, msg], 'name', 'Loading...');
            
end

% ---------------------------------------
% Update Waitbar
% ---------------------------------------
function updateWaitbar(h, i, j, filename)

m = num2str(i);
n = num2str(j);
msg = [' (', repmat('0', 1, length(n) - length(m)), m, '/', n, ')'];

x = fileparts(filename);

if isempty(x)
    x = filename;
end

waitbar(i/j, h, ['Loading ../', x, msg]);

end

% ---------------------------------------
% Status
% ---------------------------------------
function status(varargin)

if ~varargin{1}
    return
end

switch varargin{2}
    
    case 'exit'
        fprintf(['\n', repmat('-',1,50), '\n']);
        fprintf(' EXIT');
        fprintf(['\n', repmat('-',1,50), '\n']);
        
    case 'file_count'
        fprintf([' STATUS  Importing ', num2str(varargin{3}), ' files...', '\n\n']);
        
    case 'file_name'
        fprintf(' %s', varargin{3});
        
    case 'import'
        fprintf(['\n', repmat('-',1,50), '\n']);
        fprintf(' IMPORT');
        fprintf(['\n', repmat('-',1,50), '\n\n']);
        
    case 'java_error'
        fprintf([' STATUS  Unable to load file selection interface...', '\n']);
        
    case 'abort'
        m = num2str(varargin{3});
        n = num2str(varargin{4});
        fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
        fprintf([' File import cancelled...', '\n']);
        
    case 'loading_file'
        m = num2str(varargin{3});
        n = num2str(varargin{4});
        fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
        
    case 'loading_stats'
        fprintf([' (', parsebytes(varargin{3}), ')\n']);
        
    case 'selection_cancel'
        fprintf([' STATUS  No files selected...', '\n']);
        
    case 'selection_error'
        fprintf([' STATUS  No files found...', '\n']);
        
    case 'subfolder_search'
        fprintf([' STATUS  Searching subfolders...', '\n']);
        
    case 'stats'
        fprintf(['\n Files   : ', num2str(varargin{3})]);
        fprintf(['\n Elapsed : ', parsetime(varargin{4})]);
        fprintf(['\n Bytes   : ', parsebytes(varargin{5}),'\n']);
        
end

end

% ---------------------------------------
% FileUI
% ---------------------------------------
function [file, status] = FileUI(file)

% JFileChooser (Java)
if ~usejava('swing')
    status = 2;
    return
end

fc = javax.swing.JFileChooser(java.io.File(pwd));

% Options
fc.setFileSelectionMode(fc.FILES_AND_DIRECTORIES);
fc.setMultiSelectionEnabled(true);
fc.setAcceptAllFileFilterUsed(false);

% Filter: Agilent (.D, .MS, .CH, .UV)
agilent = com.mathworks.hg.util.dFilter;

agilent.setDescription('Agilent files (*.D, *.MS, *.CH, *.UV)');
agilent.addExtension('d');
agilent.addExtension('ms');
agilent.addExtension('ch');
agilent.addExtension('uv');

fc.addChoosableFileFilter(agilent);

% Initialize UI
status = fc.showOpenDialog(fc);

if status == fc.APPROVE_OPTION
    
    % Get file selection
    fs = fc.getSelectedFiles();
    
    for i = 1:size(fs, 1)
        
        % Get file information
        [~, f] = fileattrib(char(fs(i).getAbsolutePath));
        
        % Append to file list
        if isstruct(f)
            file = [file; f];
        end
    end
end

end

% ---------------------------------------
% File verification
% ---------------------------------------
function file = FileVerify(str, file)

for i = 1:length(str)
    
    [~, f] = fileattrib(str{i});
    
    if isstruct(f)
        file = [file; f];
    end
    
end

end

% ---------------------------------------
% Subfolder contents
% ---------------------------------------
function file = parsesubfolder(file, searchDepth, fileType)

searchIndex = [1, length(file)];

while searchDepth >= 0
    
    for i = searchIndex(1):searchIndex(2)
        
        [~, ~, fileExt] = fileparts(file(i).Name);
        
        if any(strcmpi(fileExt, {'.m', '.git', '.lnk'}))
            continue
        elseif file(i).directory == 1
            file = parsedirectory(file, i, fileType);
        end
        
    end
    
    if length(file) > searchIndex(2)
        searchDepth = searchDepth-1;
        searchIndex = [searchIndex(2)+1, length(file)];
    else
        break
    end
end

end

% ---------------------------------------
% Directory contents
% ---------------------------------------
function file = parsedirectory(file, fileIndex, fileType)

filePath = dir(file(fileIndex).Name);
filePath(cellfun(@(x) any(strcmpi(x, {'.', '..'})), {filePath.name})) = [];

for i = 1:length(filePath)
    
    fileName = [file(fileIndex).Name, filesep, filePath(i).name];
    [~, fileName] = fileattrib(fileName);
    
    if isstruct(fileName)
        [~, ~, fileExt] = fileparts(fileName.Name);
        
        if fileName.directory || any(strcmpi(fileExt, fileType))
            file = [file; fileName];
        end
    end
end

end

% ---------------------------------------
% Data = byte string
% ---------------------------------------
function str = parsebytes(x)

if x > 1E9
    str = [num2str(x/1E9, '%.1f'), ' GB'];
elseif x > 1E6
    str = [num2str(x/1E6, '%.1f'), ' MB'];
elseif x > 1E3
    str = [num2str(x/1E3, '%.1f'), ' KB'];
else
    str = [num2str(x/1E3, '%.3f'), ' KB'];
end

end

% ---------------------------------------
% Data = time string
% ---------------------------------------
function str = parsetime(x)

if x > 60
    str = [num2str(x/60, '%.1f'), ' min'];
else
    str = [num2str(x, '%.1f'), ' sec'];
end

end

% ---------------------------------------
% File header
% ---------------------------------------
function data = parseinfo(f, data)

data.file_version = fpascal(f, 0, 'uint8');

if isnan(str2double(data.file_version))
    data.file_version = [];
end

if isempty(data.file_version)
    return
end

switch data.file_version
    
    case {'2', '8', '81', '30', '31'}
        
        data.file_info    = fpascal(f,  4,    'uint8');
        data.sample_name  = fpascal(f,  24,   'uint8');
        data.sample_info  = fpascal(f,  86,   'uint8');
        data.operator     = fpascal(f,  148,  'uint8');
        data.datetime     = fpascal(f,  178,  'uint8');
        data.instmodel    = fpascal(f,  208,  'uint8');
        data.inlet        = fpascal(f,  218,  'uint8');
        data.method_name  = fpascal(f,  228,  'uint8');
        data.seqindex     = fnumeric(f, 252,  'int16');
        data.vial         = fnumeric(f, 254,  'int16');
        data.replicate    = fnumeric(f, 256,  'int16');
        
    case {'130', '131', '179', '181'}
        
        data.file_info    = fpascal(f,  347,  'uint16');
        data.sample_name  = fpascal(f,  858,  'uint16');
        data.sample_info  = fpascal(f,  1369, 'uint16');
        data.operator     = fpascal(f,  1880, 'uint16');
        data.datetime     = fpascal(f,  2391, 'uint16');
        data.instmodel    = fpascal(f,  2492, 'uint16');
        data.inlet        = fpascal(f,  2533, 'uint16');
        data.method_name  = fpascal(f,  2574, 'uint16');
        data.seqindex     = fnumeric(f, 252,  'int16');
        data.vial         = fnumeric(f, 254,  'int16');
        data.replicate    = fnumeric(f, 256,  'int16');
        
end

switch data.file_version
   
    case {'30'}
        
        data.glp_flag     = fnumeric(f, 318,  'int32');
        data.data_source  = fpascal(f,  322,  'uint8');
        data.firmware_rev = fpascal(f,  355,  'uint8');
        data.software_rev = fpascal(f,  405,  'uint8');
    
    case {'130', '179'}
        
        data.glp_flag     = fnumeric(f, 3085, 'int32');
        data.data_source  = fpascal(f,  3089, 'uint16');
        data.firmware_rev = fpascal(f,  3601, 'uint16');
        data.software_rev = fpascal(f,  3802, 'uint16');
        
end

% Units
switch data.file_version
    
    case {'2'}
        
        data.time_units      = 'minutes';
        data.intensity_units = 'counts';
        data.channel_units   = 'm/z';
        
    case {'8', '81', '30'}
        
        data.time_units      = 'minutes';
        data.intensity_units = fpascal(f,  580, 'uint8');
        data.channel_units   = fpascal(f,  596, 'uint8');
        
    case {'31'}
        
        data.time_units      = 'minutes';
        data.intensity_units = fpascal(f, 326, 'uint8');
        data.channel_units   = fpascal(f, 344, 'uint8');
        
    case {'130', '179', '181'}
        
        data.time_units      = 'minutes';
        data.intensity_units = fpascal(f, 4172, 'uint16');
        data.channel_units   = fpascal(f, 4213, 'uint16');
        
        
end

% Channel
switch data.file_version

    case {'8', '81', '179', '181'}
           
        if ~isempty(regexpi(data.file_name, '(FID1A)', 'tokens', 'once'))
            data.channel = 'A';
        elseif ~isempty(regexpi(data.file_name, '(FID2B)', 'tokens', 'once'))
            data.channel = 'B';
        else
            data.channel = '';
        end
                
end

% Parse datetime
if ~isempty(data.datetime)
    data.datetime = parsedate(data.datetime);
end

% Parse instrument
data.instrument = parseinstrument(data);

% Fix formatting
data.instmodel = upper(data.instmodel);
data.inlet     = upper(data.inlet);
data.operator  = upper(data.operator);

end

% ---------------------------------------
% File data
% ---------------------------------------
function data = parsedata(f, data)

if isempty(data.file_version)
    data.file_version = fpascal(f, 0, 'uint8');
end

if isnan(str2double(data.file_version))
    data.file_version = [];
end

if isempty(data.file_version)
    return
end

% Data offset
switch data.file_version
    
    case {'2'}
        
        offset = fnumeric(f, 260, 'int32') * 2 - 2;
        scans  = fnumeric(f, 278, 'int32');
        
    case {'8', '81', '179', '181', '30', '130', '131'}
        
        offset = (fnumeric(f, 264, 'int32') - 1) * 512 ;
        scans  = fnumeric(f, 278, 'int32');
        
        
end

% Time range
switch data.file_version
    
    case {'81', '179', '181'}
        
        t0 = fnumeric(f, 282, 'float32') / 60000;
        t1 = fnumeric(f, 286, 'float32') / 60000;
        
    case {'2', '8', '30', '130'}
        
        t0 = fnumeric(f, 282, 'int32') / 60000;
        t1 = fnumeric(f, 286, 'int32') / 60000;
 
    otherwise
        
        t0 = [];
        t1 = [];
        
end

% Intensity values
switch data.file_version
    
    case {'2'}
        
        data.intensity = farray(f, offset + 8, 'int32', scans, 8);
        data.time      = farray(f, offset + 4, 'int32', scans, 8) ./ 60000;
         
        % Prevent import of full mass spectra scans
        %offset = farray(f, offset, 'int32', scans, 8) * 2 - 2;
        %data   = fpacket(f, data, offset);
        
    case {'8', '30', '130'}
        
        data.intensity = fdelta(f, offset);
        
    case {'81', '181'}
        
        data.intensity = fdoubledelta(f, offset);
        
    case {'179'}
        
        if fnumeric(f, offset, 'int32') == 2048
            offset = offset + 2048;
        end
        
        data.intensity = fdoublearray(f, offset);
        
end

% Time values
switch data.file_version
    
    case {'8', '81', '179', '181', '30', '130', '131'}

        if ~isempty(t0) && ~isempty(t1) && t1 > t0
            data.time = ftime(t0, t1, numel(data.intensity));
        end
        
end

% Scaling
switch data.file_version
    
    case {'8'}
        
        version   = fnumeric(f, 542, 'int32');
        intercept = fnumeric(f, 636, 'float64');
        slope     = fnumeric(f, 644, 'float64');
        
        switch version
            case {1, 2, 3}
                data.intensity = data.intensity .* 1.33321110047553;
            otherwise
                data.intensity = data.intensity .* slope + intercept;
        end
        
    case {'30'}
        
        version   = fnumeric(f, 542, 'int32');
        intercept = fnumeric(f, 636, 'float64');
        slope     = fnumeric(f, 644, 'float64');
        
        switch version
            case {1}
                data.intensity = data.intensity .* 1;
            case {2}
                data.intensity = data.intensity .* 0.00240841663372301;
            otherwise
                data.intensity = data.intensity .* slope + intercept;
        end
        
    case {'81'}
        
        intercept = fnumeric(f, 636, 'float64');
        slope     = fnumeric(f, 644, 'float64');
        
        data.intensity = data.intensity .* slope + intercept;
        
    case {'130'}
        
        version   = fnumeric(f, 4134, 'int32');
        intercept = fnumeric(f, 4724, 'float64');
        slope     = fnumeric(f, 4732, 'float64');
        
        switch version
            case {1}
                data.intensity = data.intensity .* 1;
            case {2}
                data.intensity = data.intensity .* 0.00240841663372301;
            otherwise
                data.intensity = data.intensity .* slope + intercept;
        end
        
    case {'179', '181'}
        
        intercept = fnumeric(f, 4724, 'float64');
        slope     = fnumeric(f, 4732, 'float64');
        
        data.intensity = data.intensity .* slope + intercept;
        
    case {'131'}
        specData = fspectrum(f, offset, scans, 1);
        data.time = [specData.retention_time]';
        data.intensity = [specData.intensity_values]';
        data.channel = specData(1).wavelength_start:specData(1).wavelength_step:specData(1).wavelength_end;
end

% Sampling Rate
if ~isempty(data.time)
    data.sampling_rate = round(1./mean(diff(data.time.*60)), 2);
end

end

% ---------------------------------------
% Data = datetime
% ---------------------------------------
function str = parsedate(str)

% Platform
if exist('OCTAVE_VERSION', 'builtin')
    return
end

% ISO 8601
formatOut = 'yyyy-mm-ddTHH:MM:SS';

% Possible Formats
dateFormat = {...
    'dd mmm yy HH:MM PM',...
    'dd mmm yy HH:MM',...
    'mm/dd/yy HH:MM:SS PM',...
    'mm/dd/yy HH:MM:SS',...
    'mm/dd/yyyy HH:MM',...
    'mm/dd/yyyy HH:MM:SS PM',...
    'mm.dd.yyyy HH:MM:SS',...
    'dd-mmm-yy HH:MM:SS',...
    'dd-mmm-yy, HH:MM:SS'};

dateRegex = {...
    '\d{1,2} \w{3} \d{1,2}\s*\d{1,2}[:]\d{2} \w{2}',...
    '\d{2} \w{3} \d{2}\s*\d{2}[:]\d{2}',...
    '\d{2}[/]\d{2}[/]\d{2}\s*\d{2}[:]\d{2}[:]\d{2} \w{2}',...
    '\d{1,2}[/]\d{1,2}[/]\d{2}\s*\d{1,2}[:]\d{2}[:]\d{2}',...
    '\d{2}[/]\d{2}[/]\d{4}\s*\d{2}[:]\d{2}',...
    '\d{1,2}[/]\d{1,2}[/]\d{4}\s*\d{1,2}[:]\d{2}[:]\d{2} \w{2}',...
    '\d{2}[.]\d{2}[.]\d{4}\s*\d{2}[:]\d{2}[:]\d{2}',...
    '\d{2}[-]\w{3}[-]\d{2}\s*\d{2}[:]\d{2}[:]\d{2}',...
    '\d{2}[-]\w{3}[-]\d{2}[,]\s*\d{2}[:]\d{2}[:]\d{2}'};

if ~isempty(str)
    
    dateMatch = regexp(str, dateRegex, 'match');
    dateIndex = find(~cellfun(@isempty, dateMatch), 1);
    
    if ~isempty(dateIndex)
        dateNum = datenum(str, dateFormat{dateIndex});
        str = datestr(dateNum, formatOut);
    end
    
end

end

% ---------------------------------------
% Data = instrument string
% ---------------------------------------
function str = parseinstrument(data)

instrMatch = @(x,str) any(cellfun(@any, regexpi(x, str)));

str = [...
    data.file_info,...
    data.inlet,...
    data.instmodel,...
    data.channel_units];

if isempty(str)
    return
end

switch data.file_version
    
    case {'2'}
        
        if instrMatch(str, {'CE'})
            str = 'CE/MS';
        elseif instrMatch(str, {'LC'})
            str = 'LC/MS';
        elseif instrMatch(str, {'GC'})
            str = 'GC/MS';
        else
            str = 'MS';
        end
        
    case {'8', '81', '179', '181'}
        
        if instrMatch(str, {'GC'})
            str = 'GC/FID';
        else
            str = 'GC';
        end
        
    case {'30', '31', '130', '131'}
        
        if instrMatch(str, {'DAD', '1315', '4212', '7117'})
            str = 'LC/DAD';
        elseif instrMatch(str, {'VWD', '1314', '7114'})
            str = 'LC/VWD';
        elseif instrMatch(str, {'MWD', '1365'})
            str = 'LC/MWD';
        elseif instrMatch(str, {'FLD', '1321'})
            str = 'LC/FLD';
        elseif instrMatch(str, {'ELS', '4260', '7102'})
            str = 'LC/ELSD';
        elseif instrMatch(str, {'RID', '1362'})
            str = 'LC/RID';
        elseif instrMatch(str, {'ADC', '35900'})
            str = 'LC/ADC';
        elseif instrMatch(str, {'CE'})
            str = 'CE';
        else
            str = 'LC';
        end

end

end

% ---------------------------------------
% Data = pascal string
% ---------------------------------------
function str = fpascal(f, offset, type)

fseek(f, offset, 'bof');
str = fread(f, fread(f, 1, 'uint8'), [type, '=>char'], 'l')';

if length(str) > 512
    str = '';
else
    str = strtrim(deblank(str));
end

end

% ---------------------------------------
% Data = numeric
% ---------------------------------------
function x = fnumeric(f, offset, type)

fseek(f, offset, 'bof');
x = fread(f, 1, type, 'b');

end

% ---------------------------------------
% Data = array
% ---------------------------------------
function x = farray(f, offset, type, count, skip)

fseek(f, offset, 'bof');
x = fread(f, count, type, skip, 'b');

end

% ---------------------------------------
% Data = packet
% ---------------------------------------
function data = fpacket(f, data, offset)

n = [];
y = [];

for i = 1:length(offset)
    
    fseek(f, offset(i)+12, 'bof');
    
    %x(i,1) = fread(f, 1, 'int32', 6, 'b');
    n(i,1) = fread(f, 1, 'int16', 4, 'b');
    y(:,end+1:end+n(i)) = fread(f, [2, n(i)], 'uint16', 'b');
    
end

% Mass values
y(1,:) = y(1,:) ./ 20;

data.channel = unique(y(1,:));

[~, index] = ismember(y(1,:), data.channel);

data.channel = [0, data.channel];

% Intensity values
data.intensity(numel(data.time), numel(data.channel)) = 0;

n(:,2) = cumsum(n);
n(:,3) = n(:,2) - n(:,1) + 1;

e = bitand(int32(y(2,:)), int32(49152));
y = bitand(int32(y(2,:)), int32(16383));

while any(e) ~= 0
    y(e~=0) = bitshift(int32(y(e~=0)), 3);
    e(e~=0) = e(e~=0) - 16384;
end

for i = 1:numel(data.time)
    data.intensity(i, index(n(i,3):n(i,2))+1) = y(n(i,3):n(i,2));
end

end

% ---------------------------------------
% Data = spectrum
% MODIFIED 01/09/21 to work with the .UV files
% ---------------------------------------
function spectrum = fspectrum(f, offset, scans, detector)

spectrum = struct(...
    'offset',                 [],...
    'identifier',            [],...
    'record_length',          [],...
    'retention_time',         [],...
    'wavelength_start',       [],...
    'wavelength_end',         [],...
    'wavelength_step',        [],...
    'spectrum_attribute',     [],...
    'additional_info_length', [],...
    'additional_info',        [],...
    'data_points',            [],...
    'intensity_values',       []...
);

%for i = 1:scans
for i = 1:scans
    
    % Set offset based on predetermined offset from ~line 724 to start
    % with. Then set the offset as the last place the file searched before.
    if i == 1
        fseek(f, offset, 'bof');
    else
    
        fseek(f, spectrum(i-1).offsetEnd, 'bof');
    end
    
    
    if i == 1
        spectrum(i).offset                 = ftell(f); %Current file location
        spectrum(i).identifier            = fread(f, 1, 'int16', 'l');
    else
        % If its not the first time, the current set offset may not
        % directly move on to the next set of data. Therefore it searchs
        % for the location of the 'spectrum identifier' number (which 
        % should be the same as the first one collected) before starting.
        foundPos = 0;
        while foundPos == 0
            % Read a new number
            currInd = fread(f, 1, 'int16', 'l');
            % If this number is equal to the spec identifier
            if currInd == spectrum(1).identifier
                % Set the new offset and current idenifier and end while
                % loop. ASSUMES that it WILL be found, this could cause
                % inf. loops in the future?
                spectrum(i).offset = ftell(f);
                spectrum(i).identifier    = currInd;
                foundPos = 1;
            end
        end
    end
    
    % Now correct location has been found, continue to add data
    spectrum(i).record_length          = fread(f, 1, 'int16', 'l');
    spectrum(i).retention_time         = fread(f, 1, 'int32', 'l')/60000;% Divide by 600000 for conversion into mins
    spectrum(i).wavelength_start       = fread(f, 1, 'int16', 'l')/20; % For some reason wavelngths are 20x larger than they should be
    spectrum(i).wavelength_end         = fread(f, 1, 'int16', 'l')/20;
    spectrum(i).wavelength_step        = fread(f, 1, 'int16', 'l')/20;
    spectrum(i).spectrum_attribute     = fread(f, 1, 'int16', 'l');
    spectrum(i).additional_info_length = fread(f, 1, 'int16', 'l');

    switch detector
        
        case 1
            % DAD: exposure_time
            spectrum(i).additional_info = fread(f, 1, 'int32', 'l');
            
        case 2
            % FLD: complement_wavelength, scan_speed
            spectrum(i).additional_info = fread(f, [1,2], 'int16', 'l');
            
        otherwise
            fseek(f, spectrum(i).additional_info_length, 'cof');
            
    end
    
    
    spectrum(i).data_points = floor(...
        (spectrum(i).wavelength_end - spectrum(i).wavelength_start) / ...
        spectrum(i).wavelength_step + 1);
 
    if spectrum(i).identifier == 65
        
        spectrum(i).intensity_values = fread(f, spectrum(i).data_points, 'int32', 'l');
     
    else  
        
        spectrum(i).intensity_values = zeros(spectrum(i).data_points, 1);
        x = [0,0];
    
        for j = 1:spectrum(i).data_points
    
            x(1) = fread(f, 1, 'int16', 'l');
        
            if x(1) ~= -32768
                x(2) = x(1) + x(2);
            else
                x(2) = fread(f, 1, 'int32', 'l');
            end
        
            spectrum(i).intensity_values(j, 1) = x(2);
        
        end
        
    end
    
spectrum(i).offsetEnd = ftell(f);
end
 
 
end

% ---------------------------------------
% Data = time vector
% ---------------------------------------
function x = ftime(start, stop, count)

if count > 2
    x = linspace(start, stop, count)';
else
    x = [start; stop];
end

end

% ---------------------------------------
% Data = delta compression
% ---------------------------------------
function y = fdelta(f, offset)

fseek(f, 0, 'eof');
n = ftell(f);

fseek(f, offset, 'bof');
y = zeros(floor(n/2), 1);

buffer = [0,0,0,0,0];

while ftell(f) < n
    
    buffer(1) = fread(f, 1, 'int16', 'b');
    buffer(2) = buffer(4);
    
    if bitshift(int16(buffer(1)), -12) ~= 0
        
        for j = 1:bitand(int16(buffer(1)), int16(4095))
            
            buffer(3) = fread(f, 1, 'int16', 'b');
            buffer(5) = buffer(5) + 1;
            
            if buffer(3) ~= -32768
                buffer(2) = buffer(2) + buffer(3);
            else
                buffer(2) = fread(f, 1, 'int32', 'b');
            end
            
            y(buffer(5),1) = buffer(2);
            
        end
        
        buffer(4) = buffer(2);
        
    else
        break
    end
    
end

if buffer(5)+1 < length(y)
    y(buffer(5)+1:end) = [];
end

end

% ---------------------------------------
% Data = double delta compression
% ---------------------------------------
function y = fdoubledelta(f, offset)

fseek(f, 0, 'eof');
n = ftell(f);

fseek(f, offset, 'bof');
y = zeros(floor(n/2), 1);

buffer = [0,0,0,0];

while ftell(f) < n
    
    buffer(4) = buffer(4) + 1;
    buffer(3) = fread(f, 1, 'int16', 'b');
    
    if buffer(3) ~= 32767
        buffer(2) = buffer(2) + buffer(3);
        buffer(1) = buffer(1) + buffer(2);
    else
        buffer(1) = fread(f, 1, 'int16', 'b') * 4294967296;
        buffer(1) = fread(f, 1, 'uint32', 'b') + buffer(1);
        buffer(2) = 0;
    end
    
    y(buffer(4),1) = buffer(1);
    
end

if buffer(4)+1 < length(y)
    y(buffer(4)+1:end) = [];
end

end

% ---------------------------------------
% Data = double array
% ---------------------------------------
function y = fdoublearray(f, offset)

fseek(f, 0, 'eof');
n = floor((ftell(f) - offset) / 8);

fseek(f, offset, 'bof');
y = fread(f, n, 'float64', 'l');

end

