# Assessment of the Appendix A Review Pass (for the Appendix B/C Deepening Pass)

**Updated 2026-08-17: the Taylor rule item below was wrong in the
2026-08-16 version and has been corrected in place (marked below) —
level gap confirmed correct against IS2017's own equations (11)/(A.21),
not the log gap this assessment originally recommended.**

Written 2026-08-16 by Claude Code, working directly against
`thesis_model_v3.mod` and the full Dynare/MATLAB results pipeline for
this thesis (steady state, GIRFs, the φ-sensitivity sweep, tail-risk
moments — all independently solved and verified over the preceding
week, not inferred from the text alone). Purpose: hand off to whoever
(Opus or otherwise) does the next pass, deepening Appendix B
(Stationarization) and Appendix C (Non-Stochastic Steady State), so that
pass starts from a verified state rather than re-litigating what's
already settled.

## Governing principle for this next pass

**Appendix B and C must be a product of Appendix A, not the reverse.**
Appendix B and C were originally derived (by Claude, in an earlier
session) from an *earlier* version of Appendix A. Appendix A has since
been substantively revised — sharper notation, several genuine
derivation gaps closed, at least one claim correctly retracted. Where B
or C disagree with the *current* A, the presumption should be that A is
right and B/C are stale, not the other way around. The one exception is
where B/C already anticipated a fix A hadn't yet made (this happened at
least once — see the Fisher equation, below) — in that direction, bring
A up to B/C, not down.

The `.mod` file is a separate, third artifact. It was built to match the
*old* B/C. Do not treat `.mod` agreement as evidence that a B/C equation
is correct — it only proves B/C and `.mod` are mutually consistent with
each other, which is expected since one was coded from the other.
Genuine verification means checking the appendix's derivation is sound
on its own terms, then checking `.mod` against the *result*.

## Status of the specific worry that prompted this review

An earlier assessment (by Opus, working from Appendix A alone, without
Appendix B, C, or the `.mod`) argued the sovereign-bank transmission
channel is inert because the disaster is never realised along the
simulated path, and that a long-term-bond rederivation would be the only
fix. **This is retracted, correctly, in `Opus_Changelog.md` Part C item
7** — falsified by this project's own results: the immediate
(perceived-risk) channel is confirmed twice independently (2026-07-30,
re-confirmed 2026-08-04/05), the φ-sweep is monotonic across all 14
grid points including φ=0 with zero solve failures (2026-08-15), and the
"realised default only" reading of Appendix A.3.3 was already retired on
2026-07-30. I independently re-verified this by grepping the entire
*implemented* Aug-16 text for every variant of the claim — none of the
alarmist framing survived into either the main text or Appendix A. Both
now correctly state: the immediate channel is real and active regardless
of realisation; the lagged channel is honestly disclosed as structurally
inactive **by construction** (`Rb`/`RK` coded at the disaster-free branch
in the `.mod`), with the long-term-bond extension flagged as an optional
future path, not a requirement. **This does not need to be revisited.**

## Confirmed correct, term-by-term against `.mod` (no action needed)

- **A2 — bank value-function timing.** B.21a–d
  (`\eta^b_t,\nu^b_t,\Omega^b_t,\lambda_t`) checked directly:
  $\Omega^b_t=(1-\sigma^b)+\sigma^b(\nu^b_t+\lambda_t\eta^b_t)$ uses
  strictly contemporaneous terms, exactly matching `.mod`'s
  `OmB = (1-sigma_b)+sigma_b*(etaB*lev+nuB)`. Exact match.
- **A3 — $R^d$ timing.** A.3.2.5 correctly shows $R^d_{t-1}$ in both
  bracket terms, matching `.mod` eq(27).
- **A6 — $\Xi_t$ / resource constraint.** The implemented derivation is
  stronger than what `Opus_Changelog.md`'s own A6 entry describes:
  rather than carrying $\Xi_t$ as a persistent term, the text derives
  the full flow identity and proves it cancels exactly, so
  $Y_t=C_t+I_t$ holds exactly — matching `.mod` eq(33) precisely.
