# Ledger — Appendix B (Stationarization)

Source: `Status_Quo_August17th.txt` lines **2626–3108**.
Cross-checked against Appendix A (1099–2625) and `thesis_model_v3.mod`.
Work **bottom-up by line number** so the numbers stay valid.

---

## 0. Verdict

The mathematics of B.1–B.14 is sound. I re-derived B.1, B.2, B.3, B.3a–c, B.6,
B.7, B.14 independently and they check out.

Two things are wrong with the appendix as a document:

**B.15–B.32 has no visible derivation at all.** Everything from the utilisation
FOC to goods-market clearing sits inside two bare `align` environments whose
only justification is LaTeX *comments* — `% A.3.1.6 Entrepreneur indifference
/ EFP — integrate out x_{t+1} via (B.star), kappa=1`. None of that compiles.
A reader of the PDF sees fourteen equations appear with no argument. That is
the whole banking block, i.e. the part of the thesis nobody else has written
and the part a supervisor will check hardest.

**Four blocks stop one step short of the result they announce.** B.2 never
collapses the certainty equivalent, so $\beta(\theta_t)$ is asserted rather than
produced. B.10/B.11 keep $x_{t+1}$ inside the expectation after the prose has
already said the product is $\Theta_t$. B.17 and B.18 state their key step in a
comment. B.24 never shows where $\tilde\Lambda^M$ comes from.

Both are fixable without touching the algebra. §3 below gives the insertions.

Where B disagrees with the current A, A wins in every case I found except one:
**B.21a–B.21d (the endogenous leverage block) is content A does not have**, and
it is correct. Keep it.

---

## 1. Errors — must change

### 1.1 B.3c: a $t{+}1$ innovation on the right of a $t$-expectation

Line 2773 reads $\Theta_t = Q^f_{t,t+1}e^{\mu+\varepsilon_{z,t+1}}\mathcal{D}(\theta_t)$.
$\varepsilon_{z,t+1}$ is not in the date-$t$ information set, so it cannot stand
outside an expectation on the right-hand side of a definition of $\Theta_t$.
Under the baseline $\varepsilon_{z,t}=0$ this is numerically harmless — and the
`.mod` writes `Theta = Q*exp(muz)*Dcal/Ecal`, i.e. $e^{\mu}$ with no innovation,
which is the correct object. The appendix should match. Fixed in §3.3.

### 1.2 B.3c: the inequality holds for $\gamma>0$, not $\gamma>1$

Line 2779 claims $\Theta_t<\mathbb{E}_t[\mathcal{M}]\mathbb{E}_t[\Gamma]$ "for
$\gamma>1$". Writing $a\equiv1-\Delta^k$ and using the three moments,

$$\mathcal{E}\mathcal{K}-\mathcal{D}=\theta(1-\theta)(1-a)\bigl(a^{-\gamma}-1\bigr),$$

which is strictly positive for every $\gamma>0$ and zero only at $\gamma=0$.
The restriction to $\gamma>1$ is not needed and understates the result.

### 1.3 B.7: the rental rate is written $r_t$, which is the policy rate

Line 2818: `r_t = mc_t^*\alpha\tilde k_t^{\alpha-1}L_t^{1-\alpha}`. But $r_t$ is
the nominal policy rate in B.31, and the summary table at line 3049 itself says
B.7 determines $P^{k,real}_t$. Appendix A (line 1454) defines $r^k_t\equiv
P^k_t/p_t$; the superscript was dropped. The `.mod` calls it `Pkr`.

**Replace L2817–2820 with:**

```latex
\begin{equation}
  P^{k,\mathrm{real}}_t = mc_t^*\,\alpha\,\tilde{k}_t^{\alpha-1}L_t^{1-\alpha}
  \tag{B.7}
  \label{eq:B_rental}
\end{equation}
```

### 1.4 B.4 is the labour–leisure condition, not a consumption FOC

The paragraph at L2784 is headed `\paragraph{Consumption FOC}` but the equation
is $c_t=w_t(1-L_t)/\varpi$, which is A.1.2, the intratemporal labour–leisure
condition. The consumption FOC is the SDF, B.3. The summary table then lists
**both** "Consumption FOC (B.4) → $c_t$" and "Labour FOC (A.1.2) → $L_t$" as
separate rows — one equation counted twice, which breaks the closure count.

Retitle the paragraph `\paragraph{Labour--Leisure Condition.}` and delete the
duplicate table row (§1.9).

### 1.5 B.29: the government budget constraint is broken in three ways

Lines 3002–3010 as they stand:

```
% Level (nominal):  p_t T_t + B_{t+1} = (1 - x_t Delta^b)(1+r_{t-1}) B_t
T_t + Q_t^bB_{t+1} = (1-x_t\Delta^b)\,B_{t-1}
\hat{T}_t + Q_tb_{t}\   = (1-x_t\Delta^b)\Gamma_{t}^{-1}\,b_{t-1}
```

