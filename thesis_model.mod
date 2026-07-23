% =========================================================================
%  Sovereign Disaster Risk, Banking Frictions and Macro Tail Outcomes
%  in a New Keynesian DSGE for the Euro Area
%  ---------------------------------------------------------------------
%  Master thesis benchmark model  -  Maximilian Stein (Paris-Dauphine, PSL)
%  Supervisor: Fabien Tripier
%
%  This file implements the STATIONARIZED equilibrium system (thesis
%  Appendix B, eqs B.1-B.35) of an Isore & Szczerbowicz (2017, JEDC)
%  New-Keynesian disaster-risk economy EXTENDED with
%     (i)   a Bernanke-Gertler-Gilchrist (1999) entrepreneur / external
%           finance premium block (BGG),
%     (ii)  a Gertler-Karadi (2011) bank block with a binding leverage
%           constraint (GK), and
%     (iii) a home-bias sovereign-bond channel + Gabaix (2012) closed-form
%           bond price (the thesis' novel sovereign-bank transmission).
%
%  WHY DYNARE:  the model is solved by perturbation.  The thesis ultimately
%  wants a THIRD-ORDER approximation (order=3 below), which Dynare produces
%  automatically; hand-coding a 3rd-order solution would be error prone.
%  This .mod is the *benchmark* whose job is to (a) have a well-defined
%  steady state and (b) SOLVE (Blanchard-Kahn satisfied) so first results
%  can be produced and debugged.
%
%  HOW TO RUN (from a MATLAB session with Dynare 6.x on the path):
%     >> addpath /Applications/Dynare/6.3-x86_64/matlab      % adjust path
%     >> dynare thesis_model                                 % baseline, phi>0
%     >> dynare thesis_model -DPHIVAL=0                       % counterfactual
%  or simply run the driver  run_thesis_model.m  which does both plus IRFs.
%
%  MODELLING CHOICES / DEVIATIONS FROM THE THESIS DRAFT  (documented so you
%  can decide whether to keep them):
%   * The Gourio (2012) trick is applied throughout: the binary disaster
%     indicator x_{t+1} is integrated out of every expectation, leaving the
%     smooth disaster PROBABILITY theta_t as the only disaster driver.  No
%     disaster is ever *realised* in the perturbation solution; disaster
%     RISK enters through betatheta(theta), the (1-theta*Deltak) wedges and
%     the bond resilience H^b.  This is exactly what makes perturbation (incl.
%     3rd order) valid and reproduces IS2017 at phi=0 with no bank block.
%   * The thesis' banking block, taken literally (B.19 R^L=E[R^K] AND B.20
%     EFP AND B.24 binding leverage), is over-identified by one equation and
%     the "pass-through" convention (bank earns R^K on loans) makes the
%     entrepreneur net-worth accelerator degenerate (R^K=R^L => zero spread).
%     To obtain a SQUARE, flow-consistent system that keeps BOTH net-worth
%     channels alive, this benchmark uses the standard GK+BGG closure:
%        - the bank earns the LOAN rate R^L on loans (flow-exact with what
%          entrepreneurs pay), see eq (BANK NW);
%        - the free-entry identity (B.19) and the EFP (B.20) are consolidated
%          into ONE Bernanke (1999) capital-demand equation
%              E_t[R^K_{t+1}] = R^L_t * s0 (N^e_t / Q_t k_{t+1})^{-chi^e}
%          see eq (CAPITAL DEMAND).  This keeps the entrepreneur premium
%          non-degenerate (N^e channel) while the binding GK leverage
%          constraint pins credit -> capital (N^b / sovereign-bank channel).
%     >>> Both deviations are minor and clearly marked; revert them only if
%         you move to a long-term bond so that unrealised theta_t moves the
%         bond price on outstanding positions (thesis Section "SECTION XXX").
%
%  VERIFICATION DONE BEFORE SHIPPING (in Python, since MATLAB was unavailable
%  in the build environment):  all 33 core equilibrium equations have
%  machine-precision-zero residuals at the closed-form steady state below,
%  and the stacked Jacobian has full rank (square, regular system).  Dynare's
%  resid / check / model_diagnostics below re-confirm this and add the
%  Blanchard-Kahn determinacy test.
% =========================================================================


