# Dynare debugging changelog — thesis_model_v3.mod

No changes have been made to `thesis_model_v3.mod` yet. This log records
the diagnostic work performed against Dynare's own internal objects
(Dynare 6.3, MATLAB R2024a) and the empirical tests run on scratch copies
of the .mod file. All scratch copies live outside the project directory
and are not part of the model.

## 2026-07-29 — Priority 1: extracted Dynare's actual dynamic Jacobian

Ran `dynare thesis_model_v3 -DORDER=1`, capturing `M_`, `oo_`, `options_`
after the (expected) Blanchard-Kahn failure at `stoch_simul`, and called
`thesis_model_v3.dynamic(...)` directly at the verified steady state
(residuals confirmed exact zero, max |resid| = 8.9e-16), using the same
`z(iyr0)` construction Dynare's own `stochastic_solvers.m` uses.

**Finding 1 — no blown-up derivative.** Scanned every entry of the raw
39x60 dynamic Jacobian (`g1`). No entry exceeds 1e4 in magnitude (largest
is ~150). This rules out a single mis-scaled term (e.g. an unrescaled
`v^(-chi)`-type expression) as the cause — the CE/Theta rescaling already
in the .mod file (see the "RESOLVED" note in the header) is working as
intended.

**Finding 2 — raw equation system is full rank.** The 39x58 endogenous-only
Jacobian (all lag/current/lead columns, in original .mod equation order,
i.e. *before* Dynare's block-recursive reduction) has rank exactly 39.
There is no literal duplicate/redundant equation in the 39-equation
system as written.

**Finding 3 — two structurally weak (but nonzero) directions exist in the
raw Jacobian.** SVD of that same matrix shows singular values 0.42-0.60
gradually, then a visible drop to 0.0398 and 0.0314 for the two smallest.
The right-singular-vectors for these two weak directions are dominated by:
  - the firm/NKPC block interacting with entrepreneur net worth
    (`w, mc, ktilde, Omega, L, Ne, y, pireset, i, X1(+1), X2(+1)`), and
  - the sovereign/disaster cascade (`Ecal, Dcal, theta, Hb, Qb, spread,
    Rd, Rf, v, Theta`) — i.e. exactly the CE/Dcal/Ecal/Theta +
    Hb/Qb/spread block flagged in the .mod header as least battle-tested.

**Finding 4 — exact rank-3 deficiency in Dynare's internal BK pencil.**
Reconstructed the (D,E) generalized-eigenvalue pencil that
`dyn_first_order_solver.m` feeds to `mjdgges` (QZ), using Dynare's own
index bookkeeping. `rank(E)=13` (deficient by 6 — this is *normal*,
matches the 6 known ~1e-16-modulus eigenvalues from purely definitional/
static identities, not a bug). `rank(D)=16` out of 19 (deficient by
**exactly 3**) — this is the direct, mechanical cause of the 3
"huge" (1e16-1e18 modulus) eigenvalues: they are QZ's numerical stand-in
for eigenvalues at infinity, produced by an exact (~1e-17) singularity in
D, not by any large individual derivative.

Since the model needs exactly 7 unstable roots (`nsfwrd=7`) and only 5
fall in the "normal" range (1.01-2.71), 2 of the 3 huge roots are
*legitimate* (required) roots that simply happen to be numerically huge;
only **1 of the 3 is the genuine excess** causing the BK failure
("8 unstable for 7 forward-looking" = excess of exactly 1, matching the
pattern already observed across every prior bisection).

**Finding 5 — decomposition of D's null space.** Within D, the
6-column subspace {RS, RK, c, L, X1, X2} has rank 4 (deficient by 2):
  - RS and RK are tied by an exact rank-1 relationship traceable to a
    single row of D that is *exactly* equation (22) (the BGG capital
    demand / EFP condition), with near-equal-magnitude, opposite-sign
    coefficients on `RK(+1)` (≈0.998, from `1-thetass*Deltak`) and `RS`
    (≈-1.003, from `premE`). This pairing is *expected/benign* — RK
    and RS share exactly one governing equation, so a rank-1 tie between
    them is structurally normal, not a bug.
  - Separately, and NOT explained by any single shared equation: the
    `c` and `L` columns of D are **exactly proportional** (ratio
    0.9459/0.3246, to ~1e-17) across every one of the 19 rows, with `X1`
    and `X2` contributing exactly zero to this null direction. This is
    the anomalous piece.

## 2026-07-29 — Priority 2: targeted bisection tests (scratch copies only)

All tests below used scratch copies (`test_A_handbuild.mod`,
`test_B_freezeL.mod`, `test_C_freezeQb.mod`), never the real
`thesis_model_v3.mod`. None of these are proposed fixes.

**Test A — revert eq(18)/(19) to the commented-out "hand build" form**
(replacing `Theta` with `Q*(1-theta*Deltak)*exp(muz)` in the X1/X2 Calvo
recursions). **Result: breaks the steady state** (residual -0.0024/-0.0029
instead of exact zero). This proves `Theta` and `(1-theta*Deltak)` are
*not* algebraically equivalent even at the calibrated steady state
(`Dcalss/Ecalss ≠ 1-thetass*Deltak`) — reverting to the hand-build form
is not a valid substitution, it changes the model's economics. Abandoned.

**Test B — freeze only `L(+1)`** to `STEADY_STATE(L)` in eq(4) (the SDF),
leaving `v(+1)`, `c(+1)` and all other leads dynamic. This is a sharper
test than the original 3-variable "v,c,L" bisection. Residual stays exact
zero (frozen at an exact identity). **Result:** forward-count correctly
drops 7→6, huge-eigenvalue-count drops 3→2, but the excess is still
**exactly 1** (7 unstable vs 6 forward). This is new evidence beyond what
had already been established: removing `L`'s own forward slot removes
exactly its own (legitimately huge but required) root — **it does not
touch the actual bug**. Combined with the prior exhaustive bisection of
all 7 forward variables, this confirms the true excess root is not
attributable to any forward-looking variable's own lead.

**Test C — freeze `Qb(-1)`** to `STEADY_STATE(Qb)` in eq(31) (removing
Qb's own lag, i.e. removing it from the predetermined block). **Result:**
excess-by-1 persists unchanged (8 vs 7), and one eigenvalue becomes
exactly `Inf` (a true zero pivot) instead of ~1e17 — i.e. this edit made
the singularity *exact* rather than removing it. Qb's own lag is not
individually responsible either, though the effect stays localized to
the same predetermined/static part of the system.

**Test D — exact algebraic substitution, not a freeze.** Equation (5),
`(1-L)/c = varpi/w`, is a maintained equilibrium condition that holds at
*every* period, including `t+1`. That means
`(1-L(+1))/(1-L) ≡ (c(+1)/c)*(w/w(+1))` is an **exact identity**, not an
approximation — substituting it into eq(4) changes nothing about the
economics, it only re-expresses the same quantity via `w` instead of `L`.
Tested replacing `((1-L(+1))/(1-L))^(varpi*(1-psi))` with
`((c(+1)/c)*(w/w(+1)))^(varpi*(1-psi))` in eq(4). Residual stays exact
zero (confirms the substitution is valid). **Result: not fixed, and
numerically worse** — 2 of the 3 problem eigenvalues become exactly `Inf`
(true zero pivots) rather than ~1e16-1e18. This rules out "L vs w as the
forward carrier of the labor-leisure margin" as the mechanism — moving
the exact same information from `L(+1)` to `w(+1)` does not remove the
collinearity, it relocates and sharpens it. This is strong evidence the
issue is not about *which* variable carries this margin forward, but
about a deeper structural interaction between the consumption/leisure
block and the rest of the reduced system.

## Current assessment

- Not a single mis-scaled term (Finding 1).
- Not a literal duplicate equation (Finding 2).
- Not resolvable by touching any one of the 7 forward-looking variables,
  including `L` specifically, which had not been isolated before
  (Test B) — the prior 4 bisections tested only 3-variable groups.
- Not resolvable by touching `Qb`'s own lag in isolation (Test C).
- The anomaly decomposes into (a) an expected, benign RS-RK rank-1 tie
  from eq(22), and (b) a genuinely unexplained exact c/L collinearity in
  the reduced forward block, plus (c) a separate weak direction in the
  raw Jacobian concentrated in the theta→Dcal/Ecal→Theta→Hb→Qb→spread
  cascade that has not yet been isolated with the same precision as (b).

No mechanism-clear, minimal (one-line) fix has been identified despite
the above. See chat response for the fork-in-the-road options being
brought back for a decision before any further code change is made.

## 2026-07-29 — Re-derivation of eqs (22)-(31) against the thesis text

Found `Master Thesis Status Quo - July 22nd Morning.txt` (a LaTeX-source
dump of the thesis) in the parent `Master_Thesis_Final` folder and
cross-checked every equation in the entrepreneur/bank/sovereign block
(eqs 22-31 in the .mod, thesis tags B.19-B.31 in that document) against
its derivation and surrounding prose. No .mod edits were made.

**Eqs (23),(24),(25),(26),(29,implicit),(30),(31),(34): exact matches**
to thesis B.21, B.22, B.25, B.24, B.28, B.29(x=0 convention), B.31
respectively. `Hb`'s `/Ecal` normalization (eq 29) is a documented,
deliberate refinement already explained in the .mod header — not a bug.

**Eq (22) — genuinely ambiguous, not a clean bug.** The thesis derives
the EFP in two pieces: B.19 (indifference, `R^L_t=(1-θΔ^k)E_t[R̃^K_{t+1}]`)
and B.20 (`R^L_t/R^d_t = s_0·(N^e_t/Q_tK_{t+1})^{-χ^e}`, described in
prose as "the bank charges a premium over its funding cost `R^d_t`").
Read literally, B.20 suggests `Rd` where the .mod's eq(22) instead uses
`RS` self-referentially. But:
  - Substituting `Rd` in for `RS` on the RHS removes `RS` from the
    equation entirely — and `RS` (current-period) does not appear
    anywhere else in the model, so this substitution leaves `RS`
    completely undetermined. Not a valid literal fix.
  - In this model, capital (`k`) is *not* an entrepreneur choice
    variable — its path is fully mechanical (accumulation identity
    (10) + resource constraint (33)), unlike a standard BGG model where
    capital demand is the object the combined B.19+B.20 condition
    solves for. With `k` already pinned elsewhere, `RS` is the only
    variable left for eq(22) to determine — which is exactly what the
    .mod does. A literal `Rd`-for-`RS` substitution would leave the
    system either under-determined (`RS` orphaned) or over-determined
    (no free variable left to satisfy an `Rd`-based constraint).
  - The thesis's own prose (line ~853 of the status-quo doc) states
    `R^L_t` "is jointly determined by the BGG premium **and** the GK
    leverage constraint" in this extended model — i.e. the thesis itself
    flags that the textbook single-premium formula is not the whole
    story once a bank layer with its own binding leverage constraint
    sits between entrepreneur and household. A fully faithful
    implementation likely needs the *shadow price* of the bank's binding
    leverage constraint (eq 26) to enter the loan-pricing condition,
    which does not currently exist as a variable anywhere in the model.
    Adding it would not be a one-line fix — it's a genuine modeling
    decision.

**Eq (27) — apparent mismatch, but very likely already reconciled.**
The status-quo document's B.26 uses `(R^K_t-R^d_t)` and `R^d_t` (all
current-period), while the .mod's eq(27) uses `(RS(-1)-Rd(-1))` and
`Rd(-1)`. This looks like a fresh discrepancy, BUT the .mod file's own
header already states, under "RESOLVED since the previous version":
*"Document B.23 now reads R^S_{t-1}, R^d_{t-1}, matching this .mod's
eq (27)... No longer flagged."* This means the user already went
through this exact reconciliation in an earlier session and updated the
thesis text accordingly. The status-quo .txt file (dated July 22nd) is
very likely a snapshot that *predates* that update, given the .mod file
was last modified July 29th — i.e. this is a thesis-text-needs-updating
flag, not a .mod bug. Flagged here for completeness, not as a finding.

**Conclusion of re-derivation:** no clean, unambiguous coding error was
found in eqs (22)-(31) when checked line-by-line against the thesis
text. The one genuine candidate (eq 22's premium reference) is a
modeling-completeness question (missing shadow-price channel from the
binding GK constraint), not a minimal fix.

## 2026-07-29 — Re-derivation superseded by newer thesis document; eq(23) bug confirmed

The user supplied a newer thesis source, `Master Thesis Status Quo -
July 28th.txt.rtf` (converted to plain text via `textutil`), replacing
the July 22nd version used above. Re-ran the full (22)-(31) cross-check
against this updated numbering (B.15-B.28 in this version).

**Eq (22) — now confirmed correct, not ambiguous.** The updated B.17
reads `E_t[R^K_{t+1}] = (1-θΔ^k)E_t[R̃^K_{t+1}] = f(n^e_t/(Q_tk^n_{t+1}))·R^S_t`
— i.e. `R^S_t` appears self-referentially on the RHS, exactly matching
the .mod's eq(22) construction. Confirms the earlier reasoning (capital
is mechanically pinned by the accumulation identity, not an entrepreneur
choice variable, so `RS` — not `Rd` — is the variable this equation
determines). Not a bug.

**Eq (27) — confirmed correct.** Updated B.23 uses `R^S_{t-1}`, `R^d_{t-1}`
throughout (not `R^K_t`, `R^d_t` as the July 22nd draft had) — exactly
matching the .mod's eq(27). Confirms the .mod header's own "RESOLVED"
note: this reconciliation had already happened; the July 22nd document
was simply a stale snapshot.

**Eq (23) — genuine, confirmed, minimal bug found.** Thesis B.18:
`n^e_t = σ^e·Γ_t^{-1}[R^K_tQ_{t-1}k^n_t - R^S_{t-1}(Q_{t-1}k^n_t-n^e_{t-1})] + ι^e`
— the comment explicitly says "factor `Γ_t^{-1}`" applies to the *entire*
bracket. The .mod's eq(23) instead applies `exp(-muz)` (the model's
stand-in for `Γ_t^{-1}`) only to the inner `Ne(-1)` term:
```
Ne = sigma_e*( RK*Qtob(-1)*k(-1) - RS(-1)*(Qtob(-1)*k(-1) - exp(-muz)*Ne(-1)) ) + iotae;
```
This is directly falsifiable by comparison with eq(27) (bank net worth),
which correctly has `exp(-muz)` as an overall factor and is structurally
the *identical* pattern in the thesis (B.23 has the same `Γ_t^{-1}[...]`
form as B.18). **Tested on a scratch copy**: moving `exp(-muz)` outside
as an overall factor, with `iotae` recalibrated in
`steady_state_model` the same way (mirroring `iotab`'s already-correct
pattern), keeps the SS residual exact zero. **Eigenvalues are
unaffected** (still 3 huge, still excess-by-1) — expected, since eq(23)
has no leads and cannot touch the forward/BK pencil. This is a real,
minimal, thesis-verified fix, independent of the BK problem — recommend
applying it regardless.

