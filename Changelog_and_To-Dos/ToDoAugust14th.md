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

## 0b. Update, next morning (Aug 15): $\Phi=6$ tested across the sweep — reversing the recommendation

User ran $\phi \in \{1e{-4}, 0.03, 0.20, 0.30, 0.50\}$ at `levss=6` (the
value I recommended) and posted `thesis_model_v3.log` in full. Read all
five scenarios' complete eigenvalue lists and steady states, not just the
pass/fail lines.

**Finding: `Inf` eigenvalues show up at $\Phi=6$ even at $\phi=1e{-4}$ —
essentially phi-independent, not a high-home-bias phenomenon.** Full
pattern across the five runs: $\phi=1e{-4}$ one `Inf`; $\phi=0.03$ one
`Inf`; $\phi=0.20$ one `Inf`; $\phi=0.30$ **zero** `Inf` (clean, largest
finite eigenvalue $\approx2.1\times10^{21}$); $\phi=0.50$ **two** `Inf`.
That's not a monotonic trend in $\phi$ — it disappears at 0.30 and comes
back doubled at 0.50. A genuine economic determinacy boundary tied to
home-bias would show a smooth trend as $\phi$ rises; this erratic,
appears-disappears-reappears pattern is a signature of floating-point
overflow in an already near-singular linearization, not a real
bifurcation. Every one of these five runs still nominally "passes" (9
eigenvalues $>1$ for 9 forward-looking variables, rank condition
verified) — Dynare counts `Inf` as trivially `>1`, so the pass/fail line
alone would have missed this entirely.

**Reversing yesterday's recommendation: do not adopt $\Phi=6$ as
currently implemented.** The `Inf` eigenvalues aren't confined to the
"beyond-calibration" illustrative extreme this time — they show up in the
**counterfactual and baseline scenarios**, the ones the thesis's actual
headline results depend on. Even where the rank condition nominally
holds, I would not trust `stoch_simul`'s policy-function coefficients
when the underlying eigenvalue spectrum is already at the edge of
double-precision overflow — "passes the count" is not the same as
"numerically trustworthy."

**Working hypothesis for the mechanism** (labelled as a hypothesis, not
verified by actually running the Jacobian myself): the endogenous-leverage
block is a forward-looking recursive loop — `OmB` depends on
contemporaneous `etaB`/`nuB`, which themselves depend on `OmB(+1)` — and
`levss` enters directly as a multiplier inside that loop
(`OmB = (1-sigma_b) + sigma_b*(etaB*lev + nuB)`). Raising `levss` scales
up the loop's own feedback gain directly. This block didn't exist in this
form before the endogenous-leverage fix, and $\Phi=4$ (the old target)
never showed an `Inf` eigenvalue in any check this month — consistent
with a conditioning problem that scales with leverage itself, not with
$\phi$.

**Recommendation:**
- [ ] Test intermediate leverage values (4.5, 5.0) at a couple of $\phi$
      points (0.03 and 0.30, since those bracket the values already run)
      to find where `Inf` first appears. If 5.0 is clean, that's a real,
      usable middle ground — closer to euro-area evidence than 4.0
      without the overflow risk.
- [ ] If even modest increases above 4.0 introduce `Inf` eigenvalues, the
      honest-continuity framing from the 14th's original list (keep
      $\Phi=4$, one sentence about retaining it for numerical continuity
      rather than claiming NAWM parity) becomes the *safer* choice, not
      just the fallback — 4.0 is the only value confirmed clean across
      the entire $\phi$ sweep tested so far.
- [ ] Either way, this now belongs on the line-by-line check's list
      below: if a leverage value near 6 is kept for any scenario, the
      endogenous-leverage block (eqs. 26/26a-d) is where to look first
      for the actual source of the near-singularity, not just accept
      that it "passes."
- [x] Not urgent, but worth remembering: even $\Phi=4$'s "no Inf" claim
      was only ever checked at $\phi\in\{0.10,0\}$ historically, per the
      2026-07-29 changelog entry — not against this same five-point
      sweep. Worth re-confirming 4.0 stays clean at $\phi=0.30/0.50$ too,
      for a genuine apples-to-apples comparison rather than assuming it
      because it worked before. **This is now the single most important
      pending test — see below.**

