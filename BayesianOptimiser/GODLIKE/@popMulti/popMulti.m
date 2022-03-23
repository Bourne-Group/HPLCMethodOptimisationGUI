classdef popMulti < popSingle
% POP_MULTI         Class definition for a population to be
%                   used for multi-objective optimization
%
% POP_MULTI is a SubClass of POP_SINGLE. The class
% constructor works in the same way as that of POP_SINGLE,
% with the exception that an additional property is set:
%
%   pop.num_objectives      (number of objectives)
%
% All inputs and other properties are the same as for
% POP_SINGLE -- type 'help pop_single' for more information.
%
% The method ITERATE is now suited to optimize multi-
% objective problems. To that end, several other (hidden)
% methods have been implemented:
%
%   NON_DOMINATED_SORT()
%
%       a general implementation of NSGA-II's non-dominated
%       sorting procedure. Sorts the current population
%       according to the domination level of the individuals.
%
%
%   pool = TOURNAMENT_SELECTION(pool_size, tournament_size)
%
%       a general tournament selection procedure, that takes
%       [tournament_size] individuals randomly selected from
%       the offspring population and lets them compete with
%       the rankings and crowding distances as determining
%       factors. The winning individual of each tournament
%       is inserted into [pool] until that [pool] contains
%       [pool_size] individuals.
%
%   UPDATE_ALGORITHMS()
%
%       Called from NON_DOMINATED_SORT(), updates some
%       globaly changing values for the different algorithms.
%       In pop_single, this is done in REPLACE_PARENTS(), but
%       as that step is not executed here, an extra method is
%       required. This updates for instance the [lbest],
%       [nbest] and [gbest] for PSO, and the temperature for
%       ASA.
%
%
% See also popSingle, GODLIKE.


% Please report bugs and inquiries to:
%
% Name    : Rody P.S. Oldenhuis
% E-mail  : oldenhuis@gmail.com
% Licence : 2-clause BSD (see License.txt)

% If you find this work useful, please consider a donation:
% https://www.paypal.me/RodyO/3.5

    %% Properties

    % properties additional to those of popSingle
    properties
        num_objectives     % number of objectives
        % contents of pop_data for multi-objective
        % optimization:
        %      pop_data.parent_population
        %      pop_data.offspring_population
        %      pop_data.function_values_parent
        %      pop_data.function_values_offspring
        %      pop_data.front_number
        %      pop_data.crowding_distance
    end

    
    %% Methods
    
    % class basics
    methods (Access = public)

        % simple constructor: create pop_single object, and
        % just add the number of objectives
        function pop = popMulti(varargin)            
            pop = pop@popSingle(varargin{:});            
            pop.num_objectives = pop.options.num_objectives;
        end 


    end

    % Public functionality
    methods
            % perform one multi-objective iteration
            iterate(pop);
    end

    % Methods for internal use
    methods (Access = protected, Hidden)

        % non-dominated sort, and crowding distance assignment
        nonDominatedSort(pop);

        % tournament selection with crowding distances and rankings
        % as competitive factors
        pool = tournamentSelection(pop, pool_size, tournament_size);

        % initialize algorithms
        initializeAlgorithms(pop);

        % Update globally changing variables associated with each algorithm
        updateAlgorithms(pop);

        % overload from pop_single
        evaluateFunction(pop);

    end 

end 
