% =========================================================================
%  Sovereign Disaster Risk, Banking Frictions and Macro Tail Outcomes
%  in a New Keynesian DSGE for the Euro Area
%  ---------------------------------------------------------------------
%  Master thesis benchmark model  -  Maximilian Stein (Paris-Dauphine, PSL)
%  Supervisor: Fabien Tripier
%
%  This file implements the STATIONARIZED equilibrium system (thesis
%  Appendix B, current numbering B.1-B.32 after the B.18-duplicate removal
%  of July 2026) of an Isore & Szczerbowicz (2017, JEDC) New-Keynesian
%  disaster-risk economy EXTENDED with
%     (i)   a Bernanke-Gertler-Gilchrist (1999) entrepreneur / external
%           finance premium block (BGG), and
%     (ii)  a Gertler-Karadi (2011) bank block with an ENDOGENOUS binding
%           leverage constraint (GK), derived from the bank's own
%           incentive constraint (see "2026-07-30 RESOLUTION" below),
%           forming, together with (i), a Rannenberg (2016)-style double
%           financial accelerator, and
%     (iii) a home-bias sovereign-bond channel + Gabaix (2012) closed-form
%           bond price, normalised per the corrected A.3.3.2 (thesis'
%           novel sovereign-bank transmission).
%
%  2026-07-29/30 RESOLUTION (Blanchard-Kahn failure, see CHANGELOG for the
%  full diagnostic trail): the persistent "8 unstable roots for 7
%  forward-looking variables" BK failure was traced, via systematic
%  isolation, to the Gertler-Karadi bank block itself: a FIXED leverage
%  ratio (the old parameter "lam") imposed as a strict equality every
%  period, together with an INDEPENDENT net-worth accumulation equation,
%  over-determines the model by exactly one degree -- present with or
%  without the BGG entrepreneur block, with or without the sovereign
%  extension. The standard Gertler-Karadi (2011) resolution is to derive
%  the leverage ratio ENDOGENOUSLY from the bank's own incentive
%  (divertability) constraint rather than calibrating it as a constant;
%  this is now implemented (new vars etaB/nuB/OmB, endogenous "lev").
%  The BGG entrepreneur block was initially removed while isolating the
%  bug, then DELIBERATELY REINSTATED once the endogenous-leverage fix was
%  validated: BGG and GK are not structurally incompatible -- only a
%  FIXED bank leverage ratio combined with independent net-worth dynamics
%  was the problem, exactly as in Rannenberg (2016), whose double
%  accelerator (entrepreneur + bank, both non-fixed) motivated re-testing
%  this. Verified: resid exact zero, BK clean (9=9) at order 1, order=3
%  pruning completes for both phi=0.03 and phi=1e-4. See CHANGELOG for the
%  full economic rationale, all intermediate (rejected and accepted)
%  specifications, and the original frictionless-firm equations preserved
%  as comments where superseded.
%
%  WHY DYNARE:  the model is solved by perturbation.  The thesis targets a
%  THIRD-ORDER approximation (order=3 below).  Steady state is supplied
%  analytically via steady_state_model; (no numerical initval search).
%
%  HOW TO RUN (from a MATLAB session with Dynare 6.x on the path):
%     >> addpath /Applications/Dynare/6.3-x86_64/matlab      % adjust path
%     >> dynare thesis_model_v3                              % baseline, phi>0
%     >> dynare thesis_model_v3 -DPHIVAL=1e-4                % counterfactual
%  or simply run the driver  run_thesis_model.m  which does both plus IRFs.
%
%  STATUS (as of this version):
%   * SDF disaster loading uses two distinct Gourio moments, Dcal (Bellman/
%     Calvo discounting) and Ecal (risk-free rate / bond pricing), per the
%     corrected Appendix B.3/B.3a-c.  See vars CE, Dcal, Ecal, Theta.
%   * Epstein-Zin certainty equivalent (CE) is a separate auxiliary
%     variable so Dynare's per-equation expectation operator applies to
%     v(+1)^(1-chi) rather than collapsing it; this is load-bearing for the
%     3rd-order risk-premium response to theta_t, not just the steady state.
%   * Sovereign resilience H^b uses the Ecal-normalised loading
%     LambdaM/Ecal (thesis A.3.3.2c), so E_t[Q*R^b]=1 holds exactly, not
%     to first order in theta.
%   * Entrepreneur equity ratio uses k^n = exp(muz)*k throughout (eqs 22,
%     24 and the matching steady-state block), consistent with B.17/B.19.
%
%  RESOLVED since the previous version:
%   * Document B.23 now reads R^S_{t-1}, R^d_{t-1}, matching this .mod's
%     eq (27) and the B.17/B.18 rate-timing convention. No longer flagged.
%   * eq (4), the SDF: v(+1)^(-chi) was previously left unscaled even
%     after CE was rescaled -- v_ss~140.6 raised to -chi~8.32 gives a
%     derivative ~4.5e16 at the steady state, which alone explains
%     eigenvalues of that magnitude in the 3rd-order solve. Rewritten as
%     the single ratio (v(+1)/STEADY_STATE(v))^(-chi), an exact identity
%     with derivative ~O(1) at the steady state. Verified against the
%     analytic steady state to exact zero residual before and after.
%
%  OPEN / FLAGGED (not yet resolved, tracked here rather than silently
%  picked one way):
%   * No perturbation-based realisation of x_t=1: theta_t (the probability)
%     moves, but no default event ever fires along the simulated path.
%     Confirm before drafting the results chapter which literature the
%     headline GIRFs correspond to.
%   * Government budget constraint / T_t (thesis B.29) not implemented;
%     T_t is a pure residual with no feedback, so the model solves without
%     it, but the equation count then only nets to the 32 stationary block
%     equations actually wired in below (35 core + reporting, plus the 4
%     SDF/moment auxiliaries CE/Dcal/Ecal/Theta = 39 vars / 39 eqs).
% =========================================================================