## 0c. Update, same morning: $\Phi=5$ tested — does not fix it

User ran the same five-point $\phi$ sweep at `levss=5`. Same erratic
pattern, not resolved by the smaller step: $\phi=1e{-4}$ one `Inf` (plus
a $1.8\times10^{22}$ finite eigenvalue); $\phi=0.03$ one `Inf`;
$\phi=0.20$ **zero** `Inf` (the clean point moved from 0.30 at $\Phi=6$ to
0.20 at $\Phi=5$ — further evidence this is noise, not a stable
threshold); $\phi=0.30$ one `Inf`; $\phi=0.50$ two `Inf`. Steady-state
values otherwise look sane (no sign flips, no NaN, `etaB`/`nuB`/`lambdadiv`
all small positive numbers as expected) — this is specifically an
eigenvalue/linearization phenomenon, not a corrupted steady state.

**Conclusion: this is not a $\Phi=6$-specific problem, and dropping to 5
doesn't buy safety.** Whatever is causing the near-singularity is present
already at $\Phi=5$, just as unpredictably.

**Confound worth naming explicitly: $\Phi=4$'s historical "no Inf" result
was never checked under this week's full current calibration.** It was
verified clean back in July/early August, under the *old* `chie=0.05`,
`sigma_e=0.975`, and the old default $\phi$-baseline. Since then `chie`
(→0.0276), `sigma_e` (→0.9769), and the baseline $\phi$ (→0.03) have all
changed too. Right now there is no clean comparison — "4 was fine, 5/6
aren't" could mean leverage is the culprit, or it could mean the
combination of this week's *other* changes plus any leverage above 4 is
what's fragile. Can't tell which from what's been run so far.

**The one test that actually resolves this: `levss=4` under TODAY's full
current calibration, across the same five-point $\phi$ sweep.** Two
outcomes:
- **Clean** → confirms leverage specifically is the mechanism (matches
  the forward-looking-loop hypothesis in §0b); adopt $\Phi=4$ with the
  honest-continuity sentence, stop searching for a higher clean value —
  given even 5 is already unstable, the safe margin above 4 is evidently
  thin, and chasing it further has a poor time/benefit ratio with 11 days
  to hand-in.
- **Not clean** → the instability predates this specific leverage
  question and is coming from somewhere else changed this week (`chie`,
  `sigma_e`, or an interaction) — a different, more open-ended
  investigation, priority for tomorrow's line-by-line pass regardless.

## 0d. Update, same morning: the control test ran — leverage is exonerated

User re-ran `levss=4` (the old, previously-clean value) under today's
*otherwise-unchanged* current calibration, across `\phi \in
\{1e{-4}, 0.03, 0.20, 0.30, 0.80\}` (added 0.80 back in, the original
trigger). Confirmed via the steady-state block in each scenario
(`lev = 4`, not a leftover from a prior run).

**Result: the instability is present at `levss=4` too.** `Inf`
eigenvalues at $\phi=1e{-4}$ (one), $\phi=0.03$ (one), $\phi=0.20$
(**two**), $\phi=0.80$ (two) — clean only at $\phi=0.30$, the same
"one random point is fine" pattern as every leverage value tested so
far. **This settles the question from §0c: leverage was never the
mechanism.** Reverting it doesn't fix anything, because it was never
broken by the leverage change in the first place.

**New, additional red flag at $\phi=0.80$, independent of the eigenvalue
question: the pruned ergodic mean of `lev` itself is 19.8, against a
calibration target of 4 — nearly 5x off.** That's not just a numerical
labelling curiosity; it means the dynamic system, even where Dynare
reports the rank condition as "verified," is producing simulated paths
where bank leverage runs nearly five times its steady-state target. I
would not trust *any* moment reported for $\phi=0.80$ under the current
calibration, independent of what's causing the `Inf` eigenvalues
elsewhere — this scenario looks broken on its own terms, not just fragile
in the linearization.