% -------------------------------------------------------------------------
%  0.  MACRO SWITCH for the home-bias parameter (baseline vs counterfactual)
%      Run  `dynare thesis_model`            -> PHIVAL defaults to 0.10
%      Run  `dynare thesis_model -DPHIVAL=0` -> counterfactual, no sov. channel
% -------------------------------------------------------------------------
@#ifndef PHIVAL
    @#define PHIVAL = 0.10
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
y           % detrended output   Y/z                            (B.15)
c           % detrended consumption C/z                         (B.4)
i           % detrended investment I/z                          (B.1)
L           % labour (stationary)                               (A.1.2)
k           % detrended end-of-period capital K_{t+1}/z         (B.1)
u           % capital utilisation                               (B.17)
ktilde      % detrended effective capital u*K/z                 (B.10)
w           % detrended real wage                               (B.8)
Pkr         % detrended real rental rate of capital             (B.9)
Q           % stochastic discount factor E_t[Lambda_{t,t+1}]    (B.3)
pi          % gross inflation                                   (B.14)
pireset     % gross reset inflation                             (B.11)
X1          % Calvo auxiliary 1                                 (B.12)
X2          % Calvo auxiliary 2                                 (B.13)
Omega       % price dispersion                                  (B.16)
mc          % real marginal cost                                (A.2)
v           % detrended EZW value function                      (B.2)
r           % gross nominal interest rate on bonds              (B.35)
Qtob        % Tobin's Q (price of installed capital)            (B.6)
% --- rates -------------------------------------------------------------
Rf          % gross real risk-free rate  = 1/Q                  (A.1.6)
Rd          % gross real deposit rate    = Rf (deposit market)  (A.5)
RL          % gross real loan rate                              (B.19/B.20)
RK          % gross real *realised* return on capital (x=0)     (B.18)
% --- entrepreneurs (BGG) ----------------------------------------------
Ne          % detrended entrepreneur net worth  N^e/z           (B.21)
QL          % value of loans  Q_t L_t   (=Q_t K_{t+1}-N^e_t)     (B.22)
% --- banks (Gertler-Karadi + home bias) -------------------------------
QbB         % value of sovereign bonds on bank books Q^b_t B^b_t (B.25)
Nb          % detrended bank net worth  N^b/z                   (B.26)
D           % detrended deposits (residual, bank balance sheet) (B.23)
% --- sovereign / disaster transmission --------------------------------
Qb          % sovereign bond price                              (B.28)
Hb          % bond resilience  H^b                              (B.27)
Rb          % gross real *realised* bond return (x=0)           (B.29)
% --- reporting only (definitional) ------------------------------------
spread      % sovereign spread  1/Q^b - R^f                     (B.31)
lev         % bank leverage  (QL+QbB)/Nb                        (reporting)
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
% NEW: banking / entrepreneur / sovereign block
Deltab chie premE sprL levE tau_e phi lam sigma_b
s0 iotae iotab LambdaM
;

% ---- IS2017 calibration (quarterly) -------------------------------------
delta0   = 0.02;      % depreciation
upsilon  = 6;         % elasticity of substitution across varieties (nu)
alpha    = 0.33;      % capital share
muz      = 0.005;     % trend TFP growth (mu)
phipi    = 1.6;       % Taylor: inflation response
phiy     = 0.4;       % Taylor: output response
sigr     = 1;         % scaling of MP shock (std set in shocks block)
rhor     = 0.85;      % interest-rate smoothing
psitilde = 2;         % inverse EIS
zeta     = 0.6;       % Calvo stickiness
gamma    = 3.8;       % relative risk aversion
tau      = 2;         % capital adjustment cost
varpi    = 2.33;      % leisure preference (Gourio 2012)
Deltak   = 0.22;      % capital & productivity destroyed in a disaster
rhotheta = 0.9;       % disaster-probability persistence
sigtheta = 0.6;       % std of disaster-risk shock
beta0    = 0.99;      % subjective discount factor
piss     = 1.005;     % gross inflation target
thetass  = 0.009;     % steady-state disaster probability
uss      = 1;         % utilisation normalisation (target u=1)

% ---- NEW banking/entrepreneur/sovereign calibration ---------------------
Deltab   = 0.30;      % sovereign haircut in a disaster (Cruces-Trebesch ~0.37)
chie     = 0.05;      % elasticity of external finance premium wrt leverage (BGG/CMR)
premE    = 1.0030;    % target entrepreneur premium  E[R^K]/R^L (~120bp annual)
sprL     = 1.0020;    % target bank loan spread       R^L/R^d   (~ 80bp annual)
levE     = 2.0;       % target entrepreneur leverage  Q k / N^e (BGG ~ 2)
tau_e    = 0.975;     % entrepreneur survival rate
phi      = @{PHIVAL}; % home-bias: sovereign-bond share of bank assets (0=cf)
lam      = 4.0;       % bank leverage multiplier  A / N^b  (Gertler-Karadi)
sigma_b  = 0.94;      % banker survival rate

