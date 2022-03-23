clc 
clear
%% Define bounds with number of qualitative and quantitative variables
nquant = 4;
nqual = 2;
bounds = [0,1;
          1,2;
          0,0;
          0,0];
%% Generate initial conditions
npoints = 10;
xquant = bounds(1,1:nquant) + ...
    (bounds(2,1:nquant)-bounds(1,1:nquant)).*...
    rand(npoints,nquant);
xqual = zeros(npoints,nqual);
for i = 1:nqual
    xqual(:,i) = randi(...
        [bounds(1,nquant+i),...
        bounds(2,nquant+i)],npoints,1);
end
X = [xquant,xqual];
y = -ftrig(X);
%% How many levels do the discrete variables have and what index are they in the input domain
% Define as a vector
levels = [2;
          2];
dim_qual = [1;
            2];
%% Initialise optimiser
optimiser = LVBayesianOptimiser('AEI', bounds, X, y, dim_qual, levels);
%% Run optimisation
for i = 1:10
    [next, fval] = optimiser.suggest();
    ynext = -ftrig(next);
    optimiser = optimiser.addData(next,ynext);
end