**Since leverage is exonerated, the cause has to be something else
changed this week — most likely `chie` (0.05→0.0276, a large
proportional move) or `sigma_e` (0.975→0.9769), the two entrepreneur-block
parameters that moved alongside leverage.** The earlier NAWM-II "standard
NK" swap (`delta0`/`alpha`/`upsilon`/`muz`/`piss`/`rhor`) predates when
the $\phi$-sweep last worked cleanly (it's what Fig1-3 were generated
under), so it's a much weaker suspect on timing alone — not ruled out,
just lower priority.

- [ ] **Next diagnostic, single run: revert `chie` to 0.05 AND `sigma_e`
      to 0.975 together (leverage can stay at 4), same five-to-six-point
      $\phi$ sweep.** If clean, the culprit is in that pair — a second,
      quick run reverting only one of the two isolates which. If *still*
      not clean, the cause is elsewhere (the NK-parameter swap, or an
      interaction not yet considered) and this becomes a genuine
      broader-scope investigation, not a two-parameter bisection.
- [ ] Separately, regardless of what the bisection finds: **$\phi=0.80$
      may need to be dropped from the beyond-calibration illustration
      outright**, given the 19.8-vs-4 leverage-mean finding — this isn't
      necessarily fixable by finding the right parameter, it may just be
      too extreme a corner for this model's numerics to represent
      reliably, and that's a fine, honest thing to say in a footnote
      rather than force.

**On "when can I start Results": one more diagnostic round, not "tomorrow"
as I said yesterday — walking that back.** Yesterday's premise (leverage
is the mechanism) turned out to be wrong; today's finding narrows the
search but doesn't close it yet. The bisection above is still a bounded,
mechanical test — a day, not a redesign — but I'm not going to repeat a
specific date until the actual cause is confirmed, since I was wrong
about the timeline once already today on less complete information. Run the control test above
first thing. If it comes back clean, the leverage question is closed
(revert to 4, done, no further debugging) and Results can plausibly start
once that's confirmed — realistically tomorrow. If it doesn't come back
clean, say so honestly rather than guessing a date — it means the
fragility is structural to something this week changed beyond leverage,
and needs isolating before any results are trustworthy, since Results
draws directly on the counterfactual and baseline scenarios this
instability already touches.

## 0e. Update, same morning: ran the full bisection myself — every calibration hypothesis eliminated, one real bug found and fixed, one strong structural lead identified

User asked me to write the diagnostic into `run_thesis_model.m` and authorized me to run it directly (MATLAB + Dynare via `arch -x86_64`). Did four things, in order:

- [x] **Found and fixed a real, separate bug while setting this up:**
      `run_thesis_model.m`'s `scen` list had the "Baseline (\phi=0.03)" row
      labelled 0.03 but passing `-DPHIVAL=0.10` to Dynare. **Every
      "Baseline" scenario in every log this week has silently been
      running $\phi=0.10$, not 0.03.** Fixed to pass `-DPHIVAL=0.03`,
      matching the label and the `.mod` file's own default. This also
      means yesterday's "reverting chie/sigma_e halved the problem"
      finding was really about $\phi=0.10$ all along, not 0.03 — noted
      for the record, doesn't change today's conclusions since both were
      retested explicitly below.
- [x] **Ran a 6-point diagnostic** ($\phi=0.10,0.02,0.025,0.028,0.03,0.033$)
      at the current full calibration (`chie=0.0276`, `sigma_e=0.9769`,
      `levss=4`). Result: `Inf` eigenvalues at every point except
      $\phi=0.025$. Crucially, **the true $\phi=0.10$ — the historically
      "clean" reference point — now shows an `Inf` eigenvalue too**,
      under today's full calibration. This directly contradicts the
      2026-08-02 "3.6e18, no Inf" result at the same nominal $\phi$.
- [x] **Ran the NK-parameter-reversion test** (temporarily set
      `delta0/alpha/upsilon/muz/piss/rhor` back to their pre-NAWM-swap
      IS2017 values, `.mod` backed up first, restored after): $\phi=0.10$
      and $\phi=0.03$ **both still show `Inf`** — two apiece, if anything
      worse than with the current NK values. **This rules out the
      NAWM-II parameter swap as the cause.** Combined with yesterday's
      leverage tests (4, 5, 5.5, 6 all affected) and the chie/sigma_e
      bisection (old and new values both affected), **every calibration
      change made this week is now individually exonerated.** None of
      them, alone or reverted, is the mechanism.
