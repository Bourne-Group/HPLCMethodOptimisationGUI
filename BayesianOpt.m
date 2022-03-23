function nextCond = BayesianOpt(X, Y, LB, UB, options, DisVarData)

    bounds = [LB;UB]; %Combine the lower and upper bounds into one array
    
    optimiser = BayesianOptimiser('ardmatern52', 'AEI', bounds, X, Y);
    [nextCond, ~] = optimiser.suggest();
end