% -------------------------------------------------------------------------
%  0.  MACRO SWITCH for the home-bias parameter (baseline vs counterfactual)
%      Run  `dynare thesis_model`            -> PHIVAL defaults to 0.03
%      Run  `dynare thesis_model -DPHIVAL=1e-4` -> counterfactual, no sov. channel
% -------------------------------------------------------------------------
@#ifndef PHIVAL
    @#define PHIVAL = 0.03
@#endif
% Perturbation order (3 = thesis target).  For a first DEBUG pass use
%   `dynare thesis_model -DORDER=1`  to isolate steady-state / Blanchard-Kahn
% issues from any 3rd-order/pruning issues.  Pruning is only added at order>=2.
@#ifndef ORDER
    @#define ORDER = 3
@#endif


%==========================================================================
%  1.  ENDOGENOUS VARIABLES  (all STATIONARY / detrended, thesis App. B)
%==========================================================================
var
% --- IS2017 real / nominal core ---------------------------------------
theta       % disaster probability                        (thesis eq 1)
betatheta   % pseudo (endogenous) discount factor beta(theta)   (A.1.5/B.2)
y           % detrended output   Y/z                            (B.14)
c           % detrended consumption C/z                         (B.4)
i           % detrended investment I/z                          (B.1)
L           % labour (stationary)                               (A.1.2)
k           % detrended end-of-period capital K_{t+1}/z         (B.1)
u           % capital utilisation                               (B.17)
ktilde      % detrended effective capital u*K/z                 (B.8)
w           % detrended real wage                               (B.6)
Pkr         % real rental rate of capital (stationary)          (B.7)
Q           % stochastic discount factor E_t[Lambda_{t,t+1}]    (B.3)
pi          % gross inflation                                   (B.12)
pireset     % gross reset inflation                             (B.9)
X1          % Calvo auxiliary 1                                 (B.10)
X2          % Calvo auxiliary 2                                 (B.11)
Omega       % price dispersion                                  (B.13)
mc          % real marginal cost                                (A.2)
v           % detrended EZW value function                      (B.2)
r           % gross nominal policy rate                         (B.31)
Qtob        % Tobin's Q (price of installed capital)            (B.5)
% --- rates -------------------------------------------------------------
Rf          % gross real risk-free rate  = 1/Q                  (A.1.6)
Rd          % gross real deposit rate    = Rf (deposit market)  (A.5)
RS          % gross real loan rate                              (B.17)
RK          % gross real *realised* return on capital (x=0)     (B.16)
% --- entrepreneurs (BGG) -- 2026-07-30: REINSTATED alongside the
%     endogenous GK bank leverage (double accelerator); see CHANGELOG ---
Ne          % detrended entrepreneur net worth  N^e/z           (B.18)
QS          % value of loans  Q_t s_t   (=Q_t K_{t+1}-N^e_t)    (B.19)
% --- banks (Gertler-Karadi + home bias) -------------------------------
QbB         % value of sovereign bonds on bank books Q^b_t b^b_t (B.22)
Nb          % detrended bank net worth  N^b/z                   (B.23)
D           % detrended deposits (residual, bank balance sheet) (B.20)
% --- sovereign / disaster transmission --------------------------------
Qb          % sovereign bond price                              (B.25)
Hb          % bond resilience  H^b                              (B.24)
Rb          % gross real *realised* bond return (x=0)           (B.26)
% --- reporting only (definitional) ------------------------------------
spread      % sovereign spread  1/Q^b - R^f                     (B.29)
% --- 2026-07-29: ENDOGENOUS Gertler-Karadi leverage (replaces fixed "lam")
lev         % bank leverage (QS+QbB)/Nb -- NOW ENDOGENOUS, load-bearing
etaB        % marginal value of bank assets funded by deposits
nuB         % marginal value of bank net worth
OmB         % banker's continuation value per unit of net worth carried fwd
% --- SDF and Bond Normalisation ---------------------------------------
CE 
Dcal 
Ecal 
Theta
;

