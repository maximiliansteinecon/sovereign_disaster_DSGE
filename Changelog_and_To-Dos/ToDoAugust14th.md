# To-Do — August 14th

Starts fresh rather than appending to `ToDoAugust13th14th.md` (kept as the
record of the 13th/14th overnight session — label-canonicalization, Part
5/6 cuts, the calibration gap-finding). This file is forward-looking:
tonight's integrity check (psi/psitilde, leverage=4, the "DIVERGENCE"
comment, the real-dynamics verdict) resolved three of four worries and
sets up tomorrow's main task.

**Deadline arithmetic:** hand-in 2026-08-26, defense 2026-09-02. **12
days** away.

## 0. Tonight's integrity check — verdicts, for the record

- [x] **`psi = 1 - (1-psitilde)/(1+varpi)` is correct; fix the text, not
      the `.mod`.** Independently re-derived the logic tonight (not just
      re-read the Aug-2/Aug-4 changelog entries, though they already had
      the right answer): differentiating the felicity function
      $[C_t(1-L_t)^\varpi]^{1-\psi}$ shows the *effective* curvature on
      consumption alone is a $\varpi$-scaled function of the *targeted*
      inverse-EIS — this is structurally the right kind of correction for
      a CES consumption-leisure aggregator under Epstein-Zin, not an ad
      hoc fix. **Still true, and worth restating: I have not verified
      this exact split appears in Gourio (2012) itself**, only that the
      `.mod` file's own comment attributes it there and the transformation
      is mathematically sensible on its own terms — a direct check of
      Gourio's own preference section is the one thing that would make
      this fully airtight, otherwise cite it as "this thesis's own
      Gourio-consistent transformation" rather than claiming Gourio states
      it verbatim.
- [ ] **Action: add `psitilde` and this formula to wherever the felicity
      function is introduced, and list both `psitilde=2` (target,
      \textcite{Isore2017}) and `psi≈1.3003` (derived) in Table 1.**
      **Est.: 20 min**, text and table together.
- [ ] **Leverage target $\Phi=4$: genuinely no citation, and I couldn't
      hand you one tonight.** Traced its origin: it's inherited from an
      older version of the model where leverage was a fixed parameter
      called `lam`, preserved as the endogenous mechanism's target so the
      rest of the steady state wouldn't need re-deriving — a sound
      *engineering* reason, not an economic one. Searched for
      Gertler-Karadi (2011)'s own leverage target to see if 4 already
      matches their baseline; the search surfaced their parameter *names*
      (ξ pins leverage) but not the actual number from their Table 1 —
      inconclusive, would need someone to actually open that table.
      **Three honest paths, your call:** (a) find GK (2011)'s real number
      and adopt/cite it directly if it's close to 4; (b) if it isn't, or
      you'd rather not re-calibrate this late, write one honest sentence
      instead of a citation — something like *"the target leverage ratio
      of 4 is retained from this model's earlier development for
      numerical continuity, within the range considered in the
      Gertler-Karadi lineage"* — true, defensible, doesn't overclaim; (c)
      recalibrate to NAWM II's Φ=6, which you already cite elsewhere in
      this exact section, for a document that's internally consistent on
      one benchmark rather than two unexplained numbers. I'd lean (b)
      unless (a) turns out to be quick. **Est.: (a) 10 min to check the
      GK paper's actual table; (b) 10 min, no `.mod` change; (c) 15 min +
      a re-solve.**