- The stale comment describes a **coupon** bond, $(1+r_{t-1})B_t$. The model
  uses a discount bond priced at $Q^b_t$ (A.4.1, L2294–2307).
- Step 1 has $B_{t+1}$ on the left against $B_{t-1}$ on the right — two periods
  apart. A.4.1 uses $B^b_t$ and $B^b_{t-1}$.
- Step 2 loses the superscript: $Q_t$ is Tobin's Q, and $b_t$, $b_{t-1}$ have
  dropped the $b$ superscript. There is also a stray `\` before the `&=`.
- $\hat T_t$ carries a hat nothing else in the appendix carries (§1.8).

Rewritten in §3.6.

### 1.6 B.31: `\lambda_\Y` will not compile, and `\lambda` is already taken

Line 3018–3019 uses `\lambda_\pi` and `\lambda_\Y`. I grepped the preamble:
there is no `\newcommand{\Y}{...}` anywhere in the file, so **`\lambda_\Y` is an
undefined control sequence** — a hard compile error, not a style issue.

Separately, $\lambda$ is the bank leverage multiplier throughout B.21–B.21d.
Main text 2.5.2 and Appendix A.4.3 both use $\varphi_\pi,\varphi_Y$. B.31 is the
only place that doesn't. Fixed in §3.6.

### 1.7 B.24: $\tilde\Lambda^M$ and $\tilde\Lambda^M_t$ in the same display

Line 2976–2978 writes $H^b_t=1-\theta_t\Delta^b\tilde\Lambda^M$ and then defines
$\tilde\Lambda^M_t$ with a subscript one line below. It is time-varying — the
closed form depends on $\theta_t$ — so the subscript belongs everywhere. Same
fix as main text L724 (Task 1 ledger §9).

### 1.8 Two detrending conventions, both live

Lines 2630–2636 define $\hat C_t, \hat K_t, \hat I_t, \hat Y_t, \hat V_t$ with
hats. Every equation after that — B.1, B.4, B.6, B.14, the whole banking block —
uses bare lowercase $c_t,k_t,i_t,y_t$. Then B.29 goes back to $\hat T_t$.

Line 2639 tries to justify keeping hats, but the document does not actually do
it. The `.mod` uses bare lowercase (`c`, `k`, `i`, `y`, `w`). **Drop the hats.**

**Replace L2630–2636 with:**

```latex
\begin{equation*}
  c_t \equiv C_t/z_t,\quad
  k_t \equiv K_t/z_t,\quad
  i_t \equiv I_t/z_t,\quad
  y_t \equiv Y_t/z_t,\quad
  v_t \equiv \tilde V_t/z_t .
