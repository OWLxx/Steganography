function results = ensemble(settings)
% -------------------------------------------------------------------------
% Ensemble Classification | December 2011 | public version 1.1
% -------------------------------------------------------------------------
% What is new in version 1.1:
%  - fixed fclose bug (Error: too many files open)
%  - covariance caching option removed (option settings.keep_cov)
%  - added settings.verbose = 2 option (screen output of only the last row)
%  - ensemble now works even if full dimension is equal to 1 or 2. If equal
%    to 1, multiple decisions are still combined if bootstrap sampling is
%    turned on as different base learners are trained on different
%    bootstrap samples (bagging)
%  - resulting output structure now contains new fields
%    .testing_image_filenames, .testing_true_labels, .testing_predictions
%    from which an information about what images were misclassified could
%    be obtained; also, the user can now extract information about false
%    alarms and missed detections
%  - instead of {cover,stego,seed_trntst,ratio}, user can specify
%    {cover,stego,cover_tst,stego_tst} - in that case, ALL cover-stego
%    pairs from 'cover' and 'stego' are used for training, and ALL features
%    from cover_tst,stego_tst (not necessarily paired) are used for
%    testing; at least one cover_tst and one stego_tst is required
%  - new option settings.store_trained_machine_as allows to save the
%    trained machine (the whole trained ensemble + its parameters)
%  - new option settings.use_trained_machine_from loads the trained
%    ensemble from the specified *.mat file (created using the previous
%    option .store_trained_machine_as) and the training phase is skipped;
%    these two options enable user to re-use already trained ensemble and
%    apply it to different sets of cover/stego features, for example to a
%    different database of images
% -------------------------------------------------------------------------
% Copyright (c) 2011 DDE Lab, Binghamton University, NY.
% All Rights Reserved.
% -------------------------------------------------------------------------
% Permission to use, copy, modify, and distribute this software for
% educational, research and non-profit purposes, without fee, and without a
% written agreement is hereby granted, provided that this copyright notice
% appears in all copies. The program is supplied "as is," without any
% accompanying services from DDE Lab. DDE Lab does not warrant the
% operation of the program will be uninterrupted or error-free. The
% end-user understands that the program was developed for research purposes
% and is advised not to rely exclusively on the program for any reason. In
% no event shall Binghamton University or DDE Lab be liable to any party
% for direct, indirect, special, incidental, or consequential damages,
% including lost profits, arising out of the use of this software. DDE Lab
% disclaims any warranties, and has no obligations to provide maintenance,
% support, updates, enhancements or modifications.
% -------------------------------------------------------------------------
% Contact: jan@kodovsky.com | fridrich@binghamton.edu | December 2011
%          http://dde.binghamton.edu/download/ensemble
% -------------------------------------------------------------------------
% References:
% [1] - J. Kodovsky, J. Fridrich, and V. Holub. Ensemble classifiers for
% steganalysis of digital media. IEEE Transactions on Information Forensics
% and Security. Currently under review.
% -------------------------------------------------------------------------
% settings
%   .cover - cover feature file(s); a string or a cell array (example_4.m)
%   .stego - stego feature file(s); a string or a cell array (example_4.m)
%   .seed_trntst - PRNG seed for training/testing set division
%   .seed_subspaces (default = random) - PRNG seed for random subspace
%         generation 
%   .seed_bootstrap (default = random) - PRNG seed for bootstrap samples
%         generation 
%   .ratio (default = 0.5) - relative number of training images from .cover
%         and .stego (the rest is used for testing)
%   .cover_tst - this is a new (optional) parameter in version 1.1; if
%         specified, ALL cover-stego pairs from .cover and .stego are used
%         for ensemble training, and the testing is performed on feature
%         file(s) specified here in cover_tst; in that case, .seed_trntst
%         and .ratio are ignored; structure of .cover_tst is the same as
%         the one of .cover
%   .stego_tst - stego counterpart of cover_tst; both (or none of them)
%         need to be specified
%   .d_sub (default = 'automatic') - random subspace dimensionality; either
%         an integer (e.g. 200) or the string 'automatic' is accepted; in
%         the latter case, an automatic search for the optimal subspace
%         dimensionality is performed, see [1] for more details
%   .L (default = 'automatic') - number of random subspaces / base
%         learners; either an integer (e.g. 50) or the string 'automatic'
%         is accepted; in the latter case, an automatic stopping criterion
%         is used, see [1] for more details
%   .output (default = './output/date_x.log') - log file where both the
%         progress and the results of the classification are stored
%   .bootstrap (default = 1) - turn on/off bootstrap sampling of the
%         training set for training of individual base learners; this
%         option will be automatically turned on when either search for
%         d_sub or an automatic stopping criterion for L is to be performed
%         as bootstrapping is needed for out-of-bag (OOB) estimates these
%         techniques are based on; see [1] for more details
%    .verbose (default = 1) - turn on/off screen output
%         = 0 ... no screen output
%         = 1 ... full screen output
%         = 2 ... screen output of only the last row (results)
%    .ignore_warnings (default = 1) - ignore 'MATLAB:nearlySingularMatrix'
%         warning during the FLD training => speed-up; ignoring these
%         warnings had no effect on performance in our experiments; if the
%         value is set to 0, warnings will not be ignored; in that case,
%         the diagonal of the ill-conditioned covariance matrix will be
%         iteratively weighted with increasing weights until the matrix is
%         well conditioned (see the code for details)
%    .store_trained_machine_as - path to the *.mat file where the trained
%         ensemble will be saved (for later use); testing is still
%         executed, as if the trained ensemble was not saved
%    .use_trained_machine_from - path to the previously trained ensemble
%         stored in the *.mat file using the previous option
%         .store_trained_machine_as; if .use_trained_machine_from is
%         specified, the training phase is skipped
%
% Parameters for the search for d_sub (when .d_sub = 'automatic'):
%
%    .k_step (default = 200) - initial step for d_sub when searching from
%         left (stage 1 of Algorithm 2 in [1])
%    .Eoob_tolerance (default = 0.02) - the relative tolerance for the
%         minimality of OOB within the search, i.e. specifies the stopping
%         criterion for the stage 2 in Algorithm 2
%
% Both default parameters work well for most of the steganalysis scenarios.
%
% Parameters for automatic stopping criterion for L (when .L ='automatic');
% see [1] for more details:
%
%    .L_kernel (default = ones(1,5)/5) - over how many values of OOB
%         estimates is the moving average taken over
%    .L_min_length (default = 25) - the minimum number of random subspaces
%         that will be generated
%    .L_memory (default = 50) - how many last OOB estimates need to stay in
%         the epsilon tube
%    .L_epsilon (default = 0.005) - specification of the epsilon tube
%
% According to our experiments, these values are sufficient for most of the
% steganalysis tasks (different algorithms and features). Nevertheless, any
% of these parameters can be modified before calling the ensemble if
% desired.
% -------------------------------------------------------------------------