## 2026-07-29 — Testing the "genuine indeterminacy" hypothesis

With the (22)-(31) block re-derivation not explaining the singularity,
and Priority-1 diagnostics having already localized the anomaly to the
household block (`c`/`L` collinearity in the reduced pencil, from eq(4)
SDF + eq(5) labor-leisure FOC), cross-checked both against the updated
thesis: **both are exact matches** (A.1.1 SDF, A.1.2 labour-leisure, in
the July 28th document) — neither equation has a textual error.

**Test G — knife-edge calibration test.** Perturbed `varpi` (leisure
weight) by +0.065% (2.33 → 2.3315) on a scratch copy, with everything
else unchanged. If the singularity were a coincidental alignment of
specific calibrated values, a tiny perturbation should turn the 3 huge
eigenvalues into large-but-finite ones that move continuously. **Result:
no change** — still exactly 3 huge eigenvalues (1e16-1e18 range), still
excess-by-1. This rules out a knife-edge calibration coincidence: the
degeneracy is a robust, structural feature of the *functional form*
(how `L` enters the Euler equation as a lead inside a ratio, combined
with the static labour-supply condition), not an accident of these
specific parameter values.

**Assessment:** both contributing equations are individually verified
correct against the current thesis text, the raw 39-equation Jacobian
is exactly full rank (no missing/duplicate equation), and the
degeneracy survives both a variable substitution (Test D) and a
parameter perturbation (Test G) — ruling out a coding typo and a
calibration coincidence as explanations. What remains is a genuine
structural property of this economy's labour margin as specified:
`L`'s forward-looking role in the Euler equation carries no
expectational content that isn't already implied by `c` and `w` via the
static labour-supply FOC, and Dynare's default block-recursive linear
solver cannot cleanly separate this at the precision needed, producing
an exact (not approximate) singularity. This is the fork-in-the-road
being brought back to the user: no minimal, mechanism-preserving
one-line fix was found despite six targeted empirical tests (B, C, D,
F, G plus the re-derivation), and any further step likely requires
either a genuine re-derivation of how the labour margin enters the
Euler equation, or accepting a documented numerical workaround.

## 2026-07-29 — eq(23) fix APPLIED to thesis_model_v3.mod

Per user decision, applied the confirmed eq(23)/`iotae` fix from Test F
directly to `thesis_model_v3.mod` (not just the scratch copy):
- `steady_state_model`: `iotae = Ness - sigma_e*exp(-muz)*(RKss*kss - RSss*(kss - Ness));`
  (was: `iotae = Ness - sigma_e*(RKss*kss - RSss*(kss - exp(-muz)*Ness));`)
