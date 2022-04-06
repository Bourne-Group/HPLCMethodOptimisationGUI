%% This function calculates the critical resolution of a given set of peaks.
% This is smallest distance between all the possible pairs of peaks. It is
% calculated using the resolution equation: 2*(Rt2-Rt1)/(W1+W2) where Rt is
% the retention time and W is the width of peaks 1 and 2. The desired
% distance between the peaks is 2 (1.5 = perfect separation so slightly
% higher than this to account for some error). The separation between the
% two peaks is to be maximised to ensure that they are well separated.
% Therefore the Rscrit value is better when it is more negative (as the
% algorithms aim to minimise not maximise). Two is subtracted to make it so
% that any Rscrit value less than 0 is good. Whereas if it is greater than
% 0, peak overlap is occurring which is bad.
 
function rsCrit = responceRscrit(peaksData, voidTime, skew, currExp, wavelength)
    
    % Extracts the peaks table given the current experiment and wavelength.
    if length(wavelength) == 1
        peaks = peaksData{currExp,5}{:, wavelength};
    else
        peaks = extractMaxWavelenInten(wavelength, peaksData, currExp);
    end
    
    % If peaks have been detected, this code removes peaks that are too
    % close to the solvent front. Any peaks that are before the solvent peak
    % time + a skew will be ignored in analysis as it is bad HPLC practise.
    if ~isempty(peaks)
        peaks = peaks(peaks(:,2)>(voidTime*skew),:);
    end
    
    % If no peaks are detected, then set the critical resolution to the max
    % value it can possibly be (0 in this instance). The smaller the
    % Rscrit, the more the peaks are separated.
    if isempty(peaks)
        rsCrit = -log(0.01);
    else
        
        % Calculates the retention time by taking into account the void time
        % (solvent front).
        rt = peaks(:,2)-voidTime;
        % Peak widths at half height, therefore as they are modelled as
        % gaussian peaks to get the standard deviation (peak width at base)
        % do width*2.355.
        width = peaks(:,4)*2.355;
        numbOfPeaks = length(rt); % Number of peaks detected
    
        % If only one peak detected, set the RsCrit to whatever the
        % retention time is divided by the width, then minus 2 and take the
        % negative value.
        if numbOfPeaks == 1
            
            % This gives the Rscrit between the one detected peak and the
            % solvent front, minus 2 for the Rscrit limit and then take the
            % negative of this value so the algorithm maximises for peak
            % distance.
            rsMin = ((2*rt/width) - 2);
            if rsMin <= 0
                rsMin = 0.01;
            end
            rsCrit = -log(rsMin);     
        else
 
            % Calculates the number of possible pair arrangements between each
            % peak recorded. E.g. for 4 peaks there would be 6 possible peak
            % arrangements: R12, R13, R14, R23, R24 and R34.
            peakLabels = numbOfArrangements(numbOfPeaks);
 
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
            
            % Make sure that the critical resoltion is not less than or
            % equal to zero as otherwise the number will be equal to
            % inifinity or an imginary number. If it is set it to a small
            % value for rsMin.
            rsMin = min(rS);
            if rsMin <= 0
                rsMin = 0.01;
            end
            rsCrit = -log(rsMin);
 
        end
    
    end
    
end