%==========================================================================
%  2.  EXOGENOUS SHOCKS
%==========================================================================
varexo
etheta      % disaster-probability shock  (the main experiment)
er          % monetary-policy shock
;

%==========================================================================
%  3.  PARAMETERS
%==========================================================================
parameters
% preferences / technology (IS2017)
muz beta0 delta0 zeta upsilon gamma psi psitilde chi alpha varpi tau
rhor rhotheta phipi phiy sigr sigtheta eta Deltak
% steady-state references used inside the model block
piss thetass
% NEW: banking/entrepreneur/sovereign block (2026-07-30: BGG params
% reinstated alongside endogenous GK leverage -- "lam" replaced by
% "lambdadiv"; double-accelerator, see CHANGELOG)
Deltab chie premE levE sigma_e sprL phi lambdadiv sigma_b
f0 iotae iotab LambdaM uss
;

% ---- IS2017 calibration (quarterly) -------------------------------------
% Disaster Risk
thetass  = 0.009;     % steady-state disaster probability
Deltak   = 0.22;      % capital & productivity destroyed in a disaster
rhotheta = 0.9;       % disaster-probability persistence
sigtheta = 0.6;       % std of disaster-risk shock

% Utility Function
beta0    = 0.9985;      % subjective discount factor
psitilde = 2;         % inverse EIS
gamma    = 3.8;       % relative risk aversion coefficient
varpi    = 2.33;      % leisure preference (Gourio 2012)

% Investment
delta0   = 0.025;      % depreciation
tau      = 2;         % capital adjustment cost
uss      = 1;         % utilisation normalisation (target u=1)

% Production
alpha    = 0.36;      % capital share
zeta     = 0.6;       % Calvo stickiness
upsilon  = 3.85;         % elasticity of substitution across varieties (nu)
muz      = 0.003;     % trend TFP growth (mu)

% Public Authority
piss     = 1.00475;     % gross inflation target
phipi    = 1.5;       % Taylor: inflation response
phiy     = 0.5;       % Taylor: output response
rhor     = 0.93;      % interest-rate smoothing

sigr     = 1;         % Taylor-rule scaling coefficient on er (always needed,
                       % regardless of whether the shock is active); the
                       % on/off switch is the shock's stderr below, NOT this
                       % parameter -- see (var er; stderr 0;) in the SHOCKS
                       % block. Leaving this commented out left sigr
                       % unassigned (NaN), which propagates through
                       % "sigr*er" in the Taylor rule and breaks the steady
                       % state even with er's stderr=0, since NaN*0=NaN.