% check settings, set default values, initial screen print
settings = check_initial_setup(settings);
% pre-generate seeds for random subspaces and bootstrap samples
PRNG = generate_seeds(settings);

if isfield(settings,'use_trained_machine_from')
    % use previously trained machine
    load(settings.use_trained_machine_from);
else
    % create training set
    [Xc,Xs,settings] = create_training(settings);

    % if full dimensionality is 1, just do a single FLD
    if settings.max_dim == 1
        settings.d_sub = 1;
        settings.k = 1;
        settings.improved_search_for_k = 0;
        settings.bootstrap_backup = settings.bootstrap;
        settings.bootstrap = settings.bootstrap_user;
    end

    % initialization of the search for k (if requested)
    [SEARCH,settings] = initialize_search(settings);
    [search_counter,results,MIN_OOB,OOB.error] = deal(0,[],1,1);

    if settings.verbose==1
        if settings.max_dim>1
            fprintf('Full dimensionality = %i\n',settings.max_dim);
        else
            fprintf('Full dimensionality = %i => turning off search for d_sub\n',settings.max_dim);
            if settings.bootstrap_backup~=settings.bootstrap
                fprintf('Turning off bootstrap as desired.\n');
            end
        end
    end


    % search loop (if search for k is to be executed)
    while SEARCH.in_progress
        search_counter = search_counter+1;

        % initialization
        [SEARCH.start_time_current_k,i,next_random_subspace,TXT,base_learner] = deal(tic,0,1,'',cell(settings.max_number_base_learners,1));

        % loop over individual base learners
        while next_random_subspace
            i = i+1;

            %%% RANDOM SUBSPACE GENERATION
            rand('state',double(PRNG.subspaces(i)));
            base_learner{i}.subspace = randperm(settings.max_dim);
            subspace = base_learner{i}.subspace(1:settings.k);

            %%% BOOTSTRAP INITIALIZATION
            OOB = bootstrap_initialization(PRNG,Xc,Xs,OOB,i,settings);

            %%% TRAINING PHASE
            base_learner{i} = FLD_training(Xc,Xs,i,base_learner{i},OOB,subspace,settings);

            %%% OOB ERROR ESTIMATION
            OOB = update_oob_error_estimates(Xc,Xs,base_learner{i},OOB,i,subspace,settings);

            [next_random_subspace,MSG] = getFlag_nextRandomSubspace(i,OOB,settings);

            % SCREEN OUTPUT
            CT = double(toc(SEARCH.start_time_current_k));
            if settings.bootstrap
                TXT = updateTXT(TXT,sprintf(' - d_sub %s : OOB %.4f : L %i : T %.1f sec%s',k_to_string(settings.k),OOB.error,i,CT,MSG),settings);
            else
                TXT = updateTXT(TXT,sprintf(' - d_sub %s : L %i : T %.1f sec%s',k_to_string(settings.k),i,CT,MSG),settings);
            end

        end % while next_random_subspace

        results.search.k(search_counter) = settings.k;
        updateLog_swipe(settings,TXT,'\n');

        if OOB.error<MIN_OOB || ~settings.bootstrap
            % found the best value of k so far
            FINAL_BASE_LEARNER = base_learner;
            [MIN_OOB,OPTIMAL_K,OPTIMAL_L] = deal(OOB.error,settings.k,i);
        end

        [settings,SEARCH] = update_search(settings,SEARCH,OOB.error);
        results = add_search_info(results,settings,search_counter,SEARCH,i,CT);
        clear base_learner OOB
        OOB.error = 1;
    end % while search_in_progress

    % training time evaluation
    results.training_time = toc(uint64(settings.start_time));
    TXT = sprintf('training time: %.1f sec',results.training_time);
    updateLog_swipe(settings,TXT,[TXT '\n']);

    % testing phase
    clear Xc Xs;

    % store trained machine if desired
    if isfield(settings,'store_trained_machine_as')
        save(settings.store_trained_machine_as,'MIN_OOB','FINAL_BASE_LEARNER','OOB','OPTIMAL_K','OPTIMAL_L','MIN_OOB','SEARCH');
    end
end

[Yc,Ys,settings,results.testing_image_filenames] = create_testing(settings);
base_learner = FINAL_BASE_LEARNER;
[TST_ERROR,results.testing_true_labels,results.testing_predictions] = calculate_testing_error(Yc,Ys,base_learner,OPTIMAL_L,OPTIMAL_K);
results.testing_error = TST_ERROR;

% final output and logging
results = collect_final_results(settings,OPTIMAL_K,OPTIMAL_L,MIN_OOB,results);
if settings.bootstrap
    TXT = sprintf('optimal d_sub %i : OOB %.4f : TST %.4f : L %i : T %.1f sec',OPTIMAL_K,MIN_OOB,TST_ERROR,OPTIMAL_L,results.time);
