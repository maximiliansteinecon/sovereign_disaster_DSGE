# Results Chapter — Feasibility & Priority Map (drafted 2026-08-01, late)

Evaluates each proposed subsection against two questions: (1) is it
actually achievable with the current, validated model and toolchain, and
(2) is it worth doing given the thesis's actual claims and the time left.
Ranked into three tiers. One flagged calibration decision needs your
input before the headline figure can be finalized (see §0).

## 0. One thing to decide first: which φ is "baseline"?

`thesis_model_v3.mod`'s `PHIVAL` default is currently **0.20** (you
changed this yourself at some point after my last verification pass,
which had used 0.10). Every result in this thesis so far — steady-state
tables, the impact-period leverage-channel decomposition, the safe-haven
check — was computed at φ=0.10 or φ=0.20 depending on which session, not
consistently one or the other. Before building the headline figures,
confirm: is 0.20 the deliberate, final calibration target (backed by
Altavilla-Pagano-Simonelli or whatever euro-area home-bias estimate
you're citing), or should it revert to 0.10? Every downstream table/figure
should be regenerated once with the *final* number — this is a
five-minute Dynare re-run, not a re-derivation, but it needs to happen
exactly once, deliberately, not be whatever the last edit happened to
leave in place.

## Tier 1 — ready now, mostly writing (do these first)

### 5.2.2 Headline disaster-risk-shock IRFs (φ=0 vs φ>0)
**Fully built.** This is exactly what `run_thesis_model.m` already
produces — GIRFs to `etheta`, both scenarios, for output/consumption/
investment/labour/inflation/rate/spread/Nb/Ne/leverage/loan rate. Once
§0 is settled, one clean re-run gives you the multi-panel figure. This
should be the centerpiece, as proposed.

**Do not present this as a single result — it decomposes into two
channels you've already proven exist, and Appendix A.3.3 has already
promised the reader this exact quantification** ("its magnitude is
quantified in Section~\ref{sec:results}" — that sentence is a debt the
appendix owes the results chapter). Specifically:
- The **impact-period leverage response** (η_t/ν_t moving before N^b_t
  has changed at all — verified 2026-07-30, `lev` moves 0.0148 at t=0
  while `Nb` is exactly 0.000000) is the "immediate, perceived-risk"
  channel. Report this explicitly as a share of the eventual peak
  response (was ~21% at the calibration tested).
- The **lagged, realised-loss channel** (Rb falling from t=1 onward,
  feeding Nb's accumulation) is the second, slower-moving piece.
This decomposition is not optional colour — it is the paper's most
original finding (per your own Appendix A.3.3, which explicitly frames
it as sharpening IS2017's own "perceived risk alone" result) and it is
already fully computed. Writing it up is the highest-value use of time
in the entire results chapter.

**Also include, briefly:** the safe-haven sign check (Q^b falls
throughout, never reverses; Δlog(H^b) dominates Δlog(R^f) at every
horizon) — one paragraph and the small table already in the changelog.
This pre-empts exactly the sharp examiner question ("could this channel
run in reverse?") before it's asked.

### 5.2.1 Steady-state comparison table (φ=0 vs φ>0)
**Fully built**, modulo §0. `Nb`, `lev`, `spread`, `QbB`, entrepreneur
premium (`premE`/𝓕), bank margin (`R^S/R^d`) are all already in the
steady-state block. This is a table-construction task, not a computation
task.

**One substitution needed:** the proposed "one TFP-shock IRF to show the
model behaves sanely outside disaster risk" is **not directly available**
— the current calibration explicitly switches off the productivity
innovation (`ε_{z,t}=0` throughout, stated in the model's own header:
"the only aggregate stochastic driver is the disaster probability θ_t").
Adding a genuine stochastic TFP shock means a new exogenous process, a
modified capital-accumulation equation, and a re-verification pass —
doable, but new scope. **Cheaper, already-available substitute:** the
monetary policy shock `er` is already declared in `varexo` and wired
through the Taylor rule; it's just calibrated to `stderr 0` (switched
off). Turning it on (pick a standard value, e.g. 25bp) costs one
parameter change and gives you exactly the same "model behaves like a
normal NK model away from disaster risk" sanity check, at essentially
zero risk. Recommend swapping TFP → monetary shock for this purpose.

### 5.1 Calibration table
**Mostly writing.** Every number is already in the `.mod` file's
parameter block and steady-state derivation — this is a transcription
task with justification prose, not new computation. The specific
citations you list (Altavilla-Pagano-Simonelli for φ, Barro-Ursúa for
θ̄, back-solved Δ^b) are literature work only I can't do for you, but the
*numbers* they're meant to justify are already fixed and known.

### 6.2 Limitations / methodology discussion
**Ready to write, high value.** This is the natural home for: the T_t/
government budget constraint gap (already self-disclosed in the .mod
header); the "no realised default along the simulated path" convention
and what it does and doesn't let you claim; and — directly reusable —
tonight's Taylor projection analysis. Cite Fernández-Villaverde &
Levintal (2018) explicitly, make the footnote-1 argument (their own paper
credits IS2017's detrending-invariance construction, which this thesis
uses throughout, with pre-empting the exact perturbation failure mode
their paper targets) as a considered-and-rejected alternative. This
section is cheap and pre-empts real examiner questions — don't skip it
for time.

## Tier 2 — real "tail" content, moderate new work, high thematic payoff

### 5.3.1 Simulated distributions, skewness/kurtosis
**Needs a genuine new computation, but a cheap one.** The ergodic-mean
machinery in `run_thesis_model.m` already burns in with `simult_` and
the solved policy functions (`oo_.dr`) — extending this to a long
*stochastic* simulation (real shock draws, not the zero-shock path used
for the ergodic mean) and computing `skewness`/`kurtosis` (built-in
MATLAB functions) on the resulting series is maybe an hour of work, no
new model equations, no BK risk. **This is the section that actually
earns the word "tail" in your title** — right now the thesis has a
disaster-*risk* mechanism but no evidence about the shape of the
resulting distribution. Strongly recommend doing this even under time
pressure; it's cheap relative to its importance for the thesis's own
framing.

### 5.3.2 Spread-at-Risk / Output-at-Risk
**Free once 5.3.1 exists** — literally percentiles of the same simulated
series. Your own instinct here is right: keep it, don't cut it, it costs
almost nothing on top of 5.3.1.

### 5.4.1 / 6.1 Sensitivity to φ (continuous sweep)
**Moderate new work, dual-purpose.** A loop over φ ∈ {0, 0.05, 0.10,
0.15, 0.20, 0.25, ...} re-using the existing solve/GIRF machinery. Two
reasons to prioritize this over 5.3.3/5.4.2: (a) it's the natural,
already-legitimized extension of IS2017's own Appendix B sensitivity
figures (γ, β₀, θ̄, Δ), so it needs no new methodological justification;
(b) **it directly resolves the still-open "φ=0 numerical fragility"
item** from `ToDoAugust1st.md` §2 — if the sweep shows a smooth trend
for φ>0 with something odd happening exactly at φ=0, that is itself a
reportable finding (and exactly what "try φ=1e-4 as a smoother
counterfactual" was proposed to test). One computation serves two ends.

## Tier 3 — cut first if behind, or reduce to a paragraph

### 5.3.3 Disaster-risk shock vs. standard risk-premium shock
**Conceptually murky given this model's own structure**, not just
low-priority. θ_t *is* the model's risk-premium-generating mechanism —
there is no other exogenous "standard risk-premium shock" currently in
the model to contrast it with. Building one would mean introducing a
genuinely new, separately-motivated shock (e.g. an exogenous discount-
factor/preference shock unrelated to disaster probability) with unclear
payoff, since the thesis's whole point is that θ_t *is* the risk-premium
channel. Your own instinct to flag this "first to cut" is correct — I'd
go further and say cut it entirely rather than rush a conceptually
unclear addition, unless a natural candidate shock is already sitting in
the model somewhere I've missed.

### 5.4.2 Stylised sovereign backstop
**Genuine new modeling** (a fiscal rule, a bailout/backstop mechanism —
new equations, new calibration, new BK re-verification), correctly
tagged optional by you already. Cut first; if time allows, reduce to a
one-paragraph "natural extension for future research" note rather than
an actually-modeled counterfactual.

## Suggested sequencing given ~4 weeks

1. Settle §0 (φ calibration), regenerate all Tier-1 numbers/figures once.
2. Write 5.1, 5.2.1, 5.2.2 (incl. the two-channel decomposition and
   safe-haven check), 6.2 — all ready now, this is the bulk of the
   chapter and de-risks the deadline immediately.
3. Build 5.3.1 (long simulation + moments) and 5.3.2 (percentiles) —
   the "tail" evidence the title promises.
4. Build 5.4.1 (φ sweep) — doubles as resolving the outstanding
   numerical-fragility to-do item.
5. Only if time remains: reconsider 5.3.3/5.4.2, or leave as brief
   discussion paragraphs in 6.2 rather than full subsections.

---

# 2026-08-19 evening update — write-up readiness, v3→v4, and new findings

This file was drafted 2026-08-01 against `thesis_model_v3.mod` and a
still-open φ calibration. Both are now settled (§0's question resolved
at φ=0.03, per `table_calibration.csv`'s sourced value), and Tier 1
almost entirely exists as actual output (`Fig1-6`, `table_*.csv`). This
section (a) states plainly whether the write-up can start, with the
Taylor-rule/Fisher-equation decision specifically addressed, and (b)
adds formulation bridges for everything discovered today that this
file's Aug 1 version couldn't have anticipated. Tier 1/2/3 above should
now be read as **historical planning, largely executed** — cross-check
against `ToDoAugust19th.md` §4 for the file-level bookkeeping.

## A. Can the write-up start? Yes. The Taylor rule decision, specifically.

**There is no outstanding Taylor-rule decision.** The functional form
(level output gap, not log gap — `phiy*(y-STEADY_STATE(y))`) was
decided 2026-08-17 and is byte-identical between `thesis_model_v3.mod`
and `thesis_model_v4.mod`; nothing about it changed today. What changed
today is the **Fisher equation** (`Q=pi(+1)/r` → the exact
`FI`-auxiliary form), which is only *adjacent* to the Taylor rule in the
sense that both equations jointly pin the nominal rate `r_t` in the
system, and in the sense that `Fisher_Taylor_Replacement_Draft.md`
(2026-08-16/17) bundled a Taylor-rule *renumbering* (A.4.3→A.4.2, since
removing Fisher from Public Authority leaves Taylor as its only
equation) together with the Fisher-equation *relocation* (Public
Authority → Households, A.1.7). The rule itself was never in question;
only its label moved.

That relocation is why "can we start the write-up" was genuinely gated
on more than just re-running Dynare. Checked tonight, cross-referencing
`Fisher_Taylor_Replacement_Draft.md` against the current draft:

- **Households appendix (lines 1289–1300 of the current draft):** the
  relocated Fisher-equation paragraph, including the covariance-condition
  derivation, is present and matches the drafted replacement text
  essentially verbatim.
- **Public Authority appendix (lines 2284–2341):** correctly trimmed to
  Taylor-rule-only, no orphaned duplicate Fisher paragraph left behind.
- **Main text (§2.2 Households ~line 310, §2.5 Public Authority
  ~lines 821–862):** same pattern, correctly split.
- **Not updated: the equation/variable-count summary table, lines
  2505–2508.** It still lists `A.4.2† Fisher equation ... A.4 Public
  Authority` and the accompanying comment at line 2519 still says "The
  Fisher equation (A.4.2)...". Per the draft's own retag instructions
  this row should move up into an `A.1 Households` grouping, retagged
  `A.1.7`, with Taylor rule renumbered `A.4.3→A.4.2`. This is a
  bookkeeping gap, not a modelling one — the underlying equation count
  is still right, the table just points at the wrong subsection now.
  **Fix before final compile; does not block starting the write-up.**

The more consequential question — was the code actually caught up with
what the text has claimed since 2026-08-16? — is now yes, and it wasn't
until today. `Fisher_Taylor_Replacement_Draft.md` and the corresponding
draft paragraph (line 1300) have asserted since the 16th/17th that the
exact Fisher form "is therefore carried in its exact form into the
stationarised system... rather than replaced by a log-linear
substitute." Until today's `thesis_model_v4.mod`, the model actually
generating the headline results (`thesis_model_v3.mod`) still used the
approximate form (`Q=pi(+1)/r`) — the text was describing a model that
did not yet exist in code. That gap is now closed: `run_thesis_model.m`
points at `v4` (since 13:12 today), `thesis_model_results.mat` and
`Fig1-6` are regenerated from it, and §C.1 below shows the exact-vs-
approximate gap is not decorative — it is large enough that citing
approximate-form numbers while the text describes the exact form would
have been a real, substantive inconsistency, not a rounding issue.

**Verdict: GO, unchanged from `ToDoAugust19th.md`'s morning call, now on
firmer footing** — that morning verdict was given *despite* the Fisher
equation being explicitly unresolved; today's work is the resolution it
was waiting on. Remaining open items (align/align* LaTeX bug, the Ξ_t
formula gap, the stale A.4.2 table row above, one sentence quantifying
§C.1 for the robustness section) are all prose/bookkeeping, fixable in
parallel with writing, not prerequisites to starting it.

## B. Formulation bridges — today's new findings, for direct use in 5.x/6.x

Each item below is labelled **[expected]** where it confirms a
prediction the thesis's own theory already makes, or **[against naive
intuition]** where a reader's first-pass expectation would likely be
wrong. This distinction is deliberate per standing instruction: a
result should never be narrated as if it were expected when it isn't,
and vice versa.

### C.1 Exact vs. approximate Fisher equation — magnitude **[expected, now quantified]**

The draft (line 1300, `par:A17`) predicts the exact/approximate gap is
"invisible... to a first-order (linearised) solution but not to the
third-order solution this thesis targets." Ran `thesis_model_v3.mod`
(approximate) fresh at order=3, baseline φ=0.03, identical shock/
methodology to the headline GIRF, and compared against `v4` (exact):

| Variable | Peak GIRF gap (% of peak) |
|---|---|
| Investment | 18.9% |
| Entrepreneur net worth `Ne` | 16.0% |
| Labour | 12.4% |
| Output | 9.3% |
| `Rf`/`Rd`/`Q` | 6.5% |
| Nominal rate `r` | 5.9% |
| Inflation | 4.4% |
| Sovereign spread | 0.08% |
| Bond resilience `Hb` | ~0 (1e-14, floating-point floor) |

Steady states are identical to 11 digits (`r_ss=1.00415201983` both) —
also **[expected]**, since the appendix's own claim is specifically that
the two forms coincide *at* the non-stochastic steady state and diverge
only in the stochastic dynamics. The pattern across variables is
**[expected]** too, once noticed: the gap is large exactly where the
causal chain routes through `r`/`pi` (real/nominal core), and
~zero exactly where it doesn't (sovereign/bond block) — a structural
consistency check as much as a robustness result. **Formulation bridge**
for 6.2 or a robustness footnote: *"Re-solving the baseline calibration
with the approximate Fisher relation in place of the exact form
[eq. X] produces peak impulse responses that differ by up to 18.9%
(investment) and 16.0% (entrepreneur net worth) at the same order and
calibration, while leaving the deterministic steady state and the
sovereign-bond block (spread, $H^b$) unchanged to numerical precision —
confirming that the exact form is not a cosmetic refinement at third
order, and that its omission would have been a first-order-sized error
carried silently into a third-order solution."*

### C.2 Tail risk vs. φ — three sub-findings, three different labels

Re-solved `v4` at φ∈{0, 0.01, 0.03, 0.10, 0.20, 0.30, 0.50}, 12,000-period
simulation each (2,000 burn-in + 10,000 retained), identical shock draws
reused at every φ so differences are structural. Full series in
`explore_tailrisk_vs_phi.mat`, figure in `Fig7_TailRisk_vs_Phi.png/.fig`.

**(i) The ergodic mean shifts with φ even though the deterministic
steady state does not — [against naive intuition, though not against
perturbation theory].** `ss(y)=0.700985` at every φ tested (leverage's
steady-state target `levss=6` and the spread's closed-form C.9 are both
φ-invariant by construction, per Appendix C — confirmed already this
session). But the *simulated ergodic mean* of output rises from 0.7328
(φ=0) to 0.7350 (φ=0.03) to 0.8458 (φ=0.5) — a 15.4% rise from φ=0 to
0.5 that the steady-state table alone would never reveal. This is
unsurprising to anyone thinking in third-order-perturbation terms (the
ergodic mean carries a risk-correction term the deterministic steady
state doesn't), but it is **not** the intuition a reader comparing only
`table_steady_state.csv` across φ would form — worth an explicit
sentence in 5.2.1 or 5.4.1 warning that the steady-state comparison
*understates* how much φ matters, because it is silent on the one
channel (the mean-shift) that a purely deterministic comparison cannot
see by construction.

**(ii) Output and bank-leverage skewness move in opposite directions as
φ rises — [against naive intuition].** The natural prior, given the
whole thesis is about home bias *amplifying* downside risk, is that
skewness of the "risk-exposed" variables should move together. They
don't: output skewness rises monotonically (0.436 → 0.540 → 1.144,
φ=0→0.03→0.5) while leverage skewness *falls* monotonically
(1.129 → 1.080 → 0.114) over the same range, crossing around φ≈0.15–0.2.
**This should not be written up as a symmetric "amplification" story —
it isn't one.** A candidate mechanism, offered as a hypothesis and not
established: the output GIRF itself is sign-changing, not one-sided — a
sharp trough on impact (−0.070 at h=0, baseline φ) followed by a
smaller but longer-lived positive overshoot (peaking +0.014 around h=4,
still positive at h=5+); if φ amplifies the overshoot phase
proportionally more than the single-period trough (consistent with
`Fig9`'s finding that φ/the extension acts on the persistence as much as
the impact), more simulated mass would land in the right tail than the
left, producing positive rather than negative skew. This is a plausible
story built from the visible IRF shape, **not a decomposition that has
been formally verified** — flag it as such if it goes in the thesis, or
leave the finding unexplained rather than assert this mechanism as
fact.

**(iii) Output-at-Risk (own-mean basis) is U-shaped in φ, not monotonic
— [against naive intuition, but corroborates an already-documented
regime change].**

| φ | 0 | 0.01 | 0.03 | 0.10 | 0.20 | 0.30 | 0.50 |
|---|---|---|---|---|---|---|---|
| (mean−p5)/mean | 9.22% | 9.18% | 9.10% | 8.89% | **8.83%** | 9.81% | 17.03% |

Downside risk relative to the prevailing mean *falls slightly* from
φ=0 to φ≈0.2, then rises sharply — nearly doubling between φ=0.3 and
φ=0.5. Naive intuition says monotonic increase throughout; the data say
otherwise. Importantly, **this is not a brand-new discovery** — it
lands almost exactly where `run_thesis_model.m`'s own Figure 3 already
flags a regime change ("BEYOND-CALIBRATION... a different regime, not a
stronger version of Figure 2," driven by the documented bank-net-worth
sign-flip at high φ) and outside the range Figure 2 calls "empirically
plausible" (φ∈{1e-4, 0.03, 0.20}). **Formulation bridge:** *"The tail-risk
sweep corroborates, through an independent metric, the regime change
already documented at the point-response level (Fig. 3): within the
empirically plausible calibration range (φ≲0.20) Output-at-Risk is
essentially flat or mildly declining in φ, while beyond it the model
enters a qualitatively different regime in which tail risk accelerates
sharply. This is a reason for caution in extrapolating the headline
amplification result beyond φ≈0.20, not a reason to doubt it within that
range."* Do not present the φ=0.5 number without this caveat attached —
it would misrepresent a beyond-calibration illustration as part of the
core result.

**(iv) Spread's excess kurtosis (~24) barely moves with φ** while its
IQR and Spread-at-Risk (p95) shift only modestly — **[in line with (i)
above once stated]**: spread's steady state is φ-invariant by
construction (C.9), and apparently so, to first approximation, is the
*shape* of its tail; φ mainly operates on quantities connected to the
bank balance sheet (leverage, net worth, output) rather than re-shaping
the sovereign-spread distribution itself. Consistent with the sovereign
block's near-total insensitivity to the Fisher-equation change in §C.1
— both point to the same structural fact, that the sovereign/disaster
block and the real/banking block are only loosely coupled through this
particular channel.

### C.3 Leverage–spread ergodic joint distribution **[mixed: level shift expected, correlation drop against naive intuition]**

`Fig8_Leverage_Spread_Ergodic.png/.fig`. The point cloud of simulated
(spread, leverage) pairs shifts to visibly higher leverage at φ=0.50 vs
φ=0.03 (centred near 13–14 vs 7–8) with the same curved co-movement
shape — **[expected]**, directly consistent with (i) above. But the
linear correlation between spread and leverage *falls* as φ rises
(0.73 at φ=0.03 → 0.64 at φ=0.50) while leverage's correlation with
*output* rises sharply over the same range (0.44 → 0.74) — **[against
naive intuition]**: more sovereign exposure on the bank balance sheet
would naively suggest *tighter*, not looser, spread-leverage coupling.
Offered as hypothesis, not established: at high φ, leverage's variation
is increasingly driven by net-worth accumulation dynamics tied to the
broader business cycle (hence the rising correlation with output) and
proportionally less by the sovereign-spread channel specifically, even
though the *level* of both leverage and spread exposure is higher. This
would need a proper variance decomposition to confirm — flag as an open
question if used, not a settled explanation.

### C.4 Extension vs. no-extension core **[mostly expected direction; one exception; one methodological caveat]**

Built `IS2017_thesiscal.mod`: the original Isore-Szczerbowicz (2017)
structural equations, unmodified, with every overlapping parameter reset
to this thesis's own calibration (not the 2017 paper's original values,
which differ on `delta0, upsilon, alpha, muz, phipi, phiy, rhor, piss,
beta0` — using the paper's own numbers would have confounded the
extension effect with an independent recalibration). `Fig9_Extension_
vs_NoExtension.png/.fig` compares GIRFs to the identical shock.

**[expected]** direction of amplification, magnitude now on record:

| Variable | Peak(v4, extension) / Peak(IS2017-cal, no extension) |
|---|---|
| Consumption | 2.86x |
| Inflation | 2.65x |
| Nominal rate | 2.24x |
| Output | 1.53x |
| Labour | 1.32x |
| Investment | 0.85x |

**[against naive intuition]**: investment is the one variable the
extension *dampens* at peak (ratio 0.85). Looking at the paths, not just
the peak ratio, the story is more precise than "extension dampens
investment": the extension leaves the initial trough roughly similar in
depth but produces a much larger subsequent overshoot (+0.108 vs +0.038
at its own peak) — so the extension changes investment's dynamic
*shape* (more overshoot, not more initial contraction) rather than
uniformly amplifying it the way it does for the other five variables.
Do not report a single "extension amplifies by ~1.3-2.9x" headline
number without carving out this exception explicitly.

**Methodological caveat, quantified, not swept under the rug:** the
no-extension file inherits the *original* 2017 paper's own risk-free-
rate formula, which uses the simpler moment $\mathcal{K}(\bar\theta)=1-
\bar\theta\Delta^k$ (this thesis's own notation, Appendix C.1c) in
`Qss`'s denominator where this thesis's own more careful derivation
(Appendix C, §D0) uses $\mathcal{E}(\bar\theta)=1-\bar\theta+
\bar\theta(1-\Delta^k)^{-\gamma}$ — the appendix's own words are that
substituting one for the other "mis-prices the risk-free rate." Checked
numerically tonight: at this calibration the two moments differ by
1.61% ($\mathcal K$=0.99802 vs $\mathcal E$=1.01414), propagating to a
0.305% difference in steady-state `r`/`Q` between the two files
(`r_ss`=1.00722 no-extension vs 1.00415 extension) that has nothing to
do with the financial-accelerator extension at all. This is small next
to the 1.3–2.9x GIRF ratios above and almost certainly does not explain
them, but it means **the comparison is not perfectly clean** — a fully
rigorous isolation would rebuild `IS2017_thesiscal.mod`'s steady-state
block to use this thesis's own $\mathcal{E}$/$\mathcal{D}$/$\mathcal{K}$
convention throughout before quoting the amplification ratios as a
precise number in the thesis text. Flagged as further work, not done
tonight given the time budget; fine to cite the ratios *with this
caveat attached* in the meantime, not fine to cite them as a clean
natural experiment.

**Also discarded, not reported as a finding:** attempted the same
long-simulation tail-risk comparison for the no-extension core. It
diverges to `NaN` after ~30 periods regardless of simulated length —
traced to `theta` (a level variable with the AR(1) written in logs
*inside* the equation) being pushed negative by an unremarkable ~1.5σ
shock and then exploding through the third-order pruned polynomial, a
generic pruned-perturbation pathology, not evidence about the extension.
Confirmed it isn't "the extension prevents instability" before
discarding it: the triggering shock was ordinary in size, and the same
shock draw sequence left all seven `v4` φ-sweep points in §C.2
unaffected. No chart built on this; mentioned here only so it isn't
independently re-attempted and mistaken for a result.
