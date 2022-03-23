function [chromatogram, file, error] = waitForChromatogram(filename, currentFiles, firstLoop)

loop = true; % Flag to end the loop when a file is detected
chromatogram = cell(1,2); % Predifine the chromatogram
error = 0;

% Loop checks if a new file is added to a folder. If it is, it checks if it
% ends in '.D' and attempts to read it. The data is added to a cell and
% analysis is performed on it.

% Checks the file to see if the folder is empty. If it is not, displays a message
% requesting it is emptyed before starting the loop.
olddir = findFilesEndingWith(filename, ".D");

if length(olddir) >= 1 && firstLoop == true
    file = "";
    loop = false;
    error = 1; % Folder is not empty.
end

while loop
    pause(5); % Wait for 5 seconds to ease the processing power
    newdir = findFilesEndingWith(filename, ".D"); % Lists the files ending with ".D" 
   
    % Checks to see if the two matrices are equal. If not, a new file has
    % been added.
    if ~isequal(newdir, olddir) 
        
        % Extracts the new files added to the folder.
        matchedFiles = zeros(1, length(newdir));
        % Loops through the new file names too see which files match
        for y = 1:length(newdir)
            if (sum(currentFiles == newdir(y))>0)
                matchedFiles(y) = 1;
            end
        end
        
        % Turns the numerical array into a logical array and removes 
        % the files that matched with those in currentFiles. 
        matchedFiles = logical(matchedFiles);
        newdir(matchedFiles) = [];
        file = newdir(1); % Only returns the first spectra name if mutiple are detected at once
        
        if length(newdir) > 1
           error = 2; % Should only read one file at a time, raise error.
        end
            
        data = importAgilent("file", filename + newdir(1), 'verbose', 'off'); % Imports the data
        data = {data.channel_units; data.time; data.intensity}'; % Simplifies the table and converts it to a cell

        % Process the data given the conditions
        chromatogram(1,1) = {processChromatogram(data, [0.5,0.5,5,1e-04],[1e11,1e-04,1,1e-04], 0.1, 1, 1)};

        % Adds the response vairables to a cell with the chromatogram data
        chromatogram(1,2) = {responseVariables(chromatogram{1,1}, 3, 1.5, 0, 0.6)};

        loop = false; % Ends the loop and returns to the main function

    end
end

end


function fileNamesEnding = findFilesEndingWith(folderName, fileEnd)
%% Returns all the files in a directory ending in the given extention.
    
    % Sets the current directory
    directory = dir(folderName);
    
    % Lists the current files in the directory an pre-defines the new array
    % containing the names of each file as a string
    allFileNames = {directory.name};
    fileNamesEnding = string();
    
    % Turns allFileNames which is a cell array into the string array 
    % fileNamesEnding
    for y = 1:length(allFileNames)
        fileNamesEnding(y) = allFileNames{y};
    end
    
    % Isolate all the file names with the given extension.
    fileNamesEnding = fileNamesEnding(endsWith(fileNamesEnding, fileEnd));
end