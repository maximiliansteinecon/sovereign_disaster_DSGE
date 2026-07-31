# To-Do — July 31st

Picking up from a long July 30th session: the Blanchard-Kahn failure is
resolved (BGG + endogenous Gertler-Karadi leverage, both scenarios
verified end-to-end), and the Appendix A review is in progress. This
list folds in everything open from today's chat plus the senior lit-review
critique (`ToDoJuly30th.md`), roughly in priority order.

## 1. Model / Appendix A (carrying over from today)

- [ ] Finish your own edits 1-3 in Appendix A (paragraph after eq. A.3.2.3
      re: fixed vs. endogenous λ_t; eq. A.3.2.5 timing R^d_t → R^d_{t-1};
      eq. A.5.4 + companion prose λ → λ_t).
- [ ] **Decide how to handle the perceived-risk-channel finding** (see
      CHANGELOG, "2026-07-30 — Appendix A review... numerical test"
      section, just added). The propagation-chain paragraph at the end of
      A.3.3 currently claims the mechanism works through realised default
      only — this is now demonstrated numerically false. There's already
      a commented-out sentence in Appendix A describing the correct
      (lagged, mark-to-market) channel; a *second*, immediate channel via
      endogenous leverage now also exists. Recommend rewriting that
      paragraph to describe both channels rather than deleting the
      finding to preserve the old claim — but this is your call on
      framing since it touches the thesis's core narrative.
- [x] Once Appendix A is settled, move to **Appendix B** (Stationarization)
      review — same process: equation-by-equation against the .mod file,
      confirm/flag, only rewrite what's verified. Note: B.21 (leverage
      constraint) currently still shows fixed λ — needs the same
      λ → λ_t treatment as A.3.2.3/A.5.4.
      *(2026-08-01: done — B.21a-B.21d inserted and verified verbatim
      against the .mod file; table row fixed.)*
- [x] Then **Appendix C** (Non-Stochastic Steady State) — same process.
      Section D8 ("Bank Block") is the one most affected by the
      endogenous-leverage derivation; D7 ("Entrepreneur Block") should be
      unaffected (BGG reinstated verbatim).
      *(2026-08-01: review done — D7 confirmed unaffected as anticipated;
      D8 surfaced a genuine open question, see CHANGELOG "2026-08-01 —
      Appendix C review" section: eq. C.33-C.35's "bond term = 0 exactly"
      claim uses a different R^b convention than eq. C.31/C.32 and the
      .mod file both actually use. NOT resolved — needs your decision.)*
- [ ] Optional, lower priority: sanity-check the `phi=0` counterfactual's
      flagged numerical fragility (literal `Inf` and ~1e20 eigenvalues at
      that exact corner case, vs. a clean spectrum at `phi=0.10`/`0.20`)
      — e.g. try `phi=1e-4` as a smoother counterfactual, or compare
      2nd- vs 3rd-order GIRFs, if this starts to matter for the results
      chapter.
- [ ] Optional: cross-check headline GIRF magnitudes (consumption,
      investment, labour) against IS2017's own published IRFs as a final
      sanity check before drafting results.

## 2. Literature review (from `ToDoJuly30th.md` — senior review, July 29th draft)

**Highest priority — content gaps:**
- [ ] Restore/rewrite the financial-accelerator-channel sentence (currently
      commented out) — and note it now needs to describe **two** channels
      given item 1 above (immediate perceived-risk-via-leverage +
      lagged realised-loss-via-net-worth), not the original single
      "activates only upon realised default" framing.
- [ ] Add **Rebelo, Wang & Yang (2022, JoF)** — "Rare Disasters, Financial
      Development, and Sovereign Debt" — closest existing paper combining
      rare-disaster pricing with sovereign debt; not citing it invites the
      question of whether you know it.
- [ ] Add **Sosa-Padilla (2018, JME)** — "Sovereign Defaults and Banking
      Crises" — closest existing quantitative precedent to your locked
      mechanism (banks exposed to sovereign debt, default triggers credit
      contraction via bank balance sheets).
- [ ] Bring **Gennaioli, Martin & Rossi (2014, JF)** into the lit review
      prose itself, not just the A.3.2.4 institutional footnote.
- [ ] Add **Rannenberg (2016, JMCB)** to the Banking-Sector-Frictions
      comparison — and note this is now stronger than before: today's
      session *numerically validated* that BGG + endogenous GK leverage
      solve together cleanly, directly confirming Rannenberg's
      double-accelerator precedent applies to your setup, not just citing
      it as a hypothetical.

**Structural fixes:**
- [ ] Fix "three subbranches" (line 1) vs. four actual transitions —
      either fold the Tsai/Gabaix/Chen paragraph into paragraph 1, or
      relabel as four.
- [ ] Trim paragraph 2 (Tsai/Gabaix/Chen) — currently redundant with
      paragraph 1's Gabaix (2012) point; either sharpen into a real
      argument (e.g. re: calibrating θ_t to a historical panel) or cut.
- [ ] Consolidate the "two layers" framing (asset-pricing vs. economic
      layer) — introduced twice, generically then thesis-specifically;
      state it once, in your own terms.

**Citation accuracy:**
- [ ] Fix key: `Gabaix2015` → this is actually Farhi & Gabaix (2016, QJE)
      — rename to `FarhiGabaix2016` or `Farhi2016`.
- [ ] Fix typo: `Gouriroux2021` → `Gourieroux2021`.
- [ ] Add directionality caveat for `Singh2016` and `Boehm2020` — both
      document bank→sovereign causality; your model is sovereign→bank
      only. Needs one sentence acknowledging the loop is empirically
      bidirectional and why you model one leg (reuse the Gertler2010
      interbank-irrelevance logic already in the Banking-Sector-Frictions
      section).
- [ ] Resolve `Engler2016` mechanism mismatch — its transmission runs
      through interbank collateral, not direct balance-sheet erosion,
      which contradicts your own later argument that interbank mechanisms
      are "structurally irrelevant." Either drop it here or flag it as a
      related-but-distinct channel.
- [ ] Add scope clarifier for `DiTommaso2023`/`ECB2023FSR` — both are
      climate-specific; your θ_t/Δᵏ process is generic Barro-Rietz-Gabaix,
      not climate risk. One clarifying clause needed, not a deletion.

## 3. Housekeeping

- [ ] `git status` shows two deleted-but-unstaged files from before this
      session started (`thesis_model.mod`, `thesis_model_ent+bank_channel_v1.mod`)
      — worth a conscious decision (restore, or confirm intentional and
      commit the deletion) rather than leaving them dangling.
- [ ] Consider committing today's work (BK resolution + BGG/GK decision)
      as a checkpoint before starting Appendix B/C — it's a natural,
      substantial, self-contained milestone.