- Model block eq(23): `Ne = sigma_e*exp(-muz)*( RK*Qtob(-1)*k(-1) - RS(-1)*(Qtob(-1)*k(-1) - Ne(-1)) ) + iotae;`
  (was: `Ne = sigma_e*( RK*Qtob(-1)*k(-1) - RS(-1)*(Qtob(-1)*k(-1) - exp(-muz)*Ne(-1)) ) + iotae;`)

**Verified on the real file** (`dynare thesis_model_v3 -DORDER=1`):
`resid;` shows exact zero for every equation including `Ne` (0.000000);
eigenvalue structure unchanged as expected (3 huge eigenvalues, 8 vs 7
excess-by-1) since eq(23) has no leads and cannot affect the
forward/BK pencil. This is a **bug fix** (faithful correction to match
thesis B.18), not an abstraction — classification: bug fix, applied,
verified.

Continuing to investigate the core household-block structural
degeneracy (c/L collinearity) per user direction.

## 2026-07-29 — Confirming and explaining the structural degeneracy

**Test H — large multi-parameter perturbation.** Changed `gamma` (3.8→4.5,
+18%), `zeta` (0.6→0.75, +25%), and `tau` (2→3, +50%) simultaneously on a
scratch copy (a much larger, multi-dimensional test than Test G's single
0.065% nudge). Result: identical structure — still exactly 3 huge/infinite
eigenvalues, still excess-by-1. This makes the knife-edge/coincidence
explanation untenable regardless of which parameter is suspected.

**Mechanism, now identified precisely.** Recomputed the raw 39-equation
Jacobian's SVD under the Test H calibration and compared the two weakest
singular values to the original: **0.0366 vs 0.0398, and 0.0308 vs
0.0314** — essentially unchanged (<8% movement) despite the large
parameter shifts, while the other 6 smallest singular values in the same
matrix moved by 10-15% under the same perturbation (e.g. 0.418→0.434).
This is decisive: the weak direction's *magnitude* is a property of the
equations' functional form (which variables multiply which, and how),
not of the specific calibrated values.

That weak direction (identified in Finding 3, Priority 1) is dominated by
the labour/production/NKPC cluster: `w, mc, ktilde, Omega, L, Ne, y,
pireset, i, X1(+1), X2(+1)`. The mechanism: `w` never appears with a lag
or lead anywhere in the model, so Dynare's dynamic solver is *required*
to eliminate it via a joint (QR-based) static-block projection before
building the forward/backward (D,E) pencil used for the BK check. That
elimination uses *all 20* static equations simultaneously, including
eq(5) — the labour-leisure FOC `(1-L)/c=varpi/w`, which is an *exact*,
rigid algebraic identity (not an approximation) tying `L` to `c` (given
`w`). The already near-singular production/NKPC block (Finding 3) provides
the "almost" — eq(5)'s exactness, propagated through `w`'s elimination,
supplies exactly what's needed to complete it into a *true* rank
deficiency in the reduced system. This is consistent with every prior
test: freezing `L` (Test B) removes its own root but not the excess;
substituting `L(+1)` for `w(+1)` (Test D) relocates the problem into the
very cluster that's already weak, making it worse; large parameter
changes (Tests G, H) don't move the weak direction's magnitude at all.

**Conclusion:** this is a genuine structural property of the model as
correctly specified — not a coding error (every contributing equation
checks out against the thesis text), not a calibration accident (robust
under both small and large, single- and multi-parameter perturbations).
It reflects a real, if subtle, near-degeneracy in how the Calvo/NKPC/
labour-demand block is jointly identified in this specific calibration
family, sharpened to an exact singularity by the (perfectly correct)
exact labour-leisure condition once Dynare eliminates the wage. Resolving
it requires either a genuine re-derivation of this block's identification
(an economic/modelling decision) or a documented, flagged numerical
workaround — this remains the fork-in-the-road brought back to the user.

## 2026-07-29 — Independent re-derivation of Appendix B and C

Per user request, independently re-derived the stationarization (Appendix B)
and steady-state (Appendix C) mathematics from Appendix A's level-form
equations, symbol-by-symbol, without relying on the document's own algebra.
Focused on the hardest part: the Epstein-Zin SDF/Bellman/certainty-
equivalent construction and its interaction with the Gourio trick, since
that is where a sign/exponent error would most plausibly hide and
propagate into the .mod file's `CE`/`Dcal`/`Ecal`/`Theta` auxiliaries.

