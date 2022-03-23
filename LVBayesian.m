function nextCond = LVBayesian(X, Y, LB, UB, options, DisVarData)

    bounds = [LB;UB]; %Combine the lower and upper bounds into one array
    
    if isempty(DisVarData)
        indexDisVar = [];
        levels = [];
    else
        indexDisVar = DisVarData(1,:)';
        levels = DisVarData(2,:)';
    end
    
    optimiser = LVBayesianOptimiser('AEI', bounds, X, Y, indexDisVar, levels);
    [nextCond, ~] = optimiser.suggest();
end