else
    TXT = sprintf('optimal d_sub %i : TST %.4f : L %i : T %.1f sec',OPTIMAL_K,TST_ERROR,OPTIMAL_L,results.time);
end
updateLog_swipe(settings,TXT,[TXT '\n'],1);

% -------------------------------------------------------------------------
% SUPPORTING FUNCTIONS
% -------------------------------------------------------------------------

function settings = check_initial_setup(settings)
% check settings, set default values
settings.start_time = tic;

% if PRNG seeds for random subspaces and bootstrap samples not specified, generate them randomly
if ~isfield(settings,'seed_subspaces') || ~isfield(settings,'seed_bootstrap')
    rand('state',sum(100*clock));
    if ~isfield(settings,'seed_subspaces')
        settings.seed_subspaces = round(rand()*899999997+100000001);
    end
    if ~isfield(settings,'seed_bootstrap')
        settings.seed_bootstrap = round(rand()*899999997+100000001);
    end
end

% default location of a log-file
if ~isfield(settings,'output')
    settings.output = ['output/' date() '_1.log'];
    i = 1;
    while exist(settings.output,'file')
        i = i+1;
        settings.output = ['output/' date() '_' num2str(i) '.log'];
    end
end

% check cover,stego,seed_trntst
if ~isfield(settings,'cover'),  error('ERROR: settings.cover not specified.'); end
if ~isfield(settings,'stego'),  error('ERROR: settings.stego not specified.'); end
if ~ischar(settings.cover) && (length(settings.cover)~=length(settings.stego)),error('ERROR: settings.cover and settings.stego do not have equal lengths.');end

settings.testing_sets_separately = 0;
if isfield(settings,'cover_tst')
    % testing sets defined separately
    if ~ischar(settings.cover) && (length(settings.cover)~=length(settings.cover_tst)),error('ERROR: settings.cover_tst and settings.cover do not have equal lengths.');end
    if ~isfield(settings,'stego_tst'), error('ERROR: settings.stego_tst not specified'); end
    if ~ischar(settings.cover) && (length(settings.cover)~=length(settings.stego_tst)),error('ERROR: settings.stego_tst and settings.cover do not have equal lengths.');end
    settings.testing_sets_separately = 1;
end


if ~settings.testing_sets_separately && ~isfield(settings,'seed_trntst'),   error('ERROR: settings.seed not specified.');  end

% set default values
if ~isfield(settings,'ratio'), settings.ratio = 0.5; end
if settings.testing_sets_separately, settings.ratio = 1; end
if ~isfield(settings,'L'),     settings.L = 'automatic'; end
if ~isfield(settings,'d_sub'), settings.d_sub = 'automatic'; end
settings.k = settings.d_sub;
if ~isfield(settings,'bootstrap'), settings.bootstrap = 1; end
settings.bootstrap_user = settings.bootstrap;
if ~isfield(settings,'normalize'), settings.normalize = 0; end
if ~isfield(settings,'type'), settings.type = 'FLD'; end
if ~isfield(settings,'criterion'), settings.criterion = 'min(MD+FA)'; end
if ~isfield(settings,'fusion_strategy'), settings.fusion_strategy = 'majority_voting'; end
if ~isfield(settings,'verbose'), settings.verbose = 1; end
if ~isfield(settings,'max_number_base_learners'), settings.max_number_base_learners = 500; end

if ~isfield(settings,'ignore_warnings')
    % ignore 'MATLAB:nearlySingularMatrix' warning during FLD => speed-up
    % (no effect on performance according to our experiments)
    settings.ignore_warnings = true;
end

if isfield(settings,'keep_cov'), warning('Covariance caching (option settings.keep_cov) was disabled in Ensemble version 1.1.\n'); end %#ok<WNTAG>

% Set default values for the automatic stopping criterion for L
if ischar(settings.L)
    if ~isfield(settings,'L_kernel'),     settings.L_kernel = ones(1,5)/5; end
    if ~isfield(settings,'L_min_length'), settings.L_min_length = 25; end
    if ~isfield(settings,'L_memory'),     settings.L_memory = 50; end
    if ~isfield(settings,'L_epsilon'),    settings.L_epsilon = 0.005; end
    settings.bootstrap = 1;
end

% Set default values for the search for the subspace dimension k
if ischar(settings.k)
    if ~isfield(settings,'Eoob_tolerance'), settings.Eoob_tolerance = 0.02; end
    if ~isfield(settings,'k_step'), settings.k_step = 200; end
    settings.bootstrap = 1;
    settings.improved_search_for_k = 1;
else
    settings.improved_search_for_k = 0;
end

initial_screen_output(settings);

function initial_screen_output(settings)
% initial screen and logging output
if settings.verbose==1
    printfunc = @fprintf2;
else
    printfunc = @fprintf;
end
    
[pathstr, name, ext] = fileparts(settings.output); %#ok<NASGU>
if ~isempty(pathstr) && ~exist(pathstr,'dir'), mkdir(pathstr); end

fid = fopen(settings.output,'w');
printfunc(fid, '# -------------------------\n');
printfunc(fid, '# Ensemble classification\n');

if ischar(settings.cover)
    COVER_OUT = settings.cover;
else
    COVER_OUT = '{';
    for i=1:length(settings.cover)
        COVER_OUT = [COVER_OUT settings.cover{i} ',']; %#ok<AGROW>
    end
    COVER_OUT = [COVER_OUT(1:end-1) '}'];
end
if ischar(settings.stego)
    STEGO_OUT = settings.stego;
else
    STEGO_OUT = '{';
    for i=1:length(settings.stego)
        STEGO_OUT = [STEGO_OUT settings.stego{i} ',']; %#ok<AGROW>
    end
    STEGO_OUT = [STEGO_OUT(1:end-1) '}'];
end

