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
- [ ] **REOPENED — not actually resolved. The citation logic still holds,
      but $\Phi=5.5$ breaks Blanchard-Kahn at the high end of the
      home-bias sweep, and $\Phi=6$ will likely be worse, not better.**
      Tested $\Phi=5.5$ across the full $\phi$ sweep: baseline
      ($\phi=0.10$) and core ($\phi=0.20$) solve cleanly. $\phi=0.50$
      nominally "passes" the rank condition but with **two literal `Inf`
      eigenvalues** in the spectrum — a result I would not trust even
      though the count happens to work out. $\phi=0.80$ **fails outright**:
      8 eigenvalues $>1$ where 9 are needed, "rank condition ISN'T
      verified," hard Blanchard-Kahn error, `stoch_simul` aborts.
      **Leading hypothesis: numerical conditioning, not a new economic
      bug or a real determinacy loss** — the model already had
      huge-but-finite eigenvalues (1e16-1e20 range) at every calibration
      checked this month, flagged and accepted back on 2026-08-02; the
      progression to literal `Inf` here is erratic across $\phi$ (2.1e20
      at 0.10, 1.1e19 at 0.20, `Inf` at 0.50, `Inf` again at 0.80) rather
      than a smooth trend, which points more toward ill-conditioning
      being pushed over a floating-point edge than toward a genuine
      economic bifurcation. **Can't rule out the alternative, though**: a
      bank that is both more levered and more concentrated in one asset
      is, in a literal economic sense, closer to fragile — this could be
      a real determinacy boundary, which would actually be a legitimate
      (if inconvenient) finding, not a bug.
      **What actually matters for the thesis right now: the baseline
      result is not at risk.** $\phi=0.10$ is clean. This only threatens
      the "BEYOND-CALIBRATION ILLUSTRATION" sweep ($\phi=0.50$/$0.80$),
      which is explicitly non-core by its own label.
      **Diagnostic steps before touching the `.mod` file again** (both
      cheap, both worth doing before deciding anything):
      1. Re-run $\phi=0.80$ at the *old* `levss=4.0` to check whether this
         is new (broken by this week's leverage change) or was already
         marginal and just never got stress-tested at the extreme end of
         the sweep before.
      2. Map the actual breaking point: try $\phi=0.30/0.40/0.60/0.70$ at
         `levss=5.5` — a smooth degradation across these points would
         support the conditioning hypothesis; a sudden cliff at one
         specific value would support a genuine determinacy boundary.
      **Given 5.5 already breaks, do not move to $\Phi=6$ before this is
      understood** — higher leverage amplifies the same balance-sheet
      channel, so 6 is expected to fail at least as early in the $\phi$
      sweep as 5.5 does, likely earlier. The Coenen (2018) citation
      reasoning from before still stands on its own merits — this isn't
      about the justification being wrong, it's about whether the number
      it points to is numerically usable across the full sweep this
      thesis wants to run. Old (unresolved, superseded by the above):
      User found the NAWM~II footnote themselves (absconding rate and
      start-up funds jointly calibrated to $\Phi=6$ and a 2.17pp retail
      spread) and asked the right follow-up question — does importing
      $\Phi$ also require importing the 2.17pp spread, and moving
      `premE`/`sprL`'s citations off \textcite{Gelain2010}? **Reasoned
      answer: no.** Leverage is a pure balance-sheet-structure fact, no
      double-counting risk, transfers cleanly. The spread doesn't
      transfer, because NAWM's 2.17pp is *their* single-friction total
      (no entrepreneur layer in their model), structurally the same kind
      of object as Gelain's 200bp single-friction total — importing both
      totals and stacking them on top of each other would double-count
      the same real-world wedge twice. This is exactly the identification
      problem the existing dagger-footnote already names; the reasoning
      just needed to be applied to this specific question. Confirmed
      mechanically too: `levss` and `sprL` are already independent
      targets in the `.mod` file's own `steady_state_model` block —
      `lambdadiv` is back-solved as a function of both, so changing
      `levss` alone doesn't force `sprL` to move.
      **Action, for the user to implement:** `levss = 4.0` → `levss =
      6.0`, cite `\textcite{Coenen2018}` (joins `sigma_b`, already cited
      there — Table 2 becomes more internally grouped, not less). Leave
      `sprL`, `premE`, and the Gelain (2010) 120bp/80bp footnote
      untouched. **Est.: 2 min `.mod` edit + a re-solve (pending — verify
      `resid;`/`check;` stay clean at $\Phi=6$, same as any calibration
      change).**
- [ ] **Consequence, now scheduled rather than open-ended: re-verify the
      two-channel magnitude only after the $\Phi=6$ re-solve lands, not
      before.** Higher steady-state leverage directly scales the
      immediate channel (assets = $\lambda_t\times$ net worth), so this
      change is expected to move IRF magnitudes, not just the table. The
      existing "re-verify two-channel magnitude at final calibration"
      to-do item (carried from the 12th) now has a concrete trigger: do
      it after this specific change, since this is likely the last
      calibration-value change before that check is meaningful.
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
