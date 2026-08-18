# Ledger — Appendix C (Non-Stochastic Steady State)

Source: `Status_Quo_August17th.txt` lines **3109–3796**.
Every equation re-derived independently from Appendix B and cross-checked
against `thesis_model_v3.mod`'s `steady_state_model` block.
Work **bottom-up by line number**.

---

## 0. Verdict

Appendix C is in much better shape than Appendix B. It has real prose, a
recursive solution algorithm, admissibility conditions and a nesting
discussion — the structure a referee wants. **I re-derived C.2, C.3, C.4, C.5,
C.6, C.13, C.16, C.18, C.25, C.27, C.28, C.30, C.32, C.35 and C.36 from scratch
and they are all correct.**

Fourteen of the sixteen match the `.mod` to the last exponent. The two that do
not are C.27/C.28 — and there the appendix is right and the code is wrong (§4,
and Task 3 ledger §2.1).

What C needs is narrower than what B needed: four derivation steps that are
asserted rather than shown, one inequality inherited wrong from B.3c, one
numerical claim that is off by a factor of four, a missing calibration input,
and a tag/label scheme that says C in the tags and D in the labels.

---

## 1. Errors — must change

### 1.1 C.5: the inequality holds for $\gamma>0$, not $\gamma>1$

Line 3275 repeats the B.3c claim. Same algebra as the Appendix B ledger §1.2:
with $a\equiv1-\Delta^k$,
$\mathcal{E}\mathcal{K}-\mathcal{D}=\bar\theta(1-\bar\theta)(1-a)(a^{-\gamma}-1)>0$
for every $\gamma>0$. Fix both places or neither — leaving them inconsistent
is worse than leaving them wrong.

Note this is *not* the same condition as the one two paragraphs earlier at
line 3252, where "$\mathcal{D}>1$ (for $\gamma>1$)" **is** correct:
$a^{1-\gamma}>1$ requires $\gamma>1$. Two different claims, one right and one
wrong, four lines apart — which is presumably how the error propagated.

### 1.2 C.34/§D8: the quarterly spread figure is wrong by a factor of four

Line 3700 states $\overline{\mathrm{spread}}\approx0.70\%$ against
$\bar R^S-\bar R^f\approx0.20\%$ quarterly. Recomputing from the calibration
($\bar\theta=0.009$, $\Delta^b=0.37$, $\Delta^k=0.22$, $\gamma=3.8$):

$$\Lambda^M=0.78^{-3.8}=2.5706,\quad \mathcal{E}=1.014135,\quad
\tilde\Lambda^M=2.5348,\quad \bar H^b=0.991559,$$
$$\bar R^f=0.99929,\quad \bar Q^b=0.992263,\quad
\overline{\mathrm{spread}}=1/\bar Q^b-\bar R^f=0.008507 .$$

That is **85.07 quarterly basis points, i.e. 0.851% per quarter**, and it
reproduces `table_steady_state.csv`'s 85.0769 exactly. The loan spread figure
(0.20%) is right.

The conclusion survives and is in fact stronger than stated: $\varsigma$ is
increasing in $\phi$ because $0.851\%>0.20\%$, not because $0.70\%>0.20\%$.
Replace the number.

### 1.3 Admissibility condition (vi) contradicts the text that derives it

Line 3787 requires "$\bar R^{S}>\bar R^{f}$ and $\phi<1$" for $\bar\eta^b>0$.
But line 3698 has just derived the weaker statement: $\bar\eta^b>0$ holds "for
any $\phi\in[0,1]$ provided $\bar R^S>\bar R^f$ **or**
$\overline{\mathrm{spread}}>0$ --- either wedge alone is enough". The condition
table should state what the derivation actually gives.

**Replace L3787–3788 with:**

```latex
  \text{(vi)} & \varsigma>0,\;\text{i.e. }\bar R^{S}>\bar R^{f}
              \;\text{ or }\;\overline{\mathrm{spread}}>0
             & \bar\eta^{b}>0,\text{ leverage constraint binds}\\[2pt]
```

### 1.4 The leverage target $\lambda$ enters from nowhere

$\lambda$ is used in C.29, C.30, C.31, C.32, C.34 and C.35, and it is the
object the whole bank block is calibrated around (`levss = 6` in the `.mod`),
but the solution algorithm at L3735–3764 never lists it as an input. A reader
following the algorithm cannot execute step 6.

**Insert — Appendix C, `\subsection{Solution Algorithm and Summary}`, between
`The ordering is` (L3733) and `\begin{enumerate}` (L3735):**

