%% =======================================================================
%  run_thesis_model.m
%  Driver for the master-thesis benchmark model  thesis_model_v3.mod
%  ------------------------------------------------------------------------
%  Maximilian Stein - Sovereign Disaster Risk, Banking Frictions and Macro
%  Tail Outcomes in a NK-DSGE for the Euro Area.
%
%  WHAT THIS SCRIPT DOES (single, consolidated driver -- 2026-08-05: folded
%  in the former standalone phi_sweep.m so the project keeps exactly one
%  .mod and one .m file, per instruction)
%   1. Solves the model with Dynare at THIRD ORDER (order=3, pruning) for
%      EVERY phi in PHI_GRID below, ONCE each, sharing the solved results
%      across all three figures produced (no redundant solves).
%   2. Computes the ERGODIC MEAN in the absence of shocks (the correct
%      centring point for nonlinear/3rd-order RFs), exactly as in the
%      Isore-Szczerbowicz (2017) replication code (uses Dynare's simult_).
%   3. Builds GENERALISED IRFs to a disaster-risk shock (etheta): the
%      difference between the shocked path and the no-shock path, in
%      percent of the ergodic mean (raw annualized bps for spread/Rb/Qb).
%   4. Produces THREE separate figures, because they answer different
%      questions and must not be read as one continuous story (see
%      CHANGELOG "2026-08-05"):
%        Figure 1 - HEADLINE: baseline (phi=0.10) vs counterfactual
%                   (phi=1e-4). This is the thesis's main comparison.
%        Figure 2 - CORE PHI SWEEP: phi in {1e-4, 0.10, 0.20}, the
%                   empirically plausible calibration range (matches
%                   the euro-area home-bias literature, e.g.
%                   Battistini-Pagano-Simonelli 2014). Consumption,
%                   investment, spread and leverage are robustly
%                   monotonic in phi here -- this is the figure that
%                   supports the amplification claim.
%        Figure 3 - BEYOND-CALIBRATION ILLUSTRATION: phi in {0.50, 0.80}
%                   against the phi=0.10 baseline for reference. NEITHER
%                   value is empirically documented for euro-area bank
%                   sovereign exposure. Included only to show the limit
%                   behaviour of the model's own "no realised default
%                   along the simulated path" convention (bank net worth
%                   N^b can flip from a loss to a GAIN at these values,
%                   because a bond price that falls but never actually
%                   defaults mechanically raises next period's realised
%                   yield -- see CHANGELOG 2026-08-05 for the full
%                   diagnosis). Do NOT present this figure as "more of
%                   the same" amplification -- it demonstrates a
%                   different regime, not a stronger version of Figure 2.
%   5. Plots the key macro-financial variables and saves everything to
%      .mat (one consolidated file, all phi scenarios).
%
%  HOW TO RUN
%   >> addpath /Applications/Dynare/6.3-x86_64/matlab   % <-- adjust to yours
%   >> cd  <folder containing this file and thesis_model_v3.mod>
%   >> run_thesis_model
%
%  REQUIREMENTS: MATLAB (R2018b+) with Dynare 6.x on the path.
%  TIP for a first debug pass: open thesis_model_v3.mod and switch
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

% All phi values needed across all three figures, solved ONCE each and
% shared -- this is the "solve once, plot three ways" design that keeps
% this a single sustainable script rather than one-off throwaway copies.
% {label, dynare macro-define, line style, RGB color}
scen = { ...
    'Counterfactual (\phi=1e-4)',     '-DPHIVAL=1e-4', '--', [0.85 0.33 0.10]; ...
    'Baseline  (\phi=0.10)',          '',              '-',  [0.00 0.45 0.74]; ...
    'Core sweep (\phi=0.20)',         '-DPHIVAL=0.20', ':',  [0.47 0.67 0.19]; ...
    'BEYOND-CALIBRATION (\phi=0.50)', '-DPHIVAL=0.50', '-.', [0.49 0.18 0.56]; ...
    'BEYOND-CALIBRATION (\phi=0.80)', '-DPHIVAL=0.80', '--', [0.30 0.30 0.30] ...
};
IDX_CF20   = 1;   % index of phi=1e-4 in scen/R
IDX_BASE10 = 2;   % index of phi=0.10 in scen/R
IDX_20     = 3;   % index of phi=0.20 in scen/R
IDX_50     = 4;   % index of phi=0.50 in scen/R (beyond-calibration)
IDX_80     = 5;   % index of phi=0.80 in scen/R (beyond-calibration)

