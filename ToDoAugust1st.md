# To-Do — August 1st

Carries forward everything not yet resolved from `ToDoJuly31st.md`
(kept intact, not deleted — see that file for full history/annotations)
plus one new, urgent finding from today's full-document consistency
pass. Roughly in priority order.

## 1. URGENT — fix the main-text/Appendix A.3.3 contradiction

- [ ] **The Introduction's hypothesis paragraph (lines 112-114) now
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

## 2. Model / Appendix carryover (mostly done — two optional items left)

- [ ] Optional, lower priority: sanity-check the `phi=0` counterfactual's
      flagged numerical fragility (literal `Inf` and ~1e20 eigenvalues at
      that exact corner case, vs. a clean spectrum at `phi=0.10`/`0.20`)
      — e.g. try `phi=1e-4` as a smoother counterfactual, or compare
      2nd- vs 3rd-order GIRFs, if this starts to matter for the results
      chapter.
- [ ] Optional: cross-check headline GIRF magnitudes (consumption,
      investment, labour) against IS2017's own published IRFs as a final
      sanity check before drafting results.
      *(2026-08-01: scope for this item now includes a targeted
      Euler-residual accuracy check of the current order-3 solution, same
      style as Fernandez-Villaverde & Levintal (2018)'s own Table 4/5
      diagnostic -- see item 6 below for why this replaces a full
      Taylor-projection reimplementation.)*

## 3. Literature review (user taking this over personally)

**Highest priority — content gaps:**
- [ ] Add **Rebelo, Wang & Yang (2022, JoF)** — "Rare Disasters, Financial
      Development, and Sovereign Debt". Not yet present anywhere in the
      document (verified 2026-08-01).
- [ ] Add **Sosa-Padilla (2018, JME)** — "Sovereign Defaults and Banking
      Crises". Not yet present (verified 2026-08-01).
- [ ] Bring **Gennaioli, Martin & Rossi (2014, JF)** into the lit review
      prose itself — still only in the A.3.2.4 institutional footnote
      (verified 2026-08-01).
- [ ] Add **Rannenberg (2016, JMCB)** to the Banking-Sector-Frictions
      comparison — not yet present (verified 2026-08-01). Note it's now
      stronger than before: BGG + endogenous GK leverage solving together
      cleanly (2026-07-30/31) directly confirms Rannenberg's double-
      accelerator precedent applies to this exact setup.

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
