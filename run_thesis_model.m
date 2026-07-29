%% =======================================================================
%  run_thesis_model.m
%  Driver for the master-thesis benchmark model  thesis_model.mod
%  ------------------------------------------------------------------------
%  Maximilian Stein - Sovereign Disaster Risk, Banking Frictions and Macro
%  Tail Outcomes in a NK-DSGE for the Euro Area.
%
%  WHAT THIS SCRIPT DOES
%   1. Solves the model with Dynare at THIRD ORDER (order=3, pruning) for
%          (a) the BASELINE          phi = 0.10  (banks hold sovereign bonds)
%          (b) the COUNTERFACTUAL    phi = 0     (sovereign-bank channel off)
%   2. Computes the ERGODIC MEAN in the absence of shocks (the correct
%      centring point for nonlinear/3rd-order IRFs), exactly as in the
%      Isore-Szczerbowicz (2017) replication code (uses Dynare's simult_).
%   3. Builds GENERALISED IRFs to a disaster-risk shock (etheta): the
%      difference between the shocked path and the no-shock path, in percent
%      of the ergodic mean, and overlays baseline vs counterfactual.
%   4. Plots the key macro-financial variables and saves everything to .mat.
%
%  HOW TO RUN
%   >> addpath /Applications/Dynare/6.3-x86_64/matlab   % <-- adjust to yours
%   >> cd  <folder containing this file and thesis_model.mod>
%   >> run_thesis_model
%
%  REQUIREMENTS: MATLAB (R2018b+) with Dynare 6.x on the path.
%  TIP for a first debug pass: open thesis_model.mod and switch
%  stoch_simul to  order=1  (faster; isolates steady-state / BK problems
%  from any 3rd-order/pruning issues).  Once order=1 solves, go back to 3.
%% =======================================================================

clear; close all; clc;

% --- make sure Dynare is on the path -------------------------------------
if isempty(which('dynare'))
    error(['Dynare is not on the MATLAB path. Add it first, e.g.\n' ...
           '   addpath /Applications/Dynare/6.3-x86_64/matlab\n' ...
           'then re-run run_thesis_model.']);
end

%% ---------------------- user settings -----------------------------------
MODEL      = 'thesis_model_v3';   % .mod file name (without extension)
                               % MUST match the actual .mod filename exactly --
                               % this project has previously had a 'thesis_model.mod'
                               % that silently diverged from the file actually being
                               % edited. If a stale thesis_model.mod exists anywhere
                               % on the MATLAB path, dynare() will find and run THAT
                               % one instead, with no error and no warning.
                               % Check `which thesis_model.mod` before running if in doubt.
burnin     = 10000;            % periods to reach the ergodic mean
nIrf       = 20;               % IRF horizon (quarters)
shockName  = 'etheta';         % shock to study ('etheta' or 'er')
shockSize  = 0.01;             % innovation size (log units); IS2017 used 0.01
korder     = 3;                % MUST equal order= in stoch_simul (=3)
                                % If you follow the order=1 debug tip above (editing
                                % the .mod's @#define ORDER = 1, or passing -DORDER=1),
                                % you MUST also set korder=1 here, or simult_ below will
                                % reconstruct the pruned state space at the wrong order
                                % and fail confusingly. These two are not auto-synced.

% Scenarios: {label, extra dynare macro-define, line style}
scen = { ...
    'Baseline  (\phi=0.10)',   '',            '-'  ; ...
    'Counterfactual (\phi=0)', '-DPHIVAL=0',  '--' };

%% ---------------------- solve each scenario ------------------------------
R = struct();                                   % results container
for s = 1:size(scen,1)
    fprintf('\n==== Solving scenario: %s ====\n', scen{s,1});

    % ---- run Dynare (recomputes steady state for the given phi) ----------
    if isempty(scen{s,2})
        dynare(MODEL, 'noclearall');            % baseline (PHIVAL default)
    else
        dynare(MODEL, 'noclearall', scen{s,2}); % counterfactual (-DPHIVAL=0)
    end

    % ---- snapshot the Dynare objects for this scenario -------------------
    M  = M_; oo = oo_; op = options_;
    R(s).label   = scen{s,1};
    R(s).style   = scen{s,3};
    R(s).M       = M;
    R(s).names   = M.endo_names;

    % ---- 1) ergodic mean in the absence of shocks ------------------------
    nshk   = M.exo_nbr;
    ex0    = zeros(burnin, nshk);
    ys     = oo.dr.ys;                          % deterministic steady state
    pathEM = simult_(M, op, ys, oo.dr, ex0, korder);
    ergM   = pathEM(:, end);                    % ergodic mean (last column)
    R(s).ergmean = ergM;

    % ---- 2) generalised IRF to the chosen shock --------------------------
    y0 = repmat(ergM, 1, M.maximum_lag);        % start from ergodic mean
    jshk = strcmp(M.exo_names, shockName);      % locate the shock column

    exI  = zeros(nIrf, nshk);  exI(1, jshk) = shockSize;   % impulse at t=1
    ex0b = zeros(nIrf, nshk);                              % no-shock baseline
    pShock = simult_(M, op, y0, oo.dr, exI,  korder);
    pBase  = simult_(M, op, y0, oo.dr, ex0b, korder);

    % GIRF: (shocked - no-shock) in percent of the ergodic mean
    R(s).girf = 100 * (pShock - pBase) ./ ergM;   % rows=vars, cols=0..nIrf
end

%% ---------------------- plotting -----------------------------------------
% variables to display (name in the model, and a nice title)
plotVars = { ...
   'betatheta','Discount factor \beta(\theta)'; ...
   'y',        'Output'; ...
   'c',        'Consumption'; ...
   'i',        'Investment'; ...
   'L',        'Labour'; ...
   'pi',       'Inflation'; ...
   'r',        'Nominal rate'; ...
   'spread',   'Sovereign spread'; ...
   'Nb',       'Bank net worth N^b'; ...
   'Ne',       'Entrepreneur net worth N^e'; ...   % 2026-07-30: BGG reinstated (double accelerator)
   'lev',      'Bank leverage (endogenous)'; ...
   'RS',       'Loan rate R^S'};   % was 'RL' -- no such variable; loan rate is RS

figure('Name','GIRF to a disaster-risk shock','Position',[80 80 1200 900]);
for p = 1:size(plotVars,1)
    subplot(4,3,p); hold on; grid on;
    for s = 1:numel(R)
        jv = strcmp(R(s).names, plotVars{p,1});
        y  = R(s).girf(jv, :);              % includes impact period
        plot(0:numel(y)-1, y, R(s).style, 'LineWidth', 1.4);
    end
    title(plotVars{p,2}, 'Interpreter','tex');
    xlabel('quarters'); ylabel('% dev.'); xlim([0 nIrf]);
    if p==1, legend({R.label}, 'Location','best', 'Interpreter','tex'); end
end
sgtitle(sprintf('Response to a %+g disaster-risk innovation (order=%d)', ...
        shockSize, korder));

%% ---------------------- save --------------------------------------------
save('thesis_model_results.mat', 'R', 'plotVars', 'shockName', 'shockSize');
fprintf('\nDone. Results saved to thesis_model_results.mat\n');
