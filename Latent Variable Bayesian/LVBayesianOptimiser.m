classdef LVBayesianOptimiser
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        X = [];% Input data
        Xscaled
        y = [];% Response
        yscaled
        ymu
        ysigma
        nvars
        nquant
        nqual
        bounds = [];
        dim_qual
        levels
        d_lv = 2;
        n_starts = 200;
        mdl % GP surrogate
        acq_type
        ratio = 0.2;
        ymin
        contextual
    end
    
    methods
        function obj = LVBayesianOptimiser(acq_type, bounds, X, y, dim_qual, levels)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            if nargin == 0
                
            elseif nargin == 1
            else
                obj.acq_type = acq_type;
                obj.bounds = bounds;
                obj.X = X;
                obj.y = y;
                obj.dim_qual = dim_qual;
                obj.nqual = length(dim_qual);
                obj.nquant = size(X,2) - obj.nqual;
                obj.levels = levels;
                obj = obj.scaleY();
                obj = obj.scaleX();
                obj.nvars = size(X,2);
                obj.mdl = gpFit(obj.X,obj.yscaled, obj.n_starts, ...
                    obj.dim_qual, obj.d_lv, obj.levels);
                [~, ind] = min(obj.y);
            
                % In case of noise
                [obj.ymin, ~] = gpPredict(obj.mdl, obj.X(ind,:));
                
                if strcmp(obj.acq_type,'EI')
                
                else
                    % AEI
                    npoints = 10000;
                    xquant = obj.bounds(1,1:obj.nquant) + ...
                        (obj.bounds(2,1:obj.nquant)-obj.bounds(1,1:obj.nquant)).*...
                        rand(npoints,obj.nquant);
                    xqual = zeros(npoints,obj.nqual);
                    for i = 1:obj.nqual
                        xqual(:,i) = randi(...
                            [obj.bounds(1,obj.nquant+i),...
                            obj.bounds(2,obj.nquant+i)],npoints,1);
                    end
                    x = [xquant,xqual];
                    [~,y_cov] = gpPredict(obj.mdl,x);
               
                    obj.contextual = abs(mean(diag(y_cov))/obj.ymin);
                end
            end    
        end
        
        function obj = addData(obj,X,y)
            %addData Adds data to the class and refits the GP surrogate
            % FUTURE Add option not to refit each time
            if isempty(obj.mdl)
            
            else
                obj.X = [obj.X;X];
                obj.y = [obj.y;y];
            end
            % scale input and outputs
            obj = obj.scaleY();
            obj = obj.scaleX();
            % fit GP surrogate
            obj.mdl = gpFit(obj.X,obj.yscaled, obj.n_starts, ...
                    obj.dim_qual, obj.d_lv, obj.levels);
                [~, ind] = min(obj.y);
            
                % In case of noise
            [obj.ymin, ~] = gpPredict(obj.mdl, obj.X(ind,:));
            if strcmp(obj.acq_type,'EI')
                
            else
               % AEI
                    npoints = 10000;
                    xquant = obj.bounds(1,1:obj.nquant) + ...
                        (obj.bounds(2,1:obj.nquant)-obj.bounds(1,1:obj.nquant)).*...
                        rand(npoints,obj.nquant);
                    xqual = zeros(npoints,obj.nqual);
                    for i = 1:obj.nqual
                        xqual(:,i) = randi(...
                            [obj.bounds(1,obj.nquant+i),...
                            obj.bounds(2,obj.nquant+i)],npoints,1);
                    end
                    x = [xquant,xqual];
                    [~,y_cov] = gpPredict(obj.mdl,x);
               
                    obj.contextual = abs(mean(diag(y_cov).^2)/obj.ymin);
            end
        end
        
        function obj = scaleY(obj)
           [obj.yscaled, obj.ymu, obj.ysigma] = zscore(obj.y);
        end
        
        function y = revertY(obj,yscaled)
            y = yscaled .* obj.ysigma + obj.ymu;
        end
        
        function obj = scaleX(obj)
            obj.Xscaled = obj.X;
            obj.Xscaled(:,1:obj.nquant) = (obj.X(:,1:obj.nquant) - obj.bounds(1,1:obj.nquant)) ./ ...
                (obj.bounds(2,1:obj.nquant) - obj.bounds(1,1:obj.nquant));
        end
        
        function X = revertX(obj, Xscaled)
            X = Xscaled .* (obj.bounds(2,:) - obj.bounds(1,:)) + ...
                obj.bounds(1,:);
        end
        
        function f = acquisition(obj, X)
            
            [mu,y_cov] = gpPredict(obj.mdl,X);
            sd = sqrt(diag(y_cov));
            clearvars y_cov
            if strcmp(obj.acq_type,'EI')
                c = obj.ratio;
            else
                c = obj.contextual;
            end
            z = (obj.ymin - mu - c) ./ sd;
            
            f = -((obj.ymin - mu - c).*normcdf(z) + sd.*normpdf(z));
        end
        
        function [next, fval] = suggest(obj, p)
            
            if nargin<2
                           