- [x] **The "(27) BANK NET WORTH -- DIVERGENCE from thesis B.24" comment
      is resolved, not a live bug — verified tonight, term by term,
      against the actual current Appendix B text (not just the `.mod`
      file's own claims about itself).** Read the real Stationarization
      appendix directly: `B.23` is genuinely the bank net worth equation
      (matches the `.mod`'s `Nb` equation term for term — $\sigma^b$,
      $\Gamma_t^{-1}$, both excess-return brackets, $\iota$, all present
      and in the right places) and `B.24` is genuinely "Resilience and
      SDF loading" (also matches the `.mod`'s `Hb` equation exactly, once
      you confirm `Ecal` $=\mathcal{E}(\theta_t)=1+\theta_t[(1-\Delta^k)^{-\gamma}-1]$,
      which it does). The comment is a historical note — inserting the
      "Endogenous Leverage Multiplier" block (B.21a-d) shifted every
      subsequent equation's number by four slots relative to whatever
      earlier draft the `.mod` comment was first written against, and
      your past self correctly caught and documented the shift at the
      time. Not something that needs fixing; it needs nothing.
      **Worth doing anyway tomorrow, though, precisely because this
      pattern exists: check whether any *other* `(B.xx)` comment in the
      `.mod` file's model block has the same kind of stale numbering
      (unlikely to be a formula bug like this one wasn't, but cheap to
      rule out systematically while doing the full pass).**
- [x] **Verdict on "is this actually dynamic or hard-coded": genuinely
      dynamic, standard practice, no red flags.** `stoch_simul(order=3,
      pruning, ...)` is Dynare's real perturbation solver — third-order
      with pruning (Andreasen et al.) is a standard, published choice for
      exactly this kind of model, where the risk premium is invisible
      below second order. The changelog history (which I read in full
      tonight, not skimmed) shows a real Blanchard-Kahn failure that got
      properly root-caused — a fixed leverage parameter over-determining
      the system by one degree — and fixed by deriving leverage
      endogenously from the bank's own incentive constraint, verified
      with `resid;` (exact zero, all equations), `check;` (clean rank
      condition, 9 forward-looking variables), and `stoch_simul` actually
      completing at order 3 for multiple calibrations. You don't hit — or
      need to fix — a Blanchard-Kahn failure in a hard-coded/fake system.
      This is what real DSGE debugging looks like.
- [x] **The changelog's endogenous-leverage derivation is already where
      it needs to be — no action needed.** Checked: the "Endogenous
      Leverage Multiplier" paragraph already sits in Appendix B
      (Stationarization → Banking Block, right after the B.20/B.21
      equations), and it already contains the real derivation ($\eta^b_t$,
      $\nu^b_t$, $\Omega^b_t$, $\lambda_t$, eqs. B.21a-d) — not a stub, an
      actual writeup, consistent with the changelog's own derivation.
      This must have happened at some point this week and I hadn't
      registered it — good, one less thing to port over.

## 1. Tomorrow's main task: the line-by-line `.mod`-vs-equations check

This is the real ask. Suggested order, given tonight's findings — start
where the risk is highest, not top-to-bottom mechanically:

1. **Entrepreneur and Banking block first** (dynamic eqs ~20-31,
   appendix B.15-B.26) — the block that changed most this week
   (`chie`, `sigma_e`, `phi` all moved) and the one tonight's spot-check
   already partially covered. Extend the same term-by-term method used
   tonight for eqs (27)/(29) to the rest: (25) home-bias, (26)/(26a-d)
   leverage block, (28) balance sheet, (30) bond price, (31) bond return.
2. **Household/SDF and Firms blocks next** — haven't been touched by
   this week's calibration changes, lower risk, but "120% sure" means
   checking them anyway, not assuming.
3. **Public Authority and market clearing last** — shortest block, lowest
   complexity.
4. **While in there:** note every `(B.xx)`/`(D.x)` comment tag and
   confirm it still points at the right equation in the current, current-
   numbered appendix text (per the pattern found tonight) — cheap to do
   in the same pass, not a separate task.

Not time-boxing this one in minutes — you asked for 120% certainty, that
means as long as it actually takes, not a rushed estimate.

## 2. Carried forward, unchanged, from `ToDoAugust13th14th.md`

Everything not resolved above is still open there: the Taylor Rule
paragraph's unclear new sentence ("enformecemt"), the lagged-channel
sentence's fourth-pass wording, the three main-text derivation cuts in
`main_writing.md` Part 6. None of these block tomorrow's check — they're
independent, do them whenever.
