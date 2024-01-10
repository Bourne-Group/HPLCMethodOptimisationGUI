function peaksList = extractMaxWavelenInten(wavelengths, peaksData, currExp)
    tol = 0.005;

    peaksDataLimitsInd = (peaksData{currExp,3}>=min(wavelengths)) & (peaksData{currExp,3}<=max(wavelengths));
    peaksDataLimits = peaksData{currExp, 5}(peaksDataLimitsInd);
    if length(wavelengths) == 1 && wavelengths >= 190
        peaksList = peaksDataLimits{1,1};
        peaksList(:,6) = wavelengths;
    elseif length(wavelengths) == 1 && wavelengths < 190
        peaksList = peaksData{currExp, 5}{:}
        peaksList(:,6) = wavelengths;
    else
    
    interval = wavelengths(2)-wavelengths(1);

    peaksList = []; % [time, intensity, width, area, wavelength]

    for currentPeaks = 1:length(peaksDataLimits)
        % Round times to 2 dp to identify same
        % peaks within tolerences
        timesUnique = peaksDataLimits{currentPeaks}(:,2);
        intensities = peaksDataLimits{currentPeaks}(:,3);

        % See if there are any new items to be
        % added
        if isempty(peaksList)
            % on first iteration the list is empty,
            % so add everything
            indOfNewPeaks = true(length(timesUnique),1);
        else
            % Find the times in the current list
            % that are not new
            indOfNewPeaks = ~ismembertol(timesUnique, peaksList(:,1), tol);
        end

        % Add the data to the end of the list if
        % there are new data points
        if nnz(indOfNewPeaks) ~= 0
            peaksList = [peaksList; peaksDataLimits{currentPeaks}(indOfNewPeaks,2),...
                peaksDataLimits{currentPeaks}(indOfNewPeaks,3), peaksDataLimits{currentPeaks}(indOfNewPeaks,4),...
                peaksDataLimits{currentPeaks}(indOfNewPeaks,5), ones(nnz(indOfNewPeaks),1)*(min(wavelengths) + interval*(currentPeaks-1))];
        end

        % If a current time does exist, then check if the
        % intensity is higher (opposite of the
        % index of new peaks) and replace it if it
        % is
        indCompPeaks = ~indOfNewPeaks;
        % Only loop if a new peak has been detected
        if nnz(indCompPeaks) > 0
            % Compare each of the new times one by
            % one
            for currentComp = 1:nnz(indCompPeaks)
                % Only execute if this is a peak of
                % interest
                if indCompPeaks(currentComp) == 1
                    % Find the location (index) of
                    % the peak
                    location = find(ismembertol(peaksList(:,1),timesUnique(currentComp), tol));
                    %location = find(ismembertol(peaksList(:,1),timesUnique(currentComp)));
                    
                    % If intensity is larger then
                    % replace it with this new
                    % wavelength. If there are more than within the tolernece
                    % replace all of them with this new single value
                    if intensities(currentComp) > peaksList(location, 2)
                        peaksList(location,:) = ones(length(location), size(peaksDataLimits{currentPeaks},2)) .* [peaksDataLimits{currentPeaks}(currentComp,2),...
                            peaksDataLimits{currentPeaks}(currentComp,3), peaksDataLimits{currentPeaks}(currentComp,4),...
                            peaksDataLimits{currentPeaks}(currentComp,5), wavelengths(currentPeaks)];
                        
                        % Removes any duplicates if any
                        [~,indDupe] = unique(peaksList(:,1));
                        peaksList = peaksList(indDupe,:);
                    end
                end
            end
        end
    end
    
    % Sort the rows based on time in assending order
    peaksList = sortrows(peaksList, 1);
    % Label each peak from 1 to the number of peaks and set as first row
    labels = 1:size(peaksList,1);
    peaksList = [labels' peaksList];
    end
end