% ---- parameter transformations (Gourio 2012/2014) -----------------------
psi = 1 - (1-psitilde)/(1+varpi);
chi = 1 - (1-gamma)/(1-psi);

%==========================================================================
%  4.  CLOSED-FORM STEADY STATE  (computed here; used in initval below)
%      Derivation: thesis Appendix B + Appendix D logic.  All quantities
%      verified to give zero equation residuals (see header).
%==========================================================================
LambdaM = (1-Deltak)^(-gamma);                                   % disaster SDF loading (B.27)

% --- household / SDF block (identical to IS2017; disaster in preferences)--
betathetass = beta0*((1 - thetass + thetass*exp((1-gamma)*log(1-Deltak)))^(1/(1-chi)));
Qss  = betathetass*exp((1-psi)*muz)/((1-thetass*Deltak)*exp(muz)); % SDF SS (B.3)
rss  = piss/Qss;                                                  % nominal rate (Fisher)
Rfss = 1/Qss;   Rdss = Rfss;                                      % risk-free / deposit
RLss = sprL*Rdss;                                                 % loan rate
ERKss = premE*RLss;                                               % E[R^K] = premE*R^L
RKtildess = ERKss/(1-thetass*Deltak);                            % disaster-free cap. return
pkrss = RKtildess - (1-delta0);                                  % rental rate (u=1,Qtob=1)
eta   = pkrss/delta0;                                            % utilisation curvature (=> u=1)

% --- firm block (IS2017 closed form, uses modified pkrss) ----------------
piresetss = (((piss)^(1-upsilon)-zeta)/(1-zeta))^(1/(1-upsilon));
mcss = ((upsilon-1)/upsilon)*(1/piss) *((1-zeta*Qss*(1-thetass*Deltak)*exp(muz)*(piss)^upsilon)/(1-zeta*Qss*(1-thetass*Deltak)*exp(muz)*(piss)^(upsilon-1)))*piresetss;
klss = (mcss*alpha/pkrss)^(1/(1-alpha));                          % effective K / L
wss  = mcss*(1-alpha)*(klss)^alpha;
omegass = ((1-zeta)*(piresetss)^(-upsilon)*(piss)^upsilon)/(1-zeta*(piss)^upsilon);
clss = (1/omegass)*(klss)^alpha - klss*(exp(muz)-1+delta0);       % c / L
lss  = 1/(1+(varpi/wss)*clss);
kss  = klss*lss;   ktildess = kss;   css = clss*lss;
ylss = clss + klss*(exp(muz)-1+delta0);   yss = ylss*lss;   iss = yss-css;
X1ss = yss*mcss/(1-zeta*Qss*(1-thetass*Deltak)*exp(muz)*(piss)^upsilon);
X2ss = yss/(1-zeta*Qss*(1-thetass*Deltak)*exp(muz)*(piss)^(upsilon-1));
vss  = (css*(1-lss)^varpi)^(1-psi)/(1-betathetass*exp(muz*(1-psi)));
Qtobss = 1;    RKss = RKtildess;

% --- entrepreneur block ---------------------------------------------------
Ness = kss/levE;                                                  % net worth (Qtob=1)
s0   = premE*(1/levE)^(chie);                                     % EFP scale (=> premE at SS)
iotae = Ness - tau_e*(RKss*kss - RLss*(kss - exp(-muz)*Ness));    % startup transfer (residual)
QLss = kss - Ness;                                                % loan value

% --- bank block -----------------------------------------------------------
Ass  = QLss/(1-phi);                                              % total bank assets
QbBss = phi*Ass;                                                  % sovereign-bond value
Nbss = Ass/lam;                                                   % bank net worth (leverage binds)
Dss  = Ass - Nbss;                                                % deposits
Hbss = 1 - thetass*Deltab*LambdaM;                               % resilience
Qbss = Hbss/Rfss;                                                % bond price
Rbss = 1/Qbss;                                                   % realised bond return (x=0)
iotab = Nbss - sigma_b*exp(-muz)*((RLss-Rdss)*QLss + (Rbss-Rdss)*QbBss + Rdss*Nbss); % startup
spreadss = 1/Qbss - Rfss;
levss = (QLss+QbBss)/Nbss;