\end{equation*}
```

**Delete L2639** — first snippet `Where in~\ref{appsec:firms} already lowercase
symbols are used`, last snippet `while Appendix B.3-B5 needed to be derived
manually.` Two problems in one sentence: it promises a hat convention the
document abandons, and it says B.3–B.5 were derived manually when B.3–B.5 are
household equations that follow IS2017 directly. The blocks with no template are
the banking ones.

**Insert in its place:**

```latex
Real prices already deflated by $p_t$ keep their existing lowercase symbols
($w_t\equiv W_t/p_t$, $P^{k,\mathrm{real}}_t\equiv P^k_t/p_t$); the operation
in this appendix is deflation by the productivity trend $z_t$ only, and where a
variable requires both the two are applied in sequence. The household and firm
blocks below follow the corresponding steps in \textcite{Isore2017}; the banking
block (B.15--B.28) has no template and is derived here from the level-form
equations of Appendix~\ref{sec:banking_block} directly.
```

### 1.9 The summary table (L3031–3092) was written against the old Appendix A

- Entrepreneur, bank and disaster rows still cite **A.3.x.y tags and level-form
  capital-letter variables** — $N^e_t$, $Q_tS_t$, $D_t$, $N^b_t$, $H^b_t$,
  $Q^b_t$, $R^b_t$ — in a table summarising the *stationarised* system. They
  should be B.15–B.28 and lowercase.
- Rows 3079/3080/3086 cite A.4.1 / A.4.3 / A.4.2; should be B.29 / B.31 / B.30.
  A.4.2 no longer exists after the Task-1 Fisher relocation (now A.1.7).
- **The four B.21a–B.21d equations are missing entirely.** They introduce
  $\eta^b_t,\nu^b_t,\Omega^b_t,\lambda_t$ — four variables and four equations —
  and the table does not count them. The closure statement is wrong until they
  are in.
- Row 3042 double-counts A.1.2 with B.4 (§1.4).
- Row 3087 `\S\ref{par:A511}` is undefined (Task-1 ledger §3).

### 1.10 Two labels inside `align*`

L2714 (`eq:B_bellman`, referenced at L2719) and L2882 (`eq:B_production`) sit
inside starred environments, so `\eqref` prints the wrong number. Change both
to unstarred `align` with `\notag` on the non-tagged rows.

---

## 2. What can stay untouched

Verified correct and at the right depth. Do not expand these.

| eq | status |
|---|---|
| B.1 | Correct. The state-by-state cancellation argument (L2684) is the right level — it is the one non-obvious step and it is explained. |
| B.3, B.3a | Correct. The trend-exponent collapse $\psi+\chi(1-\psi)=\gamma$ is shown properly, and the cross-check against $\Lambda^M$ at L2756 is exactly the kind of internal verification a referee wants. |
| B.5, B.8, B.9, B.12, B.13 | Trivial. One sentence each, already present. Leave. |
| B.6, B.14 | Correct; the exponent bookkeeping is shown. |
| B.20, B.21, B.22, B.25, B.26, B.27 | Pure relabelling or already-stationary. One short sentence each is all they need — but they currently have **none** (comment-only). See §3.5. |
| B.21a–B.21d | **Correct and load-bearing.** This block does not exist in Appendix A and it is what makes $\lambda_t$ endogenous. The `.mod`'s eqs (26a)–(26d) match it. Keep as is; only the discounting caveat in §4 attaches. |
| B.30 | Correct as stated. The exact Fisher form is right; the `.mod` is what disagrees (§4). |
| B.32 | Trivial. |

---

## 3. Insertions — deepening where it is needed

### 3.1 Conditional independence and the $k$ vs $k^n$ convention

B.3b, B.3c and B.17 all separate $x_{t+1}$ from the rest of an integrand without
saying they may. It is legitimate — the main text establishes it at
`\subsection{The Disaster State}` — but it is used three times in this appendix
and stated zero times. One statement here covers all three.

The relation $k^n_{t+1}=k_{t+1}\Gamma_{t+1}$ is currently at **L2998**, after
its first use at B.17/B.18/B.19. Move it up.

**Insert — Appendix B, between the moment definitions (L2652, ending
`They are distinct objects and are not interchangeable.`) and
`\paragraph{\textcite{Gourio2012} Trick}` (L2656):**

```latex
Two conventions are used throughout and are recorded once here. First, capital
carries two detrended counterparts. The quantity committed at the end of
period~$t$ is deflated by the date-$t$ trend, $k^{n}_{t+1}\equiv K_{t+1}/z_t$,
while the stock entering production at $t+1$ is deflated by its own trend,
$k_{t+1}\equiv K_{t+1}/z_{t+1}$. The two differ by the growth realised in
between,
%
\begin{equation*}
  k^{n}_{t+1}=k_{t+1}\,\Gamma_{t+1},
  \qquad
  \Gamma_{t+1}\equiv\frac{z_{t+1}}{z_t}
  =e^{x_{t+1}\ln(1-\Delta^k)+\mu+\varepsilon_{z,t+1}} .
\end{equation*}
%
Balance-sheet equations dated $t$ use $k^{n}_{t+1}$, since the loan is
contracted before the disaster is drawn; production and accumulation use
$k_{t+1}$.

Second, the disaster indicator is drawn independently of the innovations
$\varepsilon_{\theta,t+1}$ and $\varepsilon_{z,t+1}$ conditional on date-$t$
information. Every factorisation below of the form
$\mathbb{E}_t[g(\cdot)\,e^{\kappa x_{t+1}\ln(1-\Delta^k)}]
=\mathbb{E}_t[g(\cdot)]\cdot\mathbb{E}_t[e^{\kappa x_{t+1}\ln(1-\Delta^k)}]$
rests on it, and without it none of them is exact. The premise is stated in
Section~\ref{sec:disaster_state}; it is what makes the detrended state entering
$t+1$ independent of $x_{t+1}$, and hence $v_{t+1}$, $\tilde R^K_{t+1}$ and
$\xi_{i,t+1}$ all measurable with respect to the disaster-free branch.
```

**Then delete from L2998** — first snippet `The detrended capital committed at
$t$ relates to the realised detrended stock`, last snippet `so that $k^n$ and
$k$ coincide up to the growth factor realised between $t$ and $t+1$.` Keep the
following sentence about $\iota^e_t$ and $\iota_t$.

### 3.2 B.2 — finish the collapse, so $\beta(\theta_t)$ is produced not asserted

The Bellman detrending stops at $\mathcal{R}^v_t$ and never integrates out
$x_{t+1}$. That last step is the entire content of the endogenous discount
factor, and it is also exactly what the `.mod` implements
(`betatheta*exp((1-psi)*muz)*STEADY_STATE(v)*CE^(1/(1-chi))`). Adding it makes
appendix and code visibly the same object.

**Insert — Appendix B, `\paragraph{Utility function and Stochastic Discount
Factor.}`, between the B.2 display (ends L2715, `\end{align*}`) and
`For the stochastic discount factor \eqref{eq:SDF}, each factor is detrended in
turn.` (L2717):**

```latex
Two exponent identities follow directly from $\chi\equiv1-\frac{1-\gamma}{1-\psi}$
and are used repeatedly below:
%
\begin{equation*}
  (1-\psi)(1-\chi)=1-\gamma,
  \qquad
  \chi(1-\psi)=(1-\psi)-(1-\gamma)=\gamma-\psi .
