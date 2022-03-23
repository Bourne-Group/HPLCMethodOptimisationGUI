function varargout = GODLIKE(funfcn, ...                             
                             varargin)
% GODLIKE              Global optimizer combining the power of a 
%                      - Genetic algorithm
%                      - Diffential Evolution algorithm
%                      - Particle Swarm Optimization algorithm
%                      - Adaptive Simulated Annealing algorithm
%
% Usage:
%
% (Single-objective optimization)
%================================
%   sol = GODLIKE(obj_fun)
%   sol = GODLIKE(obj_fun, lb, ub)
%   sol = GODLIKE(..., ub, A,b)
%   sol = GODLIKE(..., b, Aeq,beq)
%   sol = GODLIKE(..., beq, confcn)
%   sol = GODLIKE(..., confcn, intcon)
%   sol = GODLIKE(..., intcon, options)
%   sol = GODLIKE(..., intcon, 'option', value, ...)
%
%   [sol, fval] = GODLIKE(...)
%   [sol, fval, exitflag] = GODLIKE(...)
%   [sol, fval, exitflag, output] = GODLIKE(...)
%
%
% (Multi-objective optimization)
% ==============================
%   sol = GODLIKE(obj_fun12..., lb, ub, ...)
%   sol = GODLIKE({obj_fun1, obj_fun2,...}, lb, ub, ...)
%
%   [sol, fval] = GODLIKE(...)
%   [..., fval, Pareto_front] = GODLIKE(...)
%   [..., Pareto_front, Pareto_Fvals] = GODLIKE(...)
%   [..., Pareto_Fvals, exitflag] = GODLIKE(...)
%   [..., exitflag, output] = GODLIKE(...)
%
%
% INPUT ARGUMENTS:
% ================
%
%   obj_fun        The objective function of which the global minimum
%                  will be determined (function_handle). For multi-
%                  objective optimization, several objective functions
%                  may be provided as a cell array of function handles,
%                  or alternatively, in a single function that returns
%                  the different function values along the second
%                  dimension.
%                  Objective functions must accept either a [popsize x
%                  dimensions] matrix argument, or a [1 x dimensions]
%                  vector argument, and return a [popsize x number of
%                  objectives] matrix or [1 x number of objective]
%                  vector of associated function values (number of
%                  objectives may be 1). With the first format, the
%                  function is evaluated vectorized, in  the second
%                  case CELLFUN() is used, which is a bit slower in
%                  general.
%
%   lb, ub         The lower and upper bounds of the problem's search
%                  space, for each dimension. May be scalar in case all
%                  bounds in all dimensions are equal. Note that at
%                  least ONE of these must have a size of [1 x
%                  dimensions], since the problem's dimensionality is
%                  derived from it.
%
%   A,b            Linear inequality and linear equality constraints, 
%   Aeq, beq       respectively; not yet fully implemented.
%
%   conFcn         Non-linear constraint function(s); not yet fully
%                  implemented.
%
%    intcon        Integer-constrained values; not yet fully implemented.
%
%   options/       Sets the options to be used by GODLIKE. Options may
%   'option',      be a structure created by set_options, or given as
%      value       individual ['option', value] pairs. See set_options
%                  for a list of all the available options and their
%                  defaults.
%
% OUTPUT ARGUMENTS:
% =================
%
%   sol            The solution that minizes the problem globally,
%                  of size [1 x dimensions]. For multi-objective
%                  optimization, this indicates the point with the
%                  smallest distance to the (shifted) origin.
%
%   fval           The globally minimal function value
%
%   exitflag       Additional information to facilitate fully automated
%                  optimization. Negative is `bad', positive `good'. A
%                  value of '0' indicates GODLIKE did not perform any
%                  operations and exited prematurely. A value of '1'
%                  indicates normal exit conditions. A value of '-1'
%                  indicates a premature exit due to exceeding the preset
%                  maximum number of function evaluations. A value of
%                  '-2' indicates that the amount of maximum GODLIKE
%                  iterations has been exceeded, and a value of '-3'
%                  indicates no optimum has been found (only for single-
%                  objective optimization).
%
%   output         structure, containing much additional information
%                  about the optimization as a whole; see the manual
%                  for a more detailed description.
%
%   (For multi-objective optimization only)
%
%   Pareto_front,  The full set of non-dominated solutions, and their
%   Pareto_Fvals   associated function values.
%
%   See also fminsearch, fminbnd, set_options.


% Please report bugs and inquiries to:
%
% Name    : Rody P.S. Oldenhuis
% E-mail  : oldenhuis@gmail.com
% Licence : 2-clause BSD (See License.txt)


% If you find this work useful, please consider a donation:
% https://www.paypal.me/RodyO/3.5