**Result: no errors found in Appendix B or C.** Verified exactly: B.1
(capital accumulation), B.2 (Bellman, including the χ-substitution
`χ(1-ψ)=γ-ψ`), B.3 (SDF, including the `Γ^{-γ}` trend-loading result),
A.1.5 (β(θ)), B.3b/B.3c (𝓔, Θ), B.10/B.11 (Calvo recursions with Θ — this
also explains *why* the Θ-based formulation is correct and the
commented-out "hand build" alternative in the .mod file is not: hand-build
uses the capital-destruction moment 𝒦 (κ=1) where the Calvo recursion
needs the trending-payoff moment 𝒟 (κ=1-γ) — these are different Gourio
moments, confirming Test A's finding from a different angle), A.3.3.2/2c
(H^b), and C.1–C.5 (steady-state 𝒟, 𝓔, Q̄^f, R̄^f, Θ) all match exactly
against independent derivation.

One notational point worth flagging (not a bug): the .mod file's `v`
variable is consistent with Appendix B only if read as $v_{thesis}^{1-\psi}$
rather than $v_{thesis}$ directly — every exponent in eqs (2) and (4)
checks out exactly under that reading. Suggested adding a one-line
clarifying comment in the .mod file for anyone cross-referencing against
the thesis text directly.

**Conclusion:** Appendix B and C are mathematically sound. The core BK
singularity is not explained by an error in either appendix.

## 2026-07-29 — Mechanism for the core singularity, and why it resists a minimal fix

Building on the fully-verified SDF equation, identified the precise
mechanism: `L` appears with a lead only in eq(4) (SDF), via
`((1-L(+1))/(1-L))^(varpi*(1-psi))`. Eq(5), the labor-leisure FOC
`(1-L)/c=varpi/w`, is a static equation holding at *every* period,
including t+1 — so `L(+1)` carries no independent information beyond
`c(+1)` and `w(+1)`. Dynare's forward-variable classification is purely
syntactic (any variable ever appearing with a lead), so it counts 7
forward variables (RK, v, c, L, pi, X1, X2) when the true economic count
is 6 — `L`'s slot duplicates `c`'s. This produces exactly one spurious
unstable root, matching the "8 unstable for 7 forward" pattern seen in
every prior test. It is invisible to the raw (single-period) Jacobian,
which is why Finding 2 (full rank 39) doesn't contradict it — the
redundancy is a genuinely multi-period (t chained to t+1) phenomenon that
only the BK/QZ reduction can see.

**Why this can't be cleanly fixed by substitution:** eliminating `L` via
`L=1-c·varpi/w` everywhere requires solving `w` jointly with `L`, since
`w` is itself defined by eq(12) (`w=mc(1-alpha)(ktilde/L)^alpha`), which
also depends on `L`. The two are circularly determined, not sequentially
substitutable, so this isn't expressible as a straightforward Dynare
equation rewrite. The one substitution that *is* mechanically clean
(Test D — replacing `L(+1)` with `c(+1),w(+1)` in eq(4) only) merely
relocates the forward role onto `w`, which sits inside the already-weak
production/pricing cluster (Finding 3) — explaining why Test D made
things worse rather than better.

**Assessment:** resolving this requires either a genuine reformulation of
how the labor margin enters the Euler equation (e.g. GHH-style
preferences removing the wealth effect on labor supply — a real economic
modeling choice) or a documented numerical workaround. This is the
fork-in-the-road, now understood at a mechanistic level, brought back to
the user for a decision.

## 2026-07-29 — Exhausting further numerical possibilities

**Test I — cycle-reduction with progressively looser tolerance.** The
earlier cycle-reduction attempt (diag7) failed with a NaN breakdown
(info=402, an internal matrix inversion produced NaN). Retried with
`dr_cycle_reduction_tol` at 1e-7, 1e-5, 1e-3, and 0.1 — four orders of
magnitude of slack. **Identical failure every time** (same info code,
same residual norm at breakdown). This rules out "insufficient
precision/slow convergence" as the cause: the breakdown is a genuine
algebraic singularity (a matrix that must be inverted becomes exactly
singular partway through the iteration), not a numerical-tolerance
artifact. Combined with the identical QZ failure, **two structurally
different solution algorithms both hit an exact wall on this model** —
strong, convergent evidence that this is a real mathematical property of
the linearized system, not an artifact of either algorithm.

**Conclusion: no further numerical-workaround avenue remains.** Every
solver-level lever available in Dynare 6.3 (QZ criterium range, cycle
reduction at any tolerance) has been tried and fails identically. The
issue is structural, not numerical, confirming the mechanism identified
above (`L`'s forward role duplicating `c`'s via the static labor FOC).

## 2026-07-29 — Evaluating GHH-style preferences

Per user instruction, evaluated (analytically, not by implementing and
testing) whether switching to GHH-style preferences would resolve the
Euler equation's redundant forward-variable problem, and whether GHH is
even compatible with the Gourio disaster-risk framework.

**Is GHH compatible with rare-disaster risk?** Yes, in principle. GHH
utility is typically written $u(C_t,L_t)=\frac{(C_t-\theta z_t
L_t^{1+\eta}/(1+\eta))^{1-\sigma}}{1-\sigma}$ in a trend-growth economy —
scaling the labor disutility term by the same trend $z_t$ that scales
consumption is the standard, well-established adjustment (used
throughout the GHH+growth literature) and would inherit the Gourio
disaster scaling on $z_t$ consistently, the same way the current model's
$(1-L_t)^\varpi$ term does implicitly (since $L_t$ is already stationary
and needs no rescaling). No structural incompatibility with rare-disaster
risk or Epstein-Zin recursive preferences generally — combinations of EZ
and GHH exist elsewhere in the literature. So GHH is *applicable*.

**Does GHH solve the redundant-forward-variable problem? No — it
relocates it, onto a variable that is provably in the same weak cluster.**
Under GHH, the labor-supply condition becomes wage-only,
$\theta L_t^\eta = w_t$ (no wealth effect — this is GHH's whole point).
But the marginal utility of consumption entering the Euler equation is
now $u_C = \hat C_t^{-\sigma}$ where $\hat C_t \equiv
C_t-\theta L_t^{1+\eta}/(1+\eta)$ — and substituting the wage-only labor
supply condition, $\hat C_t = C_t - \frac{1}{1+\eta}\theta^{-1/\eta}
w_t^{(1+\eta)/\eta}$. **The Euler equation's forward-looking term is now
$\hat C_{t+1}/\hat C_t$, which still requires $w_{t+1}$ explicitly** — GHH
does not remove the labor-market variable from the Euler equation, it
only changes its functional form from multiplicative
(`(1-L(+1))/(1-L)`) to additive (via the composite good). And critically,
`w` is exactly the variable already implicated in the second weakest
direction of the raw Jacobian (Finding 3: `w, mc, ktilde, Omega, L, Ne, y,
pireset, i` — precisely the labor-demand/production cluster `w` sits in
via eq(12)/(13)), and Test D already showed empirically that relocating
the forward role onto `w` makes the singularity *worse*, not better
(2 exact `Inf` eigenvalues instead of 3 large-finite ones). There is no
reason to expect a different outcome under GHH, since the same joint
circularity between labor supply and labor demand (now tighter under GHH,
since `L` is pinned by `w` alone with no consumption buffer at all) feeds
into the same weak cluster.

**Conclusion: GHH does not resolve the feasibility issue.** It is
technically applicable to this framework, but based on this analysis it
would relocate rather than remove the redundant-forward-variable problem,
onto a variable already shown empirically to make things worse. Per the
"if and only if" instruction, the deeper "impact on the thesis" analysis
was not pursued, since the evaluation is negative — switching would cost
real derivation and calibration effort (a full re-derivation of the
Bellman/SDF/labor-FOC block, replacing the well-verified Appendix B) for,
on this analysis, no expected improvement.

This still leaves the same fork: either a genuine re-derivation of a
*different* aspect of how the labor margin enters the Euler equation
(not GHH), or a documented numerical workaround, or accepting this is a
structural property of the model that may need to be reported as a
limitation.

## 2026-07-29 — Comparison against two earlier model versions

User supplied two earlier drafts (`thesis_model_v1.txt` and
`thesis_model_ent+bank_channel_v1.txt`, the latter claimed to have
"initially solved") and asked (a) whether Taylor projection (Levintal
2018 / Fernández-Villaverde & Levintal 2018) could sidestep the current
BK problem, and (b) whether reverting to either earlier draft is
advisable.

**Taylor projection:** does not sidestep the issue. It builds on a
first-order perturbation solution as its basis/starting point, so BK
must still hold at order 1 for exactly the reason it must hold before
attempting order 2/3 perturbation. Since the failure has been shown to
be structural (identical breakdown across two unrelated linear solvers —
QZ and cycle-reduction), a projection-based method sitting on the same
linear foundation would hit the same wall.

**Both earlier drafts actually tested (not just diffed) via Dynare:**

- `thesis_model_v1_old` (matches user-supplied `thesis_model_v1.txt`):
  fails BK identically to the current `v3` (8 unstable vs 7 forward),
  and in fact slightly worse — one eigenvalue is an exact `Inf` rather
  than large-finite. This version has the `CE`/`Dcal`/`Ecal`/`Theta`
  refinement but *not yet* the single-ratio rescaling of `v(+1)` in the
  SDF (uses `v(+1)^(-chi)*STEADY_STATE(v)^chi` as two separate factors,
  which the `v3` header already documents as producing a ~4.5e16
  derivative before Dynare's automatic differentiation even gets to
  combine them). Confirms the `v3` rescaling fix was necessary, but also
  confirms it does not resolve the deeper `L`/`c` redundancy.

- `thesis_model_entbank_old` (matches user-supplied
  `thesis_model_ent+bank_channel_v1.txt`, the claimed "initially solved"
  version): `check;` reports "rank condition verified" (7 unstable = 7
  forward) and `stoch_simul(order=3)` completes with finite (if large)
  `ghx`/`ghxx`/`g_3` matrices. **However**, the eigenvalue list itself
  contains a `1.105e+33` and a literal `Inf` — i.e. the same class of
  pathological eigenvalue seen in every other version, just landing on
  the side of the stable/unstable partition that happens not to trip
  Dynare's count check. Directly verified the mechanism: extracted the
  actual dynamic Jacobian and confirmed the `v(+1)` column has a nonzero
  entry *only* in the Bellman equation (row 2) — its entry in the SDF
  equation (eq 4) is **exactly zero**. This proves the term
  `v(+1)^(-chi)/(v(+1)^(1-chi))^(-chi/(1-chi))` in that equation is a
  literal algebraic identity that cancels to the constant 1 for every
  value of `v(+1)`, at every order — not a linearization artifact, an
  exact cancellation. This is precisely the failure mode the `v3`
  header's own `CE` auxiliary variable was introduced to prevent ("without
  this the EZ risk adjustment cancels identically at every order"). The
  entrepreneur/bank-channel draft predates that fix and has the bug it
  was designed to solve: its Euler equation carries **no Epstein-Zin
  risk-adjustment at all** — the central asset-pricing mechanism of the
  thesis is silently inert in this version, even though the model runs.

**Recommendation: do not revert to either earlier draft.** The `L`/`c`
redundancy identified earlier is present in all three versions (eq 5 is
identical throughout their history) and produces the same class of
huge/infinite generalized eigenvalues in every one of them — what
differs is only whether that eigenvalue happens to land in a position
that trips Dynare's crude count-based BK check. The entrepreneur/bank
draft "passes" only because disabling the EZ risk term elsewhere changes
the Jacobian's structure enough to relocate the problem, not because it
is fixed. Reverting would trade a diagnosable, honest failure (current
`v3`) for a silent one: the model would run and produce output, but the
Euler equation would not implement what Appendix B (correctly) specifies,
and this would not be caught by any Dynare check — only by comparing the
.mod file against the thesis text line by line, which is exactly the
supervisor-facing check this changelog exists to support.

## 2026-07-29 — Downsizing tests, and tracing the issue to the original IS2017 code

Per user request, explored downsizing the current model and testing
whether the BK failure is specific to the thesis's BGG/GK/sovereign
extensions.

**Test J — flatten the BGG external finance premium** (`chie`: 0.05 →
0.0001, near-zero leverage-elasticity). Still fails, 8 vs 7, unchanged.

**Test K — fix capital utilisation** (`u=1`, replacing the utilisation
FOC eq(20) with a trivial identity, removing the `eta` curvature
channel). Still fails, 8 vs 7 (with one eigenvalue now an exact `Inf`
rather than large-finite — slightly worse, not better).

**Decisive test — the original, unmodified IS2017 (2017, JEDC) replication
code**, found in `Isore-Szczerbowicz-2017-JEDC-codes_raw/`, run directly
(one syntax fix only: `resid(1);` → `resid;` for Dynare 6.3 compatibility,
no economic content touched). Findings:

- Their Euler equation (line 126) has the identical structure: `(c(+1)/c)^(-psi)
  * ((1-L(+1))/(1-L))^(varpi*(1-psi)) * ... * v(+1)^(-chi)/(v(+1)^(1-chi))^(-chi/(1-chi))`.
  The last factor is the *exact same* algebraic construction found in
  `thesis_model_ent+bank_channel_v1` and proven there to cancel to the
  constant 1. Directly extracted their Jacobian: the `v(+1)` entry in
  their own SDF equation is `1.75e-17` — zero to machine precision. Their
  published Epstein-Zin risk-adjustment term is inert, exactly like the
  thesis's earliest draft.
- Their own `check;` reports "rank condition verified" (9 unstable = 9
  forward — this model has no BGG/GK, so different variable count,
  `nsfwrd=9` including `Pkr`, `u` as forward variables via the household's
  own capital-investment FOC) — but the eigenvalue list contains **four
  literal `Inf` values**, more extreme than anything found in any version
  of the thesis model. The "pass" is again a count coincidence, not a
  genuine clean solve.
- Their own `stoch_simul(order=3, ...)` (no `pruning` option specified)
  computes the covariance matrix of shocks but then errors immediately
  afterward ("Not enough input arguments") in the custom ergodic-mean
  simulation code that follows — suggesting the published results may
  themselves rest on more fragile numerical ground than a clean solve.

**Conclusion:** this redundancy (`L`'s forward role duplicating `c`'s via
the static labor FOC) is not a bug in the thesis's implementation and is
not something downsizing the entrepreneur/bank/sovereign extensions can
fix — it is a **latent property of the underlying IS2017 + Epstein-Zin +
non-separable-labor framework itself**, present since the 2017 paper.
It has never had to be confronted before because the original paper's
own Euler equation construction happens to (apparently inadvertently)
disable the exact channel that exposes it. The thesis's `CE`-based
implementation is the more correct one — it is precisely *because* it
correctly implements the EZ risk-adjustment (which the original paper's
own code does not) that the latent redundancy surfaces as a real BK
failure rather than a masked one.

This reframes the fork-in-the-road: not "what did I do wrong," but "how
should the thesis handle a genuine, previously undocumented numerical
fragility in the framework it extends." Options being brought back to
the user: (1) match the original paper's approach (the degenerate EZ
term) with full transparency that this reproduces IS2017's own construction
and its limitation, clearly documented as inherited, not introduced; (2) a
genuine re-derivation of the labor margin using additively (not just
GHH) separable utility, decoupling marginal utility of consumption from
labor entirely — not yet evaluated; (3) a documented, flagged numerical
workaround; (4) presenting the finding itself (that correctly implementing
EZ risk-adjustment in this framework exposes a fragility the foundational
paper's own code does not confront) as a small methodological contribution
of the thesis.

---

## 2026-07-29 — "Matching IS2017" empirically tested and rejected; genuinely-separable utility re-confirmed infeasible

Per the user's explicit instruction ("consider whether framing the finding
as a contribution is as worthy as matching IS2017's own approach; if not,
follow the matching of 2017... but explore genuinely separable (non-GHH)
utility"), both branches were pursued. **Neither produces a working
model.** All new work below is in the scratch directory only —
`thesis_model_v3.mod` is UNCHANGED except for the previously-applied and
approved eq(23) fix.

### Branch 1: matching IS2017's own construction (three variants tested)

The evaluation itself (contribution-framing vs. matching) was decided in
favour of matching: claiming a methodological finding about a published
paper as a thesis contribution is a strong, unverified claim to lean on
under deadline pressure, whereas matching the published paper's own
construction is defensible by direct comparison. However, matching turns
out **not to be available** as a fix for the current (BGG+GK+sovereign)
model — it was only ever tested indirectly via `entbank_old`, an earlier,
less-refined draft, and that "pass" does not carry over:

- **Test L — remove `CE`, use `v(+1)` directly** (the literal IS2017
  Euler-equation construction, `v(+1)^(-chi)/(v(+1)^(1-chi))^(-chi/(1-chi))`,
  with `Dcal`/`Ecal` kept for the Calvo/bond-pricing refinements).
  Residuals exact zero (confirms the algebra is an identity, as expected).
  `check;` still fails: **8 eigenvalues > 1 for 7 forward-looking
  variables**, with two enormous eigenvalues (`6.4e16`, `5.9e17`) and one
  literal `Inf`.
- **Test M — Test L, plus reverting the `Theta`-based Calvo recursions
  (eqs 18/19) and the `Ecal`-normalised bond resilience (eq 29) to their
  pre-refinement, hand-built forms** (`zeta*Q*(1-theta*Deltak)*exp(muz)*...`
  in place of `zeta*Theta*...`; `Hb = 1-theta*Deltab*LambdaM` in place of
  `Hb = 1-theta*Deltab*LambdaM/Ecal`), with matching steady-state formula
  updates so residuals stay exact zero. **Still fails identically**: 8 vs
  7, eigenvalues `3.4e17`, `7.6e18`, `Inf`. This rules out the
  `Theta`/`Ecal` refinements as the reason `entbank_old` "passes."
- **Test N — instead of touching the SDF construction at all, directly
  eliminate the diagnosed root cause**: in eq(4), `(1-L(+1))` is replaced
  by `varpi*c(+1)/w(+1)` using the static labour-leisure FOC (5) evaluated
  at `t+1` — an exact identity, not an approximation (verified: residuals
  exact zero, steady state unchanged to 5 significant figures). This
  removes `L` as a forward-looking variable entirely (`L` no longer has
  any lead anywhere in the system) in favour of `w(+1)`, which is not
  independently duplicated by any other lead. **Still fails identically**:
  8 vs 7, eigenvalues `9.4e16`, `5.0e19`, `Inf`.

A direct Jacobian inspection of Test N confirms all 7 forward-looking
columns (`c, w, pi, X1, X2, v, RK`) have genuine nonzero derivatives
(none is a "fake"/zero-norm lead) — so the failure is not explained by any
single miscast variable. **Three independent, well-targeted structural
interventions, each addressing a different specific hypothesis, produce
the same qualitative failure (8 vs 7, one huge + one exact `Inf`
eigenvalue).** This is strong evidence the true singular direction is a
*deeper* structural feature of the EZ + Gourio-trick + non-separable-labor
construction that is not reachable by substituting out any one candidate
redundancy — consistent with (not contradicting) the earlier finding that
the *published* IS2017 code exhibits the same disease (4 literal `Inf`
eigenvalues, passing only by a count coincidence).

**Conclusion: "matching IS2017" is not a viable fix for this thesis's
model.** It was never actually tested against the current model before
(only inferred from `entbank_old`, a structurally different, less-refined
draft with its own uncorrected Euler equation — see below). Directly
applied to the current BGG+GK+sovereign specification, in three different
forms, it fails identically to the status quo.

`entbank_old`'s apparent "pass" is now understood to not be attributable
to CE, Theta/Ecal, or the L/c redundancy at all — its Euler equation
(`Q*(1-theta*Deltak)*exp(muz) = ... betatheta*exp((1-psi)*muz) * ...`) is
in fact a *different, uncorrected* SDF specification, missing the
`Ecal`/`Dcal` disaster-risk normalisation the thesis's own methodology
established as necessary (see the 2026-07-2x entries above, "Sovereign
resilience H^b uses the Ecal-normalised loading... so E_t[Q*R^b]=1 holds
exactly, not to first order in theta"). `entbank_old`'s 7=7 count is most
likely a coincidence of a smaller, differently-specified system rather
than a validated fix, and its own eigenvalue list separately contains a
literal `1.1e33` and `Inf` — i.e. it exhibits the same underlying disease,
just packaged with a different (and less correct) SDF equation. It is not
a model worth reverting to.

### Branch 2: genuinely (non-GHH) separable utility

Re-confirmed infeasible for the reason already logged: additive
separability of consumption and labour in the period-utility kernel
breaks the homogeneity-of-degree-`(1-psi)` structure that the Gourio
(2012)/Isoré-Szczerbowicz (2017) closed-form disaster-moment trick
(`Dcal`, `Ecal`) requires to integrate out the binary disaster indicator
in closed form. This is a more fundamental incompatibility than GHH's
"no wealth effect on labour supply" property — it is not a preference
choice that can be swapped in without rebuilding the entire SDF
derivation from scratch, which is out of scope for the remaining timeline.
No new evidence obtained this session changes this assessment.

### Branch 3 (new): a fourth, independent intervention — external habit formation

To test whether the excess unstable root is specific to the household/SDF
block at all (as opposed to a genuine new-dynamics probe), a minimal
external consumption-habit term was added on top of `thesis_model_v3`
(untouched CE/Dcal/Ecal/Theta): utility kernel
`((c-hab*c(-1))*(1-L)^varpi)^(1-psi)`, Euler ratio
`((c(+1)-hab*c)/(c-hab*c(-1)))^(-psi)`, labour FOC
`(1-L)/(c-hab*c(-1))=varpi/w`, `hab=0.001` (steady state re-derived
consistently, residuals exact zero). Unlike Tests L/M/N, this does not
eliminate any existing redundancy — it adds a genuinely new predetermined
state (`c(-1)`, previously unused anywhere in the model). Effect: exactly
one new, well-behaved stable eigenvalue appears (`0.0012`, consistent with
a small habit root), and the two/three previously huge eigenvalues become
three large-but-finite values (`3.9e16, 8.9e17, 1.4e18`, no more literal
`Inf`) — but **the count is still 8 unstable for 7 forward-looking**,
unchanged.

**This is the most informative negative result of the session.** Four
qualitatively different interventions — removing `CE`, hand-building
`Theta`/`Ecal`, eliminating `L`'s forward role via the static FOC, and
*adding* new genuine consumption dynamics via habit formation — all leave
the excess-unstable-root count exactly unchanged at 8 vs 7. Three of the
four only touch the household/Euler/SDF block. Since adding new dynamics
there (Test O) affects the eigenvalue *magnitudes* but not the *count*,
the excess unstable root is very unlikely to originate in the household/
EZ/SDF block at all. By elimination, the more likely location is the
entrepreneur/bank/sovereign block (eqs 22–31) — which is exactly the
block the user asked to have re-derived at the start of this debugging
session (before the CE/EZ investigation took priority) and which has not
been re-examined with the same rigour since the eq(23) fix.

### Branch 4 (new, decisive): the root cause is NOT in the household/SDF
### block at all — it is the BGG + Gertler-Karadi combination

Given that four independent interventions in the household/EZ/SDF block
all left the excess-unstable-root count unchanged, the household/SDF
block was ruled out as the location of the problem and the search moved
to the entrepreneur/bank/sovereign block (eqs 22-31), by elimination.

**Test P — pure IS2017+capital core, entrepreneur/bank/sovereign block
(eqs 22-31) removed entirely**, replaced with the plain frictionless
no-arbitrage capital condition `Q*(1-theta*Deltak)*RK(+1)=1`. The thesis's
own refined `CE`/`Dcal`/`Ecal`/`Theta` SDF construction is untouched.
**Result: SOLVES CLEANLY.** `check;` reports "7 eigenvalues > 1 for 7
forward-looking variables, rank condition verified" and `stoch_simul`
completes with a full, finite, sensible variance decomposition/
correlation/autocorrelation table. (Note: the eigenvalue list still
contains two literal `Inf` values even in this clean pass — this
confirms `Inf` eigenvalues are not inherently pathological in this
CE/Gourio-trick construction; what matters for Blanchard-Kahn is the
*count* matching the number of jump variables, not whether individual
generalized eigenvalues are finite.) **This decisively confirms the
excess-unstable-root problem does not originate in the household/EZ/SDF
block.**

**Test R1 — BGG entrepreneur block reinstated on top of Test P**
(`Ne`, `QS`, eqs 22-24 of v3), with the loan rate simplified to
`RS=Rf` (frictionless: entrepreneurs borrow directly from households, no
bank intermediation, no sovereign block). **Result: SOLVES CLEANLY**
(order 1, full valid `stoch_simul` output). **BGG alone does not break
BK.**

**Test R2 — Gertler-Karadi bank block reinstated on top of Test R1**
(`Nb`, `D`, `Rd`, eqs 26-28 of v3 with `QbB=0`, i.e. `phi=0`/no sovereign
bonds yet; loan rate `RS` now determined jointly by the leverage
constraint rather than fixed to `Rf`). **Result: FAILS, identically to
every other variant tested** — 8 eigenvalues > 1 for 7 forward-looking
variables, with one huge (`3.6e18`) and one exact `Inf` eigenvalue.
**This isolates the excess unstable root to the interaction of the BGG
entrepreneur block and the Gertler-Karadi bank block — neither alone is
sufficient, but combined they break Blanchard-Kahn.** (The sovereign
block, `phi>0`, was not even needed to reproduce the failure — it is
therefore exonerated as well.)

**Test R3 — attempted fix: `Nb(-1)` in the net-worth accumulation
equation (27) replaced by `QS(-1)/lam`**, using the binding leverage
constraint (26) evaluated at `t-1` (an exact identity given the
constraint holds every period) — the same style of substitution that
worked as a *hypothesis test* (though not as a fix) for the `L`/`c` and
`QbB`/`QS` redundancies earlier. **Result: still fails, now with *two*
literal `Inf` eigenvalues** (worse, not better). A direct Jacobian
extraction on Test R2 confirms the raw one-step Jacobian is full row
rank (33 of 33) — the singularity is not a naive linear dependence
visible in `g1` itself, but arises in Dynare's internal state-space
reduction (the (D,E) generalized-eigenvalue pencil), consistent with a
genuine economic over-determination rather than an algebraic typo.

**Economic interpretation:** BGG's external-finance-premium condition
(eq 22) and Gertler-Karadi's leverage constraint (eq 26) are two
*independent* binding constraints imposed on the *same* loan quantity
`QS` — the entrepreneur's demand for loans is pinned by their own
net-worth-to-capital ratio (BGG), while the bank's supply of those same
loans is *simultaneously* pinned by the bank's own net-worth-to-assets
ratio (GK leverage). Stacking both frictions on the identical security
this way is unusual relative to the literature: standard treatments use
either BGG (entrepreneurs borrow at a spread from a frictionless/
competitive banking sector) *or* GK (banks intermediate between
households and firms, with firms themselves frictionless) as the single
source of the external-finance wedge, precisely to avoid two
independent constraints jointly over-determining one quantity. This is
very likely the true, previously mis-identified root cause — not the
Epstein-Zin/CE construction, which is fully exonerated by Test P/R1.

### Branch 5 (correction, decisive): the culprit is the GK bank block
### itself, not the BGG+GK interaction — pinned down to a single equation

Per the discussion following Branch 4, the direction "keep the GK bank
block, drop BGG" was selected. Implementing and testing it (Test S: full
v3 with BGG's `Ne`/eq(22-24) removed, capital producers made frictionless,
bank+sovereign block otherwise untouched) **still fails identically**
(8 vs 7). This contradicts the Branch-4 hypothesis that BGG+GK *combined*
were the problem — the bank block alone is implicated.

Confirmed by direct, clean isolation:

- **Test T — pure core + frictionless capital financing + GK bank block,
  with NO BGG and NO sovereign/home-bias block at all** (not `phi=0`,
  which leaves the sovereign equations structurally present with a
  degenerate zero steady state and is not a valid "no sovereign" test —
  `QbB`/`Qb`/`Hb`/`Rb` were removed from the variable list entirely).
  **Still fails**, 8 vs 7, now with **three** literal `Inf` eigenvalues.
  This proves the GK bank block itself — independent of BGG and of the
  sovereign extension — is sufficient to break Blanchard-Kahn.
- **Test U — Test T with eq(27) (bank net-worth accumulation) replaced by
  `Nb = STEADY_STATE(Nb)`** (freezing net worth, keeping the leverage
  constraint `QS=lam*Nb` and the balance sheet `QS=Nb+D` untouched).
  **SOLVES CLEANLY**: "7 eigenvalues > 1 for 7 forward-looking variables,
  rank condition verified," `stoch_simul` completes. This pins the excess
  unstable root down to **eq(27) specifically**, not the leverage
  constraint (26) or the balance sheet (28).

**Economic diagnosis:** the model imposes the leverage constraint
`QS=lam*Nb` with `lam` a *fixed calibrated constant*, holding as a strict
equality every period — while *simultaneously* letting `Nb` evolve via
its own independent law of motion (retained earnings, eq 27). Given `QS`
is already pinned by the real side of the economy (capital demand,
`QS=Qtob*exp(muz)*k`), the system has three equations (leverage,
accumulation, capital demand) jointly determining what is, in a
correctly-specified Gertler-Karadi model, only two genuinely independent
margins. In the original Gertler-Karadi (2011) framework this doesn't
arise because the leverage ratio itself is *not* a fixed constant — it is
derived endogenously each period from the bank's own incentive/
enforcement constraint (a shadow-price condition), which moves with the
state of the economy rather than pinning `QS/Nb` at an exact fixed ratio
every period. This thesis's simplification (calibrating `lam` as a
constant target rather than deriving it from the bank's own FOC) is what
creates the exact one-degree over-determination, and it does so
regardless of whether BGG or the sovereign extension are present —
consistent with every test in Branches 4-5.

Two earlier substitution attempts targeting this same redundancy from a
different angle (Test Q: `QbB(-1)→phi/(1-phi)*QS(-1)`; Test R3:
`Nb(-1)→QS(-1)/lam`) did **not** resolve it — only fully removing the
*accumulation dynamics* (Test U) did. This shows the redundancy is not a
simple duplicated-lag algebra issue (fixable by substitution) but a
genuine over-determination from imposing a fixed leverage ratio
alongside independent net-worth dynamics — resolving it properly requires
either (a) deriving the bank's leverage ratio endogenously (the standard
Gertler-Karadi incentive-constraint derivation, a real but well-defined
piece of additional modelling work), or (b) accepting one of the two
mechanisms as non-binding/passive (e.g. reporting-only leverage, as in
Test U, at the cost of losing the amplification channel that binding
leverage is meant to provide).

### Branch 6 (RESOLUTION): endogenous Gertler-Karadi leverage, BGG removed
### -- applied to thesis_model_v3.mod, verified end-to-end

Following discussion of Branch 5, the direction chosen was: (1) keep the
GK bank block as the model's sole financial friction (BGG entrepreneur
block removed, capital producers frictionless), and (2) fix the actual
root cause properly by deriving the bank's leverage ratio ENDOGENOUSLY
from its own incentive constraint, rather than the reporting-only /
non-binding shortcut (Test U).