\end{equation*}
%
The first says the certainty equivalent loads the disaster factor at exponent
$1-\gamma$. Applying it to $\mathcal{R}^v_t$, separating $x_{t+1}$ from the
remaining integrand, and using \eqref{eq:gourio_star} at $\kappa=1-\gamma$
together with $1/(1-\chi)=(1-\psi)/(1-\gamma)$,
%
\begin{align*}
  \mathcal{R}^v_t
  &=\Bigl(\mathbb{E}_t\bigl[v_{t+1}^{1-\gamma}
      e^{(1-\gamma)(\mu+\varepsilon_{z,t+1})}\bigr]\cdot
      \mathbb{E}_t\bigl[e^{(1-\gamma)x_{t+1}\ln(1-\Delta^k)}\bigr]
    \Bigr)^{\!\frac{1}{1-\chi}}\\[2mm]
  &=\Bigl(\mathcal{D}(\theta_t)\,
      \mathbb{E}_t\bigl[v_{t+1}^{1-\gamma}
      e^{(1-\gamma)(\mu+\varepsilon_{z,t+1})}\bigr]
    \Bigr)^{\!\frac{1-\psi}{1-\gamma}} .
\end{align*}
%
The disaster moment therefore factors out of the continuation value entirely,
and the constant it leaves behind, multiplied by $\beta_0$, is
%
\begin{equation*}
  \beta_0\,\mathcal{D}(\theta_t)^{\frac{1-\psi}{1-\gamma}}
  \;=\;\beta_0\Bigl[(1-\theta_t)+\theta_t(1-\Delta^k)^{1-\gamma}\Bigr]^{\frac{1-\psi}{1-\gamma}}
  \;=\;\beta(\theta_t),
\end{equation*}
%
which is \eqref{eq:betatheta}. The pseudo-discount factor is thus not an
additional assumption but the residue the disaster leaves in the Bellman
equation once $x_{t+1}$ has been integrated out, and the detrended value
recursion can be written
%
\begin{equation*}
  v_t^{1-\psi}=\bigl[c_t(1-L_t)^{\varpi}\bigr]^{1-\psi}
  +\beta(\theta_t)\,e^{(1-\psi)\mu}
   \Bigl(\mathbb{E}_t\bigl[v_{t+1}^{1-\gamma}\bigr]\Bigr)^{\!\frac{1-\psi}{1-\gamma}},
\end{equation*}
%
evaluated at $\varepsilon_{z,t+1}=0$ as in the baseline.
```

### 3.3 B.3b / B.3c — justify pulling $Q^f$ out, and repair the innovation

**Replace L2758–2780** (first snippet `Applying~\eqref{eq:gourio_star} at
$\kappa=-\gamma$ gives the moment required`, last snippet `as shown in
Appendix~\ref{sec:D2}.`) **with:**

```latex
The split in~\eqref{eq:B_SDF_split} isolates the only disaster-dependent factor
in the stochastic discount factor, so any conditional moment of
$\mathcal{M}_{t,t+1}$ is the corresponding moment of $Q^{f}_{t,t+1}$ multiplied
by a moment of $e^{\kappa x_{t+1}\ln(1-\Delta^k)}$. By the conditional
independence recorded above, the two factor.

At $\kappa=-\gamma$ this gives the moment required by the deposit
Euler~\eqref{eq:HHO_Deposit_Euler} and the risk-free
rate~\eqref{eq:riskfree_rate},
%
\begin{equation}
  \mathbb{E}_t\!\left[\mathcal{M}_{t,t+1}\right]
  = \mathbb{E}_t\!\left[Q^{f}_{t,t+1}\right]\mathcal{E}(\theta_t),
  \qquad
  R^f_t=\frac{1}{\mathbb{E}_t\!\left[Q^{f}_{t,t+1}\right]\mathcal{E}(\theta_t)}
  \tag{B.3b}
  \label{eq:B_EQ}
\end{equation}
%
Multiplying instead by the growth factor $\Gamma_{t+1}$ raises the disaster
exponent by one, since $\Gamma_{t+1}$ carries $e^{x_{t+1}\ln(1-\Delta^k)}$
itself:
%
\begin{equation*}
  \mathcal{M}_{t,t+1}\Gamma_{t+1}
  = Q^{f}_{t,t+1}\,e^{\mu+\varepsilon_{z,t+1}}\,(1-\Delta^k)^{(1-\gamma)x_{t+1}} ,