% If you would like to cite this work, please use the following template:
%
% Rody Oldenhuis, orcid.org/0000-0002-3162-3660. "GODLIKE" version
% <version>, <date you last used it>. MATLAB global minimization algorithm.
% https://nl.mathworks.com/matlabcentral/fileexchange/24838-GODLIKE


    %% Initialize
    % ==========================================================================

    % Check I/O arg counts
    % NOTE: (Rody Oldenhuis) R2011b introduced different argcheck mechanism
    % The following trainwreck is the only way to maintain this basic
    % functionality, while addressing ALL related warnings in ALL versions
    % of MATLAB.
    argc = nargin;
    argo = nargout;
    if verLessThan('MATLAB', '7.13')
        error(   nargchk(3,inf,argc,'struct')); %#ok<*NCHKN>
        error(nargoutchk(0,  6,argo,'struct'));   %#ok<*NCHKE>
    else
        narginchk(3,inf);
        nargoutchk(0,6);
    end

    
    
    %{
    % Get options structure
    if (argc >= 10) 
        if argc == 10 
            assert(isstruct(varargin{end}),...
                   [mfilename ':datatype_error'],...
                   'Argument [options] must be a structure.');
        end
        options = set_options(varargin{10:end});
    else
        options = set_options();
    end
    
    % OK, time to create a devel branch. Committing this as a means to stash...
    
    unconstrained_objective = objFunction('objective_function', funfcn,...
                                          'lb'     , get_arg(1),...
                                          'ub'     , get_arg(2),...
                                          'A'      , get_arg(3),...
                                          'b'      , get_arg(4),...
                                          'Aeq'    , get_arg(5),...
                                          'beq'    , get_arg(6),...
                                          'nonlcon', get_arg(7),...
                                          'intcon' , get_arg(8));
    function arg = get_arg(n)
        arg = []; if argc-1>=n, arg = varargin{n}; end, end
    %}
    % {
    lb = varargin{1};
    ub = varargin{2};
    varargin(1:2) = [];
    %}
    

    % resize and reshape boundaries and dimensions
    [lb,...
     ub,...
     sze,...
     popsize,...
     dimensions,...
     confcn,...
     constrained,...
     which_ones,...
     options] = reformat_input(lb,ub,...
                               varargin{:});

    % test input objective function(s) to determine the problem's dimensions,
    % number of objectives and proper input format
    [options,...
     single,...
     multi,...
     test_evaluations] = test_funfcn(options);

    % initialize more variables
    number_of_algorithms = numel(which_ones);            % number of algorithms to use       
              generation = 1;                            % this is the first generation
                     pop = cell(number_of_algorithms,1); % cell array of [population] objects
     num_funevaluations  = 0;                            % number of function evaluations
     [converged, output] = check_convergence();          % initial output structure
          outputFcnbreak = false;                        % exit condition for output functions

    % Initially, [output] is a large structure used to move data to and from all the
    % subfunctions. Later, it is turned into the output argument [output] by removing some
    % obsolete entries from the structure.

    % if an output function's been given, evaluate them to allow them to do 
    % any initialization they need
    state = 'init'; 
    if ~isempty(options.OutputFcn)
        cellfun(@(x) x([],[],state),...
                options.OutputFcn,...
                'UniformOutput', false);
    end

    % do an even more elaborate check
    options = check_parsed_input(nargout, ...
                                 single,...
                                 multi,...
                                 popsize,...
                                 dimensions,...
                                 which_ones,...
                                 options);


    %% GODLIKE loop
    % ==========================================================================

    % GODLIKE loop
    while ~converged

        % randomize population sizes (minimum is 5 individuals)        
        if length(popsize) == number_of_algorithms
            frac_popsize  = popsize;
            total_popsize = sum(popsize);
        else
            % Randomize population sizes (minimum is 5 individuals)
            frac_popsize  = break_value(popsize, 5, number_of_algorithms);
            total_popsize = popsize;
        end

        % randomize number of iterations per algorithm
        % ([options.GODLIKE.ItersUb] is the maximum TOTAL amount
        % of iterations that will be spent in all of the algorithms combined.)
        frac_iterations = break_value(options.GODLIKE.ItersUb,...
                                      options.GODLIKE.ItersLb,...
                                      number_of_algorithms);

        % shuffle (or initialize) populations
        pop = interchange_populations(pop);

        % loop through each algorithm
        for algo = 1:number_of_algorithms

            % perform algorithm iterations
            if strcmpi(pop{algo}.algorithm, 'MS')
                % Multi-start behaves differently; it needs to
                % execute its iterations inside popSingle.

                % save previous value of number of function evaluations
                prev_FE = pop{algo}.funevals;

                % pass data via arguments
                pop{algo}.iterate(frac_iterations(algo), num_funevaluations);

                % adjust number of function evaluations made
                num_funevaluations = num_funevaluations + pop{algo}.funevals - prev_FE;

            else
                counter = 0; % used for single-objective optimization
                for jj = 1:frac_iterations(algo)

                    % do single iteration on this population
                    pop{algo}.iterate;

                    % evaluate the output functions
                    if ~isempty(options.OutputFcn)
                        % most intensive part, here in the inner loop
                        state = 'interrupt';
                        % collect information
                        [x, optimValues] = get_outputFcn_values(algo);
                        % evaluate the output functions
                        stop = cellfun(@(y)y(x, optimValues, state), ...
                                       options.OutputFcn,...
                                       'UniformOutput', false);
                        stop = any([stop{:}]);
                        % GODLIKE might need to stop here
                        if stop
                            outputFcnbreak = true;
                            break;
                        end
                    end

                    % calculate total number of function evaluations
                    % Appareantly, pop{:}.funevals doesn't work. So
                    % we have to do a loop through all of them.
                    funevaluations = 0;
                    for k = 1:number_of_algorithms
                        if ~isempty(pop{k})
                            funevaluations = funevaluations + pop{k}.funevals; end
                    end % for
                    num_funevaluations = test_evaluations + funevaluations;

                    % check for convergence of this iteration
                    [alg_converged, ...
                     output,...
                     counter] = check_convergence(false,...
                                                  output,...
                                                  counter);
                    if alg_converged
                        display_progress();
                        break;
                    end

                    % check function evaluations, and exit if it
                    % surpasses the preset maximum
                    if (num_funevaluations >= options.MaxFunEvals)
                        % also display last iteration
                        display_progress();
                        converged = true;
                        break;
                    end

                    % display progress at every iteration
                    display_progress();

                end % algorithm loop
            end

            % if one of the output functions returned a stop request, break
            if outputFcnbreak, break, end

            % if we have convergence inside the algorithm
            % loop, break the main loop
            if converged, break; end


        end % main loop

        % Break if: 
        % - one of the output functions returned a stop request
        if outputFcnbreak, converged = true; end
        % - maximum number of generation have been exceeded
        if (generation >= options.MaxIters), converged = true; end

        generation = generation + 1;

        % check for GODLIKE convergence and update output structure
        [converged, output] = check_convergence(converged, output);

        % evaluate the output functions
        if ~outputFcnbreak && ~isempty(options.OutputFcn)
            % end of a GODLIKE iteration
            state = 'iter';
            % collect the information
            [x, optimValues] = get_outputFcn_values([]);
            % call the output functions
            cellfun(@(y)y(x, optimValues, state),...
                    options.OutputFcn,...
                    'UniformOutput', false);
        end

    end % GODLIKE loop

    % display final results
    % (*NOT* if the output function requested to stop)
    if ~outputFcnbreak
        display_progress(); end


    %% Process Outputs
    % ==========================================================================

    % multi-objective optimization
    if multi

        varargout{1} = output.most_efficient_point;
        varargout{2} = output.most_efficient_fitnesses;
        varargout{3} = output.pareto_front_individuals;
        varargout{4} = output.pareto_front_fitnesses;
        varargout{5} = output.exitflag;
        % remove some fields from output structure
        output = rmfield(output, {'pareto_front_individuals'
                                  'pareto_front_fitnesses'
                                  'exitflag'
                                  'most_efficient_point'
                                  'most_efficient_fitnesses'
                         });

        % and output what's left
        varargout{6} = output;

        % in case the output function requested to stop
        if outputFcnbreak
            output.exitflag = 2;
            output.message  = 'GODLIKE was terminated by one of the output functions.';
            varargout{5} = output.exitflag ;
            varargout{6} = output;
        end

    % single-objective optimization
    elseif single

        % if all went normal
        if isfield(output, 'global_best_individual')
            varargout{1} = output.global_best_individual;
            varargout{2} = output.global_best_funval;
            varargout{3} = output.exitflag;

            % remove some fields from output structure
            outpt.algorithms = output.algorithms;   outpt.funcCount = output.funcCount;
            outpt.message    = output.message;      outpt.algorithm_info = output.algorithm_info;
            outpt.iterations = output.iterations;

            % and output
            varargout{4} = outpt;

            % in case the output function requested to stop
            if outputFcnbreak
                outpt.exitflag = 2;
                outpt.message  = 'GODLIKE was terminated by one of the output functions.';
                varargout{3} = outpt.exitflag;
                varargout{4} = outpt;
            end

        % but, no optimum might have been found
        else
            varargout{1} = NaN(1, dimensions);
            varargout{2} = NaN;
            varargout{3} = -3;
            % remove some fields from output structure
            output = rmfield(output, {'global_best_funval'
                                      'exitflag'
                                      'descent_counter'
                                      'best_individuals'
                                      'best_funcvalues'
                                      'previous_global_best_funval'
                                      'previous_best_funcvalues'
                             });

            % adjust message
            output.message = sprintf('%s\n\n All function values encountered were INF or NaN.\n',...
                                     output.message);
            % output
            varargout{4} = output;

            % in case the output function requested to stop
            if outputFcnbreak
                output.message  = 'GODLIKE was terminated by one of the output functions.';
                output.exitflag = 2;
                varargout{3} = output.exitflag;
                varargout{4} = output;
            end
        end
    end

     % last call to output function
    if ~isempty(options.OutputFcn)
        cellfun(@(y)y([],[], 'done'),...
                options.OutputFcn,...
                'UniformOutput', false);
    end


    %% Nested functions
    % ==========================================================================

    % Initialization shizzle
    % =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =



    % test the function, and determine the amount of objectives. Here
    % it is decided whether the optimization is single-objective or
    % multi-objective.
    function [options,...
              single,...
              multi,...
              fevals] = test_funfcn(options)

        % initialize
        fevals = 0;
        options.num_objectives = 1;

        % split multi/single objective
        if iscell(funfcn) && (numel(funfcn) > 1)
            % no. of objectives is simply the amount of provided objective functions
            options.num_objectives = numel(funfcn);
            % single is definitely false
            single = false;
        elseif iscell(funfcn) && (numel(funfcn) == 1)
            % single it true but might still change to false
            single = true;
            % also convert function to function_handle in this case
            funfcn = funfcn{1};
        else
            % cast fun to cell
            funfcn = {funfcn};
            % single is true but might still change to false
            single = true;
        end

        % Try to evaluate the objective and constraint functions, with the
        % original [lb]. If any evaluation fails, throw an error
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        % reshape to original size
        lb_original = reshape(lb, sze);

        % loop through all objective functions
        % (also works for single function)
        for ii = 1:numel(funfcn)

            % try to evaluate the function
            try
                % simply evaluate the function with the lower bound
                if options.ConstraintsInObjectiveFunction == 0
                    % no constraints
                    sol = feval(funfcn{ii}, (lb_original));
                % constraints might be given in the objective functions
                else
                    arg_out = cell(1, options.ConstraintsInObjectiveFunction);
                    [arg_out{:}] = feval(funfcn{ii}, lb_original);
                    sol = arg_out{1};
                    con = arg_out{options.ConstraintsInObjectiveFunction};
                    % con MUST be a vector
                    if ~isvector(con)
                        error([mfilename ':confun_must_return_vector'], [...
                             'All constraint functions must return a [Nx1] or [1xN] vector ',...
                             'of constraint violations.\nSee the documentation for more details.']);
                    end
                end
                % keep track of the number of function evaluations
                fevals = fevals + 1;

                % see whether single must be changed to multi
                if single && (numel(sol) > 1)
                    single = false;
                    options.num_objectives = numel(sol);
                    options.obj_columns    = true;
                end

                % it might happen that more than one function is provided,
                % but that one of the functions returns more than one function
                % value. GODLIKE does not handle that case
                if (numel(sol) > 1) && (ii > 1)
                    error([mfilename ':multimulti_not_allowed'], [...
                          'GODLIKE cannot optimize multiple multi-objective problems ',...
                          'simultaneously.\nUse GODLIKE multiple times on each of your objective ',...
                          'functions separately.\n\nThis error is generated because the first of ',...
                          'your objective functions returned\nmultiple values, while ',...
                          'you provided multiple objective functions. Only one of\nthese formats ',...
                          'can be used for multi-objective optimization, not both.'])
                end

            % if evaluating the function fails, throw error
            catch userFcn_ME
                pop_ME = MException([mfilename ':function_doesnt_evaluate'], ...
                                    'GODLIKE cannot continue: failure during function evaluation.');
                userFcn_ME = addCause(userFcn_ME, pop_ME);
                rethrow(userFcn_ME);
            end % try/catch

        end % for

        % see if the optimization is multi-objective
        multi = ~single;

        % loop through (all) constraint function(s)
        if constrained && ...
                (options.ConstraintsInObjectiveFunction == 0)

            for ii = 1:numel(confcn)
                % some might be empty
                if isempty(confcn{ii})
                    continue, end

                % try to evaluate the function
                try
                    % simply evaluate the function with the lower bound
                    con = feval(confcn{ii}, lb_original);
                    % keep track of the number of function evaluations
                    fevals = fevals + 1;
                    % con MUST be a vector
                    if ~isvector(con)
                        error([mfilename ':confun_must_return_vector'], [...
                              'All constraint functions must return a [Nx1] or [1xN] vector ',...
                              'of constraint violations.\nSee the documentation for more details.']);
                    end

                % if evaluating the function fails, throw error
                catch userFcn_ME
                    pop_ME = MException([mfilename ':constraint_function_doesnt_evaluate'], [...
                                        'GODLIKE cannot continue: failure during evaluation of ',...
                                        'one of the constraint functions.']);
                    userFcn_ME = addCause(userFcn_ME, pop_ME);
                    rethrow(userFcn_ME);
                end % try/catch

            end % for

        end % if constrained

    end % nested function

    
    % =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =
    % functions used in the main loop
    % =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =  =

    

    % shuffle and (re)initialize the population objects
    function pop = interchange_populations(pop)

        % just initialize populations if this is the first iteration
        if (generation == 1)
            
            for ii = 1:number_of_algorithms
                
                options.algorithm = which_ones{ii};
                
                if single
                    pop{ii} = popSingle(funfcn,...
                                        frac_popsize(ii),...
                                        lb, ub,...
                                        sze,...
                                        dimensions,...
                                        options);
                else
                    pop{ii} = popMulti(funfcn,...
                                       frac_popsize(ii),...
                                       lb, ub,...
                                       sze,...
                                       dimensions,...
                                       options);
                end
            end  
            
            return;
            
        end

        % don't shuffle if there's only one algorithm
        if (number_of_algorithms == 1)
            return, end

        % initialize
        parent_pops    = zeros(total_popsize, dimensions);
        parent_fits    = zeros(total_popsize, options.num_objectives);
        offspring_pops = parent_pops;
        offspring_fits = parent_fits;
        
        if multi
            front_numbers = zeros(total_popsize, 1);

            %crowding_distances = [front_numbers;front_numbers];
            %{
            if (generation == 2)
               % only one set after 1st generation
               crowding_distances = front_numbers;
            else
               crowding_distances = [front_numbers;front_numbers];
            end
            %}
            crowding_size = 0;
            for ii = 1:number_of_algorithms
                if (pop{ii}.iterations == 1)
                    % only one set after 1st generation
                    crowding_size = crowding_size + pop{ii}.size;
                else
                    crowding_size = crowding_size + 2 * pop{ii}.size;
                end
                crowding_distances = zeros(crowding_size, 1);
            end

        end
        
        if constrained
            parent_constrviolation     = zeros(popsize, numel(confcn));
            parent_unpenalized_fits    = zeros(popsize, options.num_objectives);
            offspring_constrviolation  = parent_constrviolation;
            offspring_unpenalized_fits = parent_unpenalized_fits;
        end
        
        lfe1 = 0;
        lfe2 = 0; % Last Filled Entry (lfe)

        % extract all current populations, their function values,
        % and other relevant information
        for ii = 1:number_of_algorithms

            % rename stuff for clarity
            popinfo = pop{ii}.pop_data;         
            popsz   = pop{ii}.size;

            % both for single and multi-objective
            parent_pops(lfe1+1:lfe1+popsz, :)  = popinfo.parent_population;
            parent_fits(lfe1+1:lfe1+popsz, :)  = popinfo.function_values_parent;
            offspring_pops(lfe1+1:lfe1+popsz,:)= popinfo.offspring_population;
            offspring_fits(lfe1+1:lfe1+popsz,:)= popinfo.function_values_offspring;

            % stuff specific for multi-objective optimization
            if multi
                front_numbers(lfe1+1:lfe1+popsz, :)        = popinfo.front_number;

                if (pop{ii}.iterations == 1)
                    multisize = popsz;
                else
                    multisize = 2*popsz;
                end

                crowding_distances(lfe2+1:lfe2+multisize, :) = popinfo.crowding_distance;
                lfe2 = lfe2 + multisize;
            end

            lfe1 = lfe1 + popsz;
            lfe2 = lfe2 + popsz;

        end % for

        % shuffle everything at random
        [dummy, rndinds] = sort(rand(total_popsize, 1));%#ok<ASGLU>
        parent_pops = parent_pops(rndinds,:);    
        parent_fits = parent_fits(rndinds,:);    
        
        offspring_pops = offspring_pops(rndinds,:);
        offspring_fits = offspring_fits(rndinds,:);

        if multi
            [dummy, rndinds2]  = sort(rand(crowding_size, 1));%#ok<ASGLU>
            front_numbers      = front_numbers(rndinds,:);
            crowding_distances = crowding_distances(rndinds2,:);
        end

        % re-initialize populations accordingly
        for ii = 1:number_of_algorithms

            % rename for clarity
            fp = frac_popsize(ii);

            % split everything up according to current [frac_popsize]
            new_popinfo.parent_population         = parent_pops(1:fp, :);
            new_popinfo.function_values_parent    = parent_fits(1:fp, :);
            
            new_popinfo.offspring_population      = offspring_pops(1:fp, :);
            new_popinfo.function_values_offspring = offspring_fits(1:fp, :);
            
            if multi
                new_popinfo.front_number      = front_numbers(1:fp, :);
                new_popinfo.crowding_distance = crowding_distances(1:fp, :);
            end % if

            % change options - options for ASA are always different
            options = pop{ii}.options;

            % apply re-heating
            options.ASA.T0 = options.ASA.T0 / options.ASA.ReHeating / generation;

            % re-initialize
            if single, pop{ii} = popSingle(new_popinfo, pop{ii}, options);
            else,      pop{ii} = popMulti (new_popinfo, pop{ii}, options);
            end

            % shrink arrays (using "... = [];" for deletion is rather slow)
            parent_pops = parent_pops(fp+1:end,:);  
            parent_fits = parent_fits(fp+1:end,:);  
            
            offspring_pops = offspring_pops(fp+1:end,:);
            offspring_fits = offspring_fits(fp+1:end,:);
            
            if multi
                front_numbers      = front_numbers(fp+1:end,:);
                crowding_distances = crowding_distances(fp+1:end,:);
            end

        end 
    end 

    % update output values, and check for convergence
    function [converged,...
              output,...
              counter] = check_convergence(converged,...
                                           output,...
                                           varargin)

         % some algorithms might be doubly used.
         % save which ones they are
         persistent sames

         % no input - initialize
         if (nargin == 0)

             % initially, no convergence
             converged = false;

             % some algorithms might be doubly used. Find out
             % which ones, and create proper indices
             sames = ones(number_of_algorithms, 1);
             for ii = 1:number_of_algorithms
                 same        = strcmpi(which_ones, which_ones{ii});
                 sames(same) = 1:nnz(same);
             end

             % general settings
             output.algorithms = upper(which_ones); % algorithms used
             output.exitflag   = 0;                 % neutral exitflag
             output.message    = sprintf('No iterations have been performed.');
             output.funcCount  = 0;
             for ii = 1:number_of_algorithms
                 output.algorithm_info.(upper(which_ones{ii}))(sames(ii)).funcCount  = 0;
                 output.algorithm_info.(upper(which_ones{ii}))(sames(ii)).iterations = 0;
             end

             % initialize [output] for single-objective optimization
             if single
                 output.descent_counter               = 0;
                 output.global_best_individual        = NaN(1,dimensions);
                 output.previous_global_best_individual = NaN(1,dimensions);
                 output.global_best_funval            = inf;
                 output.previous_global_best_funval   = inf;
                 output.best_funcvalues               = inf(1,number_of_algorithms);
                 output.previous_best_funcvalues      = inf(1,number_of_algorithms);
                 output.best_individuals              = NaN(number_of_algorithms,dimensions);
                 output.previous_best_individuals     = NaN(number_of_algorithms,dimensions);
                 for ii = 1:number_of_algorithms
                     output.algorithm_info.(upper(which_ones{ii}))(sames(ii)).last_population = [];
                     output.algorithm_info.(upper(which_ones{ii}))(sames(ii)).last_fitnesses  = [];
                 end
             end

             % initialize [output] for multi-objective optimization
             if multi
                 output.pareto_front_individuals = [];
                 output.pareto_front_fitnesses   = [];
                 output.most_efficient_point     = [];
                 output.most_efficient_fitnesses = [];
             end

             % we're done!
             return;

         % otherwise, update according to the current status of [pops]
         else

             % both per-algorithm and global check needs to be performed.
             % the mode of operation depends on the presence of a third
             % input argument. If given, only the current populations is
             % checked. If  omitted, all populations are checked.
             if (nargin == 3)
                 alg_conv  = true;
                 algorithm = algo;
                 counter   = varargin{1};
             else
                 alg_conv = false;
             end

             % general stuff
             output.funcCount  = num_funevaluations;
             output.iterations = generation;
             for ii = 1:number_of_algorithms
                 output.algorithm_info.(upper(which_ones{ii}))(sames(ii)).iterations = pop{ii}.iterations;
                 output.algorithm_info.(upper(which_ones{ii}))(sames(ii)).funcCount  = pop{ii}.funevals;
             end

             % convergence might already have occured. Determine the reason
             if converged
                 
                 % maximum function evaluations have been exceeded.
                 if (num_funevaluations >= options.MaxFunEvals)
                     output.exitflag = -1;
                     output.message = sprintf(['Optimization terminated:\n',...
                         ' Maximum amount of function evaluations has been reached.\n',...
                         ' Increase ''MaxFunEvals'' option.']);
                 end
                 
                 % maximum allowable iterations have been exceeded.
                 if (generation >= options.MaxIters)
                     output.exitflag = -2;
                     output.message = sprintf(['Optimization terminated:\n',...
                         ' Maximum amount of iterations has been reached.\n',...
                         ' Increase ''MaxIters'' option.']);
                 end
                 
             end

             % stuff specific for single objective optimization
             if single

                 % store previous global best function value
                 output.previous_global_best_individual = output.global_best_individual;
                 output.previous_global_best_funval = output.global_best_funval;
                 output.previous_best_funcvalues    = output.best_funcvalues;
                 output.previous_best_individuals   = output.best_individuals;

                 % assign global best individuals and their function
                 % values per algorithm
                 for ii = 1:number_of_algorithms
                     [output.best_funcvalues(ii), ind] = min(pop{ii}.fitnesses);
                     output.best_individuals(ii,:) = pop{ii}.individuals(ind, :);
                 end
                 
                 % save new global best individual and function value
                 [min_func_val, index] = min(output.best_funcvalues);
                 if (output.global_best_funval > min_func_val)
                     output.global_best_funval     = min_func_val;
                     output.global_best_individual = output.best_individuals(index, :);
                 end

                 % check convergence
                 if ~converged

                     % per-algorithm convergence
                     if alg_conv
                         
                         % update counter
                         if output.best_funcvalues(algorithm) < options.AchieveFunVal
                             if abs(output.previous_best_funcvalues(algorithm) - ...
                                    output.best_funcvalues(algorithm)) <= options.TolFun &&...
                                all(abs( output.previous_best_individuals(algorithm) - ...
                                         output.best_individuals(algorithm) )) <= options.TolX
                                 counter = counter + 1;
                             else
                                 counter = 0;
                             end
                         end % if

                         % if counter is larger than preset maximum,
                         % convergence has been achieved
                         if (counter > options.TolIters)
                             converged = true;
                         end

                     % GODLIKE-convergence
                     else
                         % update counter
                         if output.global_best_funval < options.AchieveFunVal
                             if abs(output.previous_global_best_funval - ...
                                     output.global_best_funval) <= options.TolFun && ...
                                all(abs( output.previous_global_best_individual - ...
                                         output.global_best_individual )) <= options.TolX
                                 output.descent_counter = output.descent_counter + 1;
                             else
                                 output.descent_counter = 0;
                             end
                         end % if

                         % if counter is larger than preset maximum, and the
                         % minimum amount of iterations has been performed,
                         % convergence has been achieved
                         if generation > options.MinIters && (output.descent_counter > 2)
                             converged = true;
                         end 
                     end

                     % finalize output
                     if converged && ~alg_conv
                         % insert the last population in the output
                         for ii = 1:number_of_algorithms
                             output.algorithm_info.(which_ones{ii})(sames(ii)).last_population = ...
                                 pop{ii}.individuals;
                             output.algorithm_info.(which_ones{ii})(sames(ii)).last_fitnesses = ...
                                 pop{ii}.fitnesses;
                         end
                         % finalize output structure
                         output.exitflag = 1;
                         output.message = sprintf(['Optimization terminated:\n\n',...
                                                   ' Coordinate differences were less than OPTIONS.TolX, and decrease\n',...
                                                   ' in function value was less than OPTIONS.TolFun for two consecutive\n',...
                                                   ' GODLIKE-iterations. GODLIKE algorithm converged without any problems.']);
                     end
                 end 
             end

             % stuff specific for multi-objective optimization
             if multi

                 % check convergence
                 if ~converged
                     
                     % see if the minimum amount of iterations has
                     % been performed yet
                     if generation > options.MinIters
                         % test if ALL populations are non-dominated
                         all_nd = false(number_of_algorithms, 1);
                         for ii = 1:number_of_algorithms
                             all_nd(ii) = all(pop{ii}.pop_data.front_number == 0);
                         end

                         % if we have not broken prematurely, all fronts are zero, and
                         % thus we have convergence
                         if all(all_nd), converged = true; end

                         % finalize output structure
                         if converged
                             % complete output structure
                             output.exitflag = 1;
                             output.message = sprintf(['Optimization terminated:\n',...
                                                       'All trial solutions of all selected algorithms are non-dominated.\n',...
                                                       'GODLIKE algorithm converged without any problems.']);
                         end 
                     end 
                 end 

                 % if converged, complete output structure
                 if converged

                     % output complete Pareto front
                     for ii = 1:number_of_algorithms
                         output.pareto_front_individuals = [output.pareto_front_individuals;
                                                            pop{ii}.individuals];
                         output.pareto_front_fitnesses = [output.pareto_front_fitnesses;
                                                          pop{ii}.fitnesses];
                     end

                     % find most efficient point and its fitnesses
                     origin              = min(output.pareto_front_fitnesses);
                     shifted_fitnesses   = bsxfun(@minus, ...
                                                  output.pareto_front_fitnesses, ...
                                                  origin);
                     distances_sq        = sum(shifted_fitnesses.^2,2);
                     [dummy, index]      = min(distances_sq);%#ok<ASGLU>

                     output.most_efficient_point     = output.pareto_front_individuals(index, :);
                     output.most_efficient_fitnesses = output.pareto_front_fitnesses(index, :);
                 end 
             end 
         end 
         
    end 


    % form the proper [x] and [optimValues] for output functions
    function [x,...
              optimValues] = get_outputFcn_values(algorithm)

        % collect all the information one could possibly desire
        if ~isempty(algorithm)
            opt.algorithm  = pop{algorithm}.algorithm;
            opt.funcCount  = pop{algorithm}.funevals;
            opt.iterations = pop{algorithm}.iterations;
        else
            opt.algorithm  = [];
            opt.funcCount  = [];
            opt.iterations = [];
        end
        optimValues.optimizer = opt;

        optimValues.algorithm = 'GODLIKE';
        optimValues.funcCount = num_funevaluations;
        optimValues.iteration = generation;
        optimValues.popsize   = popsize;

        if single
            optimValues.type = 'single-objective';
            
            if constrained
                optimValues.best_fval                      = output.global_best_funval_unconstrained;
                optimValues.best_fval_constraint_violation = output.global_best_funval_constrviolation;
            else
                optimValues.best_fval = output.global_best_funval;
            end
            
            x = reshape(output.global_best_individual, sze);
            optimValues.best_individual = x;

        else
            optimValues.type = 'multi-objective';

            [non_dominated,...
             non_dominated_fits, ...
             most_efficient_point,...
             most_efficient_fitnesses,...
             violations] = get_Paretos();

            optimValues.number_of_nondominated_solutions = size(non_dominated,1);
            optimValues.nondominated_solutions           = non_dominated;
            optimValues.nondominated_function_values     = non_dominated_fits;
            optimValues.most_efficient_point             = reshape(most_efficient_point, sze);
            optimValues.most_efficient_fitnesses         = most_efficient_fitnesses;
            x = reshape(most_efficient_point, sze);

            if constrained
                optimValues.constraint_violations = violations; end
            
        end
        
    end

    % Get the complete Pareto-front, and the most efficient point
    % (multi-objective optimization only)
    function [non_dominated,...
              non_dominated_fits, ...
              most_efficient_point,...
              most_efficient_fitnesses,...
              violations] = get_Paretos()
        % TODO: (Rody Oldenhuis) complete this

        % for unconstrained problems
        violations = [];

        % get complete current Pareto front
        non_dominated      = [];
        non_dominated_fits = [];

        % find the last non-empty population in this stream
        t = sum(~cellfun('isempty', pop(:)));

        % the algorithm might not have been used yet
        %{
        if (pop{t}.iterations == 0)
            continue; end
        %}

        % get the indices for the non-dominated members
        Pareto_indices = (pop{t}.pop_data.front_number == 0);

        % append its individuals
        non_dominated = [non_dominated
                         pop{t}.individuals(Pareto_indices, :)];

        % and its fitnesses
        if constrained
            non_dominated_fits = [non_dominated_fits
                                  pop{t}.pop_data.unpenalized_function_values_parent(Pareto_indices, :)];
            violations = [violations
                          pop{t}.pop_data.constraint_violations_parent(Pareto_indices, :)];
        else
            non_dominated_fits = [non_dominated_fits
                                  pop{t}.fitnesses(Pareto_indices, :)];
        end

        % find most efficient point and its fitnesses
        origin                   = min(non_dominated_fits);
        shifted_fitnesses        = bsxfun(@minus, non_dominated_fits, origin);
        ranges                   = max(non_dominated_fits) - origin;
        scaled_fitnesses         = bsxfun(@rdivide, shifted_fitnesses*min(ranges), ranges);
        distances_sq             = sum(scaled_fitnesses.^2,2);
        [mindist_sq, index]      = min(distances_sq);%#ok
        most_efficient_point     = non_dominated(index, :);
        most_efficient_fitnesses = non_dominated_fits(index, :);

    end 

    % display the algorithm's progress
    function display_progress()

        % Double-check the options
        if isempty(options.display)
            return; end

        % If the algorithm is multistart, only print the header

        % current loop indices
        loop_index = algo;
        %TODO - display for MS
%         if ~strcmpi(pop{algo}.algorithm, 'MS')
%             algorithm_index = jj; end
         algorithm_index = jj;

        % Command window
        if any(strcmpi(options.display, {'on' 'CommandWindow'}))

            print_progress(loop_index,...
                           algorithm_index,...
                           generation,...
                           single,multi,...
                           number_of_algorithms,...
                           which_ones,...
                           pop,...
                           converged,...
                           options,...
                           frac_popsize,...
                           frac_iterations,...
                           output);
        end % if

        % Plot
        if strcmpi(options.display, 'Plot')
            plot_progress(loop_index,...
                          generation,...
                          single,multi,...
                          lb,ub,...
                          number_of_algorithms,...
                          which_ones,...
                          pop,...
                          converged,...
                          output);
        end % if
    end % nested function

end 