```latex
Three objects are calibration inputs rather than model outputs and are taken
as given at the start: the steady-state bank leverage $\lambda$, the bank
margin $\bar R^{S}/\bar R^{d}$, and the entrepreneur equity ratio $\varkappa$.
Each is matched to a data target rather than solved for, and each has a
structural parameter that is then recovered residually --- the diversion
fraction $\theta^{b}$ from $\lambda$ in step~7, the premium scale $f_0$ from
$\varkappa$ in step~6. This inversion is what keeps the calibration disciplined:
the free parameters are the ones that are hard to observe, and the ones matched
directly are the ones that are not.
```

### 1.5 C.33 does not exist

Tags run C.32 → C.34. Either renumber C.34–C.36 down by one or insert the
missing equation, but the gap should not survive into a submitted draft.

### 1.6 Tags say C, labels say D

Every equation tag is `C.x`; every label is `eq:D_*` and every subsection
`sec:D0`–`sec:D10`; the section header comment at L3095 says "APPENDIX C" while
L3169 refers to "the notation remark in C.0" and the Appendix B table at L3085
cites "Appendix D10". This is legacy from when the steady state was Appendix D.

Nothing breaks — labels are opaque strings — but it is confusing to anyone
reading the source, including a co-author or a replication package user.
Lowest priority of anything in this ledger; if you touch it, rename
`sec:D*` → `sec:C*` and `eq:D_*` → `eq:C_*` in one pass and recompile twice.

### 1.7 $\iota$ should be $\iota^b$

C.31, C.32 and the algorithm use bare $\iota$ for the *banker* start-up
transfer while $\iota^e$ carries a superscript. Same fix as Appendix B ledger
§3.5. The `.mod` already distinguishes `iotab`/`iotae`.

---

## 2. Insertions — the four steps that are asserted rather than shown

### 2.1 C.3: show that the rewritten SDF is B.3

Lines 3195–3204 write the SDF in a form with exponent $\psi-\gamma$ on the
value ratio and $\Gamma_{t+1}^{-\psi}$ outside, and say only that it is
"obtained by substituting $\chi(1-\psi)=\gamma-\psi$". It is equivalent, but a
reader has to do the work. Two lines close it, and they also make the
$\Gamma^{-\gamma}$ of B.3 visible in C.

**Insert — Appendix C, `\paragraph{Stochastic discount factor.}`, between the
display ending L3204 and `in which the certainty equivalent has been written
out explicitly.` (L3206):**

```latex
%
The two forms are the same object. Collecting the trend factors,
$\bigl(v_{t+1}\Gamma_{t+1}\bigr)^{\psi-\gamma}\Gamma_{t+1}^{-\psi}
 = v_{t+1}^{\psi-\gamma}\,\Gamma_{t+1}^{-\gamma}$,
which is the $\Gamma_{t+1}^{-\gamma}$ loading of~\eqref{eq:B_SDF}; and
$v_{t+1}^{\psi-\gamma}=v_{t+1}^{-\chi(1-\psi)}$ by the same substitution. The
form written here simply groups the trend with the value function instead of
separating them, which is what makes the steady-state evaluation below a
one-line calculation.
```

### 2.2 C.13: show the step from B.9 to marginal cost

Line 3388 says "Substituting into the reset-price condition and solving for
marginal cost" and then displays C.13. The substitution is two lines and is the
only place in the nominal block where anything happens.

**Insert — Appendix C, `\subsection{Price Setting}`, between `Substituting
into the reset-price condition~\eqref{eq:B_reset_pi} and solving for marginal
cost,` (L3388–3390) and the C.13 display (L3392):**

```latex
%
their ratio is
%
\begin{equation*}
  \frac{\bar\xi_1}{\bar\xi_2}
  =\overline{mc}\;
   \frac{1-\zeta\,\Theta\,(1+\bar\pi)^{\nu-1}}
        {1-\zeta\,\Theta\,(1+\bar\pi)^{\nu}} ,
\end{equation*}
%
so that~\eqref{eq:B_reset_pi} evaluated at the steady state reads
$(1+\bar\pi^{*})=\frac{\nu}{\nu-1}(\bar\xi_1/\bar\xi_2)(1+\bar\pi)$ and
inverts to
```

### 2.3 C.35: "collapse, exactly as before" refers to nothing in this document

Line 3687 says the coefficient recursions "collapse, exactly as before, to
$\bar\nu^b=\bar\Omega^b$ and $\bar\eta^b=\varsigma\bar\nu^b$". There is no
"before" — the recursions B.21a–B.21d live in Appendix B and the collapse is
never performed anywhere. It is three lines.