\end{equation*}
%
so that \eqref{eq:gourio_star} applies at $\kappa=1-\gamma$ and delivers the
moment required wherever a payoff that itself grows with the trend is
discounted,
%
\begin{equation}
  \Theta_t\;\equiv\;\mathbb{E}_t\!\left[\mathcal{M}_{t,t+1}\Gamma_{t+1}\right]
  = \mathbb{E}_t\!\left[Q^{f}_{t,t+1}e^{\mu+\varepsilon_{z,t+1}}\right]
    \mathcal{D}(\theta_t)
  \tag{B.3c}
  \label{eq:B_Theta}
\end{equation}
%
Writing $a\equiv1-\Delta^k$, the two moments satisfy
$\mathcal{E}\mathcal{K}-\mathcal{D}=\theta_t(1-\theta_t)(1-a)(a^{-\gamma}-1)>0$
for every $\gamma>0$, so
$\Theta_t<\mathbb{E}_t[\mathcal{M}_{t,t+1}]\,\mathbb{E}_t[\Gamma_{t+1}]$: the
stochastic discount factor and the growth factor are negatively correlated
through the shared disaster draw, and the gap widens with risk aversion. It is
$\Theta_t$ that carries $\beta(\theta_t)$ in closed form: at the non-stochastic
steady state $\Theta=\beta(\bar\theta)e^{(1-\psi)\mu}$, derived in
Appendix~\ref{sec:D2}. Substituting $\mathcal{D}$ for $\mathcal{E}$
in~\eqref{eq:B_EQ} --- equivalently, treating the discount factor and the growth
factor as independent --- would suppress roughly half of the precautionary
reduction in the risk-free rate that is the defining result of the rare-disaster
literature \parencite{Rietz1988,Barro2006,Gourio2012}.
```

The last sentence promotes L2782, which is currently commented out. It is a
genuine result and should be visible.

### 3.4 B.10 / B.11 — finish in $\Theta_t$ form

The prose at L2853 already says the product $\mathcal{M}_{t,t+1}\Gamma_{t+1}$ is
$\Theta_t$, but the displayed equations still carry the raw exponential. The
`.mod` implements the $\Theta$ form (`X1 = y*mc + zeta*Theta*X1(+1)*pi(+1)^upsilon`).
Close the gap.

**Replace L2847–2859** (first snippet `\begin{equation}` immediately after
`in equation~\eqref{eq:aux1}, every term carries exactly one factor of $z_t$,
which cancels:`, last snippet the `\end{equation}` closing B.11) **with:**

```latex
\begin{equation}
  \xi_{1t} = y_t\,mc_t^*
  +\zeta\,\mathbb{E}_t\Bigl[\mathcal{M}_{t,t+1}\,\Gamma_{t+1}\,
    (1+\pi_{t+1})^{\nu}\,\xi_{1,t+1}\Bigr]
  \tag{B.10}
  \label{eq:B_Xi1}
\end{equation}
%
\begin{equation}
  \xi_{2t} = y_t
  +\zeta\,\mathbb{E}_t\Bigl[\mathcal{M}_{t,t+1}\,\Gamma_{t+1}\,
    (1+\pi_{t+1})^{\nu-1}\,\xi_{2,t+1}\Bigr]
  \tag{B.11}
  \label{eq:B_Xi2}
\end{equation}
%
The growth factor appearing here is not a duplicate of anything inside
$\mathcal{M}_{t,t+1}$. The stochastic discount factor is a ratio of marginal
utilities and is scale-free by construction, whereas $\Xi_{1t}$ and $\Xi_{2t}$
trend with output and must be deflated; the two effects are separate and both
are present. The discount object in \eqref{eq:B_Xi1}--\eqref{eq:B_Xi2} is
therefore $\Theta_t$ of~\eqref{eq:B_Theta}, not $1/R^f_t$, and the distinction
is not cosmetic: the two differ by the moment ratio
$\mathcal{D}(\theta_t)/\mathcal{E}(\theta_t)$, which moves with $\theta_t$.
Using the capital-destruction moment $\mathcal{K}$ here instead --- the natural
guess, since $\Gamma_{t+1}$ contains one power of the disaster factor --- would
be wrong: $\mathcal{K}$ is the $\kappa=1$ moment of the disaster factor alone,
whereas the object required is the $\kappa=1-\gamma$ moment of the disaster
factor \emph{combined with} the discount factor's own $-\gamma$ loading.
```

### 3.5 B.15–B.28 — convert the comment-only block into visible derivation

This is the main body of work. The two `align` environments at L2893–2930 and
L2962–2996 stay, but each gets a heading and one to four lines of argument, so
nothing is justified only in a comment. Keep the equations exactly as they are
except for the $\tilde\Lambda^M_t$ subscript and the $\iota$ notation.

**Delete** the LaTeX comments `% A.3.1.1 Utilisation FOC — stationary,
unchanged` and its siblings — they are superseded by the prose below.

**Insert — Appendix B, `\subsection{Banking Block}`, immediately after the
conventions comment block (L2892) and before `\begin{align}` (L2893):**

```latex
Three groups of equations appear here. The entrepreneur block mixes trending
balance-sheet quantities with stationary rates, so it requires both a $z_t$
deflation and one application of \eqref{eq:gourio_star}. The bank block is
almost entirely relabelling, because the leverage constraint and the value
function are homogeneous of degree one in net worth. The disaster-transmission
block is dimensionless throughout and passes into the stationarised system
unchanged in form.
```

**Insert — after the first `align` closes (L2930) and before
`\paragraph{Endogenous Leverage Multiplier.}` (L2932):**

```latex
\noindent Four of these deserve a line. The utilisation
condition~\eqref{eq:A3_util} equates two prices and is stationary as written, so
B.15 is the level equation relabelled. B.16 splits the return on capital into
the disaster factor and a disaster-free component $\tilde R^K_{t+1}$, which is a
ratio of stationary prices; the split is what allows the indicator to be
integrated out separately in the next equation.