printfunc(fid,['# cover : ' COVER_OUT '\n']);
printfunc(fid,['# stego : ' STEGO_OUT '\n']);
if isfield(settings,'cover_tst')
    
    
    if ischar(settings.cover)
        COVER_OUT = settings.cover_tst;
    else
        COVER_OUT = '{';
        for i=1:length(settings.cover_tst)
            COVER_OUT = [COVER_OUT settings.cover_tst{i} ',']; %#ok<AGROW>
        end
        COVER_OUT = [COVER_OUT(1:end-1) '}'];
    end
    if ischar(settings.stego_tst)
        STEGO_OUT = settings.stego_tst;
    else
        STEGO_OUT = '{';
        for i=1:length(settings.stego_tst)
            STEGO_OUT = [STEGO_OUT settings.stego_tst{i} ',']; %#ok<AGROW>
        end
        STEGO_OUT = [STEGO_OUT(1:end-1) '}'];
    end
    printfunc(fid,['# cover - testing: ' COVER_OUT '\n']);
    printfunc(fid,['# stego - testing: ' STEGO_OUT '\n']);
else
    printfunc(fid,'# trn/tst ratio : %.4f\n',settings.ratio);
end
if ~ischar(settings.L)
    printfunc(fid,'# L : %i\n',settings.L);
else
    printfunc(fid,'# L : %s (min %i, length %i, eps %.5f)\n',settings.L,settings.L_min_length,settings.L_memory,settings.L_epsilon);
end
if ischar(settings.k)
    printfunc(fid,'# d_sub : automatic (Eoob tolerance %.4f, step %i)\n',settings.Eoob_tolerance,settings.k_step);
else
    printfunc(fid,'# d_sub : %i\n',settings.k);
end
if isfield(settings,'seed_trntst')
    if length(settings.seed_trntst)==1
        printfunc(fid,'# seed 1 (trn/tst) : %i\n',settings.seed_trntst);
        printfunc(fid,'# seed 2 (subspaces) : %i\n',settings.seed_subspaces);
        if settings.bootstrap
            printfunc(fid,'# seed 3 (bootstrap) : %i\n',settings.seed_bootstrap);
        end
    else
        printfunc(fid,'# seeds : [%i',settings.seed_trntst(1));
        for i=2:length(settings.seed)
            printfunc(fid,',%i',settings.seed_trntst(i));
        end
        printfunc(fid,']\n');
    end
end
if settings.bootstrap
    printfunc(fid,'# bootstrap : yes\n');
else
    printfunc(fid,'# bootstrap : no\n');
end
printfunc(fid, '# -------------------------\n');
fclose(fid);

function [next_random_subspace,TXT] = getFlag_nextRandomSubspace(i,OOB,settings)
% decide whether to generate another random subspace or not, based on the
% settings
TXT='';
if ischar(settings.L)
    if strcmp(settings.L,'automatic')
        % automatic criterion for termination
        next_random_subspace = 1;
        if ~isfield(OOB,'x'), next_random_subspace = 0; return; end
        if length(OOB.x)<settings.L_min_length, return; end
        A = convn(OOB.y(max(length(OOB.y)-settings.L_memory+1,1):end),settings.L_kernel,'valid');
        V = abs(max(A)-min(A));
        if V<settings.L_epsilon
            next_random_subspace = 0;
            return;
        end
        if i == settings.max_number_base_learners,
            % maximal number of base learners reached
            next_random_subspace = 0;
            TXT = ' (maximum reached)';
        end
        return;
    end
else
    % fixed number of random subspaces
    if i<settings.L
        next_random_subspace = 1;
    else
        next_random_subspace = 0;
    end
end

function [settings,SEARCH] = update_search(settings,SEARCH,currErr)
% update search progress
if ~settings.search_for_k, SEARCH.in_progress = false; return; end

SEARCH.E(settings.k==SEARCH.x) = currErr;

% any other unfinished values of k?
unfinished = find(SEARCH.E==-1);
if ~isempty(unfinished), settings.k = SEARCH.x(unfinished(1)); return; end

% check where is minimum
[MINIMAL_ERROR,minE_id] = min(SEARCH.E);

if SEARCH.step == 1 || MINIMAL_ERROR == 0
    % smallest possible step or error => terminate search
    SEARCH.in_progress = false;
    SEARCH.optimal_k = SEARCH.x(SEARCH.E==MINIMAL_ERROR);
    SEARCH.optimal_k = SEARCH.optimal_k(1);
    return;
end


if minE_id == 1
    % smallest k is the best => reduce step
    SEARCH.step = floor(SEARCH.step/2);
    SEARCH = add_gridpoints(SEARCH,SEARCH.x(1)+SEARCH.step*[-1 1]);
elseif minE_id == length(SEARCH.x)
    % largest k is the best
    if SEARCH.x(end) + SEARCH.step <= settings.max_dim && (min(abs(SEARCH.x(end) + SEARCH.step-SEARCH.x))>SEARCH.step/2)
        % continue to the right
        SEARCH = add_gridpoints(SEARCH,SEARCH.x(end) + SEARCH.step);
    else
        % hitting the full dimensionality
        if (MINIMAL_ERROR/SEARCH.E(end-1) >= 1 - settings.Eoob_tolerance) ... % desired tolerance fulfilled
            || SEARCH.E(end-1)-MINIMAL_ERROR < 5e-3 ... % maximal precision in terms of error set to 0.5%
            || SEARCH.step<SEARCH.x(minE_id)*0.05 ... % step is smaller than 5% of the optimal value of k
            % stopping criterion met
            SEARCH.in_progress = false;
            SEARCH.optimal_k = SEARCH.x(SEARCH.E==MINIMAL_ERROR);
            SEARCH.optimal_k = SEARCH.optimal_k(1);
            return;
        else
            % reduce step
            SEARCH.step = floor(SEARCH.step/2);
            if SEARCH.x(end) + SEARCH.step <= settings.max_dim
                SEARCH = add_gridpoints(SEARCH,SEARCH.x(end)+SEARCH.step*[-1 1]);
            else
                SEARCH = add_gridpoints(SEARCH,SEARCH.x(end)-SEARCH.step);
            end;
        end
    end
