# Results Collection — living source document for the Results chapter

**Purpose.** Every verified, model-based finding relevant to the Results
chapter (Section 5 / `secmain:calibrationandresults`), collected in one
place so you can write from this instead of re-deriving or re-finding
anything scattered across the changelog. Current as of the model version
in `thesis_model_v3.mod` / `run_thesis_model.m` as of 2026-08-05.

**Maintenance rule, stated once so it governs everything below:** this
file is updated, never silently rewritten. If a later finding contradicts
an earlier entry here, and the later finding is verified factually and
substantively correct, the OLD text is struck through (~~like this~~)
with a dated note pointing to the correction — it is not deleted. If a
new finding does not survive verification, it is not added at all. Every
entry carries the changelog date it traces back to, so you can always
find the full derivation in `CHANGELOG_dynare_debug.md`.

---

## 1. Calibration facts established

- Full calibration lives in `thesis_model_v3.mod`, organized into
  Disaster Risk / Utility Function / Investment / Production / Public
  Authority / banking-entrepreneur blocks. Citation template for the
  write-up (2026-08-02): cite IS2017 as the load-bearing source for
  every parameter outside the entrepreneur/banking block, and separately
  note the deeper original sources (e.g. Barro 2006/2008 for the
  disaster probability) for scholarly completeness — do not imply
  independent recalibration from the deeper sources.
- `PHIVAL` (home bias) default = **0.10**, final (2026-08-02) — resolves
  an earlier 0.10-vs-0.20 ambiguity in favor of 0.10.
- `Deltab` (sovereign haircut) = **0.37**, matches the Cruces-Trebesch
  citation already in its own comment (2026-08-02, corrected from an
  earlier 0.30 that didn't match its own citation).
- **`psitilde`=2 vs `psi`≈1.3003 — both needed in the write-up.**
  `psitilde=2` is the calibration target matched to IS2017's reported
  inverse-EIS. The thesis's own eq. 208 `\psi` symbol (used directly in
  the Bellman equation) is NOT `psitilde` — it's the Gourio
  (2012/2014)-style transformation `psi = 1-(1-psitilde)/(1+varpi) =
  1.3003`. The calibration table needs BOTH values, with the
  transformation stated in the Appendix utility section (2026-08-04).
  Not yet inserted into the thesis text — recommendation delivered,
  insertion is yours.
- `phipi`=1.5, `phiy`=0.5 (Taylor rule) — **not yet independently
  verified against IS2017's own table** (2026-08-02/04). Open.
- `sigr` (MP shock Taylor-rule coefficient) = 1, always assigned
  regardless of whether the `er` shock itself is active (`stderr`
  controls activation, not `sigr`) — this was briefly a critical bug
  (unassigned parameter broke the steady state entirely) on 2026-08-04,
  fixed same day. Confirm this distinction is understood before touching
  either value again.

## 2. The core "two-channel" hypothesis — numerically confirmed

**Hypothesis (thesis Introduction, lines ~111-113 as of the Aug 4th
draft):** time-varying sovereign disaster risk depresses output and
tightens credit through two distinct channels — an **immediate** channel
(perceived risk via the bank's incentive constraint, operating whether
or not a default ever realizes) and a **lagged** channel (realised
default eroding bank net worth, a standard BGG-style financial
accelerator activated through bank sovereign bond holdings).