B.17 is that integration. Since $\tilde R^K_{t+1}$ is measurable with respect to
the disaster-free branch, \eqref{eq:gourio_star} applies at $\kappa=1$:
%
\begin{equation*}
  \mathbb{E}_t\bigl[R^K_{t+1}\bigr]
  =\mathbb{E}_t\bigl[e^{x_{t+1}\ln(1-\Delta^k)}\bigr]\,
   \mathbb{E}_t\bigl[\tilde R^K_{t+1}\bigr]
  =\bigl[(1-\theta_t)+\theta_t(1-\Delta^k)\bigr]\mathbb{E}_t\bigl[\tilde R^K_{t+1}\bigr]
  =\mathcal{K}(\theta_t)\,\mathbb{E}_t\bigl[\tilde R^K_{t+1}\bigr],
\end{equation*}
%
so the participation condition A.3.1.6 becomes B.17. This is the one place
$\mathcal{K}$ appears rather than $\mathcal{D}$ or $\mathcal{E}$: the payoff
being averaged is the physical capital stock itself, not a discounted claim.

B.18 requires care with the dating, because every term in the bracket is
contracted at $t-1$ while the equation is deflated by $z_t$. Writing
$k^n_t\equiv K_t/z_{t-1}$ and $n^e_{t-1}\equiv N^e_{t-1}/z_{t-1}$,
%
\begin{equation*}
  \frac{Q_{t-1}K_t}{z_t}=Q_{t-1}k^n_t\,\frac{z_{t-1}}{z_t}=Q_{t-1}k^n_t\,\Gamma_t^{-1},
  \qquad
  \frac{N^e_{t-1}}{z_t}=n^e_{t-1}\Gamma_t^{-1},
\end{equation*}
%
and since the gross rates $R^K_t$ and $R^S_{t-1}$ are already stationary, the
factor $\Gamma_t^{-1}$ is common to the whole bracket rather than attaching to
any single term. The start-up transfer scales with the trend,
$\iota^e_t=\iota^e z_t$, so it enters the detrended equation as a constant and
sits \emph{outside} the bracket. B.23 has the identical structure and inherits
the same treatment. Getting this wrong --- applying $\Gamma_t^{-1}$ to the
lagged net-worth term alone --- changes the steady-state level of net worth
without changing the Blanchard--Kahn count, so it is not caught by a
determinacy check.

B.19 follows from $Q_tK^n_{t+1}/z_t=Q_tk^n_{t+1}$ by the convention above.
```

**Insert — after the second `align` closes (L2996), replacing the paragraph at
L2998** (first snippet `The detrended capital committed at $t$`, last snippet
`requires the level-form transfers to scale with the productivity trend.`)
**with:**

```latex
\noindent The bank block B.20--B.23 is relabelling: the balance sheet, the
binding leverage constraint and the home-bias identity are all linear in
quantities that share the trend $z_t$, so dividing through leaves their form
untouched, and the ratio $\phi/(1-\phi)$ is dimensionless. B.23 is the exception
only in the sense that it carries the same $\Gamma_t^{-1}$ bracket structure as
B.18, for the same reason and with the same treatment of the start-up transfer
$\iota^b_t=\iota^b z_t$.

The disaster-transmission block B.24--B.28 needs no deflation at all: resilience,
the bond price, the bond return and the spread are ratios of same-trend
quantities or pure probabilities. One step is worth making explicit. The SDF
loading of A.3.3.2 is defined as a ratio of conditional moments,
$\tilde\Lambda^M_t\equiv\mathbb{E}_t[\mathcal{M}^d_{t,t+1}]/\mathbb{E}_t[\mathcal{M}_{t,t+1}]$.
Using the split~\eqref{eq:B_SDF_split} for the numerator and~\eqref{eq:B_EQ} for
the denominator, the common factor $Q^{f}_{t,t+1}$ cancels and
%
\begin{equation*}
  \tilde\Lambda^M_t
  =\frac{(1-\Delta^k)^{-\gamma}}{\mathcal{E}(\theta_t)}
  =\frac{(1-\Delta^k)^{-\gamma}}
        {1+\theta_t\bigl[(1-\Delta^k)^{-\gamma}-1\bigr]},