%                 [next,fval] = GODLIKE(@(x)obj.acquisition(x),...
%                                 obj.bounds(1,:), obj.bounds(2,:),[],...
%                                 'MaxIters',100,'popsize',500);    
                
                %next = obj.revertX(next);
                
                opts = optimoptions(@ga, ...
                    'PopulationSize', 150, ...
                    'MaxGenerations', 200, ...
                    'EliteCount', 10, ...
                    'FunctionTolerance', 1e-8);
                
                [next,fval] = ga(@(x)obj.acquisition(x),obj.nvars,[],[],[],[],...
                    obj.bounds(1,:),obj.bounds(2,:),[],[obj.dim_qual],opts);
%                 fval=1000;
%                 for j = 1:10
%                 npoints = 10000;
%                 xquant = obj.bounds(1,1:obj.nquant) + ...
%                         (obj.bounds(2,1:obj.nquant)-obj.bounds(1,1:obj.nquant)).*...
%                         rand(npoints,obj.nquant);
%                 xqual = zeros(npoints,obj.nqual);
%                 for i = 1:obj.nqual
%                     xqual(:,i) = randi(...
%                             [obj.bounds(1,obj.nquant+i),...
%                             obj.bounds(2,obj.nquant+i)],npoints,1);
%                 end
%                 x = [xquant,xqual];
%                 [f, ind] = min(obj.acquisition(x));
%                 if f < fval
%                     next = x(ind,:);
%                     fval = f;
%                 end
%                 end
            else
                if p>4
                    warning('Batches greater than 4 points lead to significant impact on algorithms performance')
                end
                % Kriging Believer implementation, utilising expected
                % value as the vitual response
                % FUTURE UCB or LCB kriging believer 
                % mu +/- 3*sd
                next = zeros(p,obj.nvars);
                fval = zeros(p,1);
                tempopt = BayesianOptimiser(obj.kernel,obj.acq_type,...
                    obj.bounds, obj.X, obj.y);
                
                for i = 1:p
                    [next(i,:), fval(i)] = tempopt.suggest();
                    % look to use ysd in the future
                    [ynext, ~] = predict(tempopt.mdl,next(i,:));
                    % convert to non normalised values
                    ynext = tempopt.revertY(ynext);
                    tempopt = tempopt.addData(next(i,:),ynext);
                end
            end
        end
    end
end
%% Utility functions taken from:
% A Latent Variable Approach to Gaussian Process Modeling with Qualitative 
% and Quantitative Factors
% https://www.tandfonline.com/doi/abs/10.1080/00401706.2019.1638834
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function X_latent = toLatent(X, dim_qual, z, d_lv, levels)

% This function transforms the original X into latent space
% X - a matrix of input data, each row is a sample
% dim_qual - an index array of qualitative variables
% z - an array of the latent variable values for qualitative variables
% d_lv - the dimension of latent space, 1 or 2
% levels - an array of the levels of each qualitative variable
% returns a matrix contains both continuous x variables and the latent variables z

[n,d] = size(X);
n_qual = length(dim_qual); % number of qualitative variables

Z_qual = zeros(n, d_lv*n_qual); % matrix of latent variables

for i = 1:n_qual

    x_qual = X(:,dim_qual(i));
    
    if i ==1
        n_prev = 0;
    else
        n_prev = sum(levels(1:i-1)) - (i-1);
    end

    
    if d_lv==2
        Z_qual(x_qual==1,[2*i-1,2*i])=0; % set the first level to be zero in latent space
    elseif d_lv==1
        Z_qual(x_qual==1,i)=0;
    end
    
    
    % plug x_lv into each level of qualitative variables
    for j = 2:max(levels(i))
        if d_lv==2
            Z_qual(x_qual==j,[2*i-1,2*i])=repmat(z([2*n_prev + 2*(j-1)-1,2*n_prev + 2*(j-1)]),[sum(x_qual==j),1]);
        elseif d_lv==1
            Z_qual(x_qual==j,i)=repmat(z(n_prev + j-1),[sum(x_qual==j),1]);
        end
    end

end

% combine quantitative and qualitative variables
if d > n_qual
    X_latent = [X(:,1:d-n_qual), Z_qual];