**Confirmed numerically, twice, at two different points in time:**
- 2026-07-30 (original finding, phi=0.10-ish calibration of that date):
  bank leverage (`lev`) moves at the shock's impact period while bank net
  worth (`Nb`) is exactly `0.000000` at that same period (`Nb` is
  predetermined, per its own accumulation equation — cannot respond
  within the period it's dated).
  ~~Cited magnitude: `lev` moves 0.0148 at impact.~~ **SUPERSEDED
  2026-08-04/05** — this number does not match a fresh run at the
  current (post-2026-08-02 recalibration) parameters; see below.
- 2026-08-04/05 (current calibration, after the `run_thesis_model.m`
  off-by-one column fix — see §5): at the TRUE impact period, `lev`
  moves **0.00769** while `Nb` is exactly **0.000000** — the qualitative
  finding is intact and, if anything, more cleanly confirmed (correct
  column now used); the specific magnitude has changed because the
  calibration changed (`Deltab`, Taylor rule) since 07-30, not because of
  any error. **Use 0.00769, not 0.0148, if citing a number in Section
  5.2.2** — and re-run once more at your truly final calibration before
  submission, since this number is only as final as the calibration is.

**Appendix A.3.3's own documented caveat, independently re-confirmed
twice more (2026-08-01 IS2017 cross-check, 2026-08-05 phi sweep):** the
immediate channel's sign "depends on how the shock moves the bank's
portfolio margin ... not mechanically on the direction of theta_t alone."
This is not a weakness to hide — it has now been observed consistently
across three separate numerical exercises and should be stated as a
robust, reproducible feature of the mechanism, not a one-off quirk.

## 3. Safe-haven finding (2026-08-01)

Under a pure disaster-probability increase (no realised default), the
sovereign bond price `Q^b_t = H^b_t/R^f_t` can in principle RISE rather
than fall, if the risk-free rate `R^f` falls faster than resilience `H^b`
— a flight-to-safety/safe-haven response. Checked and confirmed as a real
possibility in this model's mechanics; at the baseline calibration tested,
`Q^b` falls throughout the horizon and does not reverse (Δlog(H^b)
dominates Δlog(R^f) at every horizon tested), so the headline GIRF itself
does not exhibit it — but the mechanism is real and becomes directly
relevant at high phi (§5 below). **Lit-review gap flagged 2026-08-04, not
yet closed:** this concept has no supporting citation anywhere in the
document (e.g. Beber-Brandt-Kavajecz 2009, Krishnamurthy 2002) despite
motivating a genuine model result — needs one sentence with a citation
before the Results chapter reports it cold.

## 4. IS2017 GIRF cross-check (2026-08-01 evening; corrected 2026-08-05)

~~Compared this model's order-3 GIRF panel (baseline phi=0.10 vs
counterfactual, +0.01 disaster-risk shock) against IS2017's own Fig. 3
("Disaster-risky bonds, tau=0.3" — not confirmed whether this is their
headline/baseline figure or a secondary robustness variant; check before
citing it as "the baseline" — still open).~~ **SUPERSEDED 2026-08-05 —
IS2017's Fig. 1 ("Main scenario", EIS=0.5, zeta=0.6) is the correct
benchmark, not Fig. 3: it matches this thesis's own calibration on both
EIS and Calvo stickiness exactly, and is explicitly their headline
scenario, not a robustness variant. Re-did the comparison against Fig. 1
below; the Fig. 3 comparison's specific amplitude claim is struck out
in the next bullet.**

- ~~**Finding 1 — systematic 2-5x larger amplitude** in this model vs
  IS2017, for a matched 0.01 shock. Plausibly the banking-block's own
  amplification (consistent with, and supportive of, the thesis's
  claim) — but NOT yet distinguished from a possible deep-parameter
  calibration mismatch.~~ **SUPERSEDED 2026-08-05 — this was imprecise.**
  Redone against the correct benchmark (Fig. 1), quarter-aligned (see
  below): there is no uniform gap in either direction. Output and labour
  are actually SMALLER in our model than IS2017's; consumption and
  inflation are LARGER; investment is not a magnitude difference at all
  but a genuine SHAPE difference (see below). **Still open: verify
  gamma/psi(tilde)/tau/alpha against IS2017's own table** — now the more
  precisely-targeted next step, since the pattern is mixed rather than a
  single across-the-board multiplier.
- **Finding 2 — spread-units plotting bug. FIXED 2026-08-04.** Was
  comparing `run_thesis_model.m`'s %-of-ergodic-mean spread panel
  (mechanically ~100x too large, since spread's own steady state is near
  zero) against IS2017's raw-level risk-premium panel. Now plotted in
  raw annualized bps. Still valid, unaffected by the Fig.1/Fig.3
  correction above.
