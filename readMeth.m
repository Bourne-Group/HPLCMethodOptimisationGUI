function data = readMeth(filename)
    %READMETH Reads the method files and extracts th solvent and flow rate
    %data from the HPLC methd run. Returns a structure. NEEDS WORK.
    
    % Uses a matlab generated import function to read the text file.
    methData = importMethFile(filename);
    methData = methData.Data; % Converts table to text array
    
    % Reads first 25 lines of text file line by line. Extracts the desired
    % numbers from the file. If there is no number returned, set it to 0.
    for lineNumb = 1:25
        if contains(methData(lineNumb), "Solvent A")
            solventA = regexp(methData(lineNumb),'\d*[.]\d* %', 'match');
            solventA = str2double(regexp(solventA,'\d*[.]\d*', 'match'));
            if isempty(solventA)
                solventA = 0;
            end
        elseif contains(methData(lineNumb), "Solvent B")
            solventB = regexp(methData(lineNumb),'\d*[.]\d* %', 'match');
            solventB = str2double(regexp(solventB,'\d*[.]\d*', 'match'));
            if isempty(solventB)
                solventB = 0;
            end
        elseif contains(methData(lineNumb), "Solvent C")
            solventC = regexp(methData(lineNumb),'\d*[.]\d* %', 'match');
            solventC = str2double(regexp(solventC,'\d*[.]\d*', 'match'));
            if isempty(solventC)
                solventC = 0;
            end
        elseif contains(methData(lineNumb), "Solvent D")
            solventD = regexp(methData(lineNumb),'\d*[.]\d* %', 'match');
            solventD = str2double(regexp(solventD,'\d*[.]\d*', 'match'));
            if isempty(solventD)
                solventD = 0;
            end
        elseif contains(methData(lineNumb), "Column Flow")
            colFlow = str2double(regexp(methData(lineNumb),'\d*[.]\d*', 'match'));
            if isempty(colFlow)
                colFlow = 0;
            end
        end
    end    
    data = struct2cell(struct("method",[solventA solventB solventC solventD colFlow stopTime]));
    
end