elseif (minE_id == length(SEARCH.x)-1) ... % if lowest is the last but one
        && (settings.k + SEARCH.step <= settings.max_dim) ... % one more step to the right is still valid (less than d)
        && (min(abs(settings.k + SEARCH.step-SEARCH.x))>SEARCH.step/2) ... % one more step to the right is not too close to any other point
        && ~(SEARCH.E(end)>SEARCH.E(end-1) && SEARCH.E(end)>SEARCH.E(end-2)) % the last point is not worse than the two previous ones
    % robustness ensurance, try one more step to the right
    SEARCH = add_gridpoints(SEARCH,settings.k + SEARCH.step);
else
    % best k is not at the edge of the grid (and robustness is resolved)
    err_around = mean(SEARCH.E(minE_id+[-1 1]));
    if (MINIMAL_ERROR/err_around >= 1 - settings.Eoob_tolerance) ... % desired tolerance fulfilled
        || err_around-MINIMAL_ERROR < 5e-3 ... % maximal precision in terms of error set to 0.5%
        || SEARCH.step<SEARCH.x(minE_id)*0.05 ... % step is smaller than 5% of the optimal value of k
        % stopping criterion met
        SEARCH.in_progress = false;
        SEARCH.optimal_k = SEARCH.x(SEARCH.E==MINIMAL_ERROR);
        SEARCH.optimal_k = SEARCH.optimal_k(1);
        return;
    else
        % reduce step
        SEARCH.step = floor(SEARCH.step/2);
        SEARCH = add_gridpoints(SEARCH,SEARCH.x(minE_id)+SEARCH.step*[-1 1]);
    end
end

unfinished = find(SEARCH.E==-1);
settings.k = SEARCH.x(unfinished(1));
return;
    
function [SEARCH,settings] = initialize_search(settings)
% search for k (=d_sub) initialization
if strcmp(settings.k,'automatic')
    % automatic search for k
    if settings.k_step >= settings.max_dim/4, settings.k_step = floor(settings.max_dim/4); end
    if settings.max_dim < 10, settings.k_step = 1; end
    SEARCH.x = settings.k_step*[1 2 3];
    if settings.max_dim==2, SEARCH.x = [1 2]; end
    SEARCH.E = -ones(size(SEARCH.x));
    SEARCH.terminate = 0;
    SEARCH.step = settings.k_step;
    settings.k = SEARCH.x(1);
    settings.search_for_k = true;
else
    SEARCH = [];
    settings.search_for_k = false;
end
SEARCH.in_progress = true;

function TXT = updateTXT(old,TXT,settings)
if isfield(settings,'kmin')
    if length(TXT)>3
        if ~strcmp(TXT(1:3),' - ')
            TXT = [' - ' TXT];
        end
    end
end
if settings.verbose==1
    if exist('/home','dir')
        % do not delete on cluster, it displays incorrectly when writing through STDOUT into file
        fprintf(['\n' TXT]);
    else
        fprintf([repmat('\b',1,length(old)) TXT]);
    end
end

function s = k_to_string(k)
if length(k)==1
    s = num2str(k);
    return;
end

s=['[' num2str(k(1))];
for i=2:length(k)
    s = [s ',' num2str(k(i))]; %#ok<AGROW>
end
s = [s ']'];

function fprintf2(fid,varargin)
fprintf(varargin{:});
fprintf(fid,varargin{:});

function updateLog_swipe(settings,TXT,TXT2,final)
if ~exist('final','var'), final=0; end
if settings.verbose==1 || (settings.verbose==2 && final==1), fprintf(TXT2); end
fid = fopen(settings.output,'a');
fprintf(fid,[TXT '\n']);
fclose(fid);

function PRNG = generate_seeds(settings)
rand('state',settings.seed_subspaces);
PRNG.subspaces = round(single(rand(1000,1))*899999997+100000001);
rand('state',settings.seed_bootstrap);
PRNG.bootstrap = round(single(rand(1000,1))*899999997+100000001);

function [Xc,Xs,settings] = create_training(settings)
% create training set (Xc and Xs)

if settings.verbose==1, fprintf('creating training set\n'); end

if ischar(settings.stego)
    % single feature file

    S = load(settings.stego,'names');
    C = load(settings.cover,'names');
    [Sn,Sx] = sort(S.names); clear S
    [Cn,Cx] = sort(C.names); clear C
    names = intersect(Cn,Sn);
    Ckeep = ismember(Cn,names); clear Cn
    Skeep = ismember(Sn,names); clear Sn

    if ~isfield(settings,'cover_tst')
        % create training and testing parts
        rand('state',settings.seed_trntst);
        names_rnd = names(randperm(length(names)));
        trn_names = names_rnd(1:round(settings.ratio*length(names)));
        TRN_ID = ismember(names,trn_names);
        clear trn_names names_rnd
    else
        % take all for training (testing on different files)
        TRN_ID = ismember(names,names);
    end

    % create training part from C
    C = load(settings.cover,'F');
    C = C.F(Cx,:); C = C(Ckeep,:); clear Ckeep Cx
    C(~TRN_ID,:) = []; Xc = C; clear C

    % create training part from S
    S = load(settings.stego,'F');
    S = S.F(Sx,:); S = S(Skeep,:); clear Skeep Sx
    S(~TRN_ID,:) = []; Xs = S; clear S
