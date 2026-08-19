% Sovereign Disaster Risk, Banking Frictions and Macro Tail Outcomes
% in a New Keynesian DSGE for the Euro Area
% by Maximilian Stein (Universite Paris-Dauphine, PSL)
% Supervisor: Fabien Tripier
%
% Extends Isore & Szczerbowicz (2017, JEDC) with a Bernanke-Gertler-
% Gilchrist (1999) entrepreneur block, a Gertler-Karadi (2011) bank block
% with endogenous leverage, and a home-bias sovereign-bond channel priced
% via the Gabaix (2012) linearity-generating closed form. Implements the
% stationarized system of thesis Appendix B.
%
% v4 vs v3: replaces the approximate Fisher equation (eq 6) with the exact
% form A.1.7/B.30 via a new auxiliary FI (same construction as CE). Also
% carries the eq(23)/iotae entrepreneur net-worth fix (trend-growth factor
% was double-counted on the capital terms). v3 (approximate Fisher, same
% eq-23 fix) kept on disk unchanged, for comparison. Full derivation and
% verification history: CHANGELOG_dynare_debug.md, ToDoAugust19th.md.
%
% Known open items, not resolved in this version:
%  - No perturbation-based realisation of x_t=1: theta_t moves, but no
%    default event fires along the simulated path (stated modelling
%    limitation, not a bug).
%  - Government budget constraint / T_t (thesis B.29) not implemented;
%    a pure residual with no feedback, so the model solves without it.
%  - Eqs (18)/(19)/(26b)/(26c) factor a covariance term the same way the
%    old eq(6) did (Theta/Q are t-measurable and factor outside Dynare's
%    implicit expectation). Not bounded for (26b)/(26c) yet -- see the
%    2026-08-19 briefing. Recommendation is to leave as is; not a fix
%    pending, a number pending.
%  - psi transformation (below, in the parameter block): supervisor-gated,
%    do not change without sign-off.
%
% Run:  dynare thesis_model_v4                 (baseline, phi>0)
%       dynare thesis_model_v4 -DPHIVAL=1e-4    (counterfactual)
%   or run_thesis_model.m, which does both plus IRFs.

@#ifndef PHIVAL
    @#define PHIVAL = 0.03
@#endif
@#ifndef ORDER
    @#define ORDER = 3
@#endif

