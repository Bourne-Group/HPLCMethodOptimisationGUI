%% This function calculates the critical resolution, time the last peak
%% eluted and the number of peaks and combines them into a weighted
%% response function.
% This works by scanning all the previous chromograms and peaks
% detected to calculate the maximum and minimum possible values of the
% RsCrit, method time and number of peaks. The actual values are then
% calculated for the current experiment and the number is scaled between 0
% and 1 based on the min/max values. The scaled RsCrit, method time and
% number of peak values are then combined into a weighted response where 0
% is good separation and 1 is poor separation. The optimisation algorithm
% will try to minimise the result.
 
function resp = responceCombFunc1(peaksData, voidTime, skew, currExp, wavelength)
    
    % Extracts the peaks table given the current experiment and wavelength.
    if length(wavelength) == 1
        peaks = peaksData{currExp,5}{:, wavelength};
    else
        peaks = extractMaxWavelenInten(wavelength, peaksData, currExp);
    end
    
    % If peaks have been detected, this code removes peaks that are too
    % close to the solvent front. Any peaks that is before the solvent peak
    % time + a skew will be ignored in analysis as it is bad HPLC practise.
    
    if ~isempty(peaks)
        peaks = peaks(peaks(:,2)>(voidTime*skew),:);
    end
    
    % If no peaks are detected, then set the critical resolution, peak
    % number and method times to their max values.
    if isempty(peaks)
        peakNumb = 0; % Max possible peak number (more negative = better)
        rsCrit = 2; % Max possible value that RsCrit can be
        
        % Takes the chromatogram and finds the maximum possible time from the
        % data to set as the overall max method time. This can change with each
        % iteration of the algorithm so each datapoint previously run needs
        % to be reprocessed.
        maxTimes = cell2mat(cellfun(@max, peaksData(:,2), 'UniformOutput', false));
        methodTime = max(maxTimes(:,1)); % Max possible value of method time
    
    % If peaks are detected then the RsCrit, method time and peak number
    % can be calcluated
    else   
        % Calculates the retention time by taking into account the void time
        % (solvent front).
        rt = peaks(:,2)-voidTime;
        % Peak widths at half height, therefore as they are modelled as
        % Gaussian peaks to get the standard deviation (peak width at base)
        % do width*2.355.
        width = peaks(:,4)*2.355;
        
        %Number of peaks detected (negative value as algorithm tries to
        %minimise)
        peakNumb = -length(rt);
        % Max method time which relates to the time the last peak eluted.
        methodTime = max(peaks(:,2));
    
        % If only one peak detected, set the RsCrit to whatever the
        % retention time is divided by the width, then minus 2 and take the
        % negative value.
        if peakNumb == -1      
            % This gives the Rscrit between the one detected peak and the
            % solvent front, minus 2 for the Rscrit limit and then take the
            % negative of this value so the algorithm maximises for peak
            % distance.
            rsCrit = -((2*rt/width) - 2);
      
        else
            % Calculates the number of possible pair arrangements between each
            % peak recorded. E.g. for 4 peaks there would be 6 possible peak
            % arrangements: R12, R13, R14, R23, R24 and R34.
            peakLabels = numbOfArrangements(abs(peakNumb));
 
            % Pre-defines resolutions that will contain all the Rs values
            rS = zeros(1, size(peakLabels,1));
 
            % Loops through each possible peak pair combination and calculates the
            % Rs value of those peaks.
            for row = 1:size(peakLabels,1)
 
                % predefine the index to make it easier to understand
                peak1 = peakLabels(row, 1);
                peak2 = peakLabels(row, 2);
 
                % Calculate the Rs value using the equation:
                % 2*(Rt2-Rt1)/(W2+W1)
                rS(row) = 2.*(rt(peak2)-rt(peak1))./(width(peak2)+width(peak1));
            end
            
            % Subtract 2 so that the critical resolution is zero when it is
            % at 2. Then take the negative. The more negative the Rscrit
            % the greater the separation. Any value greater than 0 means
            % peak overlap is occurring which is bad.
            rsCrit = -(min(rS)-2);      
        end
    end
    
    % Takes all the chromatograms and finds the maximum possible time from the
    % data to set as the overall max method time. This can change with each
    % iteration of the algorithm so each datapoint previously run needs
    % to be reprocessed.
    maxTimes = cell2mat(cellfun(@max, peaksData(:,2), 'UniformOutput', false));
    maxmethodTime = max(maxTimes(:,1)); % Max possible value of method time
    minmethodTime = voidTime*skew;
    
    % The largest possible RsCrit value is 2 (perfect overlap).
    % The smallest RsCrit value uses the void time using an arbitrary 
    % width value (0.2)
    maxrsCrit = 2;
    %minrsCrit = -(((2*(maxmethodTime -(voidTime*skew)))/0.2)-2);
    % Want seperation to be large but a value that is greater than -2
    % already means very good speration. A good value to play around with!
    minrsCrit = 0;
    
    % Gets the largest possible peak number from all the chromatograms and 
    % takes the negative value of it (as we want to minimise)
    maxpeakNumb = 0;
    %minpeakNumb = -max(cellfun(@(x) size(x,1), peaksData(:,7)));
    minpeakNumb = -10;
    
    % Now take the actual values and normalise them so that they are between
    % 0 and 1    
    methodTime = (methodTime-minmethodTime)/(maxmethodTime-minmethodTime);
    rsCrit = (rsCrit-minrsCrit)/(maxrsCrit-minrsCrit);
    % Set any value of rscrit that is less than 0 equal to 0.
    if rsCrit < 0
        rsCrit = 0;
    end
    peakNumb = (peakNumb - minpeakNumb)/(maxpeakNumb-minpeakNumb);
 
    % Combine into a single response using weightings. Here the number of
    % peaks is most important, followed by the critical resolution of the
    % peaks and then the method time. 
    resp = (0.6*peakNumb) + (0.3*rsCrit) + (0.1*methodTime);
end

