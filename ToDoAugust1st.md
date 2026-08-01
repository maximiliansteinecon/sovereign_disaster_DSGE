# To-Do — August 1st

Carries forward everything not yet resolved from `ToDoJuly31st.md`
(kept intact, not deleted — see that file for full history/annotations)
plus one new, urgent finding from today's full-document consistency
pass. Roughly in priority order.

## 1. URGENT — fix the main-text/Appendix A.3.3 contradiction

- [x] **The Introduction's hypothesis paragraph (lines 112-114) now
      directly contradicts Appendix A.3.3.** Restoring the commented-out
      "financial accelerator channel activates only upon a realised
      default" sentence fixed the literature-review critique's complaint
      about a missing hypothesis-half, but reintroduced the exact claim
      that was numerically falsified on 2026-07-30 and that Appendix
      A.3.3 was correctly rewritten to contradict (the "Immediate
      channel: perceived risk via the bank's incentive constraint"
      paragraph, which is present "even along a sample path on which
      x_t=1 never realizes"). Rewrite lines 112-114 to state both
      channels, mirroring the A.3.3 language — this is a single-paragraph
      fix, but it is the most examiner-visible inconsistency in the
      document right now and should be closed before anything else.
      *(2026-08-01 evening: VERIFIED RESOLVED — the rewritten paragraph
      (now lines 112-115) states both channels using A.3.3's own
      language almost verbatim. See CHANGELOG "2026-08-01 (evening)"
      entry for the side-by-side comparison. One cosmetic nit only: a
      stray leading space in `\textit{ lagged financial accelerator
      channel}` on line 115.)*

## 2. Model / Appendix carryover (mostly done — two optional items left)

- [x] Optional, lower priority: sanity-check the `phi=0` counterfactual's
      flagged numerical fragility (literal `Inf` and ~1e20 eigenvalues at
      that exact corner case, vs. a clean spectrum at `phi=0.10`/`0.20`)
      — e.g. try `phi=1e-4` as a smoother counterfactual, or compare
      2nd- vs 3rd-order GIRFs, if this starts to matter for the results
      chapter.
      *(2026-08-01 evening: DONE — `run_thesis_model.m`'s counterfactual
      scenario switched from `-DPHIVAL=0` to `-DPHIVAL=1e-4`
      (`thesis_model_v3.mod`'s comment updated to match). Verified at
      order=1 that the φ=1e-4 eigenvalue spectrum (1 Inf, 3 finite
      eigenvalues ~1e17) is structurally identical to the validated
      φ=0.10 baseline, vs. the genuinely degenerate exact-φ=0 spectrum
      (2 Inf, 2 finite eigenvalues reaching ~1e18-3e20). Also re-verified
      solving cleanly at order=3/pruning (the actual thesis target), no
      BK error, no NaN. Full table in CHANGELOG. NOTE: also found, as a
      side effect of checking `git diff`, that `thesis_model_v3.mod`'s
      `PHIVAL` default has been changed by you from 0.20 to **0.10** —
      this resolves `main_results_path.md` §0's open calibration
      question in favor of 0.10, assuming that was a deliberate,
      final decision and not an incidental edit. Flag if not.)*
- [x] Optional: cross-check headline GIRF magnitudes (consumption,
      investment, labour) against IS2017's own published IRFs as a final
      sanity check before drafting results.
      *(2026-08-01: scope for this item now includes a targeted
      Euler-residual accuracy check of the current order-3 solution, same
      style as Fernandez-Villaverde & Levintal (2018)'s own Table 4/5
      diagnostic -- see item 6 below for why this replaces a full
      Taylor-projection reimplementation.)*
      *(2026-08-01 evening: DONE -- compared your own order=3 GIRF panel
      against IS2017 Fig. 3 ("Disaster-risky bonds, tau=0.3", their
      p.109) screenshot-to-screenshot. Sign/timing/shape match closely
      across every common variable (beta(theta), output, consumption,
      investment, labour, inflation, nominal rate). THREE findings, full
      detail in CHANGELOG "2026-08-01 (evening) -- IS2017 cross-check":
      (a) a systematic 2-5x larger amplitude in your model across all
      real variables for a nominally matched 0.01 shock -- plausibly the
      banking-block amplification the thesis claims, but NOT yet
      distinguished from a possible deep-parameter calibration mismatch;
      check gamma/psi/theta-bar/rho_theta against their table before
      claiming this as the amplification result; (b) the "Sovereign
      spread" panel (peak~1.0) vs. their "Risk Premium" panel
      (peak~2.3e-6) is almost certainly a PLOTTING UNITS BUG, not a real
      100,000x discrepancy -- `run_thesis_model.m` normalizes every GIRF
      by its own ergodic mean, which is fine for levels but blows up a
      small rate-wedge variable like `spread` whose own steady state is
      near zero; fix by plotting `spread` in raw bps, not %-of-mean,
      before this goes in the thesis; (c) at t=0-1 the phi=1e-4
      counterfactual shows a DEEPER trough than the phi=0.10 baseline in
      output/consumption/labour/inflation/nominal-rate -- the opposite of
      naive "less exposure = less amplification" intuition, though
      consistent with A.3.3's own documented ambiguous-sign caveat on the
      immediate channel. Needs one explicit sentence in
      Section~\ref{sec:results}, not left implicit. NOT independently
      confirmed: whether IS2017's Fig. 3 (a "tau=0.3" robustness variant)
      is truly their headline/baseline figure vs. a secondary scenario --
      check their own labelling before calling it "the baseline" in your
      text.)*

## 3. Literature review (user taking this over personally)

**Highest priority — content gaps:**
- [x] Add **Rebelo, Wang & Yang (2022, JoF)** — "Rare Disasters, Financial
      Development, and Sovereign Debt". Not yet present anywhere in the
      document (verified 2026-08-01).
      *(2026-08-01 evening: added — two sentences inserted into the
      paragraph 104 rare-disaster/sovereign-literature paragraph,
      contrasting Rebelo's default-decision focus with this thesis's
      continuous-pricing focus. Citation key used: `Rebelo2022` —
      confirm/add the actual `.bib` entry, not yet verified to exist.)*
- [x] Add **Sosa-Padilla (2018, JME)** — "Sovereign Defaults and Banking
      Crises". Not yet present (verified 2026-08-01).
      *(2026-08-01 evening: added — one sentence appended to the
      Bocola2016 paragraph (108), framed as complementary quantitative
      corroboration rather than a structural building block, mirroring
      the existing Bocola2016 contrast logic. Citation key
      `SosaPadilla2018` — `.bib` entry not yet verified.)*
- [x] Bring **Gennaioli, Martin & Rossi (2014, JF)** into the lit review
      prose itself — still only in the A.3.2.4 institutional footnote
      (verified 2026-08-01).
      *(2026-08-01 evening: added — one sentence appended to the same
      Bocola2016/SosaPadilla2018 paragraph (108), as the cross-country
      theoretical counterpart; the pre-existing A.3.2.4 footnote citation
      (line 1414) is untouched and now redundant-but-harmless with the
      main-text mention.)*
- [x] Add **Rannenberg (2016, JMCB)** to the Banking-Sector-Frictions
      comparison — not yet present (verified 2026-08-01). Note it's now
      stronger than before: BGG + endogenous GK leverage solving together
      cleanly (2026-07-30/31) directly confirms Rannenberg's double-
      accelerator precedent applies to this exact setup.
      *(2026-08-01 evening: added — new paragraph inserted immediately
      before the "Having evaluated the available frameworks..." concluding
      sentence of the Banking-Sector-Frictions section (123), explicitly
      naming the verified joint BK solve as confirmation the double-
      accelerator precedent extends to this setup. Citation key
      `Rannenberg2016` — `.bib` entry not yet verified.)*

**Note on all four above:** content and placement only — citation-key
`.bib` entries were NOT created or checked (outside this task's scope,
and you've reserved citation accuracy for yourself). Please verify
`Rebelo2022`, `SosaPadilla2018`, `Gennaioli2014` (already used elsewhere,
so likely fine), and `Rannenberg2016` all resolve to real `.bib` keys
before compiling.

**Structural fixes:**
- [ ] Fix "three subbranches" (line 1) vs. four actual transitions.
- [ ] Trim paragraph 2 (Tsai/Gabaix/Chen) — redundant with paragraph 1.
- [ ] Consolidate the "two layers" framing (introduced twice).

**Citation accuracy:**
- [x] ~~Fix typo: `Gouriroux2021` → `Gourieroux2021`~~ — verified fixed
      2026-08-01.
- [ ] Fix key: `Gabaix2015` → Farhi & Gabaix (2016, QJE); rename to
      `FarhiGabaix2016` or `Farhi2016`. Not yet done (verified 2026-08-01).
- [ ] Directionality caveat for `Singh2016`/`Boehm2020` — both now marked
      `!!!` in the text (your own in-progress flag), not yet resolved.
- [ ] `Engler2016` mechanism mismatch — also marked `!!!`, not yet
      resolved.
- [ ] Scope clarifier for `DiTommaso2023`/`ECB2023FSR` (climate-specific
      vs. generic disaster process).

## 4. Housekeeping

- [x] ~~Two deleted-but-unstaged files (`thesis_model.mod`,
      `thesis_model_ent+bank_channel_v1.mod`)~~ — verified 2026-08-01, no
      longer appear in `git status`, resolved.
- [ ] Commit a checkpoint. `git status` currently shows a large set of
      uncommitted changes to tracked files (`thesis_model_v3.mod`,
      `run_thesis_model.m`, `ToDoJuly31st.md`, `+thesis_model_v3/driver.m`)
      plus many untracked files (Dynare-generated `+thesis_model_v3/`
      MATLAB function directory, `.asv`/`.log` autosave/log files,
      `thesis_model_v3_bisect*.mod` scratch variants, `.DS_Store`,
      `thesis_model_results.mat`, `girf_disaster.fig`). Worth deciding
      what belongs in version control (the `.mod`/`.m`/`.md` files,
      certainly) versus what should be `.gitignore`d (Dynare's compiled
      `+thesis_model_v3/` output, `.asv`, `.log`, `.DS_Store` — these
      regenerate on every run and don't need tracking).

## 5. Bigger picture — not yet started, needed before results can be
   written up

- [ ] **Abstract/Introduction placeholders**: "We find that " and "The
      thesis is organised as follows " are still literally empty
      sentences with nothing following (verified 2026-08-01).
- [ ] **Calibration subsection** (main text, `secmain:calibrationandresults`)
      is empty.
- [ ] **Main Results subsection** (`sec:results`) is empty — one
      commented-out line, nothing else. This is where the GIRF plots,
      the impact-period leverage-channel decomposition, the safe-haven
      sign check, and the calibration table all need to actually be
      written up with numbers and interpretation, not just exist as
      Dynare output sitting in `.mat`/`.fig` files.

## 6. Solution method: Taylor projection — evaluated, CLOSED

- [x] **Taylor projection (Fernandez-Villaverde & Levintal 2018) evaluated
      as an alternative to order-3 Dynare perturbation.** Read the full
      paper (2026-08-01, late). Recommendation: do NOT reimplement.
      Their own footnote 1 credits Isore-Szczerbowicz (2017)'s
      detrending-invariance construction — the same Gourio trick this
      thesis uses throughout — with pre-empting the specific failure mode
      (discrete disaster realization breaking perturbation's local
      accuracy) their paper is built to solve. Full reasoning in
      CHANGELOG "2026-08-01 (late) — Taylor projection... NOT
      recommended". Two concrete, low-cost follow-ups instead (folded
      into item 2's GIRF cross-check above, not new scope):
      (a) cite FV&Levintal (2018) explicitly in the thesis as a
      considered-and-rejected alternative, using the footnote-1 argument
      as a pre-emptive methodological defense;
      (b) a targeted Euler-residual accuracy check of the current order-3
      solution (their own Table 4/5 diagnostic style) as evidence for
      that defense.
