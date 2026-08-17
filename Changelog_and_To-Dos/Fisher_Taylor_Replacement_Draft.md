# Fisher Equation & Taylor Rule — Final Draft Replacement Text

Drafted 2026-08-16. Taylor rule corrected 2026-08-17 (level gap, not
log gap). **Fisher equation relocated 2026-08-17** (Households, not
Public Authority). This version (v3) supersedes both earlier versions
in full — the LaTeX blocks below are the current, complete replacement;
nothing from v1/v2 should be pasted separately.

## What changed and why (read this first)

**v1 → v2 (Taylor rule, 2026-08-17):** the original log-gap
recommendation was wrong — IS2017's own eq. (11)/(A.21) use the level
gap already present in the main text, Appendix B (B.31), and the
`.mod`. Reverted. Full reasoning in `CHANGELOG_dynare_debug.md`,
2026-08-17 entry.

**v2 → v3 (Fisher equation placement, 2026-08-17):** the user asked
whether the Fisher equation is needed at all, noting IS2017's own
Public Authority section (their §2.4, pasted directly) contains *only*
the Taylor rule — no separate Fisher equation. Correct observation, but
the resolution is relocation, not deletion:

- $R^f_t$ and $R^d_t$ are already fully pinned by the deposit Euler
  (A.1.3) plus the definition (A.1.6) — clean, no covariance issue,
  nothing missing. That was never in question.
- $r_t$ (the nominal policy rate) is a *different* object. It appears
  in exactly two places in the `.mod`: the Taylor rule (which sets it)
  and the Fisher equation (which connects it to the real side via
  inflation). Drop the second and the system is short one equation for
  one variable — `r` becomes unpinned, and Dynare will not solve a
  42-variable, 41-equation system. Some version of this equation has to
  exist somewhere.
- IS2017 do have this equation — it is not absent, just not in their
  Public Authority section. Their household holds the nominal sovereign
  bond directly, so their household's own bond Euler,
  $\mathbb{E}_t[\mathcal{M}_{t,t+1}(1+r_t)/(1+\pi_{t+1})]=1$, plays
  exactly this role, stated once in their Households section (§2.2) and
  never restated in §2.4. This thesis's own text already quotes that
  exact IS2017 equation (in the Households section, at the point where
  it explains why the deposit Euler replaces it) but never actually
  delivers the replacement — that gap is what the relocated paragraph
  below fills.

**Net structural change:** the full derivation (no-arbitrage argument +
the collapse-condition analysis) moves into Households, immediately
after the risk-free-rate/deposit-market discussion — mirroring where
IS2017's own analogous equation lives. Public Authority shrinks to GBC +
Taylor rule only, matching IS2017's leaner structure, with one
cross-reference sentence back to Households. The mathematical content is
identical to the v2 draft; only its location and the surrounding framing
changed, plus the equation tags to fit Households numbering (A.1.7 in
the appendix; the main text picks a compact numbered slot after 2.2.9).

Two smaller fixes remain bundled in from v1/v2, both orthogonal to
placement and still valid:

1. **Symbol collision.** `\lambda_\pi,\lambda_\Y` collides with the bank
   leverage multiplier $\lambda_t$. Standardised on
   $\varphi_\pi,\varphi_Y$ throughout.
2. **Factual correction.** The model's only live shock is
   $\varepsilon_{\theta,t}$ — no $\varepsilon_z$ exists in the `.mod`'s
   `varexo` block at all; $\varepsilon_r$ is declared but held at
   `stderr 0`.

**Downstream, for the B/C deepening pass:**
- **B.30 needs no change** — already states the exact form, and it's
  already in the right conceptual place relative to the household block
  it discretizes from. No relocation needed in Appendix B; B is
  organised by *equation type* (SDF-discounted vs. trend-discounted),
  not by which agent's problem an equation originally came from, so
  B.30 sitting where it does was already fine.
