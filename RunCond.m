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
    GradTime = X{experiment,1};
    BInital = X{experiment,2};
    AInital = 100 - BInital;
    BFinal = X{experiment, 3};
    Temp = X{experiment,4};
    IsoTime = X{experiment, 5};
    IsoTime2 = X{experiment, 6};
    GradTime2 = X{experiment, 7};
    Switch = X{experiment, 8};
    InjVol = X{experiment, 9};
    FlowRate = X{experiment, 10};
    Column = X{experiment, 11};
    OMPhase = X{experiment, 12};
    Ph = X{experiment, 13};

    %%PFIZER EDIT HERE
    %This writes the data to a spreadsheet and then executes the functon
    %"SetAndRunHPLC.m" to initate the data transfer (a mouse clicker that
    %enters a macro into a command line in ChemStation). So in the API case
    %all the code to WRITE the method should go here. 

    %This code is assumed to run "correctly". If there is no response read
    %after "timeOutReached" time then the Application exits due to error.
    
    set(sheet12,'Range','B1', AInital); % Set inital A % solvent
    set(sheet12,'Range','B2', BInital); % Set inital B % sovent
    set(sheet12,'Range','E1', GradTime + IsoTime + 6); % Set the max time
    set(sheet12,'Range','E3', Temp); % Set the temperature
    set(sheet12,'Range','E5', InjVol); % Set the injection volume
    set(sheet12,'Range','I6', equalTime); % Set equlibration time (seconds)

    if (IsoTime == 0 && IsoTime2 == 0)
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
        set(sheet12,'Range','A11', GradTime + 6);
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
        
    elseif(IsoTime2 == 0)
        
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
        
        % Config row 4 - hold at 95 % for 5 min
        set(sheet12,'Range','A12', GradTime + IsoTime + 5);
        set(sheet12,'Range','D12', 0);
        set(sheet12,'Range','E12', 0);
        set(sheet12,'Range','C12', 95);
        set(sheet12,'Range','F12', FlowRate);

    else

        % Sets the number of method rows too 3, as there is a isocratic
        % hold time
        set(sheet12,'Range','B6', 6);
        
        % Config row 1
        set(sheet12,'Range','A9', IsoTime);
        set(sheet12,'Range','D9', 0);
        set(sheet12,'Range','E9', 0);
        set(sheet12,'Range','C9', BInital);
        set(sheet12,'Range','F9', FlowRate);
        
        BSwitch = ((Switch/100)*(BFinal - BInital)) + BInital;

        % Config row 2
        set(sheet12,'Range','A10', IsoTime + GradTime);
        set(sheet12,'Range','D10', 0);
        set(sheet12,'Range','E10', 0);
        set(sheet12,'Range','C10', BSwitch);
        set(sheet12,'Range','F10', FlowRate);

        % Config row 3
        set(sheet12,'Range','A11', IsoTime + GradTime + IsoTime2);
        set(sheet12,'Range','D11', 0);
        set(sheet12,'Range','E11', 0);
        set(sheet12,'Range','C11', BSwitch);
        set(sheet12,'Range','F11', FlowRate);

        % Config row 4
        set(sheet12,'Range','A12', IsoTime + GradTime + IsoTime2 + GradTime2);
        set(sheet12,'Range','D12', 0);
        set(sheet12,'Range','E12', 0);
        set(sheet12,'Range','C12', BFinal);
        set(sheet12,'Range','F12', FlowRate);
        
        % Config row 5 - ramp to 95 %
        set(sheet12,'Range','A13', IsoTime + GradTime + IsoTime2 + GradTime2 + 0.1);
        set(sheet12,'Range','D13', 0);
        set(sheet12,'Range','E13', 0);
        set(sheet12,'Range','C13', 95);
        set(sheet12,'Range','F13', FlowRate);
        
        % Config row 6 - hold at 95 % for 6 min
        set(sheet12,'Range','A14', IsoTime + GradTime + IsoTime2 + GradTime2 + 6);
        set(sheet12,'Range','D14', 0);
        set(sheet12,'Range','E14', 0);
        set(sheet12,'Range','C14', 95);
        set(sheet12,'Range','F14', FlowRate);
        
        set(sheet12,'Range','E1', IsoTime + GradTime + IsoTime2 + GradTime2 + 6); % Set the max time
        
    end
    
    
    set(sheet12,'Range','I1', 1); % Set spreadsheet cell RUNSAMPLE = 1;
   
    pause(2) % Quick pause to ensure values are set before moving on

    % DISABLE THIS WHEN TESTING
    % Runs the script that executes the marco on the HPLC software

    %%PFIZER EDIT HERE
    %Starts the commuincation with the instrement
    %This sets up an while loop to wait for the method to finish running.
    %The macro code that is executed then writes a '1' in a excel doc when the
    %method has finished to notifiy the loop the method has finished.
    SetAndRunHPLC

    

    %sampleRun = get(sheet12,'Range','I4').value;
    sampleRun = get(sheet12,'Range','I4');
    sampleRun = sampleRun.Value;
    
    tic
    

    %I realise this is not the bet way as it could be stuck here for the
    %max time (determined by timeOutReached) but it was the best i could do
    %with the bad macro chemsation code :')
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