\end{equation*}
%
which is the closed form quoted in B.24. Normalising by the conditional mean
rather than by the no-disaster realisation is what makes $H^b_t$ commensurate
with the $R^f_t$ it is divided by in B.25; the two objects would otherwise agree
only to first order in $\theta_t$. The spread B.28 follows from B.25 as
$1/Q^b_t-R^f_t=R^f_t(1-H^b_t)/H^b_t$, with the stated approximation dropping the
factor $R^f_t/H^b_t\approx1$.
```

Also in B.24, change `\tilde\Lambda^M` to `\tilde\Lambda^M_t` on the left-hand
side (L2976), and in B.23 change `+ \iota` to `+ \iota^b` (L2971).

### 3.6 B.29 and B.31 — repair

**Replace L3001–3020** (from `\begin{align}` through the B.31 `\tag{B.31}\\[6pt]`)
**with:**

```latex
The government budget constraint A.4.1 is stated in real terms with a discount
bond, so only the trend deflation remains. Maturing debt has face value $B^b_{t-1}$
and pays $(1-x_t\Delta^b)$ per unit; new issuance $B^b_t$ raises $Q^b_tB^b_t$.
Deflating by $z_t$, with $b^b_t\equiv B^b_t/z_t$, the maturing stock was deflated
by $z_{t-1}$ and therefore picks up $\Gamma_t^{-1}$ while current issuance does not:
%
\begin{align}
T_t + Q^b_t\,b^b_t
&= \bigl(1-x_t\Delta^b\bigr)\,\Gamma_t^{-1}\,b^b_{t-1}
\tag{B.29}\\[6pt]
%
\mathbb{E}_t\!\left[\mathcal{M}_{t,t+1}\,\frac{1+r_t}{1+\pi_{t+1}}\right] &= 1
\tag{B.30}\\[6pt]
%
r_t &= \rho_r\, r_{t-1}
     + (1-\rho_r)\!\left[\varphi_\pi(\pi_t - \bar{\pi})
     + \varphi_Y\!\left(y_t - \bar{y}\right) + \bar{r}\right]