else
    X_latent = Z_qual;
end
end

function W = toIndicator(X, dim_qual)
% This function transforms categorical dimensions into indicators W,
% used for fitting the Unrestrictive Covariance (UC) model

[n, d] = size(X);
d_qual = length(dim_qual);
X_quan = X(:,1: d-d_qual);

X_qual = X(:,dim_qual);


W = [];
for i = 1:d_qual
    I = dummyvar(X_qual(:,i));
    T = size(I,2);

    for p = 1:T
        for q = 1:T
            if p == q
                w(:, (p-1)*T + q) = I(:,p);
            else
                w(:, (p-1)*T + q) = I(:,p) + I(:,q);
            end
        end
    end

    W = [W w];
end
W = [X_quan W];
end

function R = computeR(phi, X1, X2)
% This function computes the correlation matrix btween X1 and X2
% phi - lengthscale parameters
% X1, X2 - n by d, n sample size, d dim
% correlation is calculated using squared exponential formula


[n1,d] = size(X1);
n2 = size(X2,1);

d2 = 0;
for i = 1:d
    % distance matrix multiplied by theta
    d2 = d2 + 10.^(phi(i)).*(repmat(X1(:,i),[1,n2])-repmat(X2(:,i)',[n1,1])).^2;
end

% correlation matrix
if n1 ~= n2
    R = exp(- d2);
else
    nugget = n1/(10^12 - 1); % add nugget to make sure the matrix is well conditioned
    R = exp(-d2) + nugget*eye(n1);
end
end

function logL = logLikelihood(params, X, y, dim_qual, d_lv, levels)
% This function computes the loglikelihood of GP models with quantitative and qualitative variables
% params - vector of parameters, containing scale parameters phi for continuous variables 
%          and latent variables z for qualitative variables
% X - a matrix of input data, each row is a sample
% y - a vector of response data
% dim_qual - an index array of qualitative variables
% d_lv - the dimension of latent space, 1 or 2
% returns the loglikelihood value


% without qualitative variables
if nargin == 3

    n = size(X,1);
    R = computeR(params, X,X); % correlation matrix
    
    L = chol(R,'lower');
    
    one_n = ones(1,n);
    
    R_inv_y = L'\(L\y); 
    R_inv_one = L'\(L\one_n');
    
    mu = (one_n * R_inv_y) / (one_n * R_inv_one); % mean
    R_inv_y_mu = L'\(L\(y-mu));
    sigma2 = 1/n * (y-mu)' * R_inv_y_mu; % variance
    
    logL = log(det(R))+ n*log(sigma2);
    
% with qualitative variables
elseif nargin == 6

    [n,d] = size(X);
    d_qual = length(dim_qual); % number of qualitative variables
    z = params(d-d_qual+1:end); % latent variables
    
    X1 = toLatent(X,dim_qual, z, d_lv, levels); % transform to latent space
    phi = params(1:d-d_qual); % lengthscale parameters
    R = computeR([phi,zeros([1,d_lv*d_qual])], X1,X1); % correlation matrix
    
    one_n = ones(1,n);
    L = chol(R,'lower');
    
    R_inv_y = L'\(L\y); 
    R_inv_one = L'\(L\one_n');

    mu = (one_n * R_inv_y) / (one_n * R_inv_one); % mean
    R_inv_y_mu = L'\(L\(y-mu));
    
    sigma2 = 1/n * (y-mu)' * R_inv_y_mu; % variance
    logL = log(det(R)) + n*log(sigma2);
   
end
end

function model = gpFit(X,y, n_starts, dim_qual, d_lv, levels)

% This function fits the GP model with both qualitative and quantitative variables
% X - a matrix of input data, each row is a sample, qualitative variables
% always stacked to the right of continuous inputs
% y - a vector of response
% n_starts - number of initial guesses for hyperparameters
% dim_qual - an index array of qualitative variables
% d_lv - the dimension of latent space, 1 or 2
% returns a matlab structure contains information about the fitted GP model.


