%% =======================================================================
%  run_thesis_model.m
%  Driver for the master-thesis benchmark model  thesis_model_v3.mod
%  ------------------------------------------------------------------------
%  Maximilian Stein - Sovereign Disaster Risk, Banking Frictions and Macro
%  Tail Outcomes in a NK-DSGE for the Euro Area.
%
%  WHAT THIS SCRIPT DOES (single, consolidated driver -- 2026-08-05: folded
%  in the former standalone phi_sweep.m so the project keeps exactly one
%  .mod and one .m file, per instruction; 2026-08-15: extended into the
%  full Results-chapter pipeline, see main_results_path.md for the tiering
%  this follows)
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
%        Figure 1 - HEADLINE: baseline (phi=0.03) vs counterfactual
%                   (phi=1e-4). This is the thesis's main comparison.
%        Figure 2 - CORE PHI SWEEP: phi in {1e-4, 0.03, 0.20}, the
%                   empirically plausible calibration range (Buch 2026
%                   euro-area home-bias reading ~2.5%). Consumption,
%                   investment, spread and leverage are robustly
%                   monotonic in phi here -- this is the figure that
%                   supports the amplification claim.
%        Figure 3 - BEYOND-CALIBRATION ILLUSTRATION: phi in {0.30, 0.50}
%                   against the phi=0.03 baseline for reference. NEITHER
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
%   6. Runs the admissibility check (Appendix D10, condition vii: iotae,
%      iotab > 0) for every scenario -- these are calibration-block
%      PARAMETERS, not var-list steady-state outputs, so they never show
%      up in Dynare's own printed steady-state table.
%   7. Builds the Results-chapter deliverables (main_results_path.md
%      Tier 1 + Tier 2): the two-channel decomposition and safe-haven
%      check (5.2.2), the steady-state comparison table (5.2.1), the
%      calibration table (5.1), a long stochastic simulation with tail
%      moments and Output-/Spread-at-Risk (5.3.1/5.3.2), and a continuous
%      phi sensitivity sweep (5.4.1/6.1) that doubles as the phi=0
%      numerical-fragility diagnostic. Every table is also written to a
%      .csv next to this script for direct import into the thesis.
%
%  HOW TO RUN
%   >> addpath /Applications/Dynare/6.3-x86_64/matlab   % <-- adjust to yours
%   >> cd  <folder containing this file and thesis_model_v3.mod>
%   >> run_thesis_model
%
%  REQUIREMENTS: MATLAB (R2018b+, Statistics Toolbox for skewness/kurtosis/
%  prctile) with Dynare 6.x on the path.
%  RUNTIME: the phi sweep below solves ~9 additional order=3 points on top
%  of the 5 scen points -- a full run takes on the order of 20-40 minutes.
%  Set RUN_PHI_SWEEP=false / RUN_TAIL_RISK=false for a fast Fig1-3-only
%  pass while iterating on plotting/table code.
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

RUN_TAIL_RISK  = true;         % long stochastic sim -> moments + VaR (5.3.1/5.3.2)
tailT          = 20000;        % simulated periods (post-burn-in) for moments/percentiles
tailBurnin     = 2000;
tailSeed       = 20260815;     % fixed seed, reproducible across runs

RUN_PHI_SWEEP  = true;         % continuous phi sensitivity sweep (5.4.1/6.1) --
                                % also the phi=0 numerical-fragility diagnostic
                                % (supersedes the old standalone RUN_PHI_DIAGNOSTIC
                                % block; see ToDoAugust14th.md \S0e for that history)
sweepOnlyPhis  = [0, 0.01, 0.02, 0.05, 0.075, 0.10, 0.15, 0.25, 0.40];
                                % points NOT already in `scen` below -- phi=0 is
                                % wrapped in try/catch, a hard failure there is
                                % itself the reportable finding the sweep exists to
                                % surface, not a bug in this script.