%==========================================================================
%  ENDOGENOUS VARIABLES  (all stationary / detrended, thesis Appendix B)
%==========================================================================
var
% --- core (Isore-Szczerbowicz 2017) ---------------------------------------
theta       % disaster probability                                (eq 1)
betatheta   % pseudo (endogenous) discount factor beta(theta)      (A.1.5/B.2)
y           % detrended output   Y/z                               (B.14)
c           % detrended consumption C/z                            (B.4)
i           % detrended investment I/z                             (B.1)
L           % labour (stationary)                                  (A.1.2)
k           % detrended end-of-period capital K_{t+1}/z            (B.1)
u           % capital utilisation                                  (B.17)
ktilde      % detrended effective capital u*K/z                    (B.8)
w           % detrended real wage                                  (B.6)
Pkr         % real rental rate of capital (stationary)             (B.7)
Q           % stochastic discount factor E_t[Lambda_{t,t+1}]       (B.3)
pi          % gross inflation                                      (B.12)
pireset     % gross reset inflation                                (B.9)
X1          % Calvo auxiliary 1                                    (B.10)
X2          % Calvo auxiliary 2                                    (B.11)
Omega       % price dispersion                                     (B.13)
mc          % real marginal cost                                   (A.2)
v           % detrended EZW value function                         (B.2)
r           % gross nominal policy rate                            (B.31)
Qtob        % Tobin's Q (price of installed capital)                (B.5)
% --- rates -----------------------------------------------------------------
Rf          % gross real risk-free rate  = 1/Q                      (A.1.6)
Rd          % gross real deposit rate    = Rf                       (A.5)
RS          % gross real loan rate                                  (B.17)
RK          % gross real realised return on capital (x=0)           (B.16)
% --- entrepreneurs (Bernanke-Gertler-Gilchrist 1999) ------------------------
Ne          % detrended entrepreneur net worth  N^e/z               (B.18)
QS          % value of loans  Q_t s_t  (=Q_t K_{t+1}-N^e_t)          (B.19)
% --- banks (Gertler-Karadi 2011 + home bias) --------------------------------
QbB         % value of sovereign bonds on bank books  Q^b_t b^b_t    (B.22)
Nb          % detrended bank net worth  N^b/z                       (B.23)
D           % detrended deposits (residual)                         (B.20)
% --- sovereign / disaster transmission (Gabaix 2012) ------------------------
Qb          % sovereign bond price                                   (B.25)
Hb          % bond resilience  H^b                                   (B.24)
Rb          % gross real realised bond return (x=0)                  (B.26)
spread      % sovereign spread  1/Q^b - R^f                          (B.29)
lev         % endogenous bank leverage  (QS+QbB)/Nb                  (B.21a-d)
etaB        % marginal value of bank assets funded by deposits       (B.21a)
nuB         % marginal value of bank net worth                       (B.21b)
OmB         % banker's continuation value per unit of net worth      (B.21c)
% --- SDF and bond normalisation auxiliaries ---------------------------------
CE          % Epstein-Zin certainty equivalent
Dcal        % Gourio moment, Bellman/Calvo discounting
Ecal        % Gourio moment, risk-free rate/bond pricing
Theta       % E_t[M(t,t+1)*Gamma(t+1)]                                (B.3c)
FI          % E_t[M(t,t+1)/pi(t+1)], exact Fisher auxiliary           (A.1.7/B.30)
;

%==========================================================================
%  EXOGENOUS SHOCKS
%==========================================================================
varexo
etheta      % disaster-probability shock  (the main experiment)
er          % monetary-policy shock
;

%==========================================================================
%  PARAMETERS
%==========================================================================
parameters
% preferences / technology (Isore-Szczerbowicz 2017)
muz beta0 delta0 zeta upsilon gamma psi psitilde chi alpha varpi tau
rhor rhotheta phipi phiy sigr sigtheta eta Deltak
% steady-state references used inside the model block
piss thetass
% banking / entrepreneur / sovereign block
Deltab chie premE levE sigma_e sprL phi lambdadiv sigma_b
f0 iotae iotab LambdaM uss
;

% ---- Isore-Szczerbowicz (2017) calibration (quarterly) ------------------
% Disaster Risk
thetass  = 0.009;     % steady-state disaster probability
Deltak   = 0.22;      % capital & productivity destroyed in a disaster
rhotheta = 0.9;       % disaster-probability persistence
sigtheta = 0.6;       % std of disaster-risk shock

% Utility Function
beta0    = 0.9985;    % subjective discount factor
psitilde = 2;         % inverse EIS
gamma    = 3.8;       % relative risk aversion coefficient
varpi    = 2.33;      % leisure preference (Gourio 2012)

% Investment
delta0   = 0.025;     % depreciation
tau      = 2;         % capital adjustment cost
uss      = 1;         % utilisation normalisation (target u=1)

% Production
alpha    = 0.36;      % capital share
zeta     = 0.6;       % Calvo stickiness
upsilon  = 3.85;      % elasticity of substitution across varieties (nu)
muz      = 0.003;     % trend TFP growth (mu)

% Public Authority
piss     = 1.00475;   % gross inflation target
phipi    = 1.5;       % Taylor: inflation response
phiy     = 0.5;       % Taylor: output response
rhor     = 0.93;      % interest-rate smoothing
sigr     = 1;         % Taylor-rule scaling on er; er's stderr (not this) is the on/off switch

