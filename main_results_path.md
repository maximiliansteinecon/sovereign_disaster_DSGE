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
