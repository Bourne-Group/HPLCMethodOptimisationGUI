%% Generate intial dataset
f = @(x) (x(:,1)+2*x(:,2)-7).^2+(2*x(:,1)+x(:,2)-5).^2;
bounds = [-10,-10; % lower
          10,10];% upper
Xinitial = lhsdesign(2*size(bounds,2)+1,size(bounds,2));
Xinitial = Xinitial .* (bounds(2,:) - bounds(1,:)) + bounds(1,:);
yinitial = f(Xinitial);

%% Initialise Optimiser
optimiser = BayesianOptimiser('ardmatern52', 'AEI',bounds, Xinitial, yinitial);

%% Run optimisation

for i = 1:20
    [next, fval] = optimiser.suggest();
    ynext = f(next);
    optimiser = optimiser.addData(next,ynext);
    % change exploration ratio after 5 experiments
    if i > 5
        optimiser.ratio = 0.03; 
    end
end

% %% Plot results
% figure
% scatter3(optimiser.X(:,1),optimiser.X(:,2),optimiser.X(:,3),40,optimiser.y,'filled')
% hold on
% scatter3(optimiser.X(1:10,1),optimiser.X(1:10,2),optimiser.X(1:10,3),40,'r')
% scatter3(optimiser.X(11:15,1),optimiser.X(11:15,2),optimiser.X(11:15,3),40,'g')
% scatter3(optimiser.X(15:end,1),optimiser.X(15:end,2),optimiser.X(15:end,3),40,'m')