classdef BayesianOptimiser
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
        bounds = [];
        kernel = 'ardmatern32';
        mdl % GP surrogate
        acq_type
        ratio = 0.2;
        ymin
        contextual
    end
    
    methods
        function obj = BayesianOptimiser(kernel, acq_type, bounds, X, y)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            if nargin == 0
                
            elseif nargin == 1
                obj.kernel = kernel;
            else
                obj.kernel = kernel;
                obj.acq_type = acq_type;
                obj.bounds = bounds;
                obj.X = X;
                obj.y = y;
                obj = obj.scaleY();
                obj = obj.scaleX();
                obj.nvars = size(X,2);
                obj.mdl = fitrgp(obj.X, obj.yscaled, 'FitMethod', 'exact', ...
                'KernelFunction', obj.kernel, 'Verbose', 0);
                [~, ind] = min(obj.y);
            
                % In case of noise
                obj.ymin = predict(obj.mdl, obj.X(ind,:));
                
                if strcmp(obj.acq_type,'EI')
                
                else
                    % AEI
                    x = obj.bounds(1,:) + ...
                        (obj.bounds(2,:)-obj.bounds(1,:)).*...
                        rand(1000000,obj.nvars);
                    [~,sd] = predict(obj.mdl,x);
               
                    obj.contextual = abs(mean(sd.^2)/obj.ymin);
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
            obj.mdl = fitrgp(obj.X, obj.yscaled, 'FitMethod', 'exact', ...
                'KernelFunction', obj.kernel, 'Verbose', 0);
            
            [~, ind] = min(obj.y);
            
            % In case of noise
            obj.ymin = predict(obj.mdl, obj.X(ind,:));
            if strcmp(obj.acq_type,'EI')
                
            else
               % AEI
               x = obj.bounds(1,:) + ...
                   (obj.bounds(2,:)-obj.bounds(1,:)).*...
                   rand(1000000,obj.nvars);
               [~,sd] = predict(obj.mdl,x);
               
               obj.contextual = abs(mean(sd.^2)/obj.ymin);
            end
        end
        
        function obj = scaleY(obj)
           [obj.yscaled, obj.ymu, obj.ysigma] = zscore(obj.y);
        end
        
        function obj = scaleX(obj)
            obj.Xscaled = (obj.X - obj.bounds(1,:)) ./ ...
                (obj.bounds(2,:) - obj.bounds(1,:));
        end
        
        function X = revertX(obj, Xscaled)
            X = Xscaled .* (obj.bounds(2,:) - obj.bounds(1,:)) + ...
                obj.bounds(1,:);
        end
        
        function f = acquisition(obj, X)
            
            [mu,sd] = predict(obj.mdl,X);
            if strcmp(obj.acq_type,'EI')
                c = obj.ratio;
            else
                c = obj.contextual;
            end
            z = (obj.ymin - mu - c) ./ sd;
            
            f = -((obj.ymin - mu - c).*normcdf(z) + sd.*normpdf(z));
        end
        
        function [next, fval] = suggest(obj)
            
            [next,fval] = GODLIKE(@(x)obj.acquisition(x),...
                            obj.bounds(1,:), obj.bounds(2,:),[],...
                            'MaxIters',100,'popsize',500);
            
            
            %next = obj.revertX(next);
        end
    end
end