% All phi values needed across all three figures, solved ONCE each and
% shared -- this is the "solve once, plot three ways" design that keeps
% this a single sustainable script rather than one-off throwaway copies.
% {label, dynare macro-define, line style, RGB color}
scen = { ...
    'Counterfactual (\phi=1e-4)',     '-DPHIVAL=1e-4', '--', [0.85 0.33 0.10]; ...
    'Baseline  (\phi=0.03)',          '-DPHIVAL=0.03',  '-',  [0.00 0.45 0.74]; ...
    'Core sweep (\phi=0.20)',         '-DPHIVAL=0.20', ':',  [0.47 0.67 0.19]; ...
    'BEYOND-CALIBRATION (\phi=0.30)', '-DPHIVAL=0.30', '-.', [0.49 0.18 0.56]; ...
    'BEYOND-CALIBRATION (\phi=0.50)', '-DPHIVAL=0.50', '--', [0.30 0.30 0.30] ...
};
IDX_CF20   = 1;   % index of phi=1e-4 in scen/R
IDX_BASE10 = 2;   % index of phi=0.03 in scen/R
IDX_20     = 3;   % index of phi=0.20 in scen/R
IDX_30     = 4;   % index of phi=0.30 in scen/R (beyond-calibration)
IDX_50     = 5;   % index of phi=0.50 in scen/R (beyond-calibration)
scenPhis   = [1e-4, 0.03, 0.20, 0.30, 0.50];   % must match scen row order exactly

bpsVars = {'spread','Rb','Qb'};   % rate-wedge vars reported in raw ann. bps, not %

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
    R(s).op      = op;
    R(s).dr      = oo.dr;
    R(s).names   = M.endo_names;

    % ---- admissibility check: iota, iotae > 0 (Appendix D10 condition vii) --
    % iotae/iotab are calibration-block PARAMETERS, not var-list steady-state
    % outputs, so they never appear in Dynare's printed steady-state table --
    % check them explicitly here instead.
    iotae_val = M.params(strcmp(M.param_names, 'iotae'));
    iotab_val = M.params(strcmp(M.param_names, 'iotab'));
    R(s).iotae = iotae_val;
    R(s).iotab = iotab_val;
    iotae_flag = 'OK'; if iotae_val<=0, iotae_flag = 'VIOLATED'; end
    iotab_flag = 'OK'; if iotab_val<=0, iotab_flag = 'VIOLATED'; end
    fprintf('  admissibility check: iotae = %.6g (%s), iotab = %.6g (%s)\n', ...
        iotae_val, iotae_flag, iotab_val, iotab_flag);

    % ---- 1) ergodic mean in the absence of shocks ------------------------
    nshk   = M.exo_nbr;
    ex0    = zeros(burnin, nshk);
    ys     = oo.dr.ys;                          % deterministic steady state
    R(s).ss = ys;
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

plot_panel = @(idxList, figName, titleStr) local_plot_panel(R, idxList, plotVars, bpsVars, nIrf, figName, titleStr, shockSize, korder);

%% ---------------------- Figure 1: HEADLINE (main thesis comparison) -------
plot_panel([IDX_BASE10, IDX_CF20], 'Fig1_Headline_GIRF', ...
    'HEADLINE: baseline (\phi=0.03) vs counterfactual (\phi=1e-4)');

%% ---------------------- Figure 2: CORE PHI SWEEP (calibration-plausible) --
plot_panel([IDX_CF20, IDX_BASE10, IDX_20], 'Fig2_Core_Phi_Sweep', ...
    'CORE \phi SWEEP: calibration-plausible range (1e-4, 0.03, 0.20)');

%% ---------------------- Figure 3: BEYOND-CALIBRATION illustration ---------
% Explicitly separate figure, explicitly labeled -- per CHANGELOG
% 2026-08-05, phi=0.30/0.50 are NOT empirically documented for euro-area
% bank sovereign exposure and must not be shown as a continuation of
% Figure 2's monotonic story. They illustrate a different regime (the
% "no realised default" convention's limit behaviour on N^b).
plot_panel([IDX_BASE10, IDX_30, IDX_50], 'Fig3_Beyond_Calibration', ...
    'BEYOND-CALIBRATION ILLUSTRATION (\phi=0.30/0.50, NOT empirically calibrated -- see CHANGELOG 2026-08-05)');

%% ---------------------- Two-channel decomposition + safe-haven check (5.2.2) --
twoChannel = local_two_channel_safehaven(R, IDX_BASE10);

%% ---------------------- Steady-state comparison table (5.2.1) ------------
local_steady_state_table(R, [IDX_CF20, IDX_BASE10, IDX_20]);