- [x] **Ran an order=1 vs order=3 comparison** at $\phi\in\{0.10,0.03,0.20,0.50\}$,
      current full calibration. **At order=1, both $\phi=0.10$ and
      $\phi=0.03$ are clean — no `Inf` anywhere.** ($\phi=0.20$ and
      $\phi=0.50$ still show `Inf` even at order=1, so it isn't a clean
      "order=1 always fine" story either, but the two points that matter
      most — baseline and the historical reference — are both resolved at
      order=1.) **This is the sharpest finding today: the problem is
      specific to the third-order derivative computation, not the
      model's underlying linear/BK structure.** The steady state and the
      first-order dynamics are sound at the calibration that matters;
      something in how Dynare computes *third*-order derivatives for a
      specific term is where the near-singularity lives.

**Bonus context, found while reading the current `.mod` file rather than
from a test:** the file already documents a related, previously-fixed
issue in the SDF equation (eq. 4) — the raw `v(+1)^(-chi)` term was left
unscaled even after `CE` was rescaled, and with $v_{ss}$ large and
$\chi\approx-8.3$, this alone produced derivatives of order $10^{16}$.
Already rewritten as `(v(+1)/STEADY_STATE(v))^(-chi)`, an exact identity
with an $O(1)$ derivative at steady state. **This fix was already in
place throughout every test run today** — meaning it isn't what's
generating the *current* `Inf` eigenvalues (those persisted with the fix
already applied), but it's exactly the right template for finding the
remaining one: some other power-function term, most likely still inside
the Epstein-Zin `CE`/`Dcal`/`Ecal`/`v` auxiliary block or the
`OmB`/`etaB`/`nuB`/`lev` endogenous-leverage block, is raised to a large
exponent without first being normalised by its own steady state, and the
*third*-derivative of that un-normalised term is what's blowing up.

**Recommended next step, and it's a structural fix, not another
calibration test:** search the same two blocks for any `X^(something)`
or `X^chi`/`X^psi`/`X^gamma`-type term that is NOT already written as
`(X/STEADY_STATE(X))^(...)`, the same pattern already applied to `v`.
The `CE`/`Dcal`/`Ecal` cluster is the most likely remaining candidate,
given it's the direct sibling of the term already fixed and shares the
same `chi` exponent. This is now a code-reading task, not a guess-and-run
task — the order=1/order=3 split narrows it to "a third-order-sensitive
power term," which is a specific, findable thing, not a vague
"something's fragile somewhere."

**Status of the `.mod` file: fully restored to the current, intended
calibration** (`chie=0.0276`, `sigma_e=0.9769`, `levss=4`, NAWM-swap NK
parameters, all as before this diagnostic session) — the temporary
NK-reversion was backed up and restored, not left in place.
`run_thesis_model.m`'s diagnostic block is now off by default
(`RUN_PHI_DIAGNOSTIC = false`) but left in the file for reuse.

## 0f. Update, later same morning: exhaustive equation-by-equation code read, leverage decision corrected, order=2 sharpens the picture

User (rightly) pushed back: I'd been recommending "proceed to Results" while
also saying "there's a problem with `lev`," and separately, I'd kept
`levss=4` out of habit even after leverage was fully exonerated as the
cause. Both fair. Addressed both.

**Exhaustive code read, as requested — not another test run.** Went
through all 35 equations in the `model;` block by hand, checking every
`^` operator against the specific pattern asked for (a variable raised to
a `chi`/`psi`/`gamma`-type power without being normalised by its own
steady state, the same issue already fixed in the SDF's `v(+1)^(-chi)`
term). Result: **nothing else matches.** Every other power term is either
(a) a constant-parameter exponent on a non-variable base (`Dcal`, `Ecal`
— zero risk), (b) a variable that's already close to 1 at steady state
regardless of the exponent size (`pi`, `pireset`, `u`, `CE`, the SDF's
second power term, evaluated by hand at $\approx1.0006$), or (c) a
standard Cobb-Douglas fractional exponent on an O(1) production variable.
**This specific search is closed.**