% ---- NEW banking/entrepreneur/sovereign calibration (2026-07-30) --------
Deltab   = 0.37;      % sovereign haircut in a disaster (Cruces-Trebesch ~0.37)
chie     = 0.0276;    % elasticity of external finance premium wrt leverage (Gelain 2010 posterior)
sigma_e  = 0.9769;    % entrepreneur survival rate (Gelain 2010 posterior)
sigma_b  = 0.95;      % banker survival rate
levE     = 2.0;       % target entrepreneur leverage  Q k / N^e (BGG ~ 2)
premE    = 1.0030;    % target entrepreneur premium  E[R^K]/R^S (~120bp annual)
sprL     = 1.0020;    % bank loan spread R^S/R^d -- the BANK's own friction,
                       % distinct from the entrepreneur's premium above (two
                       % independent margins, as in Rannenberg 2016's double
                       % accelerator, NOT one friction relabelled as two)
phi      = @{PHIVAL}; % home-bias: sovereign-bond share of bank assets (0=cf)
% "lam" (fixed leverage) REMOVED -- bank leverage is ENDOGENOUS, derived
% from the bank's own incentive constraint. "lambdadiv" (the divertable
% fraction of assets) is calibrated in steady_state_model below so the
% steady-state leverage stays at the SAME target (4.0) as before -- see
% CHANGELOG_dynare_debug.md for the full derivation.

% ---- parameter transformations (Gourio 2012/2014) -----------------------
psi = 1 - (1-psitilde)/(1+varpi); % Old Comment - is it actually true? has no counterpart in the thesis, which defines psi directly the inverse EIS.  It yields psi = 1.3003, not 2. 
chi = 1 - (1-gamma)/(1-psi);

%==========================================================================
%  4.  CLOSED-FORM STEADY STATE  (computed here; used in initval below)
%      Derivation: thesis Appendix B + Appendix D logic.  All quantities
%      verified to give zero equation residuals (see header).
%==========================================================================
steady_state_model;

LambdaM = (1-Deltak)^(-gamma);                                   % disaster SDF loading

% --- household / SDF block: Dcal, Ecal, Q(=E[Q]), Theta FIRST ------------
Dcalss  = 1 - thetass + thetass*(1-Deltak)^(1-gamma);
Ecalss  = 1 - thetass + thetass*(1-Deltak)^(-gamma);
Qfss    = beta0*exp(-psi*muz)*Dcalss^((gamma-psi)/(1-gamma));
Qss     = Qfss*Ecalss;                    % = E[Q]
Thetass = Qss*exp(muz)*Dcalss/Ecalss;     % = betathetass*exp((1-psi)*muz)
Rfss    = 1/Qss;
Rdss    = Rfss;
betathetass = beta0*((1 - thetass + thetass*exp((1-gamma)*log(1-Deltak)))^(1/(1-chi)));