%% ---------------------- Calibration table (5.1) ---------------------------
local_calibration_table(R(IDX_BASE10).M, R(IDX_BASE10).ss, R(IDX_BASE10).names);

%% ---------------------- Tail risk: long simulation, moments, VaR (5.3) ----
if RUN_TAIL_RISK
    local_tail_risk(R(IDX_BASE10), tailT, tailBurnin, tailSeed, korder);
end

%% ---------------------- Continuous phi sensitivity sweep (5.4.1/6.1) ------
% Deliberately a second, standalone dynare()-calling loop at SCRIPT level
% (not a function) -- Dynare's dynare() populates M_/oo_/options_ via the
% base/script workspace, the same mechanism the main scenario loop above
% relies on, so this keeps that already-proven pattern rather than risking
% it inside a function scope.
if RUN_PHI_SWEEP
    Rsweep = struct();
    k = 0;
    for sp = 1:numel(sweepOnlyPhis)
        phiVal = sweepOnlyPhis(sp);
        k = k+1;
        Rsweep(k).phi = phiVal;
        fprintf('\n==== Phi-sweep point %d/%d: phi = %.6g ====\n', sp, numel(sweepOnlyPhis), phiVal);
        try
            dynare(MODEL, 'noclearall', sprintf('-DPHIVAL=%.10g', phiVal));
            Msw = M_; oosw = oo_; opsw = options_;
            n_inf = 0;
            if isfield(oosw,'dr') && isfield(oosw.dr,'eigval')
                n_inf = sum(isinf(oosw.dr.eigval));
            end

            nshk = Msw.exo_nbr;
            ex0  = zeros(burnin, nshk);
            ys   = oosw.dr.ys;
            pathEM = simult_(Msw, opsw, ys, oosw.dr, ex0, korder);
            ergM   = pathEM(:, end);

            y0 = repmat(ergM, 1, Msw.maximum_lag);
            jshk = strcmp(Msw.exo_names, shockName);
            exI  = zeros(nIrf, nshk);  exI(1,jshk) = shockSize;
            ex0b = zeros(nIrf, nshk);
            pShock = simult_(Msw, opsw, y0, oosw.dr, exI,  korder);
            pBase  = simult_(Msw, opsw, y0, oosw.dr, ex0b, korder);
            pShock = pShock(:, Msw.maximum_lag+1:end);
            pBase  = pBase(:,  Msw.maximum_lag+1:end);
            girf   = 100 * (pShock - pBase) ./ ergM;

            jLev = strcmp(Msw.endo_names,'lev');
            jSpread = strcmp(Msw.endo_names,'spread');
            spread_bps = 10000 * (pShock(jSpread,:) - pBase(jSpread,:));
            lev_path   = girf(jLev,:);

            [~, peakIdx] = max(abs(lev_path));
            Rsweep(k).ok = true;
            Rsweep(k).n_inf = n_inf;
            Rsweep(k).peak_spread_bps = max(abs(spread_bps));
            Rsweep(k).impact_lev = lev_path(1);
            Rsweep(k).peak_lev   = lev_path(peakIdx);
            Rsweep(k).impact_share_pct = 100*abs(Rsweep(k).impact_lev)/abs(Rsweep(k).peak_lev);
        catch ME
            fprintf('  FAILED at phi=%.6g: %s\n', phiVal, ME.message);
            Rsweep(k).ok = false;
            Rsweep(k).n_inf = NaN;
            Rsweep(k).peak_spread_bps = NaN;
            Rsweep(k).impact_lev = NaN;
            Rsweep(k).peak_lev = NaN;
            Rsweep(k).impact_share_pct = NaN;
        end
    end
    % fold in the 5 already-solved scen points -- no re-solving needed
    for s = 1:numel(scenPhis)
        k = k+1;
        jLev = strcmp(R(s).names,'lev'); jSpread = strcmp(R(s).names,'spread');
        lev_path = R(s).girf(jLev,:);
        [~, peakIdx] = max(abs(lev_path));
        Rsweep(k).phi = scenPhis(s);
        Rsweep(k).ok  = true;
        Rsweep(k).n_inf = 0;
        Rsweep(k).peak_spread_bps = max(abs(R(s).girf(jSpread,:)));
        Rsweep(k).impact_lev = lev_path(1);
        Rsweep(k).peak_lev   = lev_path(peakIdx);
        Rsweep(k).impact_share_pct = 100*abs(Rsweep(k).impact_lev)/abs(Rsweep(k).peak_lev);
    end
    local_phi_sweep_report(Rsweep);