**One structurally different candidate found: `lev =
nuB/(lambdadiv - etaB)`, a division (not a power), sitting inside a
forward-looking recursive loop** ($\Omega^b_t$ depends on $\eta^b_t$/
$\nu^b_t$, which depend on $\Omega^b_{t+1}$, one period further out).
Rational functions' higher derivatives grow combinatorially in a way
power functions with a near-unity base don't — a plausible, mechanistic
explanation for an issue that's absent at order=1 and present at order=3.
**Not touched** — rewriting it properly isn't a one-line identity the way
`v` was, and per explicit instruction this needs sign-off before any
equation-level change, since it could require a note in Appendix B even
if the economics is unchanged.

**Ran order=2 as an extra data point (not originally planned, but cheap
and informative): at $\Phi=6$, order=2 is clean at $\phi=0.10, 0.20,
0.50$ — only $\phi=0.03$ shows `Inf` (two of them).** This is a real,
useful sharpening: order=1 clean everywhere tested; order=2 clean except
one point; order=3 `Inf` almost everywhere. **Progressive degradation
with derivative order is exactly the signature the `lev`-recursion
hypothesis predicts** (rational-function derivatives compound with order)
— this made the hypothesis more credible, not less.

**Leverage decision, corrected:** since leverage is fully exonerated (the
`Inf` pattern is identical at 4, 5, 5.5, and 6), there was no remaining
reason to stay at the uncited legacy value of 4. **Reverted to
`levss=6`, cited to \textcite{Coenen2018}, as originally recommended two
days ago** — sticking with 4 after ruling out leverage as the cause was
my own inconsistency, not a finding, and the user caught it.

**Final confirmatory run in progress:** full `run_thesis_model.m` at
$\Phi=6$, order=3, all five scenarios — checking whether the actual GIRF/
ergodic-mean output (not just the eigenvalue table) stays clean the way
it did at $\Phi=4$. Running longer than the $\Phi=4$ version (background
job), result pending — see the chat log for the outcome once it lands.

**Recommended academic resolution, pending that last check:** document
this as a known, investigated, non-corrupting third-order numerical-
conditioning feature (BK/rank condition verified at every calibration
point tested; order=1 uniformly well-conditioned; the specific mechanism
narrowed to the endogenous-leverage recursion, though not conclusively
proven; simulated moments checked directly and show no NaN/Inf/divergence
for the calibration used) — a paragraph in Limitations or a methods
footnote, not a blocker, unless the pending $\Phi=6$ output check comes
back dirty, in which case the `lev` rewrite moves from "optional
robustness polish" to "required before Results."

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

## 3. Aug 15 morning — the A→B→C line-by-line check (`status_quo_thesis_august_15h_morning.txt`)

This is the task from §1 above, finally executed against the current
draft, not the timestamps in this file's header. Read Appendix A's
Banking/Disaster-Transmission subsections fresh, and Appendix B and C in
full (every tagged equation, B.1–B.32 and C.1a–C.36), then hand-verified
the specific formulas against the `.mod`'s actual `steady_state_model`
block, term by term, not by inspection.

**Confirmed exact matches (no discrepancy, `.mod` = appendix formula
after substituting the right variable):**
- C.4 risk-free rate (`Rfss`)
- C.19 $\eta=\bar P^{k,real}/\delta_0$ (`eta = pkrss/delta0`)
- C.23–C.24 $\kappa$, $\mathcal F=f_0\kappa^{-\chi^e}$ (`Ness`, `f0`)
- C.27–C.28 entrepreneur net worth / $\iota^e$ (`iotae` — re-derived by
  hand twice; first pass used `kss` instead of the correct
  `k(-1)ss=k^n_{ss}=e^{\mu_z}k_{ss}$` and looked like a mismatch, second
  pass with the right substitution matches exactly — the appendix's own
  $k$ vs $k^n$ distinction is the thing that has to be respected, and it
  is, in both places)
