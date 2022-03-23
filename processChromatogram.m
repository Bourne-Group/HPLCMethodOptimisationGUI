function allData = processChromatogram(data, smoothParams, ...
        baselineParams, intInterval, minArea, maxWidth)
    % Takes the raw data in the cell format with columns [name, time,
    % intensity] in that order, as well as the smoothing
    % function parameters: [smoothness, asymmetry, iterations, gradient],
    % baseline parameters: [smoothness, asymmetry, iterations, gradient],
    % and the intergration interval and min area. 
    
    
    % Converts cell to a table to make it easier to understand which part
    % of the cell is being accessed.
    data = cell2table(data, "VariableNames", ["name", "time", "intensity"]);
    
    % Loops through each recorded wavlength of the spectra and applies the
    % smoothing function and baseline correction.
    for detector = 1:height(data)
    

        % Baseline correction (Created by James Dillon)
        b = baseline(data{detector, "intensity"}{:}, 'smoothness', ...
        baselineParams(1), 'asymmetry',baselineParams(2), 'iterations', ...
        baselineParams(3), 'gradient',baselineParams(4));

        %Subracts calculated baseline from the raw data.
        data{detector, "intensity"}{:} = data{detector, "intensity"}{:} - b;

    end
    
    % Adds the processed spectra data too a cell to be returned by the
    % function.
    allData = table2cell(data);
    
    % Loops through each of the recorded wavlengths and finds the peaks,
    % before intergrating them/
    for detector = 1:height(data)
        
        % If the row is empty, then skip to the next one.
        if isempty(data{detector, "time"}{:})
            continue
        end
        
        % Sets the stepping interval for the intergration
        x = 0:intInterval:data{detector, "time"}{:}(end);
        peakFind = zeros(length(x),2); % Pre-define the matrix that contains the found peaks
        
        % Loops through the stepping interval to find peaks at the given
        % center.
        for y = 1:length(x)
            % Uses a algorithm to find the peaks (Created by James Dillon)
            peak = peakfindEGH(data{detector, "time"}{:}, data{detector, ...
            "intensity"}{:}, 'center', x(y), 'width', 0.2);
            
            % Adds the peak's center and width to the array and rounds them
            % to 4 decimal places.
            peakFind(y,:) = [round(peak.center(1),2), round(peak.width(1),2)];
        end
        
        % Extracts the unique rows from the found peaks to avoid
        % intergrating the same peaks multiple times.
        peakFind = unique(peakFind, 'rows');
        
        % Convert the found peaks to a table to make the code easier to read
        peakFind = array2table(peakFind,'VariableNames', ["center","width"]);

        peakData = zeros(height(peakFind),4); % Pre-define the matrix that contains info on the intergrated peaks
        for y = 1:height(peakFind)
            
            % Uses a algorithm to fit the peaks to a EGH curve to calculate the area (Created by James Dillon)
            peakFit = peakfitEGH(data{detector, "time"}{:},data{detector, "intensity"}{:}, 'width', peakFind.width(y),'center', peakFind.center(y), 'minarea', minArea);
            % Adds the time, width, height and area data of each peak to
            % the array.
            peakData(y,:) = [peakFit.time,round(peakFit.width,2), round(peakFit.height,2),round(peakFit.area,2)];
        end
        
        % A final sort of the array to avoid duplication
        peakData = unique(peakData, 'rows');
        
        % Appears to always be a peak at time = 0 with 0 width and hight.
        % If it detects this, remove it.
        if peakData(1) == 0
            peakData(1,:) = [];
        end
        
        % Removes peaks of widths 0 and those greater than the defined
        % maximum
        peakData(or(peakData(:, 2) == 0, peakData(:, 2)>maxWidth),:) = [];
        
        % Adds the processed data to end of the cell to be returned by the
        % function.
        allData(detector,4) = mat2cell(peakData,size(peakData,1));
    end
    
end