% with qualitative variables
if nargin == 6 
    d = size(X,2); % total number of variables
    n_levels = zeros(length(dim_qual),1); % a vector containing the levels for each qualitative variable
    for i = 1:length(dim_qual)
        n_levels(i) = length(unique(X(:,dim_qual(i))));
    end

    n_lv = d_lv*(sum(n_levels)-length(dim_qual)); % number of latent variables
    n_quan = d-length(dim_qual); % number of quantitative variables

    phi0 = zeros(1, n_quan); % initial value of scale parameters for quantitative variables
    z0 = -0.5 + rand(1, n_lv); % initial value of latent variables

    params0 = [phi0, z0]; % complete initial parameter set
        
    if d_lv ==1
        
        lb = -2*ones(1, n_quan); ub = 2*ones(1, n_quan);
        for i = 1:length(dim_qual)
            lb = [lb, -3, -2*ones(1, n_levels(i)-2)]; % lower bound
            ub = [ub, 3, 2*ones(1, n_levels(i)-2)]; % upper bound
        end
    elseif d_lv==2
        
        lb = -2*ones(1, n_quan); ub = 2*ones(1, n_quan);
        for i = 1:length(dim_qual)
            lb = [lb, -2, 0, -2*ones(1, 2*n_levels(i)-4)]; % lower bound
            ub = [ub, 2, 0, 2*ones(1, 2*n_levels(i)-4)]; % upper bound       
        end
        
    end
    % create optimization problem to maximize loglikelihood, with 100 random initial points
    options = optimoptions('fmincon','SpecifyObjectiveGradient',false);
    problem = createOptimProblem('fmincon',...
        'objective',@(params)logLikelihood(params,X,y,dim_qual,d_lv,levels),...
        'x0',params0, 'lb', lb, 'ub', ub, 'options', options);
    ms = MultiStart('UseParallel', true);
    [params_star,f] = run(ms,problem,n_starts);
    
    model.X = X; model.y = y; model.n_starts = n_starts;
    model.dim_qual = dim_qual; model.d_lv = d_lv; model.levels = levels;
    model.phi = params_star(1:n_quan); model.z = params_star(n_quan+1:n_quan+n_lv); model.logL = f;

% without qualitative variables
elseif nargin == 3 
    d = size(X,2);
    phi0 = rand(1, d);
    lb = -2*ones(1,d); ub = 2*ones(1,d);
    
    options = optimoptions('fmincon','SpecifyObjectiveGradient',false);
    problem = createOptimProblem('fmincon',...
        'objective',@(params)logLikelihood(params,X,y),...
        'x0',phi0, 'lb', lb, 'ub', ub, 'options', options);
    ms = MultiStart('UseParallel', true);
    [params_star, f] = run(ms,problem,n_starts);
    
    model.X = X; model.y = y; model.n_starts = n_starts;
    model.phi = params_star; model.logL = f;
end
end

function [y_pred, y_cov] = gpPredict(model, x_pred)
% This function makes predictions based on fitted GP model
% model - the fitted GP model containing the following parameters:
% -- params_star - optimal parameters found by MLE
% -- X - a matrix of input data, each row is a sample
% -- y - a vector of response
% -- dim_qual - an index array of qualitative variables
% -- d_lv - the dimension of latent space, 1 or 2
% -- levels - array of levels of each qualitative variable
% x_pred - m by d, m samples and d dim


% without qualitative variables
if numel(fieldnames(model)) == 5
    
    phi = model.phi; X = model.X; y = model.y;
    
    n = size(X,1);
    R_xpredx = computeR(phi,x_pred, X);
    R_xx = computeR(phi, X, X);
    R_xpred = computeR(phi, x_pred, x_pred);
    
    mu = (ones(1,n)*(R_xx\ones(n,1)))\(ones(1,n)*(R_xx\y)); 
    sigma = 1/n*(y-mu)'*(R_xx\(y-mu));
    y_pred = mu + R_xpredx*(R_xx\(y-mu));
    y_cov = sigma*(R_xpred - R_xpredx*(R_xx\R_xpredx'));

% with qualitative variables
elseif numel(fieldnames(model)) == 9
    
    phi = model.phi; z = model.z; X = model.X; y = model.y;
    dim_qual = model.dim_qual; d_lv = model.d_lv; levels = model.levels;
    
    [n,~] = size(X);
    d_qual = length(dim_qual);
    phi = [phi, zeros(1, d_lv*d_qual)];
    
    X1 = toLatent(X,dim_qual, z, d_lv, levels);
    x_pred1 = toLatent(x_pred, dim_qual, z,d_lv, levels);
    
    R_xpredx = computeR(phi,x_pred1, X1);
    R_xx = computeR(phi, X1, X1);
    R_xpred = computeR(phi, x_pred1, x_pred1);
    
    mu = (ones(1,n)*(R_xx\ones(n,1)))\(ones(1,n)*(R_xx\y)); 
    sigma = 1/n*(y-mu)'*(R_xx\(y-mu));

    y_pred = mu + R_xpredx*(R_xx\(y-mu));
    y_cov = sigma*(R_xpred - R_xpredx*(R_xx\R_xpredx'));
end
end