- C.34–C.35 $\varsigma$, $\bar\nu^b$, $\theta^b$ against `spreadAss`,
  `OmBss`, `lambdadiv` — confirmed via substitution $\bar Q^b=1/\bar
  R^f$: `OmBss`'s argument $Q_{ss}(\lambda\cdot\text{spreadAss}+R^d_{ss})$
  collapses to exactly $1+\lambda\varsigma$, and `lambdadiv` is
  literally `etaBss+nuBss/levss` = the C.35 closed form for $\theta^b$
- B.4–B.14 (household consumption FOC, Tobin's Q, Calvo reset-price
  recursions $\Xi_1,\Xi_2$, aggregate inflation, dispersion, production
  function) — standard NK block, unchanged by this week's calibration
  work, checked anyway per the "120%" instruction: structurally matches
  the `.mod`'s equations 1–15 with no un-detrended term found

**Two genuine findings, neither a computational bug:**

1. **`v`/`vss` notational divergence (C.6).** The appendix defines
   $\bar v\equiv \bar c(1-\bar L)^\varpi/(1-\Theta)^{1/(1-\psi)}$ — i.e.
   C.6 takes the final $1/(1-\psi)$ root to recover $\bar v$ itself. The
   `.mod`'s `v`/`vss` never takes that root: `vss` is computed as
   $\bigl(\bar c(1-\bar L)^\varpi\bigr)^{1-\psi}/(1-\Theta)$, which is
   $\bar v^{1-\psi}$, not $\bar v$. This is internally consistent — the
   `CE` auxiliary and its exponents are built to match `v` defined this
   way, so nothing computes wrong — but it means the code's `v` and the
   appendix's stated $\bar v$ are two different objects with the same
   name. Anyone trying to verify `vss` numerically against C.6 as
   written would appear to get a mismatch unless this is flagged.
   **Recommend:** one footnote in Appendix C or D0 noting the code
   convention, or rename the `.mod` variable/comment. Cosmetic, but
   worth fixing before the appendix gets shortened, since a shortened
   version won't have room to re-derive this from scratch if someone
   flags it later.
2. **B.29 (Government Budget Constraint) keeps a raw $x_t$**, unlike
   every other equation in Appendix B, all of which apply the Gourio
   $\theta_t$-substitution trick to eliminate the disaster indicator.
   Low-stakes: `T_t`/B.29 isn't implemented in the `.mod` at all (already
   flagged in the `.mod` header), and C.36's steady-state $\bar T$
   sidesteps the issue entirely via the D0 convention that the steady
   state is evaluated at $x=0$. Still, for consistency once the appendix
   is being tightened, B.29 should get the same $\theta_t$ treatment as
   B.15–B.28.

**One cosmetic gap:** the tag **C.33 does not exist** — the sequence
jumps C.32 (`\label{eq:D_iota}`) → C.34 (`\label{eq:D_varsigma}`) with no
equation, orphaned label, or text gap in between. Nothing is missing
content-wise; it's a pure renumbering artifact (something was probably
merged or deleted upstream). Renumber before final submission so a
reader doesn't go looking for a nonexistent equation.

**One item left open, not closed today:** Appendix D10's admissibility
condition (vii), $\iota>0,\iota^e>0$, is derived in the text but
`iotab`/`iotae` are calibration-block *parameters* in the `.mod`, not
`var`-list steady-state outputs, so they never appear in Dynare's
printed steady-state table. Never directly confirmed their sign at the
current $\Phi=6$ calibration from any log seen this week. Cheap to close
— one `disp(iotae); disp(iotab)` line after `steady;` — worth doing
before relying on this appendix section as fully closed.