% --- rates that depend on Rdss --------------------------------------------
rss   = piss/Qss;                                                 % nominal rate (Fisher)
RSss  = sprL*Rdss;                                                % bank loan rate (bank's own friction)
ERKss = premE*RSss;                                               % 2026-07-30: BGG premium reinstated,
                                                                   % E[R^K] = premE*R^S (entrepreneur's
                                                                   % OWN margin, distinct from sprL)
RKtildess = ERKss/(1-thetass*Deltak);
pkrss = RKtildess - (1-delta0);                                   % rental rate (u=1,Qtob=1)
eta   = pkrss/delta0;                                             % utilisation curvature (=> u=1)

% --- firm block (uses Thetass, not the old hand-built discount factor) ---
piresetss = (((piss)^(1-upsilon)-zeta)/(1-zeta))^(1/(1-upsilon));
mcss = ((upsilon-1)/upsilon)*(1/piss)*((1-zeta*Thetass*(piss)^upsilon)/(1-zeta*Thetass*(piss)^(upsilon-1)))*piresetss;
klss = (mcss*alpha/pkrss)^(1/(1-alpha));                          % effective K / L
wss  = mcss*(1-alpha)*(klss)^alpha;
omegass = ((1-zeta)*(piresetss)^(-upsilon)*(piss)^upsilon)/(1-zeta*(piss)^upsilon);
clss = (1/omegass)*(klss)^alpha - klss*(exp(muz)-1+delta0);       % c / L
lss  = 1/(1+(varpi/wss)*clss);
kss  = klss*lss;   ktildess = kss;   css = clss*lss;
ylss = clss + klss*(exp(muz)-1+delta0);   yss = ylss*lss;   iss = yss-css;
X1ss = yss*mcss/(1-zeta*Thetass*(piss)^upsilon);
X2ss = yss/(1-zeta*Thetass*(piss)^(upsilon-1));
vss  = (css*(1-lss)^varpi)^(1-psi)/(1-betathetass*exp(muz*(1-psi)));
CEss = 1;                          % rescaled: (vss/STEADY_STATE(v))^(1-chi)=1 identically at SS
Qtobss = 1;    RKss = RKtildess;

% --- entrepreneur block (2026-07-30: BGG reinstated) -- knss (=e^mu*kss),
% matching dynamic eq (24) --------------------------------------------------
knss  = exp(muz)*kss;
Ness  = knss/levE;
f0    = premE*(1/levE)^(chie);
iotae = Ness - sigma_e*exp(-muz)*(RKss*kss - RSss*(kss - Ness));
QSss  = knss - Ness;                    % bank loans = capital value NET of entrepreneur equity

% --- bank block: leverage TARGET (4.0, same numeric target as the old
% fixed "lam") anchors the calibration; lev itself is now an ENDOGENOUS
% variable in the dynamic model (see eqs 26/26a-d below). -----------------
levss = 6;      % Coenen et al. (2018) / NAWM II wholesale-bank leverage target
Ass   = QSss/(1-phi);
QbBss = phi*Ass;
Nbss  = Ass/levss;
Dss   = Ass - Nbss;
Hbss  = 1 - thetass*Deltab*LambdaM/Ecalss;
Qbss  = Hbss/Rfss;
Rbss  = 1/Qbss;
iotab = Nbss - sigma_b*exp(-muz)*((RSss-Rdss)*QSss + (Rbss-Rdss)*QbBss + Rdss*Nbss);
spreadss = 1/Qbss - Rfss;

% --- 2026-07-29: endogenous GK leverage -- derive lambdadiv (divertable
% fraction of assets) so the bank's incentive constraint binds EXACTLY at
% the target steady-state leverage levss=4.0 above (same numeric steady
% state as the old fixed-"lam" version for every other variable). Full
% derivation in CHANGELOG_dynare_debug.md.
spreadAss = (1-phi)*RSss + phi*Rbss - Rdss;      % portfolio excess return over Rd
OmBss = (1-sigma_b) / (1 - sigma_b*Qss*(levss*spreadAss + Rdss));
etaBss = Qss*OmBss*spreadAss;
nuBss  = Qss*OmBss*Rdss;
lambdadiv = etaBss + nuBss/levss;                 % calibrated, not a free input

theta     = thetass;
betatheta = betathetass;
y = yss;    c = css;    i = iss;
L = lss;    k = kss;    u = uss;    ktilde = ktildess;
w = wss;    Pkr = pkrss;
Q = Qss;
pi = piss;  pireset = piresetss;
X1 = X1ss;  X2 = X2ss;
Omega = omegass;   mc = mcss;
v = vss;
r = rss;
Qtob = Qtobss;
Rf = Rfss;  Rd = Rdss;  RS = RSss;  RK = RKss;
Ne = Ness;  QS = QSss;
QbB = QbBss;  Nb = Nbss;  D = Dss;
Qb = Qbss;  Hb = Hbss;  Rb = Rbss;
spread = spreadss;  lev = levss;
etaB = etaBss;  nuB = nuBss;  OmB = OmBss;
CE    = CEss;
Dcal  = Dcalss;
Ecal  = Ecalss;
Theta = Thetass;

end;

%==========================================================================
%  5.  MODEL EQUATIONS (2026-07-30: BGG + endogenous GK double accelerator)
%      Timing:  k, Ne, Nb, QS, QbB, Qb, r, theta, Omega, Qtob are states
%      (their (-1) lags appear);  c,L,v,Pkr,u,Qtob,X1,X2,pi,RK,Rb,OmB
%      appear as (+1) leads (rational-expectations / forward looking).
%==========================================================================
model;

% ---- (1) exogenous disaster-probability process  (thesis eq 1) ----------
log(theta) = (1-rhotheta)*log(thetass) + rhotheta*log(theta(-1)) + etheta;

% ---- ADDED DURING COMMIT 4 ----------------------------------------------

 % (4a) certainty equivalent, held as its own variable so that
   %      Dynare's expectation operator applies to v^(1-chi) and not
   %      to the whole power.  Without this the EZ risk adjustment
   %      cancels identically at every order.
   % Rescaled by STEADY_STATE(v): raw v(+1)^(1-chi) has SS value ~1e20
   % (v_ss~140.6, 1-chi~9.32), which badly conditions the Jacobian used
   % by the 3rd-order (k_order) solver even though it is mathematically
   % exact. Dividing by the constant STEADY_STATE(v) first makes CE_ss=1
   % identically; the STEADY_STATE(v) factors are reinserted in eqs (2)
   % and (4) below so the algebra is UNCHANGED (verified to machine
   % precision against the un-rescaled steady state).
   CE = (v(+1)/STEADY_STATE(v))^(1-chi);
 
   % (4b)-(4c) disaster moments (thesis Appendix B conventions)
   Dcal = 1 - theta + theta*(1-Deltak)^(1-gamma);
   Ecal = 1 - theta + theta*(1-Deltak)^(-gamma);
 
   % (4d) growth-adjusted discount factor  Theta_t = E_t[Q Gamma]  (B.3c)
   Theta = Q*exp(muz)*Dcal/Ecal;

% ---- HOUSEHOLDS ---------------------------------------------------------
% (2) EZW value function, detrended                                    (B.2)
v = (c*(1-L)^varpi)^(1-psi) + betatheta*exp((1-psi)*muz)*STEADY_STATE(v)*CE^(1/(1-chi));
% (3) pseudo-discount factor beta(theta)                          (A.1.5/B.2)
betatheta = beta0*((1 - theta + theta*exp((1-gamma)*log(1-Deltak)))^(1/(1-chi)));
% (4) Epstein-Zin stochastic discount factor / consumption Euler       (B.3)
% NOTE: (v(+1)/STEADY_STATE(v))^(-chi) is written as a single ratio, not
% as v(+1)^(-chi) * STEADY_STATE(v)^chi separately. The two are an EXACT
% algebraic identity for every v, not an approximation -- but Dynare's
% automatic differentiation acts on the literal expression as written,
% not on an algebraically-simplified version of it. The raw v(+1)^(-chi)
% sub-expression has derivative ~4.5e16 at this steady state (v_ss~140.6,
% chi~-8.32), which alone is enough to produce the ~1e16-1e18 eigenvalues
% seen when this term was left unscaled -- multiplying by STEADY_STATE(v)^chi
% afterward does not fix the conditioning of the intermediate derivative.
% Writing the ratio directly keeps the value ~O(1) throughout, including
% in the derivative Dynare actually differentiates.
Q = beta0*(c(+1)/c)^(-psi)*((1-L(+1))/(1-L))^(varpi*(1-psi))
    * exp(-gamma*muz)
    * (v(+1)/STEADY_STATE(v))^(-chi)
    * (CE*exp((1-gamma)*muz)*Dcal)^(chi/(1-chi))
    * Ecal;
% (5) consumption-leisure FOC                                          (B.4)
(1-L)/c = varpi/w;
% (6) deposit / risk-free Euler (Fisher):  Q = E_t[pi(+1)]/r          (A.1.3)
Q = pi(+1)/r;
% (7) real risk-free rate                                             (A.1.6)
Rf = 1/Q;
% (8) deposit-market clearing  R^d = R^f                               (A.5)
Rd = Rf;

% ---- CAPITAL-GOODS PRODUCER & CAPITAL ACCUMULATION ----------------------
% (9) Tobin's Q                                                        (B.5)
Qtob = 1/(1 - tau*(i/k(-1) - STEADY_STATE(i)/STEADY_STATE(k)));
% (10) detrended capital law of motion (Gourio factor cancels)         (B.1)
k = ((1-delta0*u^eta)*k(-1) + (i/k(-1) - tau/2*((i/k(-1) - STEADY_STATE(i)/STEADY_STATE(k))^2))*k(-1))/exp(muz);

% ---- FIRMS & PRICE SETTING ---------------------------------------------
% (11) aggregate production                                            (B.14)
y = ktilde^alpha * L^(1-alpha) / Omega;
% (12) real wage                                                       (B.6)
w = mc*(1-alpha)*(ktilde/L)^alpha;
% (13) real rental rate                                                (B.7)
Pkr = mc*alpha*(ktilde/L)^(alpha-1);
% (14) effective capital                                               (B.8)
ktilde = u*k(-1);
% (15) reset inflation                                                 (B.9)
pireset = pi*upsilon/(upsilon-1)*X1/X2;
% (16) price dispersion                                                (B.13)
Omega = (1-zeta)*pireset^(-upsilon)*pi^upsilon + zeta*pi^upsilon*Omega(-1);
% (17) aggregate inflation                                             (B.12)
pi^(1-upsilon) = (1-zeta)*pireset^(1-upsilon) + zeta;
% (18) Calvo auxiliary X1                                              (B.10)
X1 = y*mc + zeta*Theta*X1(+1)*pi(+1)^upsilon;
% X1 = y*mc + zeta*Q*(1-theta*Deltak)*exp(muz)*X1(+1)*pi(+1)^upsilon; (hand build)
% (19) Calvo auxiliary X2                                              (B.11)
% X2 = y + zeta*Q*(1-theta*Deltak)*exp(muz)*X2(+1)*pi(+1)^(upsilon-1); (hand build)
X2 = y + zeta*Theta*X2(+1)*pi(+1)^(upsilon-1);
% ---- ENTREPRENEURS (Bernanke-Gertler-Gilchrist 1999) --------------------
% (20) utilisation FOC                                                 (B.15)
Pkr = Qtob*delta0*eta*u^(eta-1);
% (21) realised (disaster-free, x=0) return on capital                 (B.16)
RK = (Pkr*u + Qtob*(1-delta0*u^eta))/Qtob(-1);
% (22) 2026-07-30: BGG external finance premium REINSTATED on top of the
% endogenous GK bank block -- Rannenberg (2016)-style double accelerator:
% entrepreneur leverage (Ne/Qk) sets ITS OWN premium over the bank loan
% rate RS, while RS itself is set by the bank's OWN (now endogenous)
% leverage margin below. Two distinct, non-redundant financial frictions
% (see CHANGELOG for why this does not reintroduce the earlier BK issue).
(1-theta*Deltak)*RK(+1) = RS * f0 * (Ne/(Qtob*exp(muz)*k))^(-chie);
% (23) entrepreneur net-worth accumulation                            (B.18)
% FIXED: Gamma^-1 (exp(-muz)) must scale the ENTIRE bracket, not just the
% Ne(-1) term -- thesis B.18 explicitly states "factor Gamma_t^{-1}"
% applied to the whole [R^K*Q*k^n - R^S*(Q*k^n-N^e)] bracket, exactly
% mirroring eq (27)/B.23's bank net-worth structure.
Ne = sigma_e*exp(-muz)*( RK*Qtob(-1)*k(-1) - RS(-1)*(Qtob(-1)*k(-1) - Ne(-1)) ) + iotae;
% (24) entrepreneur balance sheet  (defines loan value QS)            (B.19)
QS = Qtob*exp(muz)*k - Ne;

% ---- BANKS (Gertler-Karadi 2011 + home bias) ----------------------------
% (25) home-bias portfolio identity                                    (B.22)
QbB = phi/(1-phi)*QS;
% (26) 2026-07-29: ENDOGENOUS leverage constraint, replacing the fixed
% "lam*Nb" (see CHANGELOG_dynare_debug.md for the full diagnosis: a FIXED
% leverage ratio together with the independent net-worth accumulation
% eq(27) over-determined the model by exactly one degree -- this was the
% actual root cause of the persistent Blanchard-Kahn failure).
% ORIGINAL (fixed leverage, thesis B.21): QS + QbB = lam*Nb;
QS + QbB = lev*Nb;
% (26a) banker's continuation value per unit of net worth carried into
% next period -- standard Gertler-Karadi envelope condition.
OmB = (1-sigma_b) + sigma_b*( etaB*lev + nuB );
% (26b) marginal value of a unit of bank assets funded by deposits. Home
% bias (25) fixes the QS/QbB split, so the portfolio return on total
% assets is (1-phi)*RS + phi*Rb(+1); RS is a safe, pre-contracted rate
% (no lead needed, matching the (22) zero-profit condition above), Rb(+1)
% is the disaster-exposed sovereign bond return, matching the timing
% convention already used in (27).
etaB = Q*OmB(+1)*( (1-phi)*RS + phi*Rb(+1) - Rd );
% (26c) marginal value of a unit of bank net worth (not funding assets).
nuB = Q*OmB(+1)*Rd;
% (26d) incentive (divertability) constraint, binding: a banker can
% divert fraction lambdadiv of assets; V_t=etaB_t*A_t+nuB_t*Nb_t >=
% lambdadiv*A_t binds, giving leverage = nuB/(lambdadiv-etaB). This
% REPLACES the fixed "lam" parameter with the bank's own endogenously
% time-varying leverage ratio.
lev = nuB/(lambdadiv - etaB);
% (27) BANK NET WORTH   -- DIVERGENCE from thesis B.24: see (D2)       (B.23)
Nb = sigma_b*exp(-muz)*( (RS(-1)-Rd(-1))*QS(-1) + (Rb-Rd(-1))*QbB(-1) + Rd(-1)*Nb(-1) ) + iotab;
% (28) bank balance sheet (defines deposits D)                         (B.20)
QS + QbB = Nb + D;

% ---- SOVEREIGN / DISASTER TRANSMISSION (Gabaix 2012 closed form) --------
% (29) resilience                                                      (B.24)
 Hb = 1 - theta*Deltab*LambdaM/Ecal;
% (30) sovereign bond price                                            (B.25)
Qb = Hb/Rf;
% (31) realised sovereign bond return (x=0)                            (B.26)
Rb = 1/Qb(-1);

% ---- PUBLIC AUTHORITY ---------------------------------------------------
% (32) Taylor rule                                                     (B.31)
r = rhor*r(-1) + (1-rhor)*( phipi*(pi-piss) + phiy*(y-STEADY_STATE(y)) + STEADY_STATE(r) ) + sigr*er;
% ---- MARKET CLEARING ----------------------------------------------------
% (33) aggregate resource constraint                                   (B.32)
y = c + i;

% ---- REPORTING (definitional) -------------------------------------------
% (34) sovereign spread                                                (B.28)
spread = 1/Qb - Rf;
% (35) [2026-07-29: bank leverage now determined endogenously by (26)/
% (26d) above, not a separate reporting identity -- would be redundant
% with eq(26). ORIGINAL: lev = (QS + QbB)/Nb;]

end;

% Confirm the steady state and determinacy BEFORE solving:
resid;            % should print residuals ~ 0 for every equation
steady;           % Newton solver: converges immediately (initval is exact)
check;            % eigenvalues / Blanchard-Kahn order condition
% (For extra rank/singularity diagnostics, run  model_diagnostics(M_,options_,oo_)
%  from the MATLAB prompt AFTER this file has been processed by Dynare.)

% One-time confirmation that the analytic SS matches the Appendix C target.
% Safe to delete once verified; harmless to leave in.
% disp(['Q  steady state: ', num2str(oo_.steady_state(strmatch('Q', M_.endo_names,'exact')))]);
% disp(['Rf steady state: ', num2str(oo_.steady_state(strmatch('Rf',M_.endo_names,'exact')))]);
% disp(['k  steady state: ', num2str(oo_.steady_state(strmatch('k', M_.endo_names,'exact')))]);

%==========================================================================
%  7.  SHOCKS
%==========================================================================
shocks;
var etheta; stderr sigtheta;   % disaster-risk shock (main experiment)
var er;     stderr 0;       % MP shock off by default (set >0 to activate), when enabled: sigr
end;


%==========================================================================
%  8.  SOLUTION
%      order=3  -> the third-order perturbation the thesis targets.
%      pruning  -> keeps 3rd-order simulations stable (Andreasen et al.).
%      irf=0    -> IRFs are produced from the ERGODIC MEAN in the driver
%                  run_thesis_model.m (correct notion at 3rd order), exactly
%                  as in the IS2017 replication code (simult_).
%      NOTE: to get a quick first look you can switch to order=1 and irf=20.
%==========================================================================
@#if ORDER > 1
stoch_simul(order=@{ORDER}, pruning, irf=20, periods=0, replic=1, nograph);
@#else
stoch_simul(order=1, irf=20, periods=0, replic=1, nograph);
@#endif
