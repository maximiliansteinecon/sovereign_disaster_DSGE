# To-Do — July 31st

Picking up from a long July 30th session: the Blanchard-Kahn failure is
resolved (BGG + endogenous Gertler-Karadi leverage, both scenarios
verified end-to-end), and the Appendix A review is in progress. This
list folds in everything open from today's chat plus the senior lit-review
critique (`ToDoJuly30th.md`), roughly in priority order.

## 1. Model / Appendix A (carrying over from today)

- [x] Finish your own edits 1-3 in Appendix A (paragraph after eq. A.3.2.3
      re: fixed vs. endogenous λ_t; eq. A.3.2.5 timing R^d_t → R^d_{t-1};
      eq. A.5.4 + companion prose λ → λ_t).
      *(2026-08-01: verified — all three confirmed correctly applied:
      A.3.2.3 now reads "uses an endogenous λ_t"; A.3.2.5 uses R^d_{t-1}
      throughout; A.5.4's equation and its companion prose sentence both
      now use λ_t.)*
- [x] **Decide how to handle the perceived-risk-channel finding** (see
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
      *(2026-08-01: verified — Appendix A.3.3 now has two clearly
      separated paragraphs, "Immediate channel: perceived risk via the
      bank's incentive constraint" and "Lagged channel: realised default
      via bank net worth," plus a closing synthesis paragraph correctly
      noting N^b_t is predetermined and cannot respond within the period,
      and linking back to Isoré-Szczerbowicz (2017)'s own perceived-risk
      finding. Accurately reflects the numerical result. Nothing further
      needed here except reporting the actual magnitude in the Results
      section, per the paragraph's own forward reference.)*
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
      D8 surfaced a genuine open question (eq. C.33-C.35's "bond term = 0
      exactly" claim used a different R^b convention than eq. C.31/C.32
      and the .mod file both actually use) — DECIDED: fix the thesis text,
      not the .mod file, since the realised-return convention is the
      internally consistent one (see CHANGELOG "2026-08-01 (continued) —
      DECISION" section for full reasoning + verified comparative
      statics). LaTeX replacement for the "Value-function coefficients"
      paragraph through eq. C.35 provided to the user; NOT YET inserted
      into the thesis file. `.mod` file re-verified to still solve
      cleanly at phi=0.1 specifically, order=1 and order=3/pruning, since
      it is unchanged by this decision.)*
- [x] Optional, lower priority: sanity-check the `phi=0` counterfactual's
      flagged numerical fragility (literal `Inf` and ~1e20 eigenvalues at
      that exact corner case, vs. a clean spectrum at `phi=0.10`/`0.20`)
      — e.g. try `phi=1e-4` as a smoother counterfactual, or compare
      2nd- vs 3rd-order GIRFs, if this starts to matter for the results
      chapter.
      *(2026-08-01 evening: done — see `ToDoAugust1st.md` item 2 / this
      date's CHANGELOG entry for the numerical verification.)*
- [x] Optional: cross-check headline GIRF magnitudes (consumption,
      investment, labour) against IS2017's own published IRFs as a final
      sanity check before drafting results.

## 2. Literature review (from `ToDoJuly30th.md` — senior review, July 29th draft)

**Highest priority — content gaps:**
- [x] Restore/rewrite the financial-accelerator-channel sentence (currently
      commented out) — and note it now needs to describe **two** channels
      given item 1 above (immediate perceived-risk-via-leverage +
      lagged realised-loss-via-net-worth), not the original single
      "activates only upon realised default" framing.
      *(2026-08-01: PARTIALLY done, and now a CRITICAL issue — the
      sentence was restored/uncommented in the main-text hypothesis
      paragraph (lines 112-114), but using the OLD single-channel
      "activates only upon a realised default" wording, NOT the corrected
      two-channel version. This now DIRECTLY CONTRADICTS Appendix A.3.3's
      own (correctly revised) two-channel description a few pages later.
      See CHANGELOG "2026-08-01 — critical consistency finding" and
      `ToDoAugust1st.md` item 1 — this is the single most urgent open
      item in the whole document right now.)*
      *(2026-08-01 evening: RESOLVED — rewritten to state both channels,
      verified against Appendix A.3.3 word-for-word. See CHANGELOG
      "2026-08-01 (evening)" entry and `ToDoAugust1st.md` item 1.)*
- [x] Add **Rebelo, Wang & Yang (2022, JoF)** — "Rare Disasters, Financial
      Development, and Sovereign Debt" — closest existing paper combining
      rare-disaster pricing with sovereign debt; not citing it invites the
      question of whether you know it.
      *(2026-08-01 evening: done — see `ToDoAugust1st.md` item 3.)*
- [x] Add **Sosa-Padilla (2018, JME)** — "Sovereign Defaults and Banking
      Crises" — closest existing quantitative precedent to your locked
      mechanism (banks exposed to sovereign debt, default triggers credit
      contraction via bank balance sheets).
      *(2026-08-01 evening: done — see `ToDoAugust1st.md` item 3.)*
- [x] Bring **Gennaioli, Martin & Rossi (2014, JF)** into the lit review
      prose itself, not just the A.3.2.4 institutional footnote.
      *(2026-08-01 evening: done — see `ToDoAugust1st.md` item 3.)*
- [x] Add **Rannenberg (2016, JMCB)** to the Banking-Sector-Frictions
      comparison — and note this is now stronger than before: today's
      session *numerically validated* that BGG + endogenous GK leverage
      solve together cleanly, directly confirming Rannenberg's
      double-accelerator precedent applies to your setup, not just citing
      it as a hypothetical.
      *(2026-08-01 evening: done — see `ToDoAugust1st.md` item 3.)*

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
- [x] Fix typo: `Gouriroux2021` → `Gourieroux2021`.
      *(2026-08-01: verified fixed.)*
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

*(2026-08-01 note: `Engler2016`, `Singh2016`, `Boehm2020` are now marked
with "!!!" directly in the citation text — looks like your own in-progress
flags, not yet resolved. `Rebelo2022`, `SosaPadilla2018`, `Rannenberg2016`,
and the `Gabaix2015` key fix are not yet present anywhere in the document.
`Gennaioli2014` is still only in the A.3.2.4 footnote, not in the lit
review prose. Carried to `ToDoAugust1st.md`.)*

## 3. Housekeeping

- [x] `git status` shows two deleted-but-unstaged files from before this
      session started (`thesis_model.mod`, `thesis_model_ent+bank_channel_v1.mod`)
      — worth a conscious decision (restore, or confirm intentional and
      commit the deletion) rather than leaving them dangling.
      *(2026-08-01: verified — no longer appear in `git status` at all,
      resolved somewhere along the way.)*
- [ ] Consider committing today's work (BK resolution + BGG/GK decision)
      as a checkpoint before starting Appendix B/C — it's a natural,
      substantial, self-contained milestone.