- **B.31 needs no change** beyond the coefficient-symbol rename
  ($\varphi_\pi,\varphi_Y$), as established in v2.
- One extra cross-reference to add when B is next touched: B.30's
  surrounding text could note it corresponds to the newly-numbered
  A.1.7 rather than the old A.4.2 — cosmetic, not urgent.

---

## 1. Main text — Households (§2.2) insertion

Insert immediately after the paragraph ending "...does not add an
independent equation to the system." (the $R^d_t=R^f_t$ discussion,
directly below eq. 2.2.9) and before the "Because households save
exclusively..." paragraph, OR after that paragraph and before the
Firms section starts — either position is fine; keep it inside
Households, after the risk-free-rate material it depends on.

**Also note, unrelated to this task but visible while locating the
insertion point:** the sentence "As $R^d_t$ is known at $t$,
\eqref{eq:HHO_Deposit_Euler} can be solved directly as..." currently
appears twice, verbatim, back to back as separate paragraphs, in the
current main text. Looks like a copy-paste duplication, not intentional
repetition for emphasis — worth deleting the second copy whenever this
section is next edited, independent of the Fisher-equation change.

```latex
The nominal policy rate $r_t$ set by the public authority's Taylor rule
(Section~\ref{secmain:public_authority}) is not the return on any asset
this household holds. \textcite{Isore2017} pin down the analogous object
directly through their own household's bond Euler, stated above; because
this household holds no bond of any kind, the same no-arbitrage
restriction is imposed here as the pricing condition a hypothetical,
zero-net-supply nominal bond would have to satisfy under the household
stochastic discount factor $\mathcal{M}_{t,t+1}$ of \eqref{eq:SDF}:

\begin{equation}
  \mathbb{E}_t\!\left[\mathcal{M}_{t,t+1}\,\frac{1+r_t}{1+\pi_{t+1}}\right] = 1
  \tag{2.2.10}
  \label{eq:A4_fisher}
\end{equation}

where $\pi_{t+1}\equiv p_{t+1}/p_t-1$. This does not collapse to the
commonly-quoted textbook form $R^f_t=(1+r_t)/\mathbb{E}_t[1+\pi_{t+1}]$
except under a zero-covariance condition between $\mathcal{M}_{t,t+1}$
and $1+\pi_{t+1}$ that this model does not impose: the disaster
probability $\theta_t$ moves both the discount factor and expected
inflation simultaneously, so the two are generically correlated.
Equation~\eqref{eq:A4_fisher} is therefore carried in its exact form
through stationarization (Appendix~\ref{sec:Stationarization}, B.30);
the full derivation and the precise collapse condition are given in
Appendix~\ref{par:A17}.
```

---

## 2. Main text — Public Authority (§2.5) replacement

Replaces the paragraph beginning "We are then left with determining the
Fisher Equation and Taylor Rule..." through the end of the Taylor-rule
paragraph (currently tagged (2.5.2)/(2.5.3)). The Government Budget
Constraint paragraph above it, and the Dräger (2016) paragraph below it,
are untouched.

```latex
Following \textcite{Isore2017}'s own public-authority block, the public
authority sets the nominal interest rate $r_t$ according to a
Taylor-type rule that targets the deviations of inflation from its
steady-state value $\bar{\pi}$ and of detrended output from its
steady-state level $\bar{Y}$; its relationship to the real risk-free
rate $R^f_t$ of Section~\ref{sec:households} is established there,
following IS2017's own placement of the analogous condition in the
household's problem rather than the public authority's:

\begin{equation}
  r_t = \rho_r\, r_{t-1}
        + (1 - \rho_r)\!\left[
            \varphi_\pi(\pi_t - \bar{\pi})
            + \varphi_Y\!\left(\frac{Y_t}{z_t} - \bar{Y}\right)
            + \bar{r}
          \right]
  \tag{2.5.2}
  \label{eq:A4_taylor}
\end{equation}

where $\rho_r \in (0,1)$ is the interest rate smoothing parameter,
$\varphi_\pi > 1$ the inflation response coefficient (Taylor principle),
$\varphi_Y > 0$ the output-gap response coefficient, and $\bar{r}$ the
steady-state nominal rate. The disaster probability $\theta_t$ does not
enter the Taylor rule directly; it affects $r_t$ only through its
general-equilibrium effects on $\pi_t$ and $Y_t$.
```