\tag{B.31}\\[6pt]
```

Three changes: the indices now match A.4.1 ($b^b_t$, $b^b_{t-1}$), $Q^b_t$ keeps
its superscript, and $T_t$ loses the hat it alone carried. B.30 is unchanged —
every argument is already stationary. B.31 replaces `\lambda_\pi`/`\lambda_\Y`
with $\varphi_\pi$/$\varphi_Y$, matching main text 2.5.2 and A.4.3 and freeing
$\lambda$ for the leverage multiplier. Note that $y_t$ here is $Y_t/z_t$, so the
level-gap form of A.4.3 and the detrended form written here are the same rule.

**Also delete the stale comment at L3003** — `% Level (nominal):  p_t T_t +
B_{t+1} = (1 - x_t Delta^b)(1+r_{t-1}) B_t`. It describes a coupon bond the
model does not have.

### 3.7 The summary table

**Replace the entrepreneur through public-authority rows (L3060–3089) with:**

```latex
\multicolumn{3}{l}{\textit{Entrepreneurs (A.3.1 / B.15--B.19)}}\\
Utilisation FOC (B.15)         & $u_t$            & \\
Return on capital (B.16)       & $R^K_t$          & definition; $\tilde R^K$ split\\
Participation / EFP (B.17)     & $R^S_t$          & $\mathcal{K}(\theta_t)$ moment\\
Net worth (B.18)               & $n^e_t$          & $\Gamma_t^{-1}$ on whole bracket\\
Balance sheet (B.19)           & $Q_ts_t$         & loan demand\\
\midrule
\multicolumn{3}{l}{\textit{Banks (A.3.2 / B.20--B.23)}}\\
Balance sheet (B.20)           & $d_t$            & residual\\
Leverage, binding (B.21)       & $Q^b_tb^b_t$     & with home-bias\\
Asset value coefficient (B.21a)& $\eta^b_t$       & \\
Net-worth coefficient (B.21b)  & $\nu^b_t$        & \\
Continuation value (B.21c)     & $\Omega^b_t$     & \\
Leverage multiplier (B.21d)    & $\lambda_t$      & endogenous, time-varying\\
Home-bias (B.22)               & ratio            & pins bond/loan split\\
Bank net worth (B.23)          & $n^b_t$          & $\Gamma_t^{-1}$ on whole bracket\\
\midrule
\multicolumn{3}{l}{\textit{Disaster transmission (A.3.3 / B.24--B.28)}}\\
Resilience (B.24)              & $H^b_t$          & $\tilde\Lambda^M_t$ closed form\\
Bond price (B.25)              & $Q^b_t$          & \\
Bond return (B.26)             & $R^b_t$          & definition\\
\midrule
\multicolumn{3}{l}{\textit{Public authority \& clearing (B.29--B.32)}}\\
Government budget (B.29)        & $T_t$            & real, discount bond\\
Taylor rule (B.31)             & $r_t$            & \\
Goods clearing (B.32)          & $c_t$ consistency & Walras check\\
\midrule
\multicolumn{3}{l}{\textit{Non-independent (not counted)}}\\
EFP schedule (A.3.1.3)         & --- & \emph{definition} of $f(\cdot)$\\
Banker value fn (A.3.2.2)      & --- & level-form groundwork for B.21a--B.21d\\
Fisher (B.30)                  & --- & links $r_t,R^f_t$\\
Expected bond return (B.27)    & --- & $=$ B.26 in expectation\\
Spread (B.28)                  & --- & reporting definition\\
Bond clearing (\S\ref{par:A513})      & --- & $=$ B.22\\
Loan clearing (A.5.4)                 & --- & $=$ B.19 $+$ B.21 $+$ B.22\\
```

**Also delete the duplicate household row at L3042** — `Labour FOC (A.1.2) &
$L_t$ & \\` — and retitle L3041 from `Consumption FOC (B.4)` to
`Labour--leisure (B.4)`, determining $L_t$. B.3 is the consumption FOC and
already has its own row.

**And delete the deposit-clearing row at L3087** (`Deposit clearing
(\S\ref{par:A511})`) or give `par:A511` a real target — it is one of the seven
dangling references from the Task-1 ledger.

---

## 4. Where Appendix B and the `.mod` disagree

Not Task 2, but found while checking B and it bears on how B should be worded.
Full tracing comes with Task 3.

**B.21a/B.21b — factored expectations.** B says
$\eta^b_t=\mathbb{E}_t[\mathcal{M}_{t,t+1}\Omega^b_{t+1}\bar R^{ex}_{t+1}]$. The
`.mod` writes `etaB = Q*OmB(+1)*((1-phi)*RS + phi*Rb(+1) - Rd)`, where `Q` is
$\mathbb{E}_t[\mathcal{M}_{t,t+1}]$ — a variable dated $t$. Dynare therefore
solves $\eta^b_t=\mathbb{E}_t[\mathcal{M}]\cdot\mathbb{E}_t[\Omega^b\bar R^{ex}]$,
dropping $\mathrm{Cov}_t(\mathcal{M},\Omega^b\bar R^{ex})$. At first order this
is exact; at third order it is not, and the covariance is precisely the
disaster-risk channel. Same pattern in `X1`/`X2`, which use `Theta*X1(+1)`
rather than the expectation of the product.

**B.30 Fisher.** B states the exact form. The `.mod` has `Q = pi(+1)/r`, which
is $R^f_t=(1+r_t)/\mathbb{E}_t[1+\pi_{t+1}]$ — the textbook approximation that
A.1.7 explicitly says is not used. This is the open item from the Aug-16
assessment; the replacement draft exists but is not implemented.

**B.29.** Not in the `.mod` at all. `T_t` is a pure residual with no feedback.
Defensible, since $T_t$ enters nothing else once A.4.1 is consolidated — but the
appendix should say so rather than leave a supervisor tracing A.4.1 into code
that has no such equation.

**Confirmed consistent** (worth knowing): `Theta = Q*exp(muz)*Dcal/Ecal`
reproduces B.3c exactly once $Q=\mathbb{E}_t[\mathcal{M}]=Q^f\mathcal{E}$;
`betatheta` matches B.2's collapsed form; `Hb = 1 - theta*Deltab*LambdaM/Ecal`
reproduces B.24's $\tilde\Lambda^M_t$; eq (23) now applies `exp(-muz)` to the
whole bracket, matching B.18; `QS = Qtob*exp(muz)*k - Ne` implements
$k^n_{t+1}=k_{t+1}\Gamma_{t+1}$ correctly.

---

## 5. Order of execution

1. §1.8 conventions (L2630–2639) — everything downstream inherits it
2. §3.1 insert conventions block (L2652) and delete the stale L2998 sentence
3. §3.2 B.2 completion (after L2715)
4. §3.3 B.3b/B.3c replacement (L2758–2780)
5. §1.3 B.7 symbol, §1.4 B.4 retitle
6. §3.4 B.10/B.11 (L2847–2859)
7. §3.5 banking block prose (L2892, L2930, L2996)
8. §3.6 B.29/B.31 (L3001–3020)
9. §3.7 table (L3041–3089)
10. §1.10 the two `align*` labels