- **Admissibility (Appendix D10, condition vii).** $\iota^e,\iota^b>0$
  confirmed by direct computation at every φ tested (1e-4, 0.03, 0.20,
  0.30, 0.50). Closed 2026-08-15/16.

## Real issues found, and their current status

### 1. Fisher equation — RESOLVED, draft written, pending your implementation

Real, confirmed three-way contradiction as of the Aug-16 draft: the main
text stated the simple/approximate Fisher relation
$R^f_t=(1+r_t)/\mathbb{E}_t[1+\pi_{t+1}]$ as *the* equation; Appendix A
and B both already stated the exact form
$\mathbb{E}_t[\mathcal{M}_{t,t+1}(1+r_t)/(1+\pi_{t+1})]=1$, with A
explicitly asserting "the approximate form is therefore not used"; the
`.mod` (`Q=pi(+1)/r; Rf=1/Q;`) provably implements the simple form under
Dynare's own expectation semantics.

**Resolution direction, per the governing principle above: Appendix A
and B were right; the main text was stale.** A full, from-first-principles
derivation of the exact form (no-arbitrage pricing of a notional
zero-net-supply nominal bond via the household SDF, exactly parallel to
how the sovereign bond price is already derived) plus the precise
collapse condition (covariance + Jensen decomposition, and *why* both
fail in this model — $\theta_t$ moves the SDF and expected inflation
jointly) has been written and handed to the user as
`Fisher_Taylor_Replacement_Draft.md`, ready to paste into both the main
text and Appendix A.

**Consequence for this B/C pass: none needed.** B.30 already states the
exact form correctly and requires no change — every term in it
($r,\pi,\mathcal{M}_{t,t+1}$) is already stationary, so the level
equation detrends into B.30 unchanged. This was one of the cases where
B/C were already ahead of A.

**Consequence for a later `.mod` pass (not yet decided, out of scope for
you right now):** if the exact form is adopted computationally, the
`.mod` needs a genuine equation change — structurally similar to the
`CE`-auxiliary trick already used for the Epstein-Zin value function
(introduce an auxiliary carrying the product under one expectation) —
not a one-line fix. This is explicitly deferred until B/C are settled
and handed back.

### 2. Taylor rule output-gap functional form — RESOLVED (corrected 2026-08-17), draft written, pending your implementation

**Superseded finding, kept here for the record.** The 2026-08-16 version
of this assessment concluded Appendix A's log-gap form was the
dimensionally correct one and recommended the main text, Appendix B
(B.31), and eventually the `.mod` catch up to it. **This was wrong.**
The user pointed out that IS2017 — the paper this thesis explicitly
follows for the public-authority block — uses the level-gap form
directly (their eq. 11, stationarized as their eq. A.21:
$r_t=\rho_r r_{t-1}+(1-\rho_r)[\varphi_\pi(\pi_t-\bar\pi)+\varphi_Y(y_t-\bar y)+\bar r]$).
Appendix A's log gap was the thing that had drifted from the template —
not the main text, not Appendix B, not the `.mod`, all three of which
already had the correct (level-gap) form and needed no change. The
dimensional-comparability argument this assessment made on 2026-08-16
was mathematically fine in the abstract but factually inapplicable here,
because it was never checked against the actual source template before
being applied. **Lesson for this pass: always check the specific cited
source (IS2017 here) before applying a generic best-practice argument —
"more rigorous in the abstract" is not the same test as "matches the
template this thesis says it follows."**

**Corrected resolution:** Appendix A.4.3 reverts to the level-gap form,
now justified by direct citation to IS2017 (11)/(A.21) rather than a
dimensional argument. Full corrected text is in
`Fisher_Taylor_Replacement_Draft.md` (v2, 2026-08-17).

