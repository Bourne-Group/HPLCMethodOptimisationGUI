function f = runOptHPLC(X)
%     %%Set condtions and run the HPLC
%     file = 'C:\Users\eng_adm\OneDrive - University of Leeds\PhD project infomation\Data\Code\AGILENT MACROS\Tomv3\MethodFile.xls';

    % Establish conectin with Excel server
    excelapp = actxGetRunningServer('Excel.Application');
    wkbk = excelapp.Workbooks;
    list = fieldnames(excelapp);
    sheets = excelapp.Sheets;
    sheet12 = Item(sheets,1);
    
    %Set all condtions
    Temp = X(:,1);
    GradTime = X(:,2);
    BAmmount = X(:,3);
    AAmmount = 100 - BAmmount;
    
    MaxTime = GradTime + 2;
    
    set(sheet12,'Range','B1', AAmmount);
    set(sheet12,'Range','B2', BAmmount);
    set(sheet12,'Range','A9', GradTime);
    set(sheet12,'Range','A10', MaxTime);
    set(sheet12,'Range','E1', MaxTime);
    set(sheet12,'Range','E3', Temp);
    set(sheet12,'Range','I1', 1);
    
    pause(5)
    
    SetAndRunHPLC
    
    sampleRun = get(sheet12,'Range','I4').value;
    
    while sampleRun == 0
        sampleRun = get(sheet12,'Range','I4').value;
        pause(10)
        disp("Waiting...")
    end
    
    set(sheet12,'Range','I4', 0);
    extension = get(sheet12,'Range','I5').value;
    pause(30) % Waits to make sure file is now in folder stated
    
    %% Analysis of the data (finds the new file added) and generation of the responce variables
    
    % Filename containing the contents of all the .D files from the run
    filename = "C:\Users\Public\Documents\ChemStation\1\Data\cmtmdHPLC004";
    
    % Reads and processes the chromatgorams, then sets it to the 
    [x,y,peaks] = readAndProcessChromatogram(filename + "\" + extension,1);
    
    f1 = responceNumbPeaks(peaks, 0.5, 1.1);
    f2 = responceMaxTime(peaks, 0.5, 1.1);
    f3 = responceRscrit(peaks, 0.5, 1.1);
    
    f = 3*f1 + 2*f2 + 1*f3;
    
end