Note the retag: this was (2.5.2)/(2.5.3) with two equations (Fisher +
Taylor); it is now just (2.5.2) with one. Check for any other
`\eqref{eq:A4_taylor}` or `\eqref{eq:A4_fisher}` reference in the main
text that assumed the old tag numbers — a document-wide search for both
labels before finalising is worth doing once, since the Fisher label now
resolves to a Households equation, not a Public Authority one.

---

## 3. Appendix A — Households (A.1) insertion

Insert immediately after A.1.6 (the risk-free-rate definition) and its
surrounding discussion — i.e. after "...done in equation~\eqref{eq:B_EQ}
below." and before "\paragraph{Capital-Goods Producer.}" This becomes
the new final paragraph of the Households subsection.

```latex
\paragraph{Fisher Equation}
\label{par:A17}

The nominal policy rate $r_t$ set by the Taylor rule of
Appendix~\ref{sec:public} is not the price of any asset an optimising
household or bank actually holds in this model — households save only
through deposits, and banks hold only loans and sovereign bonds
(\S\ref{sec:A3.2}). \textcite{Isore2017} pin down the analogous object
directly, through their own household's bond Euler
$\mathbb{E}_t[\mathcal{M}_{t,t+1}(1+r_t)/(1+\pi_{t+1})]=1$, since their
household holds that bond. This model's household holds no bond of any
kind, so the same relationship is imposed here as a no-arbitrage
restriction rather than a household optimality condition — exactly
parallel to how the sovereign bond price $Q^b_t$ is pinned down in
\S\ref{sec:Disaster_Transition} by requiring the household SDF to
correctly price an asset the household does not literally hold. This is
a distinct point from the household's non-holding of physical capital
noted above, which instead explains the absence of a capital-accumulation
multiplier $\Lambda^C_t$ among the first-order conditions of this
section: the relevant fact here is specifically the absence of any
bond-holding, since that is what would otherwise have generated a
nominal Euler equation directly.

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
  \tag{A.1.7}
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
```

---

## 4. Appendix A — Public Authority (A.4) replacement

Replaces everything from "We are then left with determining the Fisher
Equation and Taylor Rule." through the end of the current A.4.3
paragraph (i.e. the `\paragraph{Fisher Equation}` and
`\paragraph{Taylor Rule}` blocks together, which collapse into one
paragraph below). The Government Budget Constraint paragraph above
(`\paragraph{Government Budget Constraint}`) is untouched.

```latex
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
  \tag{A.4.2}
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
rescaling. $r_t$'s relationship to the real risk-free rate $R^f_t$ is
established in Appendix~\ref{par:A17}, following IS2017's own placement
of the analogous condition in the household's problem.

The model's only live stochastic driver is the disaster-risk innovation
$\varepsilon_{\theta,t}$: a monetary-policy shock $\varepsilon_{r,t}$ is
declared in the exogenous block but held at zero standard deviation in
the baseline calibration, and no productivity innovation is included at
all. The disaster probability $\theta_t$ does not enter the Taylor rule
directly; it affects $r_t$ only through its general-equilibrium effects
on $\pi_t$ and $Y_t/z_t$.
```

Note the retag: A.4.2 was Fisher, A.4.3 was Taylor; A.4 now has only one
numbered equation, so Taylor becomes A.4.2. If A.4 had any subsequent
equations after the old A.4.3 in the current numbering, they shift down
by one — check the Model Closing Conditions section immediately
following for any hardcoded "(A.4.3)"-style forward reference before
finalising.
