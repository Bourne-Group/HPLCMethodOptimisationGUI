%% Runs the  condtions 

function timeOutReached = RunCond(X, experiment, equalTime, timeout)
    timeOutReached = false;
   
    % Establishes a connection with the only excel file open
    excelapp = actxGetRunningServer('Excel.Application');
    wkbk = excelapp.Workbooks;
    list = fieldnames(excelapp);
    sheets = excelapp.Sheets;
    sheet12 = Item(sheets,1);

    %Set all condtions
    Temp = X{experiment,4};
    GradTime = X{experiment,1};
    IsoTime = X{experiment, 5};
    BInital = X{experiment,2};
    AInital = 100 - BInital;
    BFinal = X{experiment, 3};
    FlowRate = X{experiment, 7};
    InjVol = X{experiment, 6};
    Column = X{experiment, 8};
    OMPhase = X{experiment, 9};
    Ph = X{experiment, 10};
    
    set(sheet12,'Range','B1', AInital); % Set inital A % solvent
    set(sheet12,'Range','B2', BInital); % Set inital B % sovent
    set(sheet12,'Range','E1', GradTime + IsoTime + 2); % Set the max time
    set(sheet12,'Range','E3', Temp); % Set the temperature
    set(sheet12,'Range','E5', InjVol); % Set the injection volume
    set(sheet12,'Range','I6', equalTime); % Set equlibration time (seconds)

    if IsoTime == 0
        % Sets the number of method rows too 2, as there is no isocratic
        % hold time (if there where there would be 3 rows).
        set(sheet12,'Range','B6', 3)
        
        % Config row 1
        set(sheet12,'Range','A9', GradTime);
        set(sheet12,'Range','D9', 0);
        set(sheet12,'Range','E9', 0);
        set(sheet12,'Range','C9', BFinal);
        set(sheet12,'Range','F9', FlowRate);
        
        % Config row 2 - ramp up to 95 %
        set(sheet12,'Range','A10', GradTime + 0.1);
        set(sheet12,'Range','D10', 0);
        set(sheet12,'Range','E10', 0);
        set(sheet12,'Range','C10', 95);
        set(sheet12,'Range','F10', FlowRate);
        
        % Config row 3 - hold at 95 % for 2 min
        set(sheet12,'Range','A11', GradTime + 2);
        set(sheet12,'Range','D11', 0);
        set(sheet12,'Range','E11', 0);
        set(sheet12,'Range','C11', 95);
        set(sheet12,'Range','F11', FlowRate);
        
        % Config row 4 - set to 0 to aviod confusion
        set(sheet12,'Range','A12', 0);
        set(sheet12,'Range','D12', 0);
        set(sheet12,'Range','E12', 0);
        set(sheet12,'Range','C12', 0);
        set(sheet12,'Range','F12', 0);
        
    else
        
        % Sets the number of method rows too 3, as there is a isocratic
        % hold time
        set(sheet12,'Range','B6', 4);
        
        % Config row 1
        set(sheet12,'Range','A9', IsoTime);
        set(sheet12,'Range','D9', 0);
        set(sheet12,'Range','E9', 0);
        set(sheet12,'Range','C9', BInital);
        set(sheet12,'Range','F9', FlowRate);
        
        % Config row 2
        set(sheet12,'Range','A10', GradTime + IsoTime);
        set(sheet12,'Range','D10', 0);
        set(sheet12,'Range','E10', 0);
        set(sheet12,'Range','C10', BFinal);
        set(sheet12,'Range','F10', FlowRate);
        
        % Config row 3 - ramp to 95 %
        set(sheet12,'Range','A11', GradTime + IsoTime + 0.1);
        set(sheet12,'Range','D11', 0);
        set(sheet12,'Range','E11', 0);
        set(sheet12,'Range','C11', 95);
        set(sheet12,'Range','F11', FlowRate);
        
        % Config row 4 - hold at 95 % for 2 min
        set(sheet12,'Range','A12', GradTime + IsoTime + 2);
        set(sheet12,'Range','D12', 0);
        set(sheet12,'Range','E12', 0);
        set(sheet12,'Range','C12', 95);
        set(sheet12,'Range','F12', FlowRate);
        
    end
    
    
    set(sheet12,'Range','I1', 1); % Set spreadsheet cell RUNSAMPLE = 1;
   
    pause(2) % Quick pause to ensure values are set before moving on

    % DISABLE THIS WHEN TESTING
    % Runs the script that executes the marco on the HPLC software
    SetAndRunHPLC

    %sampleRun = get(sheet12,'Range','I4').value;
    sampleRun = get(sheet12,'Range','I4');
    sampleRun = sampleRun.Value;
    
    tic
    while sampleRun == 0
        %sampleRun = get(sheet12,'Range','I4').value;
        sampleRun = get(sheet12,'Range','I4');
        sampleRun = sampleRun.Value;
        pause(5)
        currTime = toc;
        if currTime > timeout*60
            timeOutReached = true;
            break
        end
    end

    set(sheet12,'Range','I4', 0);
    pause(2)
end

