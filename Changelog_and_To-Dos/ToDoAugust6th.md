# To-Do — August 6th

Carries forward everything unresolved from `ToDoAugust2nd_3rd_4th.md`
(kept intact, not deleted — see that file, and everything before it, for
full history/annotations). Aug 5th was literature-review-only, per your
own account, so section 1 below is new; everything else is carried
forward, re-checked against the new Aug 6th draft where the rewrite
touched it, and left as-is where it didn't.

**Deadline arithmetic, recomputed today:** hand-in **2026-08-26**,
defense **2026-09-02**. Everything substantive needs to be functionally
done by **2026-08-19** (review week starts then). That's **13 days**
from today — down from 17 on Aug 2nd. Section 5 (the master roadmap) is
almost entirely still open; the clock is the main thing that's changed
since it was written.

## 1. Literature review — critical assessment of the Aug 6th rewrite (re-verified against the actual text, not just recalled)

**Overall: a genuine, substantial improvement.** "Four related
subbranches" now actually matches four explicit ordinals (Primarily/
secondly/Thirdly/Lastly) — the count that bounced between three and four
across three prior versions looks settled. The new Epstein-Zin branch
(§1f below) closes a real gap flagged 2026-08-04. The Mexican peso crisis
sentence is now a complete, cited, accurate sentence. The rhetorical
question is gone. Credit where due — but the following are real, and
re-verified line-by-line against the file, not just remembered:

- [ ] **MUST FIX: line 91 is a literal leftover editorial note, live in
      the compiled text.** `Implement a Scenario Narrative?` has no `%`
      in front of it — confirmed by direct grep, this line has zero
      comment markers. If compiled as-is, this sentence fragment appears
      in the actual PDF, first thing in your Introduction.