**Derivation.** With BGG removed, loans (`QS`) are a safe, pre-contracted
claim from the bank's perspective (the frictionless firm bears all
disaster risk on the real capital side; see eq 22's zero-profit
condition), so the bank's *only* disaster exposure runs through its
sovereign bond holdings (`QbB`/`Rb`). Home bias (eq 25) is kept exogenous
(fixes the `QS`/`QbB` split); only the *size* of the balance sheet
(leverage) is made endogenous. Standard Gertler-Karadi (2011) linear
value-function guess `V_t = etaB_t*A_t + nuB_t*Nb_t` (`A_t=QS_t+QbB_t`),
with the incentive constraint `V_t >= lambdadiv*A_t` binding:

```
(26)  QS + QbB = lev*Nb                                  [was: = lam*Nb]
(26a) OmB = (1-sigma_b) + sigma_b*(etaB*lev + nuB)
(26b) etaB = Q*OmB(+1)*((1-phi)*RS + phi*Rb(+1) - Rd)
(26c) nuB  = Q*OmB(+1)*Rd
(26d) lev  = nuB/(lambdadiv - etaB)
```

Discounting uses the model's own `Q_t` directly multiplying forward
terms (`OmB(+1)`), exactly the same convention already used for `Theta`
in eqs (18)-(19) -- no additional Gourio-collapsing was needed, since (a)
this model's own convention treats `Rb`, `RK` etc. as ordinary "realised,
x=0" forward variables without a separate discrete disaster-jump layer
(per the model's own "OPEN/FLAGGED" note: no perturbation-based
realisation of `x_t=1` ever fires), and (b) `RS`, `Rd` are period-t known
quantities that factor outside the conditional expectation trivially.

