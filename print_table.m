function varargout = print_table(dataCell, varargin) 
%% PRINT_TABLE Print data in a table format (text or latex)
%
% Syntax:
%     PRINT_TABLE(dataTable)
%     PRINT_TABLE(dataCell)
%
%     PRINT_TABLE(__, dataDescCellstr)
%     PRINT_TABLE(__, dataDescCellstr, headerColumnCellstr, headerRowCellstr)
%
%     PRINT_TABLE(__, Name, Value)
%
%     tableStr = PRINT_TABLE(__)
%
% Input:
%     dataTable            - table data to print (see table)
%     dataCell             - cell with data to print (can be numeric matrix)
%
%     dataDescCellstr      - cell with sprintf syntax for elements in data
%                            Note, dataDesc is expanded to the complete table
%                            size if only a single element, row or column
%                            description is supplied. 
%     headerColumnCellstr  - cell array with column header names
%     headerRowCellstr     - cell array with row header name
%
%    Note, if both headerRow/Column are supplied, one can be one element longer
%    than the dimension of the dataCell, the extra element (which should be the
%    first element in the array) is then positioned at the top left corner, i.e.
%
%       |-------|-------|-------| ... |-------|
%       | EXTRA | hCol1 | hCol2 | ... | hColN |  -> Header Columns
%       |-------|-------|-------| ... |-------|
%       | hRow1 | d(1,1)| d(1,2)| ... | d(1,N)|  \
%       |   :        :       :      :      :  |   > Data part of table 
%       | hRowM | d(M,1)| d(M,2)| ... | d(M,N)|  / 
%       |-------|-------|-------| ... |-------|
%          \/
%        Header
%         Rows
%
% Options, supplied as (..., Name, Value) pairs, overrides default values:
%     printHeaderCol = 1   - print header columns (if supplied)
%     printHeaderRow = 1   - print header rows (if supplied)
%     transposeTable = 0   - transpose table compared to input format
%     printMode = 'text'   - print mode, 'text' or 'latex'
%        colSepStr = '|'   - separation string between columns (if 'text')
%        rowSepStr = ''    - separation line character between rows (if 'text')
%        rowHSepStr = '-'  - separation line character between header and data
%        colHSepStr = ''   - extra separation string between col.header and data
%     textAlignment  = 'c' - text alignment in each column (alt. 'l' or 'r')
%     	Note, is possible to supply for each column as string, e.g. 'lcl...cr'.
%     numSpaceColPad = 1   - extra space padding in each column 
%     spaceColPadAlign = 1 - use the extra space padding with the text alignment
%        Note, cosmetic change if we do not want the extra space padding to be
%        included in the aligned text, e.g. 'lText   ' -> ' lText  ', if false
%        and numSpaceColPad = 1 and textAlignment = 'l'.
%     printLatexFull = 1   - add tabular enviroment to latex table format
%     printBorder    = 0   - print simple border around the table (in text mode)   
%       borderRowStr = '-' - border type string, should be single character
%
% Output:
%     Table printed in command window, or 
%     tableStr    - string with output table, preferably printed using fprintf
%
% Comment:
%     Utility function for writing a table in either text mode or latex
%     mode. Generates a table with aligned columns by inserting spaces.
%     Can also print the transposed version of the supplied table data.
%     Provides a variety of options such as adding/removing extra space padding
%     or changing the separation characters.
%
%     Includes three additional utility functions:
%        repmat_as_needed  - repmat data into a specified size
%        rmexpzeroes       - removes unecessary zeroes from exponent string
%        cellstr2str       - concatenates cellstr with some char between parts
%
% Example usage:
%  print_table(1e2.*rand(5,3),{'%.3g'},{'a','b','c'},{'No.','1','2','3','4','5'})
%  No. |   a  |   b  |   c  
% -----|------|------|------
%   1  |  45  | 28.5 | 27.5 
%   2  | 20.6 | 67.3 | 71.7 
%   3  |  90  | 66.4 | 28.3 
%   4  | 76.3 | 12.3 | 89.6 
%   5  | 88.2 | 40.7 | 82.7 
%  print_table(1e2.*rand(5,3),{'%.3g'},{'a','b','c'},{'No.','1','2','3','4','5'},'printBorder',1)
% |-----|------|------|------|
% | No. |   a  |   b  |   c  |
% |-----|------|------|------|
% |  1  |  43  | 10.9 | 22.9 |
% |  2  | 69.4 |  39  | 83.4 |
% |  3  | 94.5 | 59.1 | 1.56 |
% |  4  | 78.4 | 45.9 | 86.4 |
% |  5  | 70.6 | 5.03 | 7.81 |
% |-----|------|------|------|
% print_table(1e2.*rand(5,3),{'%.3g'},{'a','b','c'},{'No.','1','2','3','4','5'},'printMode','latex')
% \begin{tabular}{|c|c|c|c|}\hline
%  No. &   a  &   b  &   c  \\ \hline 
%   1  & 66.9 & 67.1 & 1.96 \\ \hline 
%   2  &  50  &  60  & 43.5 \\ \hline 
%   3  & 21.8 &  5.6 & 83.2 \\ \hline 
%   4  & 57.2 & 5.63 & 61.7 \\ \hline 
%   5  & 12.2 & 15.3 &  52  \\ \hline 
% \end{tabular}
%
% See also fprintf, inputParser, table, table2cell
% repmat_as_needed, rmexpzeros, cellstr2str