%% ---------------------- solve each scenario ------------------------------
R = struct();                                   % results container
for s = 1:size(scen,1)
    fprintf('\n==== Solving scenario: %s ====\n', scen{s,1});

    % ---- run Dynare (recomputes steady state for the given phi) ----------
    if isempty(scen{s,2})
        dynare(MODEL, 'noclearall');            % baseline (PHIVAL default)
    else
        dynare(MODEL, 'noclearall', scen{s,2}); % non-default phi
    end

    % ---- snapshot the Dynare objects for this scenario -------------------
    M  = M_; oo = oo_; op = options_;
    R(s).label   = scen{s,1};
    R(s).style   = scen{s,3};
    R(s).color   = scen{s,4};
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

    % simult_ prepends M.maximum_lag columns of the (unchanged) initial
    % condition before the nIrf simulated periods, so pShock/pBase have
    % M.maximum_lag+nIrf columns, not nIrf. Column 1 of the RAW output is
    % therefore trivially pShock==pBase==ergM (verified 2026-08-04: exactly
    % zero for every variable) -- NOT the impact period. Drop that prefix so
    % column 1 of R(s).girf really is the first period after the shock,
    % matching the x-axis label ("quarters", 0-indexed) below.
    pShock = pShock(:, M.maximum_lag+1:end);
    pBase  = pBase(:,  M.maximum_lag+1:end);

    % GIRF: (shocked - no-shock) in percent of the ergodic mean
    R(s).girf = 100 * (pShock - pBase) ./ ergM;   % rows=vars, cols=0..nIrf-1

    % Rate-wedge variables (spread, Rb, Qb) have a near-zero ergodic mean,
    % so "% of ergodic mean" mechanically blows up a small absolute move
    % into a meaningless percentage (verified 2026-08-01: ~100x too large
    % against IS2017's own risk-premium panel). Overwrite these rows with
    % the raw level deviation in annualized basis points instead.
    bpsVars = {'spread','Rb','Qb'};
    for bv = 1:numel(bpsVars)
        jbv = strcmp(M.endo_names, bpsVars{bv});
        if any(jbv)
            R(s).girf(jbv,:) = 10000 * (pShock(jbv,:) - pBase(jbv,:));
        end
    end
end

%% ---------------------- shared plotting setup -----------------------------
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
bpsVars = {'spread','Rb','Qb'};

plot_panel = @(idxList, figName, titleStr) local_plot_panel(R, idxList, plotVars, bpsVars, nIrf, figName, titleStr, shockSize, korder);

%% ---------------------- Figure 1: HEADLINE (main thesis comparison) -------
plot_panel([IDX_BASE10, IDX_CF20], 'Fig1_Headline_GIRF', ...
    'HEADLINE: baseline (\phi=0.10) vs counterfactual (\phi=1e-4)');

%% ---------------------- Figure 2: CORE PHI SWEEP (calibration-plausible) --
plot_panel([IDX_CF20, IDX_BASE10, IDX_20], 'Fig2_Core_Phi_Sweep', ...
    'CORE \phi SWEEP: calibration-plausible range (1e-4, 0.10, 0.20)');

%% ---------------------- Figure 3: BEYOND-CALIBRATION illustration ---------
% Explicitly separate figure, explicitly labeled -- per CHANGELOG
% 2026-08-05, phi=0.50/0.80 are NOT empirically documented for euro-area
% bank sovereign exposure and must not be shown as a continuation of
% Figure 2's monotonic story. They illustrate a different regime (the
% "no realised default" convention's limit behaviour on N^b).
plot_panel([IDX_BASE10, IDX_50, IDX_80], 'Fig3_Beyond_Calibration', ...
    'BEYOND-CALIBRATION ILLUSTRATION (\phi=0.50/0.80, NOT empirically calibrated -- see CHANGELOG 2026-08-05)');

%% ---------------------- save --------------------------------------------
save('thesis_model_results.mat', 'R', 'plotVars', 'shockName', 'shockSize', 'scen');
fprintf('\nDone. Results saved to thesis_model_results.mat\n');
fprintf('Figures saved: Fig1_Headline_GIRF, Fig2_Core_Phi_Sweep, Fig3_Beyond_Calibration (.fig/.png)\n');

%% ---------------------- local plotting function ---------------------------
function local_plot_panel(R, idxList, plotVars, bpsVars, nIrf, figName, titleStr, shockSize, korder)
    % Cosmetic-only leading zero point (2026-08-05): R(s).girf itself is
    % NOT touched -- column 1 remains the true impact period for every
    % analysis/citation purpose (results_collection.md, the two-channel
    % decomposition, etc.). For PLOTTING ONLY, prepend a synthetic
    % quarter-0 zero so the figure visually matches IS2017's own
    % published convention (their Fig. 1 "Main scenario" plots a trivial
    % pre-shock zero at their labelled period 1, with the true response
    % only appearing at their period 2 -- confirmed against every one of
    % their 9 panels, including static ones like beta(theta)). Without
    % this, a reader lining up our figure against theirs quarter-by-
    % quarter would be comparing our TRUE impact response against their
    % PRE-shock reference point -- a spurious one-period mismatch, not a
    % real economic difference. See CHANGELOG 2026-08-05 (later).
    figure('Name', figName, 'Position',[80 80 1200 900]);
    for p = 1:size(plotVars,1)
        subplot(4,3,p); hold on; grid on;
        for ii = 1:numel(idxList)
            s = idxList(ii);
            jv = strcmp(R(s).names, plotVars{p,1});
            y  = [0, R(s).girf(jv, :)];   % prepend cosmetic zero, IS2017-style
            plot(0:numel(y)-1, y, R(s).style, 'Color', R(s).color, 'LineWidth', 1.4);
        end
        title(plotVars{p,2}, 'Interpreter','tex');
        xlabel('quarters');
        if any(strcmp(plotVars{p,1}, bpsVars))
            ylabel('bps');
        else
            ylabel('% dev.');
        end
        xlim([0 nIrf]);
        if p==1
            legend({R(idxList).label}, 'Location','best', 'Interpreter','tex', 'FontSize',7);
        end
    end
    sgtitle(sprintf('%s\nResponse to a %+g disaster-risk innovation (order=%d) -- quarter 0 = pre-shock reference (IS2017 convention)', ...
            titleStr, shockSize, korder), 'Interpreter','tex');
    savefig([figName '.fig']);
    print([figName '.png'], '-dpng', '-r150');
end