`lambdadiv` (the divertable-assets fraction) is not a free calibration
choice -- it is derived analytically in `steady_state_model` so that the
bank's incentive constraint binds exactly at the SAME target steady-state
leverage (4.0) the old fixed "lam" produced, giving bit-for-bit identical
steady-state values for every other variable (verified: `resid;` exact
zero for all 41 equations, including the 3 new ones).

**Two earlier hypotheses (Test Q: `QbB(-1)` redundancy; Test R3: `Nb(-1)`
redundancy) had failed to fix this by algebraic substitution alone --
correctly so in retrospect, since the actual problem was not a duplicated
lag but a missing structural equation (the bank's own FOC pinning
leverage), which substitution cannot supply.**

**Verification on the real `thesis_model_v3.mod`** (not just scratch):
- `resid;` -- exact zero on all 41 equations (both phi=0.10 and phi=0).
- `check;` at order=1, phi=0.10: **"9 eigenvalues > 1 for 9 forward-looking
  variables, rank condition verified"** -- clean, moderate eigenvalue
  spectrum (max finite eigenvalue ~3.6e18, comparable to pre-existing
  conditioning elsewhere in the model, no `Inf`).
- `stoch_simul(order=3, pruning)` -- completes for **both** phi=0.10 and
  phi=0, producing finite, sensible variance decompositions,
  correlations and autocorrelations.
