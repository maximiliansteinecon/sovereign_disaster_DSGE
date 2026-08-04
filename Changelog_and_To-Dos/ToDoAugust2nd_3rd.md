# To-Do — August 2nd/3rd

Carries forward everything unresolved from `ToDoAugust1st.md` (kept
intact, not deleted — see that file, and `ToDoJuly31st.md` before it,
for full history/annotations), plus today's calibration-review findings
and a self-audit of your "completed all citation/structural fixes"
claim (partially true — corrected below, not rubber-stamped). Section 6
is the master overview you asked for: an exact, prioritized list of what
remains before the Results chapter, and before review week.

**Deadline arithmetic, corrected 2026-08-02 (user supplied the real
dates):** hand-in **2026-08-26**, defense **2026-09-02**. "Review phase,
one week before" means everything substantive — model, all results, all
writing — needs to be functionally done by **2026-08-19**, leaving
2026-08-19→26 for review/polish, then a further week (08-26→09-02) before
the defense itself. That's **17 days** from today for everything in
section 6 (revised down from an earlier, incorrect Aug-28/Aug-21
assumption — sequencing below updated accordingly).

## 1. Calibration — new findings today, highest priority (blocks the Calibration subsection)

- [x] **`psi` vs `psitilde` — genuine, unresolved notation gap between
      the `.mod` file and the thesis text.** Your EIS cross-check is
      correct as far as it goes (`psitilde=2` is indeed the calibration
      target matched to IS2017's EIS=0.5), but the thesis's own eq. 208
      defines `\psi` — the literal symbol used in the felicity function,
      identical to the `.mod` file's `psi` variable — as directly "the
      inverse of the IES." `psi` is NOT 2: it's
      `psi = 1 - (1-psitilde)/(1+varpi) = 1.3003`
      (`thesis_model_v3.mod:245`, a Gourio 2012/2014 transformation
      correcting for the consumption-leisure composite; the `.mod` file's
      own comment on that line already flags "has no counterpart in the
      thesis"). Needs: (a) `psitilde` and the transformation formula
      added to the Appendix utility section, cited to Gourio (2012);
      (b) the calibration table lists BOTH `psitilde=2` (target) and
      `psi~1.3003` (the object in the Bellman equation), with one line
      connecting them. Full detail in CHANGELOG "2026-08-02".
      *(2026-08-04 night: RECOMMENDATION DELIVERED — keep calibration
      as-is, fix the thesis text only (add psitilde + transformation to
      the Appendix, cited to Gourio 2012; list both values in the
      calibration table). See CHANGELOG "2026-08-04 (night)" item 1 for
      full reasoning. Not yet inserted into the thesis text — your call,
      per the citation-accuracy/structural-fixes boundary.)*
- [ ] **`phipi`=1.5, `phiy`=0.5 (changed from 1.6/0.4) — not
      independently verified against IS2017's own table.** These read
      like textbook Taylor (1993) values rather than a specific paper's
      estimated coefficients, and the thesis's own Taylor-rule prose
      (lines 504-539) states the functional form but cites no numbers.
      Check directly against IS2017's calibration table before finalizing.
- [x] `Deltab` 0.30->0.37 — confirmed, now matches the Cruces-Trebesch
      citation already in its own comment. No action needed.
- [x] **`sigr` — was a CRITICAL BUG, not a style choice; found and fixed
      2026-08-02.** Your "updated the MP shock in the matlab file" edit
      commented out `sigr`'s value assignment (line 222) while leaving
      `sigr` itself, and its use in the Taylor rule (`r = ... + sigr*er`,
      line 506), untouched. An unassigned Dynare parameter is NaN, and
      `NaN*er` is NaN regardless of `er`'s value — including at `er=0`,
      since `stderr 0` only makes the shock's *variance* zero, it doesn't
      stop the term from being evaluated. Result: **the model did not
      solve at all** ("steady state has NaNs or Inf", confirmed by
      running it). Root cause: conflating two different things — `sigr`
      is a structural Taylor-rule coefficient that must always have a
      value; the shock's `stderr` (already correctly 0, "off by default")
      is the actual on/off switch. Fixed by restoring `sigr = 1;`
      uncommented, with a comment explaining the distinction so this
      doesn't recur. Re-verified: solves cleanly at order=3, no NaN.
      **Optional, non-urgent nice-to-have**, no longer a blocker: convert
      `sigr` to a macro switch mirroring `PHIVAL` if you want the
      Taylor-rule scaling itself (not just the shock's stderr) to vary
      across scenarios — not needed for the "MP shock, main calibration"
      item in section 6 below, which only needs `stderr` turned on with
      `sigr` at its current fixed value of 1.
- [ ] **Citation style for the calibration section — answered, use this
      template.** You asked whether to cite Isore for everything outside
      banking/entrepreneur, or name each parameter's ultimate original
      source. Standard practice for adopting another paper's calibration
      wholesale: cite IS2017 as the proximate/operative source (you copied
      their literal numbers), and separately acknowledge the deeper
      original sources for scholarly completeness, without implying you
      recalibrated from them independently. Suggested wording:
      > "Except for the entrepreneur and banking block
      > (Appendix~\ref{sec:banking_block}), all parameters are calibrated
      > identically to \textcite{Isore2017}. Several of their targets are
      > themselves drawn from the broader macro-finance literature — most
      > notably the disaster probability and severity from
      > \textcite{Barro2006,Barro2008} — which we note where relevant,
      > while following \textcite{Isore2017}'s exact numerical values
      > throughout."
      Do NOT cite the ultimate original sources (Barro, etc.) as if you
      derived the numbers from them directly — you took IS2017's numbers,
      so IS2017 is the load-bearing citation; the others are context.

## 2. Literature review — self-audit of your "completed all" claim

Your claim does not fully hold. Re-checked line-by-line against
`ToDoAugust1st.md` section 3; corrected there directly (see that file,
section 3, entries dated 2026-08-02) rather than duplicated here. Short
version, carried forward as still open:

- [x] "Three related subbranches" (line 102) still contradicts the
      actual four-ordinal-marker structure (Primarily/Secondly/thirdly/
      Lastly, plus one unlabelled paragraph at 106). NOT fixed.
      *(2026-08-02, later same morning: CONFIRMED fixed — now reads
      "four related subbranches".)*
- [ ] Paragraph 2 (Tsai2015/Chen2023, line 104) NOT trimmed — only the
      `Gabaix2015`->`Farhi2016` key inside it was fixed. Still redundant
      with paragraph 1 if that critique still holds. Not mentioned as
      fixed in your latest update — still open.
- [x] **New issue, not previously flagged:** removing `DiTommaso2023`
      left a bare, uncited empirical claim at line 106 ("Empirical
      findings on natural disasters and sovereign credit risk support the
      idea that..."). Restore a citation or cut the claim.
      *(2026-08-02, later same morning: CONFIRMED — citation restored.)*
- [x] Everything else in that section (Gabaix2015 key, Singh2016/
      Boehm2020/Engler2016, "two layers" duplication) verified genuinely
      resolved — see `ToDoAugust1st.md` section 3 for the item-by-item
      detail.
- [ ] `.bib` entries for `Rebelo2022`, `SosaPadilla2018`, `Rannenberg2016`
      (new keys I added 2026-08-01) — not created or checked by me,
      reserved for you; will break compilation if missing.

## 2a. Literature review — new findings from the Aug 4th draft (2026-08-04 night)

You said the §1/§2 redundancy was resolved — it was, but the merge
introduced three new issues, plus one pre-existing critical error I
hadn't seen before in the new historical-context paragraph. Full detail
and proposed rewrite in CHANGELOG "2026-08-04 (night)" item 2. Priority
order:

- [x] **CRITICAL: line 91 says the thesis extends \textcite{Isore2013}
      — should be \textcite{Isore2017}.** Directly contradicts the
      `.mod` file's own header and the very next paragraph's own account
      of Isore2013 as an inferior precursor. Fix before anything else in
      the lit review.
      *(2026-08-04, later update: CONFIRMED fixed — line 91 now reads
      "\textcite{Isore2017}".)*
- [x] Paragraphs 91 and 93 now largely restate each other (the euro-crisis
      sentence is duplicated verbatim) — delete paragraph 93.
      *(2026-08-04, later update: CONFIRMED — the old duplicate paragraph
      93 is gone; the euro-crisis sentence now appears exactly once,
      inside paragraph 91.)*
- [x] "Four related subbranches" (103) no longer matches the ordinal
      markers after the redundancy merge deleted the word "Secondly" —
      restore it at the start of paragraph 105.
      *(2026-08-04, later update: CONFIRMED, via the opposite fix — the
      count was changed to "three related subbranches" instead, which now
      correctly matches the three explicit ordinals present
      (Primarily/secondly/Thirdly). The unlabelled "two layers" paragraph
      reads fine as an elaboration of branch 1 rather than a claimed 4th
      branch. Resolved.)*
- [x] Merged paragraph 103 now presents extensions (Tsai/Farhi/Chen/
      Rebelo2022) before the foundational lineage (Rietz→Barro→Gabaix→
      Gourio→Isore2017) they build on — reorder foundation-first.
      *(2026-08-04, later update: CONFIRMED — foundation (Rietz→Isore2017)
      now comes first, extensions (Tsai/Farhi/Chen/Rebelo2022) after, as
      recommended. One residual issue: the transition sentence joining
      them is a grammatical fragment — "This gap...is what this thesis
      aims to close. As more empirical arguments arised that small-
      probability, high-loss states can explain..." has no main clause
      after "As...". Needs a rewrite of that one sentence, but the
      structural reordering itself is done.)*
- [ ] New paragraph 91's historical claims (1980s Latin American debt
      crisis, 1994/95 Mexican peso crisis) are uncited; one grammatical
      fragment; four typos (longreaching/oberserved/occurence/soverrign);
      the rhetorical question is stylistically informal for a thesis.
      *(2026-08-04, later update: PARTIALLY done — the Latin-American-
      crisis sentence now has a citation (`\parencite{Ams2018}`), good.
      Still open: the Mexican peso crisis sentence remains uncited AND
      still lacks a main verb ("Further, the Mexican peso crisis...which
      resulted in...due to...which was...followed by..." never resolves
      into a complete sentence); "longreaching", "soverrign",
      "subsequentily", "occurence", "oberserved" are all still misspelled;
      "such crisis" should be "such crises"; the rhetorical question is
      unchanged; "sovereign tail risk is priced by banks" is still
      imprecise (it's priced by bondholders generally, banks only hold a
      fraction via home bias). Not ticked.)*
- [ ] Two literature branches worth adding given what the model actually
      does: Epstein-Zin/recursive-preferences literature (Epstein-Zin
      1989, Weil 1990) — never engaged despite being central to the
      transmission mechanism; safe-haven/flight-to-quality literature
      (e.g. Beber-Brandt-Kavajecz 2009) — needed to motivate the
      safe-haven finding before the Results chapter reports it.
      *(2026-08-04, later update: still not present anywhere in the
      document — not started.)*
- [x] Recency check: `Hur2026` and `AnayaLongaric2025` are unusually
      recent for an Aug 2026 thesis — confirm both are actually
      published/accessible before the defense.
      *(2026-08-05: CONFIRMED by user — both publicly available.)*
      *(2026-08-04, later update: can't verify this one from the text
      itself — still yours to check externally.)*

## 3. Model/results carryover from `ToDoAugust1st.md`

- [x] Targeted Euler-residual accuracy check of the current order-3
      solution (Fernandez-Villaverde & Levintal 2018 Table 4/5 style) —
      still not done. Folds into the methodology defense in section 6.2
      (Limitations).
      *(2026-08-04 night: ATTEMPTED, result is a documented non-result,
      not a number to cite. A genuine quadrature-based check was built
      and run; it surfaced that `simult_` restarts don't compose
      correctly across repeated calls, which — compounded through the
      SDF's steep chi~-8.3 exponents — produces a spurious 20-200%
      apparent residual. NOT evidence of a model error: fully traced to
      the diagnostic's own construction. Full reasoning in CHANGELOG
      "2026-08-04 (night)" item 3 — read it before writing 6.2.)*
      *(2026-08-04, later same night: CORRECTED — the "1-2.5% restart
      discrepancy in headline variables" conclusion directly above was
      ITSELF based on a mismatched test and overstated the problem.
      Redone properly (true continuous GIRF vs. the actual restart-based
      GIRF, at the real shockSize=0.01, columns correctly aligned):
      absolute differences of 0.0000-0.0045 percentage points — negligible.
      Separately, this exercise found and fixed a REAL bug: `simult_`
      prepends `M.maximum_lag` unchanged-initial-condition columns before
      the simulated periods, so column 1 of every existing GIRF was the
      trivially-zero pre-shock state, not the impact period (verified:
      `lev`/`Nb`/`y` all exactly 0 at column 1 in the pre-fix
      `thesis_model_results.mat`). Fixed in `run_thesis_model.m` — column
      1 is now genuinely the impact period. The "two-channel" finding's
      qualitative result is unaffected (lev moves, Nb doesn't, now
      correctly at column 1); its specific cited magnitude ("0.0148")
      should be refreshed against the current calibration when writing
      Section 5.2.2 (now reads 0.00769 — likely just the Deltab/Taylor-
      rule recalibration since 07-30, not a new problem). Bottom line: no
      evidence of an Euler-equation error anywhere in this investigation.
      Full corrected account in CHANGELOG "2026-08-04 (later same
      night)".)*
- [x] **`run_thesis_model.m`'s `spread` GIRF plotting bug — still not
      fixed.** Line 102 computes every GIRF as
      `100*(shocked-baseline)/ergodic_mean`, appropriate for level
      variables but wrong for `spread` (a rate-wedge with a near-zero
      steady state), which is why it plotted at ~100x the plausible scale
      against IS2017's own risk-premium panel. Fix before any figure goes
      in the thesis — plot `spread` (and `Rb`/`Qb` if compared directly)
      in raw annualized-bps level terms instead.
      *(2026-08-04 night: DONE — `spread`, `Rb`, `Qb` now plotted in raw
      annualized bps, all other variables unchanged. Verified: full
      driver re-run completes end-to-end, no error. See CHANGELOG
      "2026-08-04 (night)" item 4.)*
- [ ] Confirm whether IS2017's Fig. 3 ("Disaster-risky bonds, tau=0.3")
      is their headline/baseline figure or a secondary robustness variant
      — matters for how you cite the comparison in the thesis.
- [x] **NEW, found tonight: `run_thesis_model.m` GIRF off-by-one column
      bug — FIXED.** `simult_` prepends `M.maximum_lag` (=1) columns of
      unchanged initial condition before the simulated periods; every
      existing GIRF's column 1 was this trivial always-zero pre-shock
      state, not the impact period. Fixed by dropping that prefix before
      computing `R(s).girf`. Re-verified end-to-end. See CHANGELOG
      "2026-08-04 (later same night)" for the full finding.
- [ ] **Re-verify the "two-channel" finding's cited magnitude before
      writing Section 5.2.2.** The qualitative result (lev moves at
      impact, Nb doesn't) is intact and now correctly at column 1, but
      the specific number from 2026-07-30 ("lev moves 0.0148") doesn't
      match a fresh run today (0.00769) — recalibration since then
      (Deltab, Taylor rule) is the likely reason, not a bug, but confirm
      with one more run at the FINAL calibration before citing a number
      in the thesis.

## 4. Housekeeping

- [ ] Commit a checkpoint — still not done. `git status` is large;
      decide what's tracked (`.mod`/`.m`/`.md`) vs. gitignored (Dynare's
      compiled `+thesis_model_v3/` package, `.asv`, `.log`, `.DS_Store`,
      `thesis_model_v3_bisect*.mod` scratch variants). **Note:** my own
      verification runs this session left a stray `+thesis_model_v3/`
      package directory; I deleted it before this to-do was written,
      which shows as a working-tree delete of the tracked
      `+thesis_model_v3/driver.m` in `git status` — nothing is staged or
      committed, so `git checkout -- +thesis_model_v3/driver.m` restores
      it if you want it back before deciding on a `.gitignore` policy.
- [ ] **Abstract/Introduction placeholders still literally empty**:
      "We find that " and "The thesis is organised as follows " —
      verified again today, unchanged.

## 5. Calibration/Results sections — still empty

- [ ] `\subsection{Calibration}` (`secmain:calibrationandresults`) — empty.
- [ ] `\subsection{Main Results}` (`sec:results`) — empty except one
      commented-out line.

---

## 6. MASTER OVERVIEW — Results chapter roadmap (2026-08-02 → 2026-08-21)

Synthesizes `main_results_path.md`'s original tiering with today's
expanded sensitivity-analysis wishlist (which mirrors and extends
IS2017's own Appendix B robustness figures). Reusability note before the
list: every item below except 6.3.1/6.3.2 follows the SAME computational
recipe — change one calibration parameter or shock choice, re-solve,
re-run the GIRF construction already in `run_thesis_model.m`. **Build
one generic parameter-sweep driver (loop over a parameter name + value
list, calling `dynare` with the right `-D` macro each time, collecting
`R(s)` structs exactly as the existing script does) rather than seven
one-off scripts** — this is the single highest-leverage engineering step
in this whole roadmap, since it turns items 6.2 and 6.4 below into
configuration, not new code.

### Tier 1 — write first (mostly ready, de-risks the deadline immediately)

1. **5.1 Calibration table.** Transcription + justification prose; every
   number already fixed in the `.mod` file. Use the citation template
   from section 1 above. Include the `psitilde`/`psi` clarification.
2. **5.2.1 Steady-state comparison table** (phi=0 vs phi>0). Already
   computed in the `.mod` steady-state block.
3. **5.2.2 Headline disaster-risk GIRFs** (phi=0 vs phi>0 vs phi=1e-4).
   Centerpiece figure. Must include, per Appendix A.3.3's own forward
   reference: (a) the impact-period leverage-channel decomposition
   (immediate vs. lagged channel, magnitudes already computed
   2026-07-30); (b) the safe-haven sign check (already in the changelog);
   (c) the IS2017 cross-check comparison and its three findings
   (amplitude gap, spread-plotting fix, impact-period sign reversal) —
   all three need one paragraph each, not silence.
4. **6.2 Limitations/methodology.** Cheap, high-value: the
   Taylor-projection considered-and-rejected discussion (already fully
   reasoned in the changelog), the Euler-residual check (item 3 above),
   the "no realised default along the simulated path" convention and
   what it does/doesn't let you claim, and the government budget
   constraint (`T_t`) gap already self-disclosed in the `.mod` header.

### Tier 2 — sensitivity analysis (moderate work, high payoff, mostly one driver script)

All of the following are cheap once the generic sweep driver above
exists (each order=3 solve took ~15s in today's verification runs) —
the work is in choosing sensible grids and writing up what moves, not
in new computation:

5. **Home bias `phi` sweep** (phi in {0, 1e-4, 0.05, 0.10, 0.15, 0.20,
   0.25}) — already flagged in `main_results_path.md` as doubling to
   resolve the phi=0 numerical-fragility to-do item (now itself
   resolved, see `ToDoAugust1st.md` item 2 — the sweep is now purely a
   robustness/figure exercise, not also a debugging one).
   *(2026-08-05: DONE — built as standalone `phi_sweep.m` first, then
   FOLDED into `run_thesis_model.m` per instruction (project keeps
   exactly one `.mod` and one `.m` file). `run_thesis_model.m` now solves
   phi in {1e-4, 0.10, 0.20, 0.50, 0.80} ONCE each and produces THREE
   clearly separated figures from the shared results: Fig1_Headline_GIRF
   (0.10 vs 1e-4, the original headline comparison, unchanged), 
   Fig2_Core_Phi_Sweep (1e-4/0.10/0.20, the calibration-plausible range),
   and Fig3_Beyond_Calibration (0.10 vs 0.50/0.80, explicitly titled
   "BEYOND-CALIBRATION ILLUSTRATION" in the figure itself, not just in
   this to-do). Standalone `phi_sweep.m` and its old outputs deleted —
   `run_thesis_model.m` is now the single sustainable source for all
   three. Re-ran end-to-end after the merge: completes cleanly, all
   three .fig/.png pairs regenerated, `thesis_model_results.mat` now
   carries all 5 phi scenarios. Consumption/investment/spread/leverage
   are robustly monotonic in phi across the whole grid — core
   amplification claim confirmed. Output and Nb are NOT monotonic, for
   two distinct, explainable reasons (immediate-channel sign ambiguity,
   already documented in A.3.3; and the model's own self-disclosed
   no-realised-default convention making higher phi actually IMPROVE Nb
   at high phi, since bond yields mechanically rise when no haircut ever
   materializes) — this is exactly why Fig3 is kept visually and titularly
   separate from Fig2. Full account in CHANGELOG "2026-08-05". Action
   item below.)*
   - [ ] **New, from the phi sweep:** add one explicit sentence to
     Section 5.2.2 (or 6.2 Limitations) stating that the headline GIRF's
     "no realised default" convention means higher phi can IMPROVE bank
     net worth in this specific experiment (bond yields rise when no
     haircut occurs) — the lagged-erosion story only applies along a
     path with an actual default, which the headline GIRF doesn't have.
     Pre-empts an obvious examiner question. Recommend keeping phi in
     {1e-4, 0.10, 0.20} for the main amplification figure and presenting
     0.50/0.80 separately as an explicit beyond-calibration illustration,
     not further confirmation of the same monotonic story (neither value
     is empirically documented for euro-area bank home bias).
6. **Risk aversion `gamma` sensitivity** — mirrors IS2017's own Appendix
   B robustness figure directly; citeable as "replicating IS2017's own
   sensitivity analysis, extended to phi."
7. **Discount factor `beta0` magnitude sensitivity** — same pattern.
8. **Steady-state disaster probability `thetass` sensitivity** — same
   pattern; directly tests how much of the result depends on the
   calibrated disaster frequency.
9. **Disaster size `Deltak` sensitivity** — same pattern; also an
   IS2017 Appendix B item.
10. **Disaster-risk persistence `rhotheta` sensitivity** — same pattern.
11. **Price stickiness `zeta` sensitivity** — your own addition, not in
    IS2017's own appendix, but the same recipe; worth keeping since it's
    the one NK-specific friction parameter not otherwise stress-tested.
12. **Strict-inflation-targeting counterfactual** (Taylor rule with
    `phiy`=0, or another clean way of isolating the inflation-response
    leg) vs. the baseline dual-mandate rule — a policy-relevant
    counterfactual, same computational recipe.
13. **MP shock, main calibration** — once `sigr` is macro-switched
    (section 1 above), this is a one-line change: `shockName='er'`
    instead of `'etheta'`, same GIRF machinery, same calibration
    otherwise. Directly answers "does the model behave like a normal NK
    model away from disaster risk" without needing a new TFP shock (the
    substitution `main_results_path.md` already recommended).

### Tier 2b — tail-risk evidence (the word "tail" in your title needs this)

14. **5.3.1 Simulated distributions** (skewness/kurtosis) — needs a
    genuine long stochastic simulation (real shock draws, not the
    zero-shock ergodic-mean path), ~1 hour of new work, no new equations.
    Given the MP shock is now on by default (section 1), decide
    explicitly whether this simulation draws disaster-risk shocks only
    or both — an explicit modelling choice to state in the text, not an
    accident of whatever the `.mod` file happens to have active.
15. **5.3.2 Spread-at-Risk / Output-at-Risk** — free once 14 exists
    (percentiles of the same simulated series).

### Tier 3 — cut first if behind schedule

16. 5.3.3 (disaster-risk shock vs. "standard" risk-premium shock) —
    conceptually murky given this model's own structure (theta_t IS the
    risk-premium mechanism); recommend cutting entirely, as previously
    discussed, rather than rushing an unclear addition.
17. Stylised sovereign backstop / bailout mechanism — genuine new
    modelling, optional; reduce to a one-paragraph future-research note
    if time is short.

### Suggested sequencing (17 days, 2026-08-02 → 2026-08-19; corrected for the real Aug-26 hand-in / Sep-2 defense)

- **Week 1 (Aug 2-8):** close section 1 (calibration fixes — psi/psitilde
  Appendix addition, phipi/phiy check; `sigr` bug already fixed today),
  close the remaining lit-review item (paragraph-2 trim, section 2), fix
  the `spread` plotting bug (section 3), build the generic sweep driver.
  Write 5.1 (calibration table) and the Abstract/Intro placeholders once
  headline numbers exist.
- **Week 2 (Aug 9-15):** run and write up Tier 1 (5.2.1, 5.2.2 with all
  three IS2017 cross-check findings, 6.2 limitations). This is the bulk
  of the chapter and the single highest-value block of the whole roadmap.
- **Week 3, shortened (Aug 16-19):** run and write up Tier 2 sensitivity
  sweeps and Tier 2b tail-risk moments; commit a clean checkpoint
  (section 4); decide on Tier 3 items (write one paragraph each, or cut).
  Only 4 days here now instead of 6 — if Tier 2/2b is running behind by
  Aug 17, cut Tier 3 immediately rather than compressing the review week.
- **Aug 19-26:** review phase only — no new computation, no new
  sections; citation/proofreading/structural polish against a frozen
  set of results.
- **Aug 26-Sep 2:** hand-in to defense — presentation prep, anticipated
  questions (the amplitude-gap and impact-period-sign findings from the
  IS2017 cross-check are exactly the kind of thing a jury will ask about
  — have the one-paragraph answers ready, not just in the thesis text).
