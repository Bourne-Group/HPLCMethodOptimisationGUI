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
    OMRamp1 = X{experiment, 1}*60; % First ramp rate. Starts in OM% per s but converted to OM% per min
    OMRamp2 = X{experiment, 2}*60; % Second ramp rate. Starts in OM% per s but converted to OM% per min
    BInital = X{experiment, 3}; % Inital OM conc between 5 and 95%
    AInital = 100 - BInital; % Inital other mobile phase conc between 5 and 95% 
    OMSwitch = X{experiment, 4}; % The percentage switch point between 10 and 90%
    BFinal = X{experiment, 5}; % The final set OM conc between 5 and 95%
    InitalIsoHoldTime = X{experiment, 6}; % Inital isocratic hold time
    MidIsoHoldTime = X{experiment, 7}; % A middle isocratic hold time if OMRamp1 and 2 are used
    Temp = X{experiment, 8}; % Temp setting
    InjVol = X{experiment, 9}; % Injection volume setting
    FlowRate = X{experiment, 10}; % Flow rate setting

    Column = X{experiment, 11}; % Type of column used (discrete)
    OMPhase = X{experiment, 12}; % OM phase selected e.g. A, B, C or D (discrete)
    Ph = X{experiment, 13}; % Ph selected e.g. A and B or C and D (discrete)
    
    set(sheet12,'Range','B1', AInital); % Set inital A % solvent
    set(sheet12,'Range','B2', BInital); % Set inital B % sovent
    set(sheet12,'Range','B5', FlowRate); % Set inital flow rate
    set(sheet12,'Range','E3', Temp); % Set the temperature
    set(sheet12,'Range','E5', InjVol); % Set the injection volume
    set(sheet12,'Range','I6', equalTime); % Set equlibration time (seconds)

    % If OMRamp1 is set but OMRamp2 is 0, then ignore MidIsoHoldTime and
    % OMSwitch and assume it is configured for a standard gradent run
    if OMRamp1 >= 0.1 && OMRamp2 == 0
        % Sets the number of method rows too 2, as there is no isocratic
        % hold time (if there where there would be 3 rows).
        set(sheet12,'Range','B6', 4)
        
        % Config row 1
        set(sheet12,'Range','A9', InitalIsoHoldTime);
        set(sheet12,'Range','D9', 0);
        set(sheet12,'Range','E9', 0);
        set(sheet12,'Range','C9', BInital);
        set(sheet12,'Range','F9', FlowRate);

        % Config row 2

        timeTaken = (BFinal-BInital)/OMRamp1; % Time taken based on the OMRamp set

        set(sheet12,'Range','A10', InitalIsoHoldTime + timeTaken);
        set(sheet12,'Range','D10', 0);
        set(sheet12,'Range','E10', 0);
        set(sheet12,'Range','C10', BFinal);
        set(sheet12,'Range','F10', FlowRate);
        
        % Config row 3
        set(sheet12,'Range','A11', InitalIsoHoldTime + timeTaken + 0.1);
        set(sheet12,'Range','D11', 0);
        set(sheet12,'Range','E11', 0);
        set(sheet12,'Range','C11', 95);
        set(sheet12,'Range','F11', FlowRate);
        
        % Config row 4
        set(sheet12,'Range','A12', InitalIsoHoldTime + timeTaken + 2.1);
        set(sheet12,'Range','D12', 0);
        set(sheet12,'Range','E12', 0);
        set(sheet12,'Range','C12', 95);
        set(sheet12,'Range','F12', FlowRate);

        set(sheet12,'Range','E1', InitalIsoHoldTime + timeTaken + 2.1); % Set the max time
    
    % If OMRamp1 is 0 and OMRamp2 is 0, then ignore MidIsoHoldTime,
    % OMSwitch, OMRamp1 and 2, and assume it is configured for standard
    % isocratic runs
    elseif OMRamp1 == 0 && OMRamp2 == 0
        
        % Sets the number of method rows too 2, as there is no isocratic
        % hold time (if there where there would be 3 rows).
        set(sheet12,'Range','B6', 3)
        
        % Config row 1
        set(sheet12,'Range','A9', InitalIsoHoldTime);
        set(sheet12,'Range','D9', 0);
        set(sheet12,'Range','E9', 0);
        set(sheet12,'Range','C9', BInital);
        set(sheet12,'Range','F9', FlowRate);

        % Config row 2

        set(sheet12,'Range','A10', InitalIsoHoldTime + 0.1);
        set(sheet12,'Range','D10', 0);
        set(sheet12,'Range','E10', 0);
        set(sheet12,'Range','C10', 95);
        set(sheet12,'Range','F10', FlowRate);
        
        % Config row 3
        set(sheet12,'Range','A11', InitalIsoHoldTime + 2.1);
        set(sheet12,'Range','D11', 0);
        set(sheet12,'Range','E11', 0);
        set(sheet12,'Range','C11', 95);
        set(sheet12,'Range','F11', FlowRate);
        
        set(sheet12,'Range','E1', InitalIsoHoldTime + 2.1); % Set the max time


    elseif OMRamp1 >= 0.1 && OMRamp2 >= 0.1
        % Sets the number of method rows too 2, as there is no isocratic
        % hold time (if there where there would be 3 rows).
        set(sheet12,'Range','B6', 6)
        
        % Config row 1
        set(sheet12,'Range','A9', InitalIsoHoldTime);
        set(sheet12,'Range','D9', 0);
        set(sheet12,'Range','E9', 0);
        set(sheet12,'Range','C9', BInital);
        set(sheet12,'Range','F9', FlowRate);

        % Config row 2

        OMSwitchVal = ((BFinal-BInital)*(OMSwitch/100))+BInital;
        timeTaken1 = (OMSwitchVal-BInital)/OMRamp1; % Time taken based on the OMRamp set

        set(sheet12,'Range','A10', InitalIsoHoldTime + timeTaken1);
        set(sheet12,'Range','D10', 0);
        set(sheet12,'Range','E10', 0);
        set(sheet12,'Range','C10', OMSwitchVal);
        set(sheet12,'Range','F10', FlowRate);
        
        % Config row 3
        set(sheet12,'Range','A11', InitalIsoHoldTime + timeTaken1 + MidIsoHoldTime);
        set(sheet12,'Range','D11', 0);
        set(sheet12,'Range','E11', 0);
        set(sheet12,'Range','C11', OMSwitchVal);
        set(sheet12,'Range','F11', FlowRate);
        
        % Config row 4

        timeTaken2 = (BFinal-OMSwitchVal)/OMRamp2; % Time taken based on the OMRamp set

        set(sheet12,'Range','A12', InitalIsoHoldTime + timeTaken1 + MidIsoHoldTime + timeTaken2);
        set(sheet12,'Range','D12', 0);
        set(sheet12,'Range','E12', 0);
        set(sheet12,'Range','C12', BFinal);
        set(sheet12,'Range','F12', FlowRate);

        % Config row 5

        set(sheet12,'Range','A13', InitalIsoHoldTime + timeTaken1 + MidIsoHoldTime + timeTaken2 + 0.1);
        set(sheet12,'Range','D13', 0);
        set(sheet12,'Range','E13', 0);
        set(sheet12,'Range','C13', 95);
        set(sheet12,'Range','F13', FlowRate);

        % Config row 6

        set(sheet12,'Range','A14', InitalIsoHoldTime + timeTaken1 + MidIsoHoldTime + timeTaken2 + 2.1);
        set(sheet12,'Range','D14', 0);
        set(sheet12,'Range','E14', 0);
        set(sheet12,'Range','C14', 95);
        set(sheet12,'Range','F14', FlowRate);

        set(sheet12,'Range','E1', InitalIsoHoldTime + timeTaken1 + MidIsoHoldTime + timeTaken2 + 2.1); % Set the max time
        
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