%==========================================================================
%  5.  MODEL EQUATIONS  (33 core + 2 reporting = 35 equations / 35 vars)
%      Timing:  k, Ne, Nb, QL, QbB, Qb, r, theta, Omega, Qtob are states
%      (their (-1) lags appear);  c,L,v,Pkr,u,Qtob,X1,X2,pi,RK appear as
%      (+1) leads (rational-expectations / forward looking).
%==========================================================================
model;

% ---- (1) exogenous disaster-probability process  (thesis eq 1) ----------
log(theta) = (1-rhotheta)*log(thetass) + rhotheta*log(theta(-1)) + etheta;

% ---- HOUSEHOLDS ---------------------------------------------------------
% (2) EZW value function, detrended                                    (B.2)
v = (c*(1-L)^varpi)^(1-psi) + betatheta*exp((1-psi)*muz)*(v(+1)^(1-chi))^(1/(1-chi));
% (3) pseudo-discount factor beta(theta)                          (A.1.5/B.2)
betatheta = beta0*((1 - theta + theta*exp((1-gamma)*log(1-Deltak)))^(1/(1-chi)));
% (4) Epstein-Zin stochastic discount factor / consumption Euler       (B.3)
Q*(1-theta*Deltak)*exp(muz) = (c(+1)/c)^(-psi) * ((1-L(+1))/(1-L))^(varpi*(1-psi)) * betatheta*exp((1-psi)*muz) * v(+1)^(-chi)/(v(+1)^(1-chi))^(-chi/(1-chi));
% (5) consumption-leisure FOC                                          (B.4)
(1-L)/c = varpi/w;
% (6) deposit / risk-free Euler (Fisher):  Q = E_t[pi(+1)]/r          (A.1.3)
Q = pi(+1)/r;
% (7) real risk-free rate                                             (A.1.6)
Rf = 1/Q;
% (8) deposit-market clearing  R^d = R^f                               (A.5)
Rd = Rf;

% ---- CAPITAL-GOODS PRODUCER & CAPITAL ACCUMULATION ----------------------
% (9) Tobin's Q                                                        (B.6)
Qtob = 1/(1 - tau*(i/k(-1) - STEADY_STATE(i)/STEADY_STATE(k)));
% (10) detrended capital law of motion (Gourio factor cancels)         (B.1)
k = ((1-delta0*u^eta)*k(-1) + (i/k(-1) - tau/2*((i/k(-1) - STEADY_STATE(i)/STEADY_STATE(k))^2))*k(-1))/exp(muz);

% ---- FIRMS & PRICE SETTING ---------------------------------------------
% (11) aggregate production                                            (B.15)
y = ktilde^alpha * L^(1-alpha) / Omega;
% (12) real wage                                                       (B.8)
w = mc*(1-alpha)*(ktilde/L)^alpha;
% (13) real rental rate                                                (B.9)
Pkr = mc*alpha*(ktilde/L)^(alpha-1);
% (14) effective capital                                               (B.10)
ktilde = u*k(-1);
% (15) reset inflation                                                 (B.11)
pireset = pi*upsilon/(upsilon-1)*X1/X2;
% (16) price dispersion                                                (B.16)
Omega = (1-zeta)*pireset^(-upsilon)*pi^upsilon + zeta*pi^upsilon*Omega(-1);
% (17) aggregate inflation                                             (B.14)
pi^(1-upsilon) = (1-zeta)*pireset^(1-upsilon) + zeta;
% (18) Calvo auxiliary X1                                              (B.12)
X1 = y*mc + zeta*Q*(1-theta*Deltak)*exp(muz)*X1(+1)*pi(+1)^upsilon;
% (19) Calvo auxiliary X2                                              (B.13)
X2 = y + zeta*Q*(1-theta*Deltak)*exp(muz)*X2(+1)*pi(+1)^(upsilon-1);

% ---- ENTREPRENEURS (Bernanke-Gertler-Gilchrist 1999) --------------------
% (20) utilisation FOC                                                 (B.17)
Pkr = Qtob*delta0*eta*u^(eta-1);
% (21) realised (disaster-free, x=0) return on capital                 (B.18)
RK = (Pkr*u + Qtob*(1-delta0*u^eta))/Qtob(-1);
% (22) CAPITAL DEMAND / external finance premium  E[R^K]=R^L*premium   (B.19+B.20)
%      Consolidates free-entry (R^L=E[R^K]) and EFP into one BGG wedge.
(1-theta*Deltak)*RK(+1) = RL * s0 * (Ne/(Qtob*k))^(-chie);
% (23) entrepreneur net-worth accumulation                            (B.21)
Ne = tau_e*( RK*Qtob(-1)*k(-1) - RL(-1)*(Qtob(-1)*k(-1) - exp(-muz)*Ne(-1)) ) + iotae;
% (24) entrepreneur balance sheet  (defines loan value QL)             (B.22)
QL = Qtob*k - Ne;