**Replace L3687** (first snippet `the coefficient recursions of
Section~\ref{par:A322} collapse, exactly as before, to`, last snippet
`$\bar\Omega^b=(1-\sigma^b)+\sigma^b(\bar\nu^b+\lambda\bar\eta^b)$. Solving the
two together,`) **with:**

```latex
the recursions~\eqref{eq:B_etab}--\eqref{eq:B_lambdat} collapse. At the steady
state $\mathbb{E}[\bar{\mathcal{M}}]=1/\bar R^{f}$ and
$\bar R^{d}=\bar R^{f}$, so~\eqref{eq:B_nub} gives
%
\begin{equation*}
  \bar\nu^b=\frac{\bar\Omega^b\,\bar R^{d}}{\bar R^{f}}=\bar\Omega^b,
  \qquad
  \bar\eta^b=\frac{\bar\Omega^b\,\bar R^{\,\mathrm{ex}}}{\bar R^{f}}
            =\varsigma\,\bar\nu^b ,
\end{equation*}
%
the second using $\bar R^{\,\mathrm{ex}}=\varsigma\bar R^{f}$ by the definition
of $\varsigma$ in~\eqref{eq:D_varsigma}. The marginal value of net worth is
therefore the continuation value itself, and the marginal value of assets is
that same object scaled by the levered excess return. Substituting both into
$\bar\Omega^b=(1-\sigma^b)+\sigma^b(\bar\nu^b+\lambda\bar\eta^b)$ leaves a
single equation in $\bar\Omega^b$,
%
\begin{equation*}
  \bar\Omega^b=(1-\sigma^b)+\sigma^b\,\bar\Omega^b\bigl(1+\lambda\varsigma\bigr),
\end{equation*}
%
which solves to
```

### 2.4 A remark C is missing: the exact and approximate Fisher equations agree here

C.14 states $1+\bar r=\bar R^f(1+\bar\pi)$ and attributes it
to~\eqref{eq:A4_fisher}. That is right, but it is worth saying *why* the exact
form and the textbook form give the same steady state — because that is exactly
why the `.mod`'s approximate Fisher (`Q = pi(+1)/r`) produces a correct steady
state while still being wrong for the dynamics. Without this remark a reader
who has absorbed A.1.7's insistence on the exact form will expect C.14 to look
different, and a supervisor checking the code against C will conclude the
discrepancy is harmless when it is not.

**Insert — Appendix C, `\subsection{Price Setting}`, immediately after the
C.14 display, replacing `at which the Taylor rule~\eqref{eq:A4_taylor} is
satisfied identically.` (L3411) with:**

```latex
at which the Taylor rule~\eqref{eq:A4_taylor} is satisfied identically. The
exact no-arbitrage form~\eqref{eq:A4_fisher} and the textbook approximation
$\bar R^{f}=(1+\bar r)/\mathbb{E}[1+\bar\pi]$ coincide here, because at the
non-stochastic steady state $\pi_{t+1}=\bar\pi$ is deterministic: both the
covariance term and the Jensen gap that separate them
(paragraph~\ref{par:A17}) vanish identically. The distinction between the two
is therefore invisible in this appendix and appears only in the dynamics, at
second order and above.
```

---

## 3. What can stay untouched

Verified correct against Appendix B and against the `.mod`. Do not expand.