- **Finding 3 — counterintuitive impact-period sign**: the near-zero-
  home-bias counterfactual showed a DEEPER trough than the phi=0.10
  baseline in several variables at impact — the opposite of naive
  "less exposure = less amplification" intuition. Re-confirmed and fully
  explained by the phi sweep (§5): this is the immediate channel's
  documented sign-ambiguity (§2), now observed a third time. Still valid.

### 4a. Corrected cross-check against IS2017 Fig. 1 (2026-08-05)

**First, a labelling subtlety worth understanding before reading the
table:** IS2017's own Fig. 1 shows every single panel — including static
ones like `beta(theta)` — at EXACTLY zero at their labelled "period 1",
with the true response only appearing at their "period 2". This is the
same "leading pre-shock reference column" that `run_thesis_model.m`'s
raw `simult_` output has (§6/CHANGELOG 2026-08-04); IS2017's own
plotting evidently never trims it either. Our own `R(s).girf` data
(post-2026-08-04 fix) does NOT carry this leading column — our "quarter
0" already is the true first response. So the correct comparison is
**our quarter 0 vs. their period 2**, not quarter-label-for-quarter-label.
(The exported figures now cosmetically re-add the zero point for direct
visual comparability — see CHANGELOG 2026-08-05 — but the underlying data
used below is the un-padded, analysis-correct version.)

| variable | IS2017 Fig.1, their period 2 (approx., read off the figure) | ours, quarter 0, phi=0.10 (exact) | ratio |
|---|---|---|---|
| `beta(theta)` | ~0.97e-3 | 0.9663e-3 | ~1.00x — near-exact match, strong confirmation the alignment above is right |
| output | ~-0.024 | -0.0204 | ~0.85x (smaller) |
| labour | ~-0.024 | -0.0098 | ~0.41x (well under half) |
| consumption | ~-0.014 | -0.0418 | ~3.0x (larger) |
| inflation | ~-0.011 | -0.0254 | ~2.3x (larger) |
| investment | dips to ~-0.065 first, recovers to +0.033 by period 4-5 | **positive throughout — no initial dip at all** (+0.073 rising to +0.138) | shape difference, not a magnitude one |