Two smaller things remain bundled into the same fix, both independent of
the level/log question and still valid:
- The main text's $\lambda_\pi,\lambda_Y$ collides with the bank leverage
  multiplier $\lambda_t$ — worse than the $\phi$ collision it presumably
  replaced. Standardised on $\varphi_\pi,\varphi_Y$ (matching what
  Appendix A had already independently settled on, for this one thing).
- Appendix A's current closing sentence claims the model is "driven by
  the two structural innovations $\varepsilon_z$ and $\varepsilon_\theta$."
  The `.mod`'s `varexo` block is `etheta er;` — there is no
  $\varepsilon_z$ shock at all (trend growth is purely deterministic in
  this calibration); the second declared-but-inactive shock is monetary
  (`er`, `stderr 0`), not TFP. Corrected in the draft.

**Consequence for this B/C pass: B.31 needs no rederivation.** Its
existing `\lambda_\Y(y_t-\bar y)` is already correct in substance and
already matches IS2017 (A.21) — only the coefficient symbol should be
renamed to $\varphi_\pi,\varphi_Y$ for consistency with the corrected
A.4.3 and main text. Cosmetic, not algebraic. This is now a no-op for
this pass, like the Fisher equation, not the "real rederivation work"
item the 2026-08-16 version of this assessment said it was.

### 3. Capital timing ($K^n_{t+1}$ vs $K_{t+1}$, A4) — OPEN, not resolved, needs a dedicated pass

Attempted the full index algebra connecting Appendix B's B.1 (written in
"plain" $k_t\equiv K_t/z_t$ notation) to the `.mod`'s eq(10) (which uses
the $k^n$ convention, $k^n_{t+1}\equiv K_{t+1}/z_t$, established
elsewhere in the same appendix). Did not reach full closure — this is
genuinely delicate, multi-step detrending/timing substitution, and I
would rather flag it open than assert a verdict I'm not fully confident
in (I already caught myself making one comparable indexing error this
week, on the entrepreneur net-worth check, before it went out).

**What is independently confirmed, and is reassuring but not
conclusive:** the steady-state relationship $k^n_{ss}=e^{\mu_z}k_{ss}$,
which this equation must nest correctly, checks out exactly against
`.mod`. The computed GIRFs for investment/capital behave like a normal
NK model's response to a risk shock — no sign flips, no structural
break. Neither of these proves the *dynamic* equation's indexing is
right; they're evidence against a *severe* error, not a clean bill of
health.

**Ask for this pass:** when you rederive the capital-accumulation block
of Appendix B from the (now more careful) A.3.1.0a/A.3.1.0b split in
Appendix A, work the $K^n\to k^n$ detrending through explicitly and
check the result against `.mod` eq(10) term by term, including the
`i/k(-1)` ratio (which, depending on exactly how the timing resolves,
may or may not need an extra trend-growth factor relative to what's
currently in B.1). Flag back if this changes anything material — do not
assume my earlier "probably fine" read of B.1 in isolation (before this
specific cross-check) settles it.

## Cosmetic but currently unfixed

**`\label{eq:betatheta}` is still duplicated** (main text, and again in
Appendix A) — flagged "BLOCKING" in `Opus_Changelog.md`'s own D1 item,
not yet fixed. Hard LaTeX error (`Label multiply defined`), unpredictable
`\eqref` resolution downstream. Trivial fix (rename one instance) but
should happen before anything else compiles cleanly.

## What this means for scope

Nothing found so far requires touching `thesis_model_v3.mod` or
re-running the results pipeline (Fig1–4, the tail-risk moments, the
φ-sweep, the calibration/steady-state tables — all already generated and
valid). The Fisher equation is the one place where a `.mod` change is
*possible* pending a future decision, explicitly deferred. Everything
else found is a text-consistency issue between Main/A/B, not a
text-vs-code issue. Proceed with the B/C deepening pass on that basis;
bring the result back and I'll re-verify against `.mod` before any code
decision is made.