- `run_thesis_model.m` -- driver updated (removed a stale `Ne` reference
  in the IRF plot list, replaced with `lev`, the new endogenous leverage
  variable) and run end-to-end for both scenarios plus GIRFs.

**One flagged fragility (not a failure, but worth watching):** at
`phi=0` (the counterfactual with no sovereign-bond holdings), `QbB=0`
identically, so `Rb(+1)`'s coefficient in eq(26b) is exactly zero --
`Rb`/`Qb`/`Hb` remain live variables (their own equations 29-31 are
unaffected) but their influence on bank leverage vanishes at exactly this
parameter value. `check;` still reports the rank condition verified
(9=9) and `stoch_simul` completes with finite output, but the eigenvalue
spectrum is much more extreme (`Inf`, ~7e22, ~9.8e22) than the phi=0.10
baseline (no `Inf`, max ~3.6e18). This mirrors the earlier finding
(Test P) that `Inf`/huge eigenvalues are not inherently pathological in
this model class as long as the count matches, but the counterfactual's
GIRFs should be inspected carefully for any signs of ill-conditioning
(e.g. compare 2nd-order vs 3rd-order results, or perturb phi slightly
away from exactly 0, e.g. phi=1e-4, if any concern arises).

**Classification: this is a deliberate modelling change, not a bug fix.**
The BGG entrepreneur block is REMOVED from the thesis's financial-
frictions story entirely (all original BGG equations preserved as
comments in the .mod file for reference); the GK bank block's leverage
constraint is now genuinely endogenous (time-varying with the state),
which is arguably a MORE faithful implementation of "Gertler-Karadi
(2011)" than the original fixed-`lam` version was, and removes the
external-finance-premium double-counting that caused the BK failure.
This should be written up in the thesis text as a substantive change to
Appendix B (eqs B.17-B.19 removed; B.21 replaced by the endogenous
leverage block above) and the model's economic narrative (no more
entrepreneur net-worth channel; the bank net-worth/leverage channel is
now the model's sole amplification mechanism for both the BGG-style
capital-financing risk and the sovereign home-bias risk).

### Where this leaves the thesis