**Bottom line: mixed, not uniform, and the investment shape difference
is the one that most needs an explanation.** Working, NOT YET CONFIRMED
hypothesis: IS2017 has no banking/entrepreneur block, so their investment
is a textbook Tobin's-Q object; ours is additionally financed through the
entrepreneur's leverage constraint and bank credit supply (BGG +
endogenous GK), which could structurally prevent the first-period
contraction IS2017 get from pure precautionary saving. Plausible, not
demonstrated — don't write this into the thesis as settled without
checking the sign of the initial credit-supply response directly (`Qtob`,
`QS`). The output/labour/consumption/inflation magnitude differences may
simply be the still-open calibration-parameter check (gamma, psi(tilde),
tau, alpha vs. IS2017's table) rather than anything structural.

## 5. Phi sensitivity sweep (2026-08-05)

Solved phi in {1e-4, 0.10, 0.20, 0.50, 0.80}, order-3 pruning, in
`run_thesis_model.m` (folded in from a standalone `phi_sweep.m` the same
day — one `.m` file, three figures from shared results, no redundant
solves). Outputs: `Fig1_Headline_GIRF`, `Fig2_Core_Phi_Sweep`,
`Fig3_Beyond_Calibration` (`.fig`/`.png` each), `thesis_model_results.mat`.

- **Robustly monotonic in phi across the ENTIRE grid:** consumption,
  investment, sovereign spread, bank leverage. This is the evidence base
  for the thesis's core amplification claim, and it holds well beyond
  just the calibrated point — use `Fig2_Core_Phi_Sweep`
  (phi=1e-4/0.10/0.20, the empirically plausible range matching the
  euro-area home-bias literature) as the supporting figure.
- **NOT monotonic: output and bank net worth (`Nb`).** Both explained,
  neither a bug:
  1. Output's impact-period sign is not ordered in phi — direct further
     confirmation of §2's documented sign-ambiguity, now observed a
     fourth time across independent checks.
  2. `Nb`'s loss actually SHRINKS as phi rises from 1e-4 to 0.2, then
     reverses to a net GAIN by phi=0.5-0.8. Mechanical cause, verified
     directly: `Rb` (realised bond return) is positive and large at
     every phi tested, because this model's GIRF has **no realised
     default along the simulated path** (`x_t=1` never fires — a
     limitation the `.mod` file already self-discloses). A bond whose
     price fell but which never actually defaults mechanically pays a
     HIGHER yield next period; a bank holding more such bonds (higher
     phi) captures more of that pickup, which increasingly offsets, and
     at phi=0.5-0.8 outright reverses, the funding-cost pressure that
     would otherwise erode `Nb`.
- **Consequence for the write-up, not yet actioned:** add one explicit
  sentence (Section 5.2.2 or 6.2) stating that the no-realised-default
  convention means higher phi can IMPROVE bank net worth in this specific
  experiment — the lagged-erosion story in the hypothesis is correctly
  scoped to require an actual default, which the headline GIRF doesn't
  have. Present phi=0.50/0.80 (`Fig3_Beyond_Calibration`) as an explicit,
  clearly-labelled beyond-calibration illustration of this limit
  behaviour, not as a stronger version of the phi=0.10/0.20 amplification
  story — neither value is empirically documented for euro-area bank
  sovereign exposure.

## 6. Solution-method accuracy

- **Taylor projection (Fernandez-Villaverde & Levintal 2018) — considered
  and rejected (2026-08-01).** Their own footnote 1 credits IS2017's
  detrending-invariance construction (the same Gourio trick this thesis
  uses throughout) with pre-empting the specific perturbation-accuracy
  failure their method targets. Reimplementing it was judged out of scope
  given the timeline; recommended as a cited, considered-and-rejected
  alternative in 6.2 instead.
- **Euler-residual accuracy check — a genuine methodological dead end,
  resolved honestly, not with a fabricated number (2026-08-04).** A
  quadrature-based check against the household SDF equation initially
  returned implausible 20-200% "residuals." Root cause fully diagnosed:
  NOT a model error — `simult_` restarts (repeated calls from an
  intermediate point) don't compose correctly across calls, and this
  small artifact gets exponentiated through the SDF's steep curvature
  (chi≈-8.3). Properly controlled test (true continuous simulation vs.
  the actual restart-based GIRF construction, at the real calibrated
  shock size) shows agreement to within 0.0000-0.0045 percentage points —
  negligible. **Recommended Limitations-section wording:** report this
  restart-discrepancy check itself as the accuracy disclosure, explicitly
  declining a full Euler-residual reimplementation for the same
  cost/benefit reason Taylor projection was declined. Do not attempt to
  produce an Euler-residual number by other means without re-reading the
  full diagnosis in CHANGELOG "2026-08-04" first — it is easy to
  reconstruct the same false alarm.
- **A real bug WAS found and fixed in the process:** `run_thesis_model.m`
  had an off-by-one column error — `simult_` prepends `M.maximum_lag`
  columns of unchanged initial condition before the simulated periods, so
  column 1 of every GIRF (prior to 2026-08-04) was the trivial, always-
  exactly-zero pre-shock state, not the impact period. Fixed; all figures
  in this document reflect the corrected version.

## 7. Open items blocking a fully "done" Results chapter

(Full detail and priority order in `ToDoAugust2nd_3rd.md` — this is a
pointer list, not a duplicate.)
- `phipi`/`phiy` vs. IS2017's own table — unverified.
- IS2017 Fig. 3 baseline-vs-robustness-variant status — unverified.
- Two-channel magnitude — re-confirm at truly final calibration before
  citing 0.00769 in the write-up.
- The no-realised-default caveat on `Nb` vs. phi — not yet written into
  the thesis text.
- Safe-haven literature citation — not yet added.
- Calibration table's `psitilde`/`psi` clarification — not yet inserted.
- Abstract/Introduction placeholders and the Calibration/Main Results
  subsections themselves are still empty in the thesis text.