%   Created by: Johan Winges
%   $Revision: 1.0$  $Date: 2014/10/06 14:00:00$
%   $Revision: 1.2$  $Date: 2014/10/07 10:00:00$
%     Changed name, added option input format, new options, some error control
%   $Revision: 1.3$  $Date: 2014/10/23 14:00:00$
%     Changed option input format to use inputParser object
%   $Revision: 1.4$  $Date: 2014/10/30 15:00:00$
%     Added textAlignment option for each column, and spaceColPadAlign option
%   $Revision: 1.5$  $Date: 2014/10/31 11:00:00$
%     Added support for table data type input

%% Set default input and parse input:
inpPar = inputParser;
addRequired(inpPar,'dataCell',...
   @(x) validateattributes(x,{'cell','numeric','table'},{'nonempty'}));
addOptional(inpPar,'dataDescCellstr',{'%g'},...   
   @(x) validateattributes(x,{'cell'},{'nonempty'})); 
% Due to bug/feature? in parse, we can not allow an optional parameter to be a
% string. Otherwise, we would change {'cell'} -> {'char','cell'}.
addOptional(inpPar,'headerColumnCellstr',[]);
addOptional(inpPar,'headerRowCellstr',[]);
addParameter(inpPar,'printMode','text',...
   @(x) any(validatestring(x,{'text','latex'})));
addParameter(inpPar,'printHeaderRow',true,...
   @(x) validateattributes(x,{'numeric','logical'},...
        {'nonempty','scalar','binary'}))
addParameter(inpPar,'printHeaderCol',true,...
   @(x) validateattributes(x,{'numeric','logical'},...
        {'nonempty','scalar','binary'}))
addParameter(inpPar,'transposeTable',false,...
   @(x) validateattributes(x,{'numeric','logical'},...
        {'nonempty','scalar','binary'}))
addParameter(inpPar,'colSepStr','|',@ischar);
addParameter(inpPar,'rowSepStr','',@ischar);
addParameter(inpPar,'colHSepStr','',@ischar);
addParameter(inpPar,'rowHSepStr','-',@ischar);
addParameter(inpPar,'textAlignment','c',...
   @(x) all(x=='c' | x=='r' | x=='l'));
addParameter(inpPar,'spaceColPadAlign',true,...
   @(x) validateattributes(x,{'numeric','logical'},...
        {'nonempty','scalar','binary'}))
addParameter(inpPar,'numSpaceColPad',1,...
   @(x) validateattributes(x,{'numeric','logical'},...
        {'nonempty','integer','positive'}))
addParameter(inpPar,'printLatexFull',true,@islogical);
addParameter(inpPar,'printBorder',0,...
   @(x) validateattributes(x,{'numeric','logical'},...
        {'nonempty','scalar','binary'}))
addParameter(inpPar,'borderRowStr','-',@ischar);

% Parse input:
parse(inpPar, dataCell, varargin{:});
%% TODO-> bugged when not supplying optional input?!

% Collect some data from inpPar results:
dataDescCellstr = inpPar.Results.dataDescCellstr;
headerColumnCellstr = inpPar.Results.headerColumnCellstr;
headerRowCellstr = inpPar.Results.headerRowCellstr;