else
    % multiple feature files
    [S,C,Sn,Sx,Cn,Cx,Ckeep,Skeep] = deal(cell(length(settings.stego),1));
    for i=1:length(settings.stego)
        S{i} = load(settings.stego{i},'names');
        C{i} = load(settings.cover{i},'names');
        [Sn{i},Sx{i}] = sort(S{i}.names);
        [Cn{i},Cx{i}] = sort(C{i}.names);
        if i==1
            names = intersect(Cn{i},Sn{i});
        else
            names = intersect(intersect(Cn{i},Sn{i}),names);
        end
    end
    for i=1:length(settings.stego)
        Ckeep{i} = ismember(Cn{i},names);
        Skeep{i} = ismember(Sn{i},names);
    end
    
    if ~isfield(settings,'cover_tst')
        % create training and testing parts
        rand('state',settings.seed_trntst);
        names_rnd = names(randperm(length(names)));
        trn_names = names_rnd(1:round(settings.ratio*length(names)));
        TRN_ID = ismember(names,trn_names);
        clear trn_names names_rnd
    else
        % take all for training (testing on different files)
        TRN_ID = ismember(names,names);
    end

    Xc=[];Xs=[];
    for i=1:length(settings.stego)
        % create training part from cover
        C = load(settings.cover{i},'F');
        C = C.F(Cx{i},:); C = C(Ckeep{i},:);
        C(~TRN_ID,:) = []; Xc = [Xc C]; clear C %#ok<AGROW>

        % create training part from stego
        S = load(settings.stego{i},'F');
        S = S.F(Sx{i},:); S = S(Skeep{i},:);
        S(~TRN_ID,:) = []; Xs = [Xs S]; clear S %#ok<AGROW>
    end
end
settings.max_dim = size(Xs,2);

function [Xc,Xs,settings,IMG] = create_testing(settings)
% create testing set (Xc and Xs)

if settings.verbose==1, fprintf('creating testing set\n'); end

if isfield(settings,'cover_tst')
    COVER_BACKUP = settings.cover;
    STEGO_BACKUP = settings.stego;
    settings.cover = settings.cover_tst;
    settings.stego = settings.stego_tst;
end


if ischar(settings.stego)
    % single feature file

    S = load(settings.stego,'names');
    C = load(settings.cover,'names');
    [Sn,Sx] = sort(S.names); clear S
    [Cn,Cx] = sort(C.names); clear C
    

    if ~isfield(settings,'cover_tst')
        names = intersect(Cn,Sn);
        Ckeep = ismember(Cn,names);
        Skeep = ismember(Sn,names);
        % create training and testing parts
        rand('state',settings.seed_trntst);
        names_rnd = names(randperm(length(names)));
        trn_names = names_rnd(1:round(settings.ratio*length(names)));
        TRN_ID_c = ismember(names,trn_names);
        TRN_ID_s = ismember(names,trn_names);
        clear trn_names names_rnd
    else
        % take all (tst-specific)
        Ckeep = ismember(Cn,Cn);
        Skeep = ismember(Sn,Sn);
        TRN_ID_c = ~ismember(Cn,Cn);
        TRN_ID_s = ~ismember(Sn,Sn);
    end

    % create training part from C
    C = load(settings.cover,'F');
    C = C.F(Cx,:); C = C(Ckeep,:);
    C(TRN_ID_c,:) = []; Xc = C; clear C

    Cn = load(settings.cover,'names');
    Cn = Cn.names(Cx); Cn = Cn(Ckeep); clear Ckeep Cx
    Cn(TRN_ID_c) = [];
    
    % create training part from S
    S = load(settings.stego,'F');
    S = S.F(Sx,:); S = S(Skeep,:);
    S(TRN_ID_s,:) = []; Xs = S; clear S

    Sn = load(settings.stego,'names');
    Sn = Sn.names(Sx); Sn = Sn(Skeep); clear Skeep Sx
    Sn(TRN_ID_s) = [];
    
else
    % multiple feature files
    
    if ~isfield(settings,'cover_tst')

        [S,C,Sn,Sx,Cn,Cx,Ckeep,Skeep] = deal(cell(length(settings.stego),1));
        for i=1:length(settings.stego)
            S{i} = load(settings.stego{i},'names');
            C{i} = load(settings.cover{i},'names');
            [Sn{i},Sx{i}] = sort(S{i}.names);
            [Cn{i},Cx{i}] = sort(C{i}.names);
            if i==1
                names = intersect(Cn{i},Sn{i});
            else
                names = intersect(intersect(Cn{i},Sn{i}),names);
            end
        end
        for i=1:length(settings.stego)
            Ckeep{i} = ismember(Cn{i},names);
            Skeep{i} = ismember(Sn{i},names);
        end
    else
        % tst-specific
        [S,C,Sn,Sx,Cn,Cx,Ckeep,Skeep] = deal(cell(length(settings.stego),1));
        for i=1:length(settings.stego)
            S{i} = load(settings.stego{i},'names');
            C{i} = load(settings.cover{i},'names');
            [Sn{i},Sx{i}] = sort(S{i}.names);
            [Cn{i},Cx{i}] = sort(C{i}.names);
            if i==1
                names_c = Cn{i};
                names_s = Sn{i};
            else
                names_c = intersect(Cn{i},names_c);
                names_s = intersect(Sn{i},names_s);
            end
        end
        for i=1:length(settings.stego)
            Ckeep{i} = ismember(Cn{i},names_c);
            Skeep{i} = ismember(Sn{i},names_s);
        end
    end
    
    if ~isfield(settings,'cover_tst')
        % create training and testing parts
        rand('state',settings.seed_trntst);
        names_rnd = names(randperm(length(names)));
        trn_names = names_rnd(1:round(settings.ratio*length(names)));
        TRN_ID_c = ismember(names,trn_names);
        TRN_ID_s = TRN_ID_c;
        clear trn_names names_rnd
    else
        % tst-specific
        if exist('names','var')
            TRN_ID_c = ~ismember(names,names);
            TRN_ID_s = ~ismember(names,names);
        else
            TRN_ID_c = ~ismember(names_c,names_c);
            TRN_ID_s = ~ismember(names_s,names_s);
        end
    end

    Xc=[];Xs=[];
    for i=1:length(settings.stego)
        % create training part from cover
        C = load(settings.cover{i},'F');
        C = C.F(Cx{i},:); C = C(Ckeep{i},:);
        C(TRN_ID_c,:) = []; Xc = [Xc C]; clear C %#ok<AGROW>

        % create training part from stego
        S = load(settings.stego{i},'F');
        S = S.F(Sx{i},:); S = S(Skeep{i},:);
        S(TRN_ID_s,:) = []; Xs = [Xs S]; clear S %#ok<AGROW>

        if i==1
            Cn = load(settings.cover{i},'names');
            Cn = Cn.names(Cx{i}); Cn = Cn(Ckeep{i});
            Cn(TRN_ID_c) = [];
            Sn = load(settings.stego{i},'names');
            Sn = Sn.names(Sx{i}); Sn = Sn(Skeep{i});
            Sn(TRN_ID_s) = [];
        end
    
    end