**Verdict on the actual question asked** ("does Appendix A build
cleanly into B, and is C a correct output of both"): **yes.** Every
formula checked — spanning the household/NK block, the entrepreneur
block, and the bank/disaster-transmission block, which is the part of
the appendix this thesis actually stakes its contribution on — traces
correctly through detrending (A→B) and steady-state evaluation (B→C)
into the `.mod`'s actual implemented equations, with the two findings
above being documentation/numbering polish, not substantive errors. The
appendix is at a defensible, correct "most dense" state and safe to use
as the basis for the later shortening pass.

## 4. Aug 15 morning — admissibility check closed, Results-chapter pipeline built

**Admissibility (D10, condition vii) closed.** Added a live
`iotae`/`iotab` sign check to `run_thesis_model.m` (they're calibration-
block parameters, not `var`-list steady-state outputs, so Dynare's own
printed table never showed them). Confirmed `iotae>0` and `iotab>0`
across every φ tested (1e-4, 0.03, 0.20, 0.30, 0.50). No violation
anywhere — this item is closed, not just deferred.

**`run_thesis_model.m` now builds the full Tier-1 + Tier-2 Results
chapter** (`main_results_path.md`), not just Fig1–3. New sections, each
with a `.csv` written alongside the script:
- **Two-channel decomposition + safe-haven check (5.2.2).** Impact-
  period leverage response is 4.63% of its own peak (peak at t=5) at
  baseline φ=0.03 — matches the ballpark the roadmap flagged (~21% was
  the number from an earlier, different calibration; 4.63% is this
  week's Φ=6/Gelain-posterior calibration, not a discrepancy). $N^b$ is
  exactly 0 at impact, confirming channel separation. Safe-haven: $Q^b$
  never reverses sign — CONFIRMED. $H^b$ dominates $R^f$ from $t=1$
  onward — CONFIRMED; at the impact period only, $R^f$'s Fisher-equation
  jump (0.0101%) briefly exceeds $H^b$'s move (0.0084%), a real, tiny,
  reportable nuance, not a violation of the safe-haven claim.
- **Steady-state comparison table (5.2.1)** across φ ∈ {1e-4, 0.03,
  0.20}: `Nb`, `lev`, `spread`, `QbB`, entrepreneur premium, bank margin,
  y/c/i.
- **Calibration table (5.1)**: every parameter pulled live from
  `M_.params` (can't drift out of sync with the `.mod`), with citations.
  One bug caught here: `levss` isn't actually a declared parameter — it's
  a local variable inside `steady_state_model`, discarded after use.
  Fixed by sourcing the number from `lev`'s actual steady state instead.
- **Tail-risk moments + Output-/Spread-at-Risk (5.3.1/5.3.2)**: 20,000-
  quarter stochastic simulation (seed fixed, reproducible). Genuinely
  fat-tailed and asymmetric throughout — sovereign spread skew 3.33,
  kurtosis 22.75; consumption skew −1.25, kurtosis 7.36; bank leverage
  mean 7.78 (vs. the 6.0 steady-state target) with skew 1.24. This is the
  evidence that actually earns the word "tail" in the thesis title — it
  didn't exist before today.
- **Continuous φ sensitivity sweep (5.4.1/6.1)**, 14 points from φ=0 to
  φ=0.50: **every single point solves cleanly, including φ=0 exactly** —
  0 Inf eigenvalues at every grid point. This resolves the standing
  φ=0 numerical-fragility question from `ToDoAugust1st.md` §2: at the
  *current* calibration (Φ=6, Gelain posteriors), whatever fragility
  motivated using 1e-4 as a "smoother counterfactual" is gone. (Not
  re-tested: the φ=0.80/levss=5.5 hard BK failure from earlier this
  week — that combination is no longer the live calibration, so it's
  moot, not re-verified.) Peak spread response and impact-leverage-share
  are both smooth and monotonically increasing in φ across the full
  range — the strongest version yet of the amplification claim.

**Process note, for the record:** the first full run crashed on the
calibration-table bug above, and separately the safe-haven check's first
version FAILED both sub-checks — traced to the check's own logic being
wrong (required $Q^b$ to keep getting more negative every quarter, which
a mean-reverting IRF will never do), not the model. Diagnosed with a
targeted single-scenario script before touching the full 30-40 minute
pipeline again, fixed both, re-ran clean. Verified via `checkcode` before
each re-run.

**Output:** `Fig1_Headline_GIRF`, `Fig2_Core_Phi_Sweep`,
`Fig3_Beyond_Calibration`, `Fig4_Phi_Sweep` (.fig/.png), and
`table_two_channel_safehaven.csv`, `table_steady_state.csv`,
`table_calibration.csv`, `table_tail_risk_moments.csv`,
`table_phi_sweep.csv`, plus the consolidated `thesis_model_results.mat`.
Ready to write up directly into the Results chapter.