- [ ] **MUST FIX: Battistini2014/Brutti2015 described twice, three lines
      apart, saying the same thing.** Confirmed verbatim: line 115
      ("...tightly linked during the euro crisis... cross-border
      exposures significantly transmit shocks in sovereign premia") and
      line 118 ("...tightly linked during the euro crisis... cross-border
      bank exposures to sovereign debt significantly transmit shocks in
      sovereign premia") are the same two papers, the same two findings,
      stated twice. Almost certainly a bridge sentence added before
      branch 2 without removing branch 2's own opening restatement — cut
      one.
- [ ] **MUST FIX: redundant sentence at the end of paragraph 105.**
      Confirmed verbatim, back-to-back: "...retained a constant disaster
      probability and therefore could not generate time-varying risk
      premia or business-cycle fluctuations driven by shifts in perceived
      risk. This entire first wave kept modelling a constant disaster
      probability, for which it could match the average level of the
      equity premium and the risk-free rate, but by construction could
      not generate time-varying risk premia or business-cycle
      fluctuations driven by shifts in perceived risk." Same claim,
      twice. Cut one.
- [ ] **Decide, don't let it regress silently: `DiTommaso2023`'s
      scope-clarifier sentence (fixed 2026-08-02) is now commented out**
      (line 113, confirmed `%`-prefixed). Not live in the document. May
      be an intentional cut given the new structure doesn't need it, but
      make it a conscious choice.
- [ ] Still open, unaffected by this rewrite (confirmed still present):
      "such crisis... they do not realise... their probability of
      **ocurrence**" (line 93) — singular/plural mismatch plus a
      misspelling of "occurrence" (one 'c' short this time — same
      underlying typo survives edits, just moves around).
- [ ] Still open: "sovereign tail risk is **priced by banks**" (line 93)
      — still imprecise; it's priced by bondholders generally via the
      SDF/bond-pricing equation, banks only hold a home-biased share.
- [ ] **Citation-verification risk list — six new/reintroduced keys need
      `.bib` entries**, confirmed each appears exactly once in the text
      (no accidental duplication, so this is just a "does the entry
      exist" check): `Mishkin1999`, `Ams2018`, `Berkman2011`,
      `Manela2017`, `Epstein1989`, `Weil1990`. On top of the
      already-flagged `Rebelo2022`, `SosaPadilla2018`, `Rannenberg2016`.
- [ ] **Specific claims added this rewrite that I cannot verify from
      memory and that carry real citation-accuracy risk if wrong** —
      not asserted as errors, flagged as needing your own check against
      the primary sources: Tsai2015 specifically covering "violations of
      the expectations hypothesis in bond pricing" and "the implied
      volatility skew in option markets"; Chen2023's "news-based" index
      and "discount-rate channel" attribution; Berkman2011's precise
      count ("447 international political crises... 1918-2006" — a very
      specific, easily-checked number); Epstein1989 "nesting the static
      CAPM" specifically (confident it nests standard expected utility;
      less sure about the static-CAPM framing).
- [ ] **The one substantive (not editorial) issue — needs your actual
      judgment, not just a copyedit.** The new Epstein-Zin paragraph's
      closing claim (whether a rise in disaster risk raises or lowers
      consumption/investment depends on EIS above/below unity) is almost
      certainly about **steady-state comparative statics**. It sits
      immediately before your hypothesis paragraph, which invites a
      reader to connect it to the GIRF's actual impulse-response
      dynamics — but IS2017's own Fig. 1 (EIS=0.5, matching yours) shows
      investment **dipping negative first**, not moving in one direction
      throughout the horizon. If this sentence is meant to explain the
      GIRF shape, say so explicitly and reconcile it with the actual
      dip; if it's steady-state-only, keep it but don't let it sit where
      a reader will conflate the two objects. This is about the
      hypothesis's own theoretical grounding, not a typo.
- [ ] Minor precision note, not urgent: "this thesis inherits [the
      EZ-Weil separation] through the banking and entrepreneur blocks"
      (line 138) arguably has the causal direction backwards — EZ
      preferences generate the household SDF that the banking/
      entrepreneur blocks' own conditions are then expressed through, not
      the reverse. Worth a wording tighten, not a hard error.
- [ ] **Note, not an action item:** `$\tilde\psi$` now appears in the
      calibration table (`\tilde\psi = 2`, "inverse EIS (EIS=0.5)"),
      per your own Aug 6th draft (calibration section not otherwise
      reviewed today, per instruction). This is a good start on the
      psi-vs-psitilde to-do item from 2026-08-04, but doesn't close it by
      itself — the Appendix still needs the `psi = 1-(1-psitilde)/(1+varpi)`
      transformation formula and its own explicit `psi~1.3003` entry
      alongside it, or a reader will see `\tilde\psi=2` in the table and
      reasonably expect that same symbol in the Bellman equation, where
      the actual object is `psi`, not `psitilde`.

## 2. Calibration — carried forward, unverified today per your instruction

- [ ] `phipi`=1.5, `phiy`=0.5 — still not independently verified against
      IS2017's own table. Now visible in your own calibration table as
      "standard Taylor-type rule" (no IS2017 citation for the specific
      numbers) — worth resolving before you finalize this section, since
      you're about to write it.
- [ ] Citation-style template (2026-08-02) — delivered, not yet
      confirmed as used, since the calibration table's Source column
      wording is now your own draft. Quick sanity check when you're
      done: does the table's own footnote track the "IS2017 as proximate
      source, deeper sources as context" framing already agreed? (At a
      glance, yes — the footnote already says almost exactly this.)

## 3. Model/results — carried forward, unchanged since 2026-08-05

- [ ] Investigate the investment shape difference (IS2017 dips negative
      first, ours doesn't at any phi tested) — working hypothesis
      (BGG+banking credit-supply channel) not yet confirmed; check the
      sign of `Qtob`/`QS`'s own initial response before writing this into
      the thesis as an explanation. **This is now directly connected to
      the new Epstein-Zin paragraph's EIS-sign claim above — resolving
      one will likely inform the other.**
- [ ] Sharpened gamma/psi(tilde)/tau/alpha-vs-IS2017 calibration check —
      still the best-motivated explanation for the mixed (not uniform)
      output/labour/consumption/inflation magnitude differences found
      2026-08-05.
- [ ] Re-verify the two-channel finding's cited magnitude (currently
      0.00769, not the stale 0.0148) against your truly final calibration
      before writing Section 5.2.2.