end

IMG = [Cn;Sn]; % testing image names

if isfield(settings,'cover_tst')
    settings.cover = COVER_BACKUP;
    settings.stego = STEGO_BACKUP;
end


function OOB = bootstrap_initialization(PRNG,Xc,Xs,OOB,i,settings)
% initialization of the structure for OOB error estimates
if settings.bootstrap
    rand('state',double(PRNG.bootstrap(i)));
    OOB.SUB = floor(size(Xc,1)*rand(size(Xc,1),1))+1;
    OOB.ID  = setdiff(1:size(Xc,1),OOB.SUB);
    if ~isfield(OOB,'Xc')
        OOB.Xc.fusion_majority_vote = zeros(size(Xc,1),1); % majority voting fusion
        OOB.Xc.num = zeros(size(Xc,1),1); % number of fused votes
        OOB.Xs.fusion_majority_vote = zeros(size(Xs,1),1); % majority voting fusion
        OOB.Xs.num = zeros(size(Xs,1),1); % number of fused votes
    end
end

function [base_learner] = findThreshold(Xm,Xp,base_learner)
% find threshold through minimizing (MD+FA)/2, where MD stands for the
% missed detection rate and FA for the false alarms rate
P1 = Xm*base_learner.w;
P2 = Xp*base_learner.w;
L = [-ones(size(Xm,1),1);ones(size(Xp,1),1)];
[P,IX] = sort([P1;P2]);
L = L(IX);
Lm = (L==-1);
sgn = 1;

MD = 0;
FA = sum(Lm);
MD2=FA;
FA2=MD;
Emin = (FA+MD);
Eact = zeros(size(L-1));
Eact2 = Eact;
for idTr=1:length(P)-1
    if L(idTr)==-1
        FA=FA-1;
        MD2=MD2+1;
    else
        FA2=FA2-1;
        MD=MD+1;
    end
    Eact(idTr) = FA+MD;
    Eact2(idTr) = FA2+MD2;
    if Eact(idTr)<Emin
        Emin = Eact(idTr);
        iopt = idTr;
        sgn=1;
    end
    if Eact2(idTr)<Emin
        Emin = Eact2(idTr);
        iopt = idTr;
        sgn=-1;
    end
end

base_learner.b = sgn*0.5*(P(iopt)+P(iopt+1));
if sgn==-1, base_learner.w = -base_learner.w; end

function OOB = update_oob_error_estimates(Xc,Xs,base_learner,OOB,i,subspace,settings)
% update OOB error estimates
if ~settings.bootstrap,return; end
OOB.Xc.proj = Xc(OOB.ID,subspace)*base_learner.w-base_learner.b;
OOB.Xs.proj = Xs(OOB.ID,subspace)*base_learner.w-base_learner.b;
OOB.Xc.num(OOB.ID) = OOB.Xc.num(OOB.ID) + 1;
OOB.Xc.fusion_majority_vote(OOB.ID) = OOB.Xc.fusion_majority_vote(OOB.ID)+sign(OOB.Xc.proj);
OOB.Xs.num(OOB.ID) = OOB.Xs.num(OOB.ID) + 1;
OOB.Xs.fusion_majority_vote(OOB.ID) = OOB.Xs.fusion_majority_vote(OOB.ID)+sign(OOB.Xs.proj);
% update errors
% TMP_c = OOB.Xc.fusion_majority_vote(OOB.Xc.num>0.3*i); TMP_c(TMP_c==0) = rand(sum(TMP_c==0),1)-0.5;
% TMP_s = OOB.Xs.fusion_majority_vote(OOB.Xc.num>0.3*i); TMP_s(TMP_s==0) = rand(sum(TMP_s==0),1)-0.5;
TMP_c = OOB.Xc.fusion_majority_vote; TMP_c(TMP_c==0) = rand(sum(TMP_c==0),1)-0.5;
TMP_s = OOB.Xs.fusion_majority_vote; TMP_s(TMP_s==0) = rand(sum(TMP_s==0),1)-0.5;
OOB.error = (sum(TMP_c>0)+sum(TMP_s<0))/(length(TMP_c)+length(TMP_s));

if ~ischar(OOB) && ~isempty(OOB)
    H = hist([OOB.Xc.num;OOB.Xs.num],0:max([OOB.Xc.num;OOB.Xs.num]));
    avg_L = sum(H.*(0:length(H)-1))/sum(H); % average L in OOB
    OOB.x(i) = avg_L;
    OOB.y(i) = OOB.error;
end

function [TST_ERROR,TRUE_LABELS,PRED] = calculate_testing_error(Yc,Ys,base_learner,L,OPTIMAL_K)

% testing error calculation
TSTc.fusion_majority_vote = zeros(size(Yc,1),1);
TSTs.fusion_majority_vote = zeros(size(Ys,1),1);

