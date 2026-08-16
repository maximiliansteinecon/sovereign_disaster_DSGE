# Fisher Equation & Taylor Rule — Final Draft Replacement Text

Drafted 2026-08-16, **Taylor rule corrected 2026-08-17.**

## Correction notice (read this first)

The first version of this draft (2026-08-16) recommended changing the
Taylor rule's output term to a log gap, on a generic dimensional-analysis
argument. **That recommendation was wrong and is withdrawn.** The user
pointed out that IS2017 — the paper this thesis explicitly follows for
its public-authority block — uses exactly the level-gap form already
present in the main text, Appendix B (B.31), and the `.mod`:

> IS2017 eq. (11): $r_t=\rho_r r_{t-1}+(1-\rho_r)\bigl[\varphi_\pi(\pi_t-\bar\pi)+\varphi_Y(Y_t/z_t-\bar Y/\bar z)+\bar r\bigr]$
>
> IS2017 eq. (A.21), stationarized: $r_t=\rho_r r_{t-1}+(1-\rho_r)[\varphi_\pi(\pi_t-\bar\pi)+\varphi_Y(y_t-\bar y)+\bar r]$

Appendix A's log-gap form was the thing that had drifted from the
template — not the main text, not Appendix B, not the `.mod`. Opus's
original "A7 dimensional fix" didn't check IS2017 directly, and the
2026-08-16 version of this draft compounded that by building a full
justification for the wrong direction. **The Taylor rule section below
is now the correction of that correction: back to the level-gap form,
justified by direct citation to IS2017 (11)/(A.21) rather than an
abstract dimensional argument.** The Fisher equation section is
unaffected — see the note at the end of that section for why.

Two smaller fixes remain bundled in, both orthogonal to the level/log
question and still valid:

1. **Symbol collision.** The currently-implemented main text uses
   `\lambda_\pi, \lambda_\Y` for the Taylor-rule coefficients. `\lambda_t`
   is already the endogenous bank leverage multiplier throughout the
   banking block (`.mod`'s `lev`). Reusing `\lambda` here creates a new
   collision worse than the `\phi` collision it was presumably chosen to
   avoid. Both replacements below use `\varphi_\pi, \varphi_Y` instead.
2. **Factual correction.** The current Appendix A.4.3 closing sentence
   says the model is "driven by the two structural innovations
   `\varepsilon_{z,t}` and `\varepsilon_{\theta,t}`." The `.mod`'s
   `varexo` block is `etheta er;` — there is no `\varepsilon_z` shock
   declared at all (trend growth is purely deterministic in this
   calibration); the second declared-but-inactive shock is monetary
   (`er`, `stderr 0`), not TFP. Corrected below.

Both blocks are drop-in replacements — copy the LaTeX between the rules
directly over the corresponding paragraphs. Equation tags are unchanged
(2.5.2/2.5.3 main text, A.4.2/A.4.3 appendix) so no other cross-reference
in the document needs to change.

**Downstream, for the B/C deepening pass (not done here, per your
instruction — flagging for you or Opus):**
- **B.30 needs no change.** It already states the exact form
  `E_t[M_{t,t+1}(1+r_t)/(1+\pi_{t+1})]=1` — the new A.4.2 below detrends
  into exactly this, unchanged, since every term in it (`r`, `\pi`,
  `\mathcal{M}_{t,t+1}`) is already trend-free. Appendix B was already
  right; only Appendix A and the main text were behind it.
- **B.31 also needs no change.** With the Taylor rule reverted to the
  level-gap form, B.31's existing `\lambda_\Y(y_t-\bar y)` is already
  correct in substance — only the coefficient symbol needs renaming to
  `\varphi_\pi,\varphi_Y` for consistency with A.4.3 and the main text,
  a cosmetic rename, not a rederivation.
- The calibration table's citation for `phiy = 0.5` needs no
  re-examination on dimensional grounds — the level-gap form matches
  IS2017's own specification directly, so if `phiy` was already sourced
  from IS2017's calibration it is already an apples-to-apples number.

---

## 1. Main text replacement (§2.5 Public Authority)

Replaces the paragraph beginning "We are then left with determining the
Fisher Equation and Taylor Rule..." through the end of the Taylor-rule
paragraph (currently tagged (2.5.2)/(2.5.3)). The Government Budget
Constraint paragraph above it, and the Dräger (2016) paragraph below it,
are untouched — paste this in between them.

```latex
We are then left with determining the Fisher equation and the Taylor
rule linking the nominal and real sides of the model.

Let $r_t$ denote the net nominal policy rate set by the Taylor rule
below. Because $r_t$ is a policy instrument rather than the return on
an asset any household or bank actually holds, its relationship to the
real risk-free rate $R^f_t$ of \eqref{eq:riskfree_rate} is fixed by
requiring that a hypothetical, zero-net-supply nominal bond paying
$(1+r_t)$ be correctly priced by the household stochastic discount
factor $\mathcal{M}_{t,t+1}$ of \eqref{eq:SDF} — the same no-arbitrage
logic already used to price the sovereign bond in
Section~\ref{sec:Disaster_Transition}. This gives the exact Fisher
relation

\begin{equation}
  \mathbb{E}_t\!\left[\mathcal{M}_{t,t+1}\,\frac{1+r_t}{1+\pi_{t+1}}\right] = 1
  \tag{2.5.2}
  \label{eq:A4_fisher}
\end{equation}

where $\pi_{t+1}\equiv p_{t+1}/p_t-1$. This does not collapse to the
commonly-quoted textbook form $R^f_t=(1+r_t)/\mathbb{E}_t[1+\pi_{t+1}]$
except under a zero-covariance condition between $\mathcal{M}_{t,t+1}$
and $1+\pi_{t+1}$ that this model does not impose: the disaster
probability $\theta_t$ moves both the discount factor and expected
inflation simultaneously, so the two are generically correlated.
Equation~\eqref{eq:A4_fisher} is therefore carried in its exact form
through stationarization (Appendix~\ref{sec:Stationarization}); the full
derivation and the precise collapse condition are given in
Appendix~\ref{par:A412}.

Further, following \textcite{Isore2017}'s own public-authority block,
the public authority sets the nominal interest rate $r_t$ according to a
Taylor-type rule that targets the deviations of inflation from its
steady-state value $\bar{\pi}$ and of detrended output from its
steady-state level $\bar{Y}$:

\begin{equation}
  r_t = \rho_r\, r_{t-1}
        + (1 - \rho_r)\!\left[
            \varphi_\pi(\pi_t - \bar{\pi})
            + \varphi_Y\!\left(\frac{Y_t}{z_t} - \bar{Y}\right)
            + \bar{r}
          \right]
  \tag{2.5.3}
  \label{eq:A4_taylor}
\end{equation}

where $\rho_r \in (0,1)$ is the interest rate smoothing parameter,
$\varphi_\pi > 1$ the inflation response coefficient (Taylor principle),
$\varphi_Y > 0$ the output-gap response coefficient, and $\bar{r}$ the
steady-state nominal rate. The disaster probability $\theta_t$ does not
enter the Taylor rule directly; it affects $r_t$ only through its
general-equilibrium effects on $\pi_t$ and $Y_t$.
```

---

## 2. Appendix A replacement (A.4.2 Fisher Equation + A.4.3 Taylor Rule)

Replaces everything from "We are then left with determining the Fisher
Equation and Taylor Rule." through the end of the current A.4.3
paragraph (i.e. the `\paragraph{Fisher Equation}` and
`\paragraph{Taylor Rule}` blocks together). The Government Budget
Constraint paragraph above (`\paragraph{Government Budget Constraint}`)
is untouched.

```latex
We are then left with determining the Fisher equation and the Taylor
rule.

\paragraph{Fisher Equation}
\label{par:A412}

The nominal policy rate $r_t$ set by the Taylor rule below is not the
price of any asset an optimising household or bank actually holds in
this model — households save only through deposits
(Appendix~\ref{appsec:households}), and banks hold only loans and
sovereign bonds (\S\ref{sec:A3.2}). Its relationship to the model's real
objects is instead pinned down by a standard no-arbitrage construction,
exactly parallel to how the sovereign bond price $Q^b_t$ is pinned down
in \S\ref{sec:Disaster_Transition} by requiring the household SDF to
correctly price an asset the household does not literally hold.

Consider a hypothetical one-period nominal bond in zero net supply,
priced at $1$ in period $t$ and paying $(1+r_t)$ with certainty, in
nominal terms, in period $t+1$. Its real payoff is
$(1+r_t)/(1+\pi_{t+1})$, random because $\pi_{t+1}\equiv p_{t+1}/p_t-1$
is not known at $t$. For the market in this notional asset to clear at
zero net holdings while every household remains individually optimising
— i.e. for no household to have a strict incentive to buy or sell it —
its price must equal the value the household's own stochastic discount
factor $\mathcal{M}_{t,t+1}$ of \eqref{eq:SDF} assigns to its real
payoff:

\begin{equation}
  \mathbb{E}_t\!\left[\mathcal{M}_{t,t+1}\,\frac{1+r_t}{1+\pi_{t+1}}\right] = 1
  \tag{A.4.2}
  \label{eq:A4_fisher}
\end{equation}

Because $(1+r_t)$ is known at $t$, it factors out of the expectation:

\begin{equation*}
  1+r_t \;=\; \frac{1}{\mathbb{E}_t\!\left[\mathcal{M}_{t,t+1}/(1+\pi_{t+1})\right]}
\end{equation*}

\paragraph{When does this collapse to the textbook form?}
Write $X\equiv\mathcal{M}_{t,t+1}$ and $Y\equiv 1/(1+\pi_{t+1})$, and use
the covariance identity
$\mathbb{E}_t[XY]=\mathbb{E}_t[X]\,\mathbb{E}_t[Y]+\mathrm{Cov}_t(X,Y)$:

\begin{equation*}
  \mathbb{E}_t\!\left[\frac{\mathcal{M}_{t,t+1}}{1+\pi_{t+1}}\right]
  = \mathbb{E}_t[\mathcal{M}_{t,t+1}]\cdot\mathbb{E}_t\!\left[\frac{1}{1+\pi_{t+1}}\right]
  + \mathrm{Cov}_t\!\left(\mathcal{M}_{t,t+1},\,\frac{1}{1+\pi_{t+1}}\right)
\end{equation*}

Using $R^f_t\equiv 1/\mathbb{E}_t[\mathcal{M}_{t,t+1}]$ (A.1.6),
equation~\eqref{eq:A4_fisher} reduces to the commonly-quoted approximate
form $R^f_t=(1+r_t)/\mathbb{E}_t[1+\pi_{t+1}]$ if and only if two
conditions both hold: (i) $\mathrm{Cov}_t\bigl(\mathcal{M}_{t,t+1},\,
1/(1+\pi_{t+1})\bigr)=0$, and (ii)
$\mathbb{E}_t[1/(1+\pi_{t+1})]=1/\mathbb{E}_t[1+\pi_{t+1}]$ — the latter
itself an equality only up to a Jensen's-inequality gap that vanishes
exclusively when $\pi_{t+1}$ is deterministic.

Neither condition holds in this model. Condition (i) fails because
$\theta_t$ is the model's sole aggregate risk factor and moves both
objects at once: a rise in perceived disaster risk simultaneously raises
$\mathcal{M}_{t,t+1}$'s exposure to the bad state through the Epstein-Zin
risk adjustment of \eqref{app:SDF}, and shifts expected inflation through
the New Keynesian block's own response to $\theta_t$, so
$\mathcal{M}_{t,t+1}$ and $\pi_{t+1}$ are generically correlated
conditional on $\theta_t$. Condition (ii) fails whenever $\pi_{t+1}$ has
any conditional variance at all, which it does at every date given the
shock $\varepsilon_{\theta,t+1}$. Both gaps are second-order-and-above
objects in the innovations, so they are invisible to a first-order
(linearised) solution but not to the third-order solution this thesis
targets — which is precisely why equation~\eqref{eq:A4_fisher} is carried
in its exact form into the stationarised system
(\S\ref{sec:Stationarization}, B.30) rather than replaced by a
log-linear substitute: doing so would reintroduce, at exactly this one
equation, the first-order approximation the rest of the solution method
is built to avoid.

The policy rate $r_t$ is not the return on the defaultable sovereign
bond. The latter is $R^b_{t+1}$ of \eqref{eq:A3_Rb}, which carries the
haircut $\Delta^b$; the wedge between its promised yield $1/Q^b_t$ and
$R^f_t$ is the sovereign spread of \eqref{eq:A3_spread}.

% \noindent\textit{Stationarization flag:} Both sides are gross rates
% --- scale-invariant, and $\mathcal{M}_{t,t+1}$ is already stationary
% by~\eqref{eq:B_SDF}. Equation~\eqref{eq:A4_fisher} passes into B.30
% unchanged. $\to$ Appendix~B.

\paragraph{Taylor Rule}
\label{par:A413}

Following \textcite{Isore2017}'s public-authority block (their eq.~11,
stationarized as their eq.~A.21), the public authority sets the nominal
interest rate $r_t$ according to a Taylor-type rule that targets
deviations of inflation from its steady-state value $\bar{\pi}$ and of
detrended output from its steady-state level $\bar{Y}$:

\begin{equation}
  r_t = \rho_r\, r_{t-1}
        + (1 - \rho_r)\!\left[
            \bar{r}
            + \varphi_\pi\bigl(\pi_t - \bar{\pi}\bigr)
            + \varphi_Y\!\left(\frac{Y_t}{z_t} - \bar{Y}\right)
          \right]
  \tag{A.4.3}
  \label{eq:A4_taylor}
\end{equation}

where $\rho_r\in(0,1)$ is the smoothing parameter, $\varphi_\pi>1$ the
inflation response (Taylor principle), $\varphi_Y>0$ the output
response, and $\bar r$ the steady-state nominal rate — renamed from
$\phi_\pi,\phi_Y$ to avoid collision with the home-bias parameter
$\phi$, and from the main text's $\lambda_\pi,\lambda_Y$ to avoid a
second, worse collision with the bank leverage multiplier $\lambda_t$
of \S\ref{sec:A3.2}. The output term is a level, not a log, deviation of
detrended output from its steady state, exactly as in
\textcite{Isore2017}'s own specification; $\varphi_Y$ is calibrated
against that same object, so the two are directly comparable without
rescaling.

The model's only live stochastic driver is the disaster-risk innovation
$\varepsilon_{\theta,t}$: a monetary-policy shock $\varepsilon_{r,t}$ is
declared in the exogenous block but held at zero standard deviation in
the baseline calibration, and no productivity innovation is included at
all. The disaster probability $\theta_t$ does not enter the Taylor rule
directly; it affects $r_t$ only through its general-equilibrium effects
on $\pi_t$ and $Y_t/z_t$.
```