| eq | check |
|---|---|
| C.1a–c | Match `Dcalss`, `Ecalss`; $\mathcal{K}$ inlined as `(1-thetass*Deltak)`. |
| C.2 | $\beta(\bar\theta)=\beta_0\mathcal{D}^{(1-\psi)/(1-\gamma)}$; `betathetass` uses $1/(1-\chi)$, identical. |
| C.3 | Re-derived: at $x=0$, $\mathcal{R}^v=\bar v e^{\mu}\mathcal{D}^{1/(1-\gamma)}$ gives $\bar Q^f=\beta_0e^{-\psi\mu}\mathcal{D}^{(\gamma-\psi)/(1-\gamma)}$. Exponent identity $(1-\psi)/(1-\gamma)-1=(\gamma-\psi)/(1-\gamma)$ confirms the second form. Matches `Qfss` exactly. |
| C.4 | $\bar R^f=1/(\bar Q^f\mathcal{E})$; matches `Qss=Qfss*Ecalss; Rfss=1/Qss`. The $\mathcal{D}$-vs-$\mathcal{E}$ sign discussion at L3250–3253 is correct. |
| C.5 | $\bar Q^fe^{\mu}\mathcal{D}=\beta(\bar\theta)e^{(1-\psi)\mu}$ verified; matches `Thetass = Qss*exp(muz)*Dcalss/Ecalss`. Only the $\gamma$ condition is wrong (§1.1). |
| C.6 | Matches `vss`, once read in the `.mod`'s convention (§5). |
| C.7–C.9 | Match `Hbss`, `Qbss`, `Rbss`, `spreadss`. The realised-vs-expected discussion at L3329–3335 is exactly right and is load-bearing for C.31. |
| C.10–C.12 | Match `piresetss`, `omegass`, `X1ss`, `X2ss`. |
| C.13 | Re-derived from B.9 + C.12; matches `mcss` term by term. |
| C.15–C.22 | Match `Qtobss`, the LOM, `knss`, `RKtildess`, `pkrss`, `eta`, `klss`, `wss`, `clss`, `ylss`, `lss`. |
| C.23–C.26 | Match `Ness`, `f0`, `QSss`. The identity $f_0=\mathcal{F}\varkappa^{\chi^e}$ with $\varkappa=1/\texttt{levE}$ gives $\mathcal{F}=\texttt{premE}$ exactly. |
| C.29–C.30 | Match `Ass`, `QbBss`, `Nbss`, `Dss`. |
| C.31–C.32 | Re-derived; matches `iotab` exactly, including the use of the **realised** $\bar R^b$. |
| C.34–C.35 | Re-derived; `spreadAss`$=\varsigma\bar R^f$, `OmBss`, `etaBss`, `nuBss`, `lambdadiv` all match. |
| C.36 | Consistent with the corrected B.29. The $r>g$ reading at L3722 is right. |

The nesting paragraph (L3794–3795) and the $\phi=0$ discussion are correct and
are confirmed numerically by `table_steady_state.csv`: output, consumption and
investment are identical to fifteen digits across $\phi\in\{10^{-4},0.03,0.20\}$.

---

## 4. Where C and the `.mod` genuinely disagree

**C.27/C.28 — and here the appendix is right.** Full diagnosis in the Task 3
ledger §2.1. In summary: B.18 detrends the entrepreneur capital term as
$Q_{t-1}k^n_t\Gamma_t^{-1}$ because $k^n_t\equiv K_t/z_{t-1}$; the `.mod` uses
`k(-1)`, which is $K_t/z_t$ and therefore already carries one $\Gamma^{-1}$.
Applying `exp(-muz)` to the whole bracket on top of that double-counts, leaving
the code with $e^{-2\mu}$ where C.28 has $e^{-\mu}$ on the
$(\bar{\tilde R}^K-\bar R^S)\bar k$ term.

Because `iotae` is calibrated residually from the same expression, the
steady-state residual is still zero and no diagnostic catches it. C.28 is the
correct target.

---

## 5. One documentation gap worth closing

The `.mod`'s `v` is not Appendix C's $\bar v$. Appendix B defines **both**
$v_t\equiv\tilde V_t/z_t$ (L2628) and $\hat V_t\equiv V_t/z_t^{1-\psi}$
(L2635), and $\hat V_t=v_t^{1-\psi}$. C.6 presents $\bar v$; the `.mod` stores
$\hat V$ — `vss = (css*(1-lss)^varpi)^(1-psi)/(1-Thetass)`, which is
$\bar v^{1-\psi}$.

Everything downstream is consistent under that reading: `(v(+1)/v_ss)^(-chi)`
is $v^{-\chi(1-\psi)}$ as B.3 requires, and `CE = (v(+1)/v_ss)^(1-chi)` is
$v^{(1-\psi)(1-\chi)}=v^{1-\gamma}$ as the collapsed B.2 requires. So this is a
labelling gap, not a bug — but anyone checking C.6 against the printed steady
state will find a number raised to $1-\psi$ and no explanation.

**Insert — Appendix C, after the C.6 display, before `which requires
$\Theta<1$` (L3296):**

```latex
Note that the object carried in the numerical implementation is
$\hat V=\bar v^{\,1-\psi}$ rather than $\bar v$ itself, following the second
convention of Appendix~\ref{sec:Stationarization}; the two differ by the
exponent that the Epstein--Zin recursion applies to the consumption--leisure
bundle, and every exponent downstream is stated in whichever of the two makes
the expression shortest.
```

---

## 6. Order of execution

1. §1.1 the $\gamma$ condition (also fix the twin in Appendix B)
2. §1.2 the spread number at L3700
3. §1.3 admissibility (vi)
4. §2.3 the C.35 collapse (L3687) — largest single insertion
5. §2.1, §2.2, §2.4, §5 the four smaller inserts
6. §1.4 calibration inputs in the algorithm
7. §1.5 C.33, §1.7 $\iota^b$
8. §1.6 the C/D label scheme, last, in one pass