for idB = 1:L
    subspace = base_learner{idB}.subspace(1:OPTIMAL_K);


    TSTc.proj = Yc(:,subspace)*base_learner{idB}.w-base_learner{idB}.b;
    TSTs.proj = Ys(:,subspace)*base_learner{idB}.w-base_learner{idB}.b;


    TSTc.fusion_majority_vote = TSTc.fusion_majority_vote+sign(TSTc.proj);
    TSTs.fusion_majority_vote = TSTs.fusion_majority_vote+sign(TSTs.proj);
end

tiec = TSTc.fusion_majority_vote==0;
ties = TSTs.fusion_majority_vote==0;
TSTc.fusion_majority_vote(tiec) = rand(sum(tiec),1)-0.5;
TSTs.fusion_majority_vote(ties) = rand(sum(ties),1)-0.5;

TRUE_LABELS = [-ones(length(TSTc.fusion_majority_vote),1);ones(length(TSTs.fusion_majority_vote),1)];
PREDc = sign(TSTc.fusion_majority_vote); PREDc(PREDc==0) = 1;
PREDs = sign(TSTs.fusion_majority_vote); PREDs(PREDc==0) = -1;
PRED = [PREDc;PREDs];

TST_ERROR = sum(TRUE_LABELS~=PRED)/length(PRED);
% (sum(TSTc.fusion_majority_vote>=0)+sum(TSTs.fusion_majority_vote<=0))/(size(TSTc.fusion_majority_vote,1)+size(TSTs.fusion_majority_vote,1));

function xc = get_xc(X,mu)
if exist('bsxfun','builtin')==5
    xc = bsxfun(@minus,X,mu);
else
    %function bsxfun is not available (older Matlab)
    xc = X;
    for iii=1:size(xc,2), xc(:,iii) = xc(:,iii)-mu(iii); end
end

function base_learner = FLD_training(Xc,Xs,i,base_learner,OOB,subspace,settings)
% FLD TRAINING
if settings.bootstrap
    Xm = Xc(OOB.SUB,subspace);
    Xp = Xs(OOB.SUB,subspace);
else
    Xm = Xc(:,subspace);
    Xp = Xs(:,subspace);
end

% remove constants
remove = false(1,size(Xm,2));
adepts = unique([find(Xm(1,:)==Xm(2,:)) find(Xp(1,:)==Xp(2,:))]);
for ad_id = adepts
    U1=unique(Xm(:,ad_id));
    if numel(U1)==1
        U2=unique(Xp(:,ad_id));
        if numel(U2)==1, if U1==U2, remove(ad_id) = true; end; end
    end
end; clear adepts ad_id

muC  = sum(Xm,1); muC = double(muC)/size(Xm,1);
muS  = sum(Xp,1); muS = double(muS)/size(Xp,1);
mu = (muS-muC)';

% calculate sigC
xc = get_xc(Xm,muC);
sigC = xc'*xc;
sigC = double(sigC)/size(Xm,1);

% calculate sigS
xc = get_xc(Xp,muS);
sigS = xc'*xc;
sigS = double(sigS)/size(Xp,1);

sigCS = sigC + sigS;

% regularization
sigCS = sigCS + 1e-10*eye(size(sigC,1));

% check for NaN values (may occur when the feature value is constant over images)
clear nan_values
nan_values = sum(isnan(sigCS))>0;
nan_values = nan_values | remove;

sigCS = sigCS(~nan_values,~nan_values);
mu = mu(~nan_values);
lastwarn('');
warning('off','MATLAB:nearlySingularMatrix');
warning('off','MATLAB:singularMatrix');

base_learner.w = sigCS\mu;

% regularization (if necessary)
[txt,warnid] = lastwarn(); %#ok<ASGLU>
while strcmp(warnid,'MATLAB:singularMatrix') || (strcmp(warnid,'MATLAB:nearlySingularMatrix') && ~settings.ignore_warnings)
    lastwarn('');
    if ~exist('counter','var'), counter=1; else counter = counter*5; end
    sigCS = sigCS + counter*eps*eye(size(sigCS,1));
    base_learner.w = sigCS\mu;
    [txt,warnid] = lastwarn(); %#ok<ASGLU>
end    
warning('on','MATLAB:nearlySingularMatrix');
warning('on','MATLAB:singularMatrix');
if length(sigCS)~=length(sigC)
    % resolve previously found NaN values, set the corresponding elements of w equal to zero
    w_new = zeros(length(sigC),1);
    w_new(~nan_values) = base_learner.w;
    base_learner.w = w_new;
end

% find threshold to minimize FA+MD
[base_learner] = findThreshold(Xm,Xp,base_learner);

function results = add_search_info(results,settings,search_counter,SEARCH,i,CT)
% update information about d_sub search
if settings.improved_search_for_k
    results.search.OOB(search_counter)  = SEARCH.E(SEARCH.x==results.search.k(search_counter));
    results.search.L(search_counter) = i;
    results.search.time(search_counter) = CT;
end

function results = collect_final_results(settings,OPTIMAL_K,OPTIMAL_L,MIN_OOB,results)
% final results collection
if isfield(settings,'seed_trntst')
    results.seed_trntst = settings.seed_trntst;
end
results.optimal.L = OPTIMAL_L;
results.optimal.k   = OPTIMAL_K;
results.optimal.OOB = MIN_OOB;
results.time = toc(uint64(settings.start_time));

function SEARCH = add_gridpoints(SEARCH,points)
% add new points for the search for d_sub
for point=points
    if SEARCH.x(1)>point
        SEARCH.x = [point SEARCH.x];
        SEARCH.E = [-1 SEARCH.E];
        continue;
    end
    if SEARCH.x(end)<point
        SEARCH.x = [SEARCH.x point];
        SEARCH.E = [SEARCH.E -1];
        continue;
    end
    pos = 2;
    while SEARCH.x(pos+1)<point,pos = pos+1; end
    SEARCH.x = [SEARCH.x(1:pos-1) point SEARCH.x(pos:end)];
    SEARCH.E = [SEARCH.E(1:pos-1) -1 SEARCH.E(pos:end)];
end