% Remake dataDescCellstr to cell if not cell
if ~iscell(dataDescCellstr)
   dataDescCellstr = {dataDescCellstr};
end

% Check if dataCell is actually in table format:
if istable(dataCell)
   dataTable   = dataCell;
   dataCell    = table2cell(dataTable);   
   % If there is no input for headers, use variable names in table:
   headerRowCellstr     = dataTable.Properties.RowNames;
   headerColumnCellstr  = dataTable.Properties.VariableNames;
   % Generate dataDescCellstr if only specified as single element and not
   % matching the data types in the table:
   if ~( (size(dataDescCellstr,1) == size(dataCell,1)) || ...
         (size(dataDescCellstr,2) == size(dataCell,2)) )
      % Find out data types:
      dataIsNumLog   = cellfun(@(data) all(isnumeric(data)) | ...
         all(islogical(data)), dataCell);
      dataIsChar  = cellfun(@(data) ischar(data), dataCell);
      if ~all(dataIsNumLog(:))
         dataDescCellstr_init = dataDescCellstr;
         dataDescCellstr = cell(size(dataCell));
         dataDescCellstr(dataIsNumLog) = dataDescCellstr_init;
         dataDescCellstr(dataIsChar)   = {'%s'};
      end
   end
end   

% Remake dataCell to cell if numeric:
if isnumeric(dataCell)
   dataCell = num2cell(dataCell);
end

colSepStr = inpPar.Results.colSepStr;
rowSepStr = inpPar.Results.rowSepStr; 
   
%% Set the separation charachters to be used in the table if latex:
if strcmp(inpPar.Results.printMode,'latex')
   colSepStr = '&';
   newLineSepStr = '\\\\ \\hline \n'; 
   % Note, we need to repeat \ signs due to usage of sprintf.
else   
   newLineSepStr = '\n'; 
end

% Print all data in dataCell using dataRowCellstrDesc:
dataCellstr = cellfun(@(dataPart, dataDescStr) ...
   sprintf(dataDescStr, dataPart), dataCell, ...
   repmat_as_needed( dataDescCellstr, size(dataCell) ), 'un', 0);

% Fix exponent display:
dataCellstr = cellfun(@(str) ... 
   rmexpzeros(str, inpPar.Results.printMode), dataCellstr,'un',0);

% Add header if it should be printed:

% Expand dataCellStr to encompas header row/column:
if ~isempty(headerRowCellstr) && inpPar.Results.printHeaderRow
   dataCellstr = cat(2, cell(size(dataCellstr,1), 1), dataCellstr);
end
if ~isempty(headerColumnCellstr) && inpPar.Results.printHeaderCol
   dataCellstr = cat(1, cell(1, size(dataCellstr,2)), dataCellstr);
end
% Add supplied header strings:
if ~isempty(headerRowCellstr) && inpPar.Results.printHeaderRow
   dataCellstr( (size(dataCellstr,1)-length(headerRowCellstr)+1):end,1)...
      = headerRowCellstr;
end
if ~isempty(headerColumnCellstr) && inpPar.Results.printHeaderCol
   dataCellstr(1, (size(dataCellstr,2)-length(headerColumnCellstr)+1):end) = ...
      headerColumnCellstr;
end
% Note, we allow for too short headers.

% Add empty string to left corner if not specified:
if isempty(dataCellstr{1})
   dataCellstr{1} = '';
end

% Transpose table if specified
if inpPar.Results.transposeTable
   dataCellstr = dataCellstr.';
end

% Check textAlignment:
if length(inpPar.Results.textAlignment) == 1
   tmp_textAlignment = inpPar.Results.textAlignment(ones(1,size(dataCellstr,2)));
elseif length(inpPar.Results.textAlignment) == size(dataCellstr,2)
   tmp_textAlignment = inpPar.Results.textAlignment;   
elseif length(inpPar.Results.textAlignment) == size(dataCellstr,2) - 1 && (...
      (inpPar.Results.transposeTable && ~isempty(headerColumnCellstr) ...
      && inpPar.Results.printHeaderCol ) || ( ...
         ~isempty(headerRowCellstr) && inpPar.Results.printHeaderRow && ...
         ~inpPar.Results.transposeTable ) )
   tmp_textAlignment = ['c', inpPar.Results.textAlignment];