% ---- banking/entrepreneur/sovereign calibration --------------------------
Deltab   = 0.37;      % sovereign haircut in a disaster (Cruces-Trebesch ~0.37)
chie     = 0.0276;    % elasticity of external finance premium wrt leverage (Gelain 2010 posterior)
sigma_e  = 0.9769;    % entrepreneur survival rate (Gelain 2010 posterior)
sigma_b  = 0.95;      % banker survival rate
levE     = 2.0;       % target entrepreneur leverage  Q k / N^e (BGG ~ 2)
premE    = 1.0030;    % target entrepreneur premium  E[R^K]/R^S (~120bp annual)
sprL     = 1.0020;    % bank loan spread R^S/R^d (bank's own friction, distinct from the entrepreneur premium)
phi      = @{PHIVAL}; % home-bias: sovereign-bond share of bank assets (0=cf)

% ---- parameter transformations (Gourio 2012/2014) ------------------------
psi = 1 - (1-psitilde)/(1+varpi); % inverse-EIS reparameterisation; yields psi=1.3003 given psitilde=2, not 2 -- unresolved, supervisor-gated
chi = 1 - (1-gamma)/(1-psi);

%==========================================================================
%  CLOSED-FORM STEADY STATE  (computed here; used in initval below)
%==========================================================================
steady_state_model;

LambdaM = (1-Deltak)^(-gamma);                                   % disaster SDF loading

Dcalss  = 1 - thetass + thetass*(1-Deltak)^(1-gamma);
Ecalss  = 1 - thetass + thetass*(1-Deltak)^(-gamma);
Qfss    = beta0*exp(-psi*muz)*Dcalss^((gamma-psi)/(1-gamma));
Qss     = Qfss*Ecalss;                    % = E[Q]
Thetass = Qss*exp(muz)*Dcalss/Ecalss;     % = betathetass*exp((1-psi)*muz)
Rfss    = 1/Qss;
Rdss    = Rfss;
betathetass = beta0*((1 - thetass + thetass*exp((1-gamma)*log(1-Deltak)))^(1/(1-chi)));

rss   = piss/Qss;                 % nominal rate (exact Fisher relation, steady state)
FIss  = Qss/piss;                 % = 1/rss identically
RSss  = sprL*Rdss;                                                % bank loan rate
ERKss = premE*RSss;                                               % E[R^K] = premE*R^S
RKtildess = ERKss/(1-thetass*Deltak);
pkrss = RKtildess - (1-delta0);                                   % rental rate (u=1,Qtob=1)
eta   = pkrss/delta0;                                             % utilisation curvature (=> u=1)

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

knss  = exp(muz)*kss;              % k^n_{t+1} convention, matches dynamic eq (24)
Ness  = knss/levE;
f0    = premE*(1/levE)^(chie);
iotae = Ness - sigma_e*(RKss*kss - RSss*(kss - exp(-muz)*Ness)  );
QSss  = knss - Ness;                    % bank loans = capital value net of entrepreneur equity

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

% lambdadiv (divertable-asset fraction) calibrated so the incentive
% constraint binds exactly at levss -- not a free input.
spreadAss = (1-phi)*RSss + phi*Rbss - Rdss;      % portfolio excess return over Rd
OmBss = (1-sigma_b) / (1 - sigma_b*Qss*(levss*spreadAss + Rdss));
etaBss = Qss*OmBss*spreadAss;
nuBss  = Qss*OmBss*Rdss;
lambdadiv = etaBss + nuBss/levss;

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
FI    = FIss;

end;

%==========================================================================
%  MODEL EQUATIONS
%      Timing:  k, Ne, Nb, QS, QbB, Qb, r, theta, Omega, Qtob are states
%      (their (-1) lags appear);  c,L,v,Pkr,u,Qtob,X1,X2,pi,RK,Rb,OmB
%      appear as (+1) leads (rational-expectations / forward looking).
%==========================================================================
model;

% (1) exogenous disaster-probability process                          (eq 1)
log(theta) = (1-rhotheta)*log(thetass) + rhotheta*log(theta(-1)) + etheta;

% (4a) certainty equivalent: kept as its own variable so Dynare's
% expectation operator applies to v(+1)^(1-chi), not the whole power;
% rescaled by STEADY_STATE(v) for numerical conditioning at order 3.
CE = (v(+1)/STEADY_STATE(v))^(1-chi);
% (4b)-(4c) disaster moments (thesis Appendix B conventions)
Dcal = 1 - theta + theta*(1-Deltak)^(1-gamma);
Ecal = 1 - theta + theta*(1-Deltak)^(-gamma);
% (4d) growth-adjusted discount factor  Theta_t = E_t[Q Gamma]         (B.3c)
Theta = Q*exp(muz)*Dcal/Ecal;

% ---- HOUSEHOLDS -----------------------------------------------------------
% (2) EZW value function, detrended                                    (B.2)
v = (c*(1-L)^varpi)^(1-psi) + betatheta*exp((1-psi)*muz)*STEADY_STATE(v)*CE^(1/(1-chi));
% (3) pseudo-discount factor beta(theta)                          (A.1.5/B.2)
betatheta = beta0*((1 - theta + theta*exp((1-gamma)*log(1-Deltak)))^(1/(1-chi)));
% (4) Epstein-Zin stochastic discount factor / consumption Euler       (B.3)
Q = beta0*(c(+1)/c)^(-psi)*((1-L(+1))/(1-L))^(varpi*(1-psi))
    * exp(-gamma*muz)
    * (v(+1)/STEADY_STATE(v))^(-chi)
    * (CE*exp((1-gamma)*muz)*Dcal)^(chi/(1-chi))
    * Ecal;
% (5) consumption-leisure FOC                                          (B.4)
(1-L)/c = varpi/w;
% (6a) Fisher equation, exact form: FI = E_t[M(t,t+1)/pi(t+1)], same
% auxiliary pattern as CE (t-measurable Ecal/CE/Dcal factor outside,
% t+1-dated c/L/v/pi stay inside the implicit expectation).   (A.1.7/B.30)
FI = Ecal * beta0*(c(+1)/c)^(-psi)*((1-L(+1))/(1-L))^(varpi*(1-psi))
     * exp(-gamma*muz) * (v(+1)/STEADY_STATE(v))^(-chi)
     * (CE*exp((1-gamma)*muz)*Dcal)^(chi/(1-chi)) / pi(+1);
% (6b) nominal policy rate implied by the exact Fisher relation
r = 1/FI;
% (7) real risk-free rate                                             (A.1.6)
Rf = 1/Q;
% (8) deposit-market clearing  R^d = R^f                               (A.5)
Rd = Rf;

% ---- CAPITAL-GOODS PRODUCER & CAPITAL ACCUMULATION -------------------------
% (9) Tobin's Q                                                        (B.5)
Qtob = 1/(1 - tau*(i/k(-1) - STEADY_STATE(i)/STEADY_STATE(k)));
% (10) detrended capital law of motion (Gourio factor cancels)         (B.1)
k = ((1-delta0*u^eta)*k(-1) + (i/k(-1) - tau/2*((i/k(-1) - STEADY_STATE(i)/STEADY_STATE(k))^2))*k(-1))/exp(muz);

% ---- FIRMS & PRICE SETTING -------------------------------------------------
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
% (19) Calvo auxiliary X2                                              (B.11)
X2 = y + zeta*Theta*X2(+1)*pi(+1)^(upsilon-1);

% ---- ENTREPRENEURS (Bernanke-Gertler-Gilchrist 1999) -----------------------
% (20) utilisation FOC                                                 (B.15)
Pkr = Qtob*delta0*eta*u^(eta-1);
% (21) realised (disaster-free, x=0) return on capital                 (B.16)
RK = (Pkr*u + Qtob*(1-delta0*u^eta))/Qtob(-1);
% (22) external finance premium: entrepreneur leverage (Ne/Qk) sets its
% own premium over the bank loan rate RS, which is itself set by the
% bank's endogenous leverage margin below -- two distinct frictions.
(1-theta*Deltak)*RK(+1) = RS * f0 * (Ne/(Qtob*exp(muz)*k))^(-chie);
% (23) entrepreneur net-worth accumulation. Gamma^-1 scales Ne(-1) only:
% k(-1) is k_t=K_t/z_t, already carrying one Gamma^-1 relative to
% k^n_t=exp(muz)*k(-1) (same substitution as eq 24), so the outer and
% inner exp(muz) cancel on the capital terms.                          (B.18)
Ne = sigma_e*exp(-muz)*( RK*Qtob(-1)*exp(muz)*k(-1)
                        - RS(-1)*(Qtob(-1)*exp(muz)*k(-1) - Ne(-1)) ) + iotae;
% (24) entrepreneur balance sheet  (defines loan value QS)             (B.19)
QS = Qtob*exp(muz)*k - Ne;

% ---- BANKS (Gertler-Karadi 2011 + home bias) -------------------------------
% (25) home-bias portfolio identity                                    (B.22)
QbB = phi/(1-phi)*QS;
% (26) endogenous leverage constraint, binding                     (B.21)
QS + QbB = lev*Nb;
% (26a) banker's continuation value per unit of net worth carried fwd
OmB = (1-sigma_b) + sigma_b*( etaB*lev + nuB );
% (26b) marginal value of a unit of bank assets funded by deposits
etaB = Q*OmB(+1)*( (1-phi)*RS + phi*Rb(+1) - Rd );
% (26c) marginal value of a unit of bank net worth
nuB = Q*OmB(+1)*Rd;
% (26d) incentive (divertability) constraint: leverage = nuB/(lambdadiv-etaB)
lev = nuB/(lambdadiv - etaB);
% (27) bank net worth accumulation                                     (B.23)
Nb = sigma_b*exp(-muz)*( (RS(-1)-Rd(-1))*QS(-1) + (Rb-Rd(-1))*QbB(-1) + Rd(-1)*Nb(-1) ) + iotab;
% (28) bank balance sheet (defines deposits D)                         (B.20)
QS + QbB = Nb + D;

% ---- SOVEREIGN / DISASTER TRANSMISSION (Gabaix 2012 closed form) ----------
% (29) resilience                                                      (B.24)
Hb = 1 - theta*Deltab*LambdaM/Ecal;
% (30) sovereign bond price                                            (B.25)
Qb = Hb/Rf;
% (31) realised sovereign bond return (x=0)                            (B.26)
Rb = 1/Qb(-1);

% ---- PUBLIC AUTHORITY -------------------------------------------------------
% (32) Taylor rule                                                     (B.31)
r = rhor*r(-1) + (1-rhor)*( phipi*(pi-piss) + phiy*(y-STEADY_STATE(y)) + STEADY_STATE(r) ) + sigr*er;
% ---- MARKET CLEARING ---------------------------------------------------------
% (33) aggregate resource constraint                                   (B.32)
y = c + i;

% ---- REPORTING (definitional) ------------------------------------------------
% (34) sovereign spread                                                (B.28)
spread = 1/Qb - Rf;

end;

resid;            % should print residuals ~ 0 for every equation
steady;           % Newton solver: converges immediately (initval is exact)
check;            % eigenvalues / Blanchard-Kahn order condition

%==========================================================================
%  SHOCKS
%==========================================================================
shocks;
var etheta; stderr sigtheta;   % disaster-risk shock (main experiment)
var er;     stderr 0;          % MP shock off by default (stderr is the on/off switch)
end;

%==========================================================================
%  SOLUTION
%      order=3 -> third-order perturbation the thesis targets, with
%      pruning (Andreasen et al.). irf=0: IRFs are built from the ergodic
%      mean in run_thesis_model.m (correct notion at 3rd order), as in
%      the Isore-Szczerbowicz replication code (simult_).
%==========================================================================
@#if ORDER > 1
stoch_simul(order=@{ORDER}, pruning, irf=20, periods=0, replic=1, nograph);
@#else
stoch_simul(order=1, irf=20, periods=0, replic=1, nograph);
@#endif