- [ ] Add the explicit "no realised default" sentence to 5.2.2/6.2 (from
      the phi-sweep finding, 2026-08-05) — bank net worth can IMPROVE with
      phi in this specific experiment; needs one sentence before the
      Results chapter reports it.
- [ ] Safe-haven/flight-to-quality literature citation (e.g.
      Beber-Brandt-Kavajecz 2009) — still not added anywhere; needed to
      motivate the safe-haven finding before the Results chapter reports
      it cold. (Epstein-Zin literature gap is now closed, per §1 above —
      this is the other half of the original 2026-08-04 pairing, still
      open.)

## 4. Sections still empty / in progress

- [x] `\subsection{Calibration}` — NOT empty as of the Aug 6th draft;
      populated with a full calibration table. (Verified today, in the
      course of locating the literature review — not otherwise reviewed,
      per your instruction. You're about to work on this next.)
- [ ] `\subsection{Main Results}` — still empty except one commented-out
      line.
- [ ] Abstract/Introduction placeholders ("We find that ", "The thesis is
      organised as follows ") — still literally empty, confirmed again
      today.

---

## 5. MASTER OVERVIEW — Results chapter roadmap (unchanged in substance since 2026-08-02/05, clock updated)

Full detail in `ToDoAugust2nd_3rd_4th.md` §6 — reproduced here in
compressed form since it's still the operative plan and almost entirely
still open. Only item 5 (phi sweep) is done.

**Tier 1 — write first:**
1. 5.1 Calibration table — in progress (see §4 above).
2. 5.2.1 Steady-state comparison table (phi=0 vs phi>0) — ready, not written.
3. 5.2.2 Headline GIRFs — ready, not written. Must include the two-channel
   decomposition, the safe-haven check, and all three (now four, with
   the investment-shape finding) IS2017 cross-check findings.
4. 6.2 Limitations — ready, not written. Taylor-projection rejection,
   Euler-residual/restart-discrepancy disclosure, no-realised-default
   convention, government budget constraint gap.

**Tier 2 — sensitivity sweeps (one driver script, mostly done via the
phi-sweep infrastructure already in `run_thesis_model.m`):** gamma,
beta0, thetass, Deltak, rhotheta, zeta sensitivities; strict-inflation-
targeting counterfactual; MP-shock-alone scenario. None run yet except phi.

**Tier 2b — tail-risk evidence:** long stochastic simulation for
skewness/kurtosis (5.3.1), Spread-at-Risk/Output-at-Risk (5.3.2). Not
started — this is the part of the roadmap that actually earns the word
"tail" in your title; don't let it slip given the tightening clock.

**Tier 3 — cut first if behind:** 5.3.3 (recommend cutting entirely, per
2026-08-02 reasoning), stylised sovereign backstop (reduce to a paragraph
if short on time).

**Sequencing, recomputed for 13 days (2026-08-06 → 2026-08-19):**
- **Aug 6-9:** close §1's must-fix items above (cheap, mechanical);
  finish the calibration section you're about to start; write the
  Abstract/Intro placeholders once headline numbers exist.
- **Aug 10-15:** Tier 1 in full (5.1 table writeup, 5.2.1, 5.2.2 with all
  four cross-check findings, 6.2). This is still the single highest-value
  block and the bulk of the chapter.
- **Aug 16-19:** Tier 2 sweeps + Tier 2b tail moments; commit a checkpoint;
  cut Tier 3 immediately if running behind rather than compressing the
  review week.
- **Aug 19-26:** review phase only.
- **Aug 26-Sep 2:** hand-in to defense prep.
