%% Function returns time of the last peak detected based on the peaks table
function maxTime = responceMaxTime(peaksData, voidTime, skew, currExp, wavelength)
    
    % Extracts the peaks table given the current experiment and wavelength.
    if length(wavelength) == 1
        peaks = peaksData{currExp,5}{:, wavelength};
    else
        peaks = extractMaxWavelenInten(wavelength, peaksData, currExp);
    end
    
    % If there are no peaks detected, it takes the total time of the 
    % chromatogram and uses this as the maximum time.
    if isempty(peaks)
        % Finds maximum time and intensity values from the chromatogram
        % data.
        maxTimes = cell2mat(cellfun(@max, peaksData(:,2), 'UniformOutput', false));
        maxTime = max(maxTimes); % Finds the maximum time value
    else
       
        % If peaks have been detected, this code removes peaks that are too
        % close to the solvent front. Any peaks that are before the solvent peak
        % time + a skew will be ignored in analysis as it is bad HPLC practise.
        peaks = peaks(peaks(:,2)>(voidTime*skew),:);
        
        % Takes all the chromatograms and finds the maximum possible time from the
        % data to set as the overall max method time. This can change with each
        % iteration of the algorithm so each datapoint prevously run needs
        % to be reprocessed.
        if isempty(peaks)
            % Finds maximum time and intensity values from the chromatogram
            % data.
            maxTimes = cell2mat(cellfun(@max, peaksData(:,2), 'UniformOutput', false));
            maxTime = max(maxTimes); % Finds the maximum time value
        else
            
            % If there are peaks remaining, return the largest time value of
            % all the peaks.
            maxTime = max(peaks(:,2));
        end
    end
end