else
   if (~isempty(headerColumnCellstr) && inpPar.Results.printHeaderCol && ...
         inpPar.Results.transposeTable ) || ( ...
         ~isempty(headerRowCellstr) && inpPar.Results.printHeaderRow && ...
         ~inpPar.Results.transposeTable )
      strExtra = sprintf(' (or %d)',size(dataCellstr,2)-1);
   else
      strExtra = '';
   end   
   warning(['The supplied textAlignemnt string has %d columns, expected ' ...
      '%d%s number of columns. Check if the table is transposed. ' ...
      'Using the first columns value for all columns.'], ...
      length(inpPar.Results.textAlignment), size(dataCellstr,2), strExtra);
   tmp_textAlignment = inpPar.Results.textAlignment(ones(1,size(dataCellstr,2)));
end


% If latex is specified, repeat any \ sign twice, as it should PROBABLY not be
% used as an escape charachter (unless it is already repeated!):
if strcmp(inpPar.Results.printMode,'latex')
%    dataCellstr = cellfun(@(str) strrep(str,'\','\\'), dataCellstr,'un',0);
   dataCellstr = cellfun(@(str) ...
      regexprep(str,'(?<!\\)\\(?!\\)','\\\\'), dataCellstr,'un',0);   
end

% Compute lengths of each column in the dataCellstr:
dataCellstrLength = cellfun(@(str) length(sprintf(str)), dataCellstr);

% Find maximum length in each column:
if inpPar.Results.spaceColPadAlign
   columnMaxLength   = max(dataCellstrLength,[],1) + ...
      2*inpPar.Results.numSpaceColPad;
else
   columnMaxLength   = max(dataCellstrLength,[],1);
end

% Find number of spaces to pad each cell with:
numSpacePad = bsxfun(@minus, columnMaxLength, dataCellstrLength );

% Pad with spaces depending on textAlignment
for iCol = 1:length(tmp_textAlignment)
   if tmp_textAlignment(iCol) == 'r' % inpPar.Results.textAlignment == 'r'
      % Pad to the left
      dataCellstr(:,iCol) = cellfun(@(str, spaceNum) ...
         [repmat(' ',1,spaceNum), str], ...
         dataCellstr(:,iCol), num2cell(numSpacePad(:,iCol)), 'un', 0);
   elseif tmp_textAlignment(iCol) == 'l' % inpPar.Results.textAlignment == 'l'
      % Pad to the right
      dataCellstr(:,iCol) = cellfun(@(str, spaceNum) ...
         [str, repmat(' ',1,spaceNum)], ...
         dataCellstr(:,iCol), num2cell(numSpacePad(:,iCol)), 'un', 0);
   elseif tmp_textAlignment(iCol) == 'c' % inpPar.Results.textAlignment == 'c'
      % Pad equal amount to the left and right:
      dataCellstr(:,iCol) = cellfun(@(str, spaceNum) ...
         [repmat(' ',1,ceil(0.5*spaceNum)), ...
         str, repmat(' ',1,floor(0.5*spaceNum))], ...
         dataCellstr(:,iCol), num2cell(numSpacePad(:,iCol)), 'un', 0);   
   end
end
   
% Put space padding on both sides equal to numColSpacePad:
if ~inpPar.Results.spaceColPadAlign && inpPar.Results.numSpaceColPad > 0
   dataCellstr = cellfun(@(str) ...
      [ repmat(' ', 1, inpPar.Results.numSpaceColPad), ...
      str, repmat(' ', 1, inpPar.Results.numSpaceColPad)], ...
      dataCellstr, 'un', 0);         
   % Update maximum length in each column with extra padding:
   columnMaxLength   = columnMaxLength + 2*inpPar.Results.numSpaceColPad;
end

% Add header/data separation line if in text mode:
if strcmp(inpPar.Results.printMode, 'text')
   if inpPar.Results.printHeaderCol && ...
         (~inpPar.Results.transposeTable && ~isempty(headerColumnCellstr) || ...
         (inpPar.Results.transposeTable && ~isempty(headerRowCellstr) ) )
      dataCellstr = cat(1, dataCellstr(1,:), ...
         arrayfun(@(num) repmat(inpPar.Results.rowHSepStr,1,num),...
         columnMaxLength,'un',0), dataCellstr(2:end,:));
   end
   if inpPar.Results.printHeaderRow && ...
         (~inpPar.Results.transposeTable && ~isempty(headerRowCellstr) || ...
         (inpPar.Results.transposeTable && ~isempty(headerColumnCellstr) ) )
      dataCellstr(:,1) = cellfun(@(str) [str inpPar.Results.colHSepStr], ...
         dataCellstr(:,1),'un',0);
   end
end

% Add row separation lines if specified:
if ~isempty(rowSepStr) && strcmp(inpPar.Results.printMode,'text')
   dataCellstrExt = cell(size(dataCellstr)+[size(dataCellstr,1)-1,0]);
   dataCellstrExt(1:2:end,:) = dataCellstr;
   tmpRowSepLines = arrayfun(@(numChar) ...
      repmat(rowSepStr, 1, numChar),columnMaxLength,'un',0);
   if inpPar.Results.printHeaderCol && ...
         (~inpPar.Results.transposeTable && ~isempty(headerColumnCellstr) || ...
         (inpPar.Results.transposeTable && ~isempty(headerRowCellstr) ) )
      dataCellstrExt([2,4],:) = [];
      dataCellstrExt(4:2:end,:) = repmat(tmpRowSepLines,size(dataCellstr,1)-3,1);
   else      
      dataCellstrExt(2:2:end,:) = repmat(tmpRowSepLines,size(dataCellstr,1)-1,1);
   end
   dataCellstr = dataCellstrExt;
end

% Add a border around the table:
if strcmp(inpPar.Results.printMode,'text') && inpPar.Results.printBorder   
   % Create extended table with border around:
   dataCellstrExt = cell(size(dataCellstr)+[2,2]);
   dataCellstrExt(2:end-1, 2:end-1) = dataCellstr;
   dataCellstrExt(1,2:end-1)   = arrayfun(@(numChar) ...
      repmat(inpPar.Results.borderRowStr, 1, numChar),columnMaxLength,'un',0);
   if inpPar.Results.printHeaderRow && ...
         (~inpPar.Results.transposeTable && ~isempty(headerRowCellstr) || ...
         (inpPar.Results.transposeTable && ~isempty(headerColumnCellstr) ) )      
      dataCellstrExt(1,2)   = {[dataCellstrExt{1,2} inpPar.Results.colHSepStr]};
   end   
   dataCellstrExt(end,2:end-1) = dataCellstrExt(1,2:end-1);   
   dataCellstr = dataCellstrExt;
end

% Generate strings for each row using cellstr2str:
dataCellstrRow = arrayfun(@(idxRow)  cellstr2str(dataCellstr(idxRow,:), ...
   colSepStr), 1:size(dataCellstr,1), 'un', 0);

% Generate strings for full table, break lines etc:
dataCellstrTable = cat(1, dataCellstrRow,...
   repmat({newLineSepStr}, size(dataCellstrRow)) );


% Create the complete table string:
tableStr = sprintf(cat(2, dataCellstrTable{:}));

% Check if latex and if we should add tabular enviroment to string;
if strcmp(inpPar.Results.printMode,'latex')    
   if  inpPar.Results.printLatexFull
   % Generate \tabular enviroment to the table
   tmpColSep = cat(1,tmp_textAlignment,repmat('|',1,length(tmp_textAlignment)));
   numColStr         = [ '{|' tmpColSep(:).' '}'];
   beginTabularStr   = sprintf( '\\begin{tabular}%s\\hline\n', numColStr);
   endTabularStr     = sprintf( '\\end{tabular}\n');
   tableStr = cat(2,beginTabularStr,tableStr,endTabularStr);
   end
   % If latex is specified, repeat any \ sign again twice:
   tableStr = strrep(tableStr,'\','\\');
   % Note, this is to ensure that 'fprintf(1, tableStr)' works.
end



% Print table if no output is asked for:
if nargout >= 1
   varargout{1} = tableStr;
else
   fprintf(1,tableStr);
end

function repData = repmat_as_needed(dataPart, repDataSize)
%% REPMAT_AS_NEEDED Repeat data in dataPart to match repDataSize if possible
% Syntax:
%     repData = REPMAT_AS_NEEDED(dataPart, repDataSize)
%     
% Comment:
%     Repeats data up repDataSize unless it is already of the correct size.

%   Created by: Johan Winges
%   $Revision: 1.0$  $Date: 2014/10/07 9:00:00$

% Check size difference between dataPart and repDataSize, repeat up to size:
dataSize    = size(dataPart);
dataSizeExt = ones(1,length(repDataSize));
dataSizeExt(1:length(dataSize)) = dataSize;
numRepDim   = repDataSize./dataSizeExt;
if all( (abs(round(numRepDim)-numRepDim)) <= eps('double') )
   repData     = repmat(dataPart, round(numRepDim));
else
   error('repmat_as_needed:invalidInput',...
      'The supplied dataPart and repDataSize have incompatible sizes')
end

function str = rmexpzeros(str, printMode)
%% RMEXPZEROS Remove extra zeroes after exponent string (i.e. 1.1e+01 remove 0)
%
% Syntax:
%     str = RMEXPZEROS(str, ( printMode='text' ) )
%     
% Comment:
%     Removes zero padding in strings containing exponent expressions on the
%     form e+/- or E+/-.  Completely removes e/E if double zeros.
%     If printMode = 'latex', repaces e+/- with ${\times}10^$
% 

%   Created by: Johan Winges
%   $Revision: 1.0$  $Date: 2012/?/? 00:00:00$
%   $Revision: 2.0$  $Date: 2014/10/06 13:00:00$
%     Cleaned function script and comments, added latex printMode

if nargin <=1 
   printMode = 'text';
end

if strcmp(printMode,'text')
   
   str = strrep(str,'e+00','');
   str = strrep(str,'e+0','e+');
   str = strrep(str,'e-00','');
   str = strrep(str,'e-0','e-');

   str = strrep(str,'E+00','');
   str = strrep(str,'E+0','E+');
   str = strrep(str,'E-00','');
   str = strrep(str,'E-0','E-');
   
elseif strcmp(printMode,'latex')   
   
   str = strrep(str,'e+00','');
   [startIndex, endIndex]  = regexp(str,'[eE][+](0*)');
   if ~isempty(startIndex)      
      if strcmp(str(1:startIndex-1),'1')
         str = ['$10^{' str(endIndex+1:end) '}$'];
      else
         str = ['$' str(1:startIndex-1) ... 
            '{\\times}10^{' str(endIndex+1:end) '}$'];
      end
   end
   [startIndex,endIndex]  = regexp(str,'[eE][-](0*)');
   if ~isempty(startIndex)      
      if strcmp(str(1:startIndex-1),'1')
         str = ['$10^{-' str(endIndex+1:end) '}$'];
      else
         str = ['$' str(1:startIndex-1) ...
            '{\\times}10^{-' str(endIndex+1:end) '}$'];
      end
   end
end

function str = cellstr2str(cellstr, separationStr, numericConversionStr)
%% CELLSTR2STR Convert a cellstring to a single string with a separation string
%
% Syntax:
%     str = cellstr2str(cellstr, separationStr)
%     str = cellstr2str(numericArray, separationStr, numericConversionStr)
%
% Comment:
%     Utility function for writing a cellstr as a single string.
%     Can also convert a numeric array to a string.
%     Main purpose is add separation charachter between the parts of the
%     cellstr.

%   Created by: Johan Winges
%   $Revision: 1.0$  $Date: 2012/?/? 00:00:00$
%   $Revision: 2.0$  $Date: 2014/10/06 13:00:00$
%     Complete overhaul of function

% Default separationStr
if (nargin <= 1)
   separationStr = ' ';
end
% Default numericConversionStr
if nargin <= 2
   numericConversionStr = '%g';
end

% Numeric input array:
if ~iscell(cellstr)
   % Convert numeric array to cellstr:
   cellstr = cellfun(@(innum) num2str(innum, numericConversionStr),...
      num2cell(cellstr),'un',0);
end

% Concatenate into output:
cellstr        = cellstr(:).';
len_cs         = length(cellstr);
cellsty        = cat(2, repmat( { separationStr }, [1, len_cs-1]), {''});
cellstr_merge  = cat(1, cellstr, cellsty );
str            = cat(2, cellstr_merge{:} ) ;