end

%% ---------------------- save --------------------------------------------
if RUN_PHI_SWEEP
    save('thesis_model_results.mat', 'R', 'plotVars', 'shockName', 'shockSize', 'scen', 'twoChannel', 'Rsweep');
else
    save('thesis_model_results.mat', 'R', 'plotVars', 'shockName', 'shockSize', 'scen', 'twoChannel');
end
fprintf('\nDone. Results saved to thesis_model_results.mat\n');
fprintf('Figures saved: Fig1_Headline_GIRF, Fig2_Core_Phi_Sweep, Fig3_Beyond_Calibration (.fig/.png)\n');
fprintf('Tables saved: table_two_channel_safehaven.csv, table_steady_state.csv, table_calibration.csv');
if RUN_TAIL_RISK,  fprintf(', table_tail_risk_moments.csv'); end
if RUN_PHI_SWEEP,  fprintf(', table_phi_sweep.csv (+ Fig4_Phi_Sweep.png)'); end
fprintf('\n');

%% ---------------------- local functions -----------------------------------
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

function out = local_two_channel_safehaven(R, idxBase)
    % Splits the headline GIRF into the two mechanisms Appendix A.3.3
    % promises the results chapter: the impact-period leverage response
    % (eta_t/nu_t move before N^b has changed at all) vs. the lagged,
    % realised-loss channel (R^b falling, feeding N^b's accumulation).
    % Also runs the safe-haven sign check from the same appendix section.
    names = R(idxBase).names;
    girf  = R(idxBase).girf;
    jLev = strcmp(names,'lev');
    jNb  = strcmp(names,'Nb');
    jQb  = strcmp(names,'Qb');
    jHb  = strcmp(names,'Hb');
    jRf  = strcmp(names,'Rf');

    lev_path = girf(jLev,:);
    Qb_path  = girf(jQb,:);
    Hb_path  = girf(jHb,:);
    Rf_path  = girf(jRf,:);

    impact_lev = lev_path(1);
    [peak_lev_abs, peak_idx] = max(abs(lev_path));
    peak_lev = lev_path(peak_idx);
    impact_share_pct = 100*abs(impact_lev)/peak_lev_abs;
    nb_at_impact = girf(jNb,1);

    % "Falls, never reverses" means never crosses back through zero (no
    % overshoot into positive territory) -- it does NOT mean monotonically
    % deepening every period. A shock with rhotheta<1 decays, so a
    % well-behaved Qb response falls on impact and recovers back TOWARD
    % zero from below; requiring diff<=0 throughout would flag exactly
    % that normal mean-reverting recovery as a "failure". Checked instead:
    % Qb stays (weakly) negative for the whole horizon, no sign flip.
    qb_never_reverses = all(Qb_path <= 1e-8);
    hb_dominates_all      = all(abs(Hb_path) >= abs(Rf_path) - 1e-10);
    hb_dominates_post_impact = all(abs(Hb_path(2:end)) >= abs(Rf_path(2:end)) - 1e-10);

    okstr = @(b) local_tern(b,'CONFIRMED','FAILED');
    fprintf('\n=========== TWO-CHANNEL DECOMPOSITION (%s) ===========\n', R(idxBase).label);
    fprintf('  Impact-period leverage response (t=0):     %+8.4f%% dev.\n', impact_lev);
    fprintf('  Peak leverage response (t=%d):               %+8.4f%% dev.\n', peak_idx-1, peak_lev);
    fprintf('  Impact-period share of peak:                  %7.2f%%\n', impact_share_pct);
    fprintf('  Bank net worth at impact (should be ~0):    %+8.6f%% dev.\n', nb_at_impact);
    fprintf('  Safe-haven: Qb stays below s.s., never reverses sign: %s\n', okstr(qb_never_reverses));
    fprintf('  Safe-haven: |d log Hb| >= |d log Rf|, every horizon incl. impact: %s\n', okstr(hb_dominates_all));
    fprintf('  Safe-haven: |d log Hb| >= |d log Rf|, t=1 onward (excl. impact): %s\n', okstr(hb_dominates_post_impact));
    if ~hb_dominates_all && hb_dominates_post_impact
        fprintf('  (At impact only, |d log Rf|=%.4f%% briefly exceeds |d log Hb|=%.4f%% -- the fast\n', ...
            abs(Rf_path(1)), abs(Hb_path(1)));
        fprintf('   Fisher-equation jump in Rf; Hb dominates at every one of the remaining %d horizons.)\n', numel(Hb_path)-1);
    end

    out = struct('impact_lev',impact_lev,'peak_lev',peak_lev,'peak_idx',peak_idx-1, ...
        'impact_share_pct',impact_share_pct,'nb_at_impact',nb_at_impact, ...
        'qb_never_reverses',qb_never_reverses,'hb_dominates_all',hb_dominates_all, ...
        'hb_dominates_post_impact',hb_dominates_post_impact);

    Metric = {'Impact-period lev response (%)';'Peak lev response (%)';'Impact share of peak (%)'; ...
              'Nb at impact (%, ~0 check)';'Qb stays below s.s., no sign reversal'; ...
              'Hb dominates Rf, every horizon incl. impact';'Hb dominates Rf, t=1 onward (excl. impact)'};
    Value  = {sprintf('%.4f',impact_lev); sprintf('%.4f',peak_lev); sprintf('%.2f',impact_share_pct); ...
              sprintf('%.6f',nb_at_impact); mat2str(qb_never_reverses); mat2str(hb_dominates_all); mat2str(hb_dominates_post_impact)};
    T = table(Metric, Value);
    writetable(T, 'table_two_channel_safehaven.csv');
end

function v = local_tern(cond, a, b)
    if cond, v = a; else, v = b; end
end

function local_steady_state_table(R, idxList)
    labels = {'Bank net worth Nb','Bank leverage lev','Sovereign spread (raw, ann. bps)', ...
        'Bank sovereign-bond holdings QbB','Entrepreneur premium E[R^K]/R^S','Bank margin R^S/R^d', ...
        'Output y','Consumption c','Investment i'};
    names = R(idxList(1)).names;
    jNb=strcmp(names,'Nb'); jLev=strcmp(names,'lev'); jSpread=strcmp(names,'spread');
    jQbB=strcmp(names,'QbB'); jRK=strcmp(names,'RK'); jRS=strcmp(names,'RS'); jRd=strcmp(names,'Rd');
    jy=strcmp(names,'y'); jc=strcmp(names,'c'); ji=strcmp(names,'i');

    n = numel(idxList);
    Mtab = zeros(9,n);
    colNames = cell(1,n);
    for c1 = 1:n
        s = idxList(c1);
        ss = R(s).ss;
        colNames{c1} = matlab.lang.makeValidName(R(s).label);
        Mtab(1,c1) = ss(jNb);
        Mtab(2,c1) = ss(jLev);
        Mtab(3,c1) = 10000*ss(jSpread);
        Mtab(4,c1) = ss(jQbB);
        Mtab(5,c1) = ss(jRK)/ss(jRS);
        Mtab(6,c1) = ss(jRS)/ss(jRd);
        Mtab(7,c1) = ss(jy);
        Mtab(8,c1) = ss(jc);
        Mtab(9,c1) = ss(ji);
    end

    fprintf('\n=========== STEADY-STATE COMPARISON TABLE ===========\n');
    fprintf('%-38s', 'Variable');
    for c1=1:n, fprintf('%20s', R(idxList(c1)).label); end
    fprintf('\n');
    for r1=1:9
        fprintf('%-38s', labels{r1});
        for c1=1:n, fprintf('%20.6g', Mtab(r1,c1)); end
        fprintf('\n');
    end

    T = array2table(Mtab, 'VariableNames', colNames, 'RowNames', labels);
    writetable(T, 'table_steady_state.csv', 'WriteRowNames', true);
end

function local_tail_risk(Rbase, T, burninT, seedVal, korder)
    M = Rbase.M;
    rng(seedVal);
    nshk = M.exo_nbr;
    jtheta = strcmp(M.exo_names,'etheta');
    ex = zeros(burninT+T, nshk);
    ex(:,jtheta) = sqrt(M.Sigma_e(jtheta,jtheta)) * randn(burninT+T,1);
    path = simult_(M, Rbase.op, Rbase.ss, Rbase.dr, ex, korder);
    path = path(:, M.maximum_lag+burninT+1:end);   % drop init cond + burn-in

    varList = {'y','c','spread','Nb','lev'};
    labels  = {'Output','Consumption','Sovereign spread','Bank net worth','Bank leverage'};

    fprintf('\n=========== TAIL-RISK MOMENTS (T=%d, seed=%d) ===========\n', T, seedVal);
    fprintf('%-20s %10s %10s %10s %10s\n','Variable','Mean','Std','Skew','Kurt');
    rowsOut = cell(numel(varList),5);
    for v = 1:numel(varList)
        jv = strcmp(Rbase.names, varList{v});
        x  = path(jv,:);
        m  = mean(x); sd = std(x); sk = skewness(x); ku = kurtosis(x);
        fprintf('%-20s %10.4f %10.4f %10.4f %10.4f\n', labels{v}, m, sd, sk, ku);
        rowsOut(v,:) = {labels{v}, m, sd, sk, ku};
    end

    jy = strcmp(Rbase.names,'y'); jspread = strcmp(Rbase.names,'spread');
    oar = prctile(path(jy,:),5);
    sar = prctile(path(jspread,:),95);
    fprintf('\n---- Output-at-Risk / Spread-at-Risk (5th/95th percentiles, levels) ----\n');
    fprintf('  Output-at-Risk (5th pct level):   %.6f  (steady state %.6f)\n', oar, Rbase.ss(jy));
    fprintf('  Spread-at-Risk (95th pct level):  %.6f  (steady state %.6f)\n', sar, Rbase.ss(jspread));

    Tout = cell2table(rowsOut, 'VariableNames', {'Variable','Mean','Std','Skewness','Kurtosis'});
    writetable(Tout, 'table_tail_risk_moments.csv');
end

function local_phi_sweep_report(Rsweep)
    phis = [Rsweep.phi];
    [phis, order] = sort(phis);
    Rsweep = Rsweep(order);
    ok = [Rsweep.ok];

    fprintf('\n=========== PHI SENSITIVITY SWEEP ===========\n');
    fprintf('%10s %8s %10s %14s %16s %10s\n','phi','ok','n_Inf','peak spread','impact lev(%)','share(%)');
    for k = 1:numel(Rsweep)
        fprintf('%10.6g %8d %10d %14.4g %16.4f %10.2f\n', Rsweep(k).phi, Rsweep(k).ok, Rsweep(k).n_inf, ...
            Rsweep(k).peak_spread_bps, Rsweep(k).impact_lev, Rsweep(k).impact_share_pct);
    end

    figure('Name','Fig4_Phi_Sweep','Position',[80 80 900 700]);
    subplot(2,1,1); hold on; grid on;
    plot(phis(ok), [Rsweep(ok).peak_spread_bps], 'o-','LineWidth',1.4,'Color',[0 0.45 0.74]);
    xlabel('\phi'); ylabel('bps'); title('Peak sovereign-spread response vs \phi', 'Interpreter','tex');

    subplot(2,1,2); hold on; grid on;
    plot(phis(ok), [Rsweep(ok).impact_share_pct], 's-','LineWidth',1.4,'Color',[0.85 0.33 0.10]);
    xlabel('\phi'); ylabel('%'); title('Impact-period leverage response as share of peak, vs \phi', 'Interpreter','tex');
    savefig('Fig4_Phi_Sweep.fig');
    print('Fig4_Phi_Sweep.png', '-dpng', '-r150');

    Phi = phis(:); Ok = ok(:); nInf = [Rsweep.n_inf]';
    PeakSpreadBps = [Rsweep.peak_spread_bps]'; ImpactLev = [Rsweep.impact_lev]';
    ImpactSharePct = [Rsweep.impact_share_pct]';
    T = table(Phi, Ok, nInf, PeakSpreadBps, ImpactLev, ImpactSharePct);
    writetable(T, 'table_phi_sweep.csv');
end