% ---- BANKS (Gertler-Karadi 2011 + home bias) ----------------------------
% (25) home-bias portfolio identity                                    (B.25)
QbB = phi/(1-phi)*QL;
% (26) binding leverage constraint  A = lambda*N^b                     (B.24)
QL + QbB = lam*Nb;
% (27) BANK NET WORTH  (bank earns the LOAN rate R^L on loans)         (B.26)
Nb = sigma_b*exp(-muz)*( (RL-Rd)*QL(-1) + (Rb-Rd)*QbB(-1) + Rd*Nb(-1) ) + iotab;
% (28) bank balance sheet (defines deposits D)                         (B.23)
QL + QbB = Nb + D;

% ---- SOVEREIGN / DISASTER TRANSMISSION (Gabaix 2012 closed form) --------
% (29) resilience                                                      (B.27)
Hb = 1 - theta*Deltab*LambdaM;
% (30) sovereign bond price                                            (B.28)
Qb = Hb/Rf;
% (31) realised sovereign bond return (x=0)                            (B.29)
Rb = 1/Qb(-1);

% ---- PUBLIC AUTHORITY ---------------------------------------------------
% (32) Taylor rule                                                     (B.35)
r = rhor*r(-1) + (1-rhor)*( phipi*(pi-piss) + phiy*(y-STEADY_STATE(y)) + STEADY_STATE(r) ) + sigr*er;
% ---- MARKET CLEARING ----------------------------------------------------
% (33) aggregate resource constraint                                   (A.5.1)
y = c + i;

% ---- REPORTING (definitional) -------------------------------------------
% (34) sovereign spread                                                (B.31)
spread = 1/Qb - Rf;
% (35) bank leverage
lev = (QL + QbB)/Nb;

end;


%==========================================================================
%  6.  STEADY-STATE INITIAL VALUES  (exact closed form from section 4)
%==========================================================================
initval;
theta = thetass;  betatheta = betathetass;  y = yss;  c = css;  i = iss;
L = lss;  k = kss;  u = uss;  ktilde = ktildess;  w = wss;  Pkr = pkrss;
Q = Qss;  pi = piss;  pireset = piresetss;  X1 = X1ss;  X2 = X2ss;
Omega = omegass;  mc = mcss;  v = vss;  r = rss;  Qtob = Qtobss;
Rf = Rfss;  Rd = Rdss;  RL = RLss;  RK = RKss;  Ne = Ness;  QL = QLss;
QbB = QbBss;  Nb = Nbss;  D = Dss;  Qb = Qbss;  Hb = Hbss;  Rb = Rbss;
spread = spreadss;  lev = levss;
end;

% Confirm the steady state and determinacy BEFORE solving:
resid;            % should print residuals ~ 0 for every equation
steady;           % Newton solver: converges immediately (initval is exact)
check;            % eigenvalues / Blanchard-Kahn order condition
% (For extra rank/singularity diagnostics, run  model_diagnostics(M_,options_,oo_)
%  from the MATLAB prompt AFTER this file has been processed by Dynare.)


%==========================================================================
%  7.  SHOCKS
%==========================================================================
shocks;
var etheta; stderr sigtheta;   % disaster-risk shock (main experiment)
var er;     stderr 0;          % MP shock off by default (set >0 to activate)
end;


%==========================================================================
%  8.  SOLUTION
%      order=2  -> the third-order perturbation the thesis targets.
%      pruning  -> keeps 3rd-order simulations stable (Andreasen et al.).
%      irf=0    -> IRFs are produced from the ERGODIC MEAN in the driver
%                  run_thesis_model.m (correct notion at 3rd order), exactly
%                  as in the IS2017 replication code (simult_).
%      NOTE: to get a quick first look you can switch to order=1 and irf=20.
%==========================================================================
@#if ORDER > 1
stoch_simul(order=@{ORDER}, pruning, irf=0, periods=0, replic=1, nograph);
@#else
stoch_simul(order=1, irf=20, periods=0, replic=1, nograph);
@#endif