**RESOLVED (2026-07-29).** The household/EZ/SDF block was fully
exonerated (CE construction, Theta/Ecal normalisation, the L/c
redundancy, and external habit formation were all tested there and none
changed the excess-unstable-root count). The problem was precisely
localised to **eq(27), the Gertler-Karadi bank net-worth accumulation
equation, in combination with the fixed-constant leverage constraint
(26)** — present with or without BGG, with or without the sovereign
extension — a genuine economic over-determination (a fixed leverage
ratio plus independent net-worth dynamics jointly over-pin the same loan
quantity), not fixable by algebraic substitution. The fix (Branch 6):
remove the BGG entrepreneur block (capital producers become frictionless,
consolidating the model's external-finance friction in the bank block)
and derive the bank's leverage ratio endogenously from its own incentive
constraint, per Gertler-Karadi (2011) itself, rather than calibrating a
fixed constant. This has been implemented in `thesis_model_v3.mod`,
verified to give exact-zero residuals, a clean Blanchard-Kahn pass (9
eigenvalues for 9 forward-looking variables) at order 1, and a completed
`stoch_simul(order=3, pruning)` for both phi=0.10 and phi=0, with
`run_thesis_model.m` running end-to-end. See Branch 6 above for the full
derivation, verification detail, and one flagged (non-blocking)
numerical-conditioning note at phi=0.

**2026-07-30**: first full steady-state/IRF/moments interpretation of this
resolved model is written up separately in `RESULTS_SUMMARY.md` (economic
interpretation, not debugging detail — kept there to stay out of this
technical log). That file also flags the open BGG-vs-Rannenberg(2016)
contribution question raised alongside it.

---

## 2026-07-30 — Testing BGG re-addition on top of endogenous GK
### (Rannenberg 2016-style double financial accelerator)

The user pointed out that Rannenberg (2016) combines BOTH a BGG-style
entrepreneur external-finance premium AND a Gertler-Karadi-style bank
leverage constraint successfully (without disaster risk), and asked
whether the earlier conclusion that BGG had to be dropped was too hasty.
This is correct, and the reasoning is worth spelling out precisely: the
original BK failure (Branch 5/6) was never caused by BGG and GK being
structurally incompatible — it was caused specifically by combining a
**fixed, calibrated leverage ratio** (the old constant `lam`) with an
**independent net-worth accumulation equation**, which over-determines
the model by exactly one degree regardless of what sits on the
entrepreneur side. Rannenberg (2016) avoids this because his bank
leverage is *also* endogenous (derived from the bank's own incentive
constraint, as in Gertler-Karadi 2011 itself), not a fixed constant. Since
Branch 6 already replaced the fixed `lam` with an endogenous leverage
block, re-adding BGG on top was a genuinely open, testable question, not
something already ruled out.

### Test W — BGG reinstated on top of the endogenous-GK model

Built directly on the validated Branch-6 endogenous-GK specification
(scratch: `test_V_endogGK.mod` → `test_W_BGGplusGK.mod`), re-adding:
- var `Ne` (entrepreneur net worth) back into the variable list;
- parameters `chie, premE, levE, sigma_e, f0, iotae` back (BGG
  calibration), kept **separate and distinct** from the bank's own
  `sprL`-based loan spread (two independent margins, as required for a
  genuine double accelerator, not a relabelling of one friction as two);
- eq(22): the BGG external-finance-premium condition reinstated exactly
  as in the original thesis (entrepreneur leverage `Ne/(Qtob*k)` sets its
  own premium over the bank loan rate `RS`), replacing the frictionless
  zero-profit condition;
- eq(23): entrepreneur net-worth accumulation reinstated exactly as
  before BGG was removed;
- eq(24): `QS = Qtob*exp(muz)*k - Ne` (bank loans = capital value net of
  entrepreneur equity, restoring the original BGG balance-sheet identity);
- steady state: `RKtildess` restored to use `premE*RSss` (entrepreneur's
  own premium over the bank's own loan rate `RSss=sprL*Rdss`) instead of
  the frictionless `RSss` directly; `QSss = knss - Ness` (net of
  entrepreneur equity) instead of `QSss = knss`. The endogenous bank
  leverage block (eqs 26/26a-d, `etaB`/`nuB`/`OmB`/`lambdadiv`
  calibration) is otherwise **completely unchanged** from Branch 6.

**Result: SOLVES CLEANLY.** Verified, not assumed:
- `resid;` — exact zero on all 42 equations (42 vars = 42 eqs: the 41
  from Branch 6 plus `Ne` and its reinstated accumulation equation).
- `check;` at order=1 — **"9 eigenvalues > 1 for 9 forward-looking
  variables, rank condition verified"** for `phi=0.10`, moderate spectrum
  (max finite eigenvalue ~9.4e17, comparable to the no-BGG version — no
  new degeneracy introduced by re-adding BGG).
- `stoch_simul(order=3, pruning)` completes for **both** `phi=0.10` and
  `phi=0`.
- `phi=0` shows the **same** conditioning fragility already flagged for
  the no-BGG version in `RESULTS_SUMMARY.md` (an `Inf` and two ~1e20
  eigenvalues, vs. a clean spectrum at `phi=0.10`) — i.e. this is a
  property of the `phi=0`/no-sovereign-bonds corner case interacting with
  the endogenous bank leverage block, not something introduced or made
  worse by BGG.

### Conclusion: this is now a genuine two-way choice, not a forced one

Both specifications are empirically validated and available:
1. **No BGG** (current `thesis_model_v3.mod`): sole friction is the
   endogenous GK bank leverage constraint; cleaner single-mechanism
   identification of the sovereign-bank-disaster channel.
2. **BGG + endogenous GK** (Test W, not yet applied to
   `thesis_model_v3.mod`): a genuine double financial accelerator
   (entrepreneur leverage premium + bank leverage premium, two distinct
   margins), extending Rannenberg (2016) to a rare-disaster setting with
   an added sovereign-bank channel on top.

This decision affects the Appendix A/B/C rewrite directly (which
equations exist, how many financial-friction parameters need justifying,
and which contribution framing — "clean sovereign-bank channel" vs.
"double accelerator extending Rannenberg (2016) to disaster risk" — the
thesis leads with) and, since Test W succeeded (contrary to the working
assumption going in), was a genuine open choice put back to the user.

### DECISION (2026-07-30): BGG + endogenous GK, applied to `thesis_model_v3.mod`

The user's call: keep BGG + endogenous GK (the double accelerator).
Rationale, as instructed to weigh on rigour/consistency rather than
novelty-seeking: the thesis's own already-written literature review
argues specifically for combining BOTH frictions — "the separation of
bank net worth N^b and entrepreneur net worth N^e, which makes it
possible for the sovereign-bank channel through N^b and the financial
accelerator N^e to function at the same time" — and BGG/GK remain a
financial-frictions layer on top of the IS2017 core either way, so
keeping both does not shift the thesis's primary anchor away from
Isoré-Szczerbowicz (2017). Rannenberg (2016) is added as a supporting
citation for why this specific two-margin combination is theoretically
sound (both leverage ratios endogenous, not fixed), not as a competing
anchor for the thesis's framing.

Test W's changes were applied to the real `thesis_model_v3.mod`
(previously in the no-BGG, Branch-6 state) — reinstating `Ne`, `chie`,
`premE`, `levE`, `sigma_e`, `f0`, `iotae`, eqs (22)-(24) in their original
BGG form, on top of the endogenous GK leverage block (eqs 26/26a-d,
`etaB`/`nuB`/`OmB`, `lambdadiv`) which is unchanged from Branch 6.
Re-verified on the real file (not just scratch):
- `resid;` — exact zero on all 42 equations.
- `check;` at order=1 — 9 eigenvalues for 9 forward-looking variables,
  rank condition verified, phi=0.10 (max finite eigenvalue ~3.4e18, no
  new degeneracy from reinstating BGG).
- `stoch_simul(order=3, pruning)` completes for both phi=0.10 and phi=0.
- `run_thesis_model.m` runs end-to-end for both scenarios (plot list
  updated: `Ne` restored, in place of `Qb` to keep the 4x3 grid at 12
  panels — `Qb`'s information is already summarised by `spread`/`Hb`).

`thesis_model_v3.mod`'s header comment block has been updated to
describe this final state (BGG+GK double accelerator, endogenous
leverage). Next step: rederive Appendix A/B/C to match this specification
exactly, in the user's own derivation/notation style, documented as its
own changelog subsection for full retraceability.

---

## 2026-07-30 — Appendix A review vs. the final model; numerical test of
### the "perceived risk without realised default" channel

Reviewing Appendix A equation-by-equation against `thesis_model_v3.mod`
(user handling the mechanical LaTeX edits directly): A.1 (Households) and
A.2 (Firms) are untouched by the BGG/GK work and match exactly. A.3.1
(entrepreneurs/BGG, eq. A.3.1.1-A.3.1.6) matches the reinstated BGG
equations in the .mod file verbatim. A.3.2.2-A.3.2.3 (banker value
function, incentive constraint) already derive, in prose, the EXACT
theory now implemented in Dynare (ν_t, η_t, Ω_t, λ_t=ν_t/(θᵇ-η_t)) — the
fix did not introduce new theory, it made the .mod file actually
implement what this section already derived, rather than the "baseline
implementation... λ_t=λ fixed" approximation described in the paragraph
immediately after eq. (A.3.2.3), which is now factually outdated. Two
further mechanical inconsistencies found: eq. (A.3.2.5) uses R^d_t
(current) where Appendix B's already-corrected eq. (B.23) and the .mod's
eq(27) use R^d_{t-1}; eq. (A.5.4) and its companion prose write the loan
supply identity with constant λ where it should now read λ_t.

**Numerical test of whether perceived risk (without realised default) can
move the model — the question behind Appendix A.3.3's propagation-chain
claim that the mechanism "operates through realised sovereign default,
not through perceived risk alone."** Order-1 IRF to a `+1 std etheta`
shock, impact period (t=0) values:

```
          t=0        t=1        t=2        t=3        t=4
lev    0.014793   0.040365   0.056938   0.066111   0.070072
QS     0.008183   0.015066   0.018462   0.020449   0.021719
QbB    0.002046   0.003767   0.004615   0.005112   0.005430
Nb     0.000000  -0.002269  -0.004073  -0.005038  -0.005326
etaB  -0.001814  -0.001060  -0.000457  -0.000042   0.000224
nuB    0.011801   0.016647   0.019329   0.020487   0.020642
Qb    -0.006433  -0.004168  -0.003010  -0.002300  -0.001815
Rb     0.000000   0.006661   0.004316   0.003116   0.002382
```

`Nb` (bank net worth) is **exactly zero at impact** — a true
predetermined state, it cannot respond contemporaneously. `lev`, `QS`,
`QbB`, `etaB`, `nuB` all move **immediately**, before `Nb` has changed at
all — because `lev` is a jump variable (η_t depends on `E_t[R^b_{t+1}]`,
a forward-looking object). By period 5 this impact-period jump in `lev`
(0.0148) is ~21% of the eventual peak response (0.0706) — quantitatively
material, not noise. `Rb` itself is zero at impact (it depends on
`Qb(-1)`, the pre-shock price) and only moves from t=1 — consistent with
a *second*, lagged mark-to-market channel operating through realised
bond returns into `Nb`'s accumulation equation, separate from the
leverage channel.

**Conclusion: the "realised default only" claim in Appendix A.3.3 is
incorrect for the model as implemented.** Two distinct channels are
present: (1) an immediate perceived-risk channel operating through the
now-endogenous bank leverage margin (η_t/ν_t respond to *expected* future
bond returns), and (2) a lagged mark-to-market channel operating through
bank net worth (as `Rb` falls following a `Qb` decline). Notably, a
sentence describing channel (2) already exists in Appendix A, currently
commented out, superseded by the (now incorrect) "realised default only"
claim a few paragraphs later. Recommendation: this strengthens rather
than weakens the thesis's contribution — "perceived risk transmits via
leverage immediately, realised losses transmit via net worth with a lag"
is a richer and more literature-consistent finding (matches IS2017's own
headline claim that perceived risk alone can generate recessions) than
"only realised default matters." The propagation-chain paragraph and the
suppressed sentence should be revised to reflect both channels, not one.
