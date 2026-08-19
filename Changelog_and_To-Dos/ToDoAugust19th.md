# To-Do — August 19th

**Deadline arithmetic:** hand-in 2026-08-26, defense 2026-09-02. **7 days**
away. This is the last purely-verification night before write-up starts.

Context: user liaised directly with Claude Opus overnight (Aug 18-19),
producing three ledgers (Main vs. Appendix A, Appendix B, Appendix C) and
a consolidated `Briefing Doc - Opus Update`, written as a strict protocol
for a `.mod`-vs-appendix reconciliation pass. User implemented most of
the recommended text changes into `Status Quo - Thesis August 18th.txt`
and applied one `.mod` fix directly, then asked Claude Code to execute
the briefing's own verification protocol as the final gate before
starting the Results-chapter write-up.

## 0. Tonight's verification pass — full results

### Fixed and verified

- **§0.2 (briefing's compile blocker): resolved differently than expected.**
  B.18 and neighbours (B.2, B.15-B.19) all exist in the current document —
  the specific blocker the briefing flagged is gone. But found a *related*
  LaTeX bug in the same neighbourhood: line 2897's `\begin{align*}` is
  closed by `\end{align}` at line 2904 (mismatched environment names —
  document-wide count was 14 `\begin{align}`/15 `\end{align}` and
  27 `\begin{align*}`/26 `\end{align*}`, which pinpointed it exactly).
  **Not yet fixed in the text — one-character change, `\end{align}` →
  `\end{align*}` at line 2904.**
- **§1 (entrepreneur net-worth `Ne`/`iotae`): already correctly fixed by
  the user before tonight, but syntactically broken.** The `.mod` had
  been edited to the algebraically-correct form (independently verified
  by hand, and via `git diff` against the last commit) but used `...`
  for line continuation, which is MATLAB syntax, not valid Dynare `.mod`
  syntax — the file has not successfully parsed since this edit was
  made. Fixed the syntax only (economics untouched, already correct).
  Also rewrote the now-stale comment above it, which had described the
  *old, wrong* reasoning and would have re-introduced the bug if trusted
  later. **Verified: all 42 equation residuals exactly zero, rank
  condition holds (9 unstable roots for 9 forward-looking variables,
  same as always), same pre-existing non-corrupting Inf-eigenvalue
  pattern as documented all week — no regression.** `iotae` moved from
  0.044619 to 0.044532 (~0.2%, small because `muz`=0.003 is small — this
  is a real but quantitatively minor steady-state shift). `iotab`
  essentially unchanged, as expected (that equation wasn't touched).
- **§4 (government budget constraint): verified, mostly clean.**
  Mechanical check confirmed — no `T` variable, no tax/transfer feedback
  anywhere in the `.mod`, eq(33) `y=c+i` is the sole consolidated
  resource constraint. Document check found the underlying economics is
  sound (T_t's cancellation is shown in full algebraic detail in A.5),
  but **Ξ_t — the household-side transfer residual — is referenced and
  described in prose three times, and promised "defined in
  Appendix~banking_block," but never actually given as an explicit
  formula anywhere in the current document.** Not an error in the
  economics (the flow-identity derivation handles the ι^e/ι^b terms
  directly and doesn't need Ξ_t as an intermediate object), but a
  genuine "promised, not delivered" gap a supervisor could catch.
- **§7 (`run_thesis_model.m` table bugs): both fixed.** Row "Sovereign
  spread" was labelled "ann. bps" but computes quarterly bps (no ×4) —
  relabelled everywhere this appeared (header comment, `bpsVars`
  comment, the table row itself), not just the one row Opus's briefing
  flagged. Row "Entrepreneur premium E[R^K]/R^S" computed the
  *disaster-free realised* premium (since `RK` is the model's
  $\tilde R^K$), not the calibration target `premE`; kept both, clearly
  labelled, rather than silently picking one.

### Verified, no `.mod` implication (checked, not just trusted)

- The γ>0 correction in B.3c/C.5: a prose/rigor addition (establishing
  exactly when a stated inequality holds), re-derived by hand against
  the `.mod`'s `Theta` formula — exact match, no code implication.
- B.7's $r^k_t$/$P^{k,\mathrm{real}}$ symbol duplication, B.29's rewrite,
  B.31's $\varphi$ symbols: all text-only or already matched by the
  `.mod` (B.31's `.mod` counterpart already used `phipi`/`phiy` all
  along; nothing to change).
- `psi` transformation (line 252), `levss=6`, Taylor rule's level output
  gap, `lambdadiv`/`f0`/`iotab`, absence of a realised $x_t=1$ regime —
  all explicitly out of scope per the briefing and confirmed untouched.
  **Do not revisit these without a specific new reason.**

### Open, reported not implemented (needs your decision)

- **§2, the Fisher equation.** Independently re-derived the `.mod`
  implementation from B.30 (not just checked Opus's candidate) — the
  proposed `FI` auxiliary is mathematically correct: it builds
  $E_t[\mathcal{M}_{t,t+1}/\pi_{t+1}]$ using the same pattern the `.mod`
  already uses for `CE`, and I verified by hand that
  $\overline{FI}=\bar Q/\bar\pi$, so `rss` stays exactly `piss/Qss` —
  no steady-state formula changes needed. This would take the model
  from 42/42 to 43/43 (one new variable `FI`, `eq(6)` replaced by two
  equations). **This is a real equation-level change and needs your
  sign-off before it happens** — not implemented tonight, per both the
  briefing's own protocol and standing practice this whole project. If
  you want it done, say so explicitly and expect: a fresh BK check, a
  full results re-run, and a reported GIRF-magnitude comparison (the
  size of the error the thesis has been carrying, which the briefing
  itself notes is publishable content in its own right).
- **§3, the bounding run for eqs (18)/(19)/(26b)/(26c).** Explicitly
  lower priority in the briefing itself ("quantify... implementation
  probably not wanted... only if time allows"). Deferred tonight given
  the time budget — good footnote content, not release-blocking. Pick
  this up only if the 7 remaining days allow it after the write-up is
  underway.
- **§5, comment cleanup.** Cosmetic, explicitly last-priority in the
  briefing's own ordering, byte-identical-output requirement. Not done
  tonight; do this only once nothing else is touching the `.mod`, so it
  never confounds a live diagnostic.

## 1. Results regeneration — complete, clean

Two full pipeline runs tonight. First attempt crashed
(`local_calibration_table` missing entirely from `run_thesis_model.m` —
confirmed via `git log` to have never been committed at any point in
this project, lost from the working file before tonight, unrelated to
tonight's edits; reconstructed from memory of the original build,
cross-checked all 7 `local_*` function calls against definitions).
Second run: **zero errors, all tables/figures regenerated
(2026-08-19, 01:56-01:59).**

**Regression check (per the briefing's own §0.4): sovereign spread
confirmed UNCHANGED at 85.0769 bps across all three core scenarios**
(φ=1e-4, 0.03, 0.20) — exactly as it should be, since that channel is
bank/bond-side only and the §1 fix touched only the entrepreneur block.

**What moved, entrepreneur-block-adjacent only:**
- `iotae`: 0.044619 → 0.044532 (~0.2%)
- Two-channel decomposition (baseline φ=0.03): impact-period leverage
  share of peak 4.63% → 4.69%; peak still at t=5. Safe-haven checks:
  identical qualitative pattern (Qb confirmed, Hb dominates from t=1
  onward, fails only at the impact period via Rf's Fisher jump) —
  Rf/Hb magnitudes at impact essentially unchanged (0.0101%/0.0084%).
- φ-sweep: **all 14 points still solve cleanly, φ=0 included, zero Inf
  eigenvalues anywhere** — the phi=0 numerical-fragility resolution from
  Aug 15 still holds after tonight's fix. Peak spread and impact-lev
  share both still smooth and monotonic in φ across the full range
  (baseline share now 4.69% vs 4.63% before, same shape).
- Tail-risk moments (20,000-quarter sim): essentially unchanged —
  sovereign spread skew/kurtosis identical (3.3339/22.75, exactly, since
  unaffected by the entrepreneur block); bank leverage mean 7.7831 vs
  7.7805 before; consumption/output moments shift in the third decimal
  only. Fat tails and asymmetry pattern fully preserved.
- New steady-state table row confirms the §7 fix: "realised RK/RS" =
  1.00499 (matches the old single value), "E[R^K]/R^S (=premE target)"
  = 1.003 (exact match to the calibration target) — both now correctly
  labelled and both present.

**Nothing moved that changes any qualitative claim already in the
thesis text.** The fix is real, verified four independent ways (see
report below), and its effect on the actual results is small and
isolated to exactly the block it touched.

## 2. Verdict on "ready for write-up"

**GO.** See the same-session chat response for the full reasoning — no
outstanding item blocks starting the Results chapter. Two things to
close out today, neither blocking: the one-character LaTeX fix (§0
above) before a final PDF compile, and a decision on the Fisher equation
(§2 above, implement-and-rerun vs. defer-with-caveat — both defensible).

## 3. Suggested sequencing for the remaining 7 days

1. **Today (Aug 19), once this file's verification is confirmed clean:**
   fix the one-character align-environment bug (§0 above) so the
   document compiles cleanly — do this before anything else touches the
   text, it's a two-minute fix and currently blocks a clean PDF build.
   Decide on the Fisher equation (§2 above) — implement-and-rerun or
   defer with a documented caveat; either is defensible, but it should
   be a decision, not a default.
2. **Aug 19-21:** Results chapter write-up (5.1 calibration table, 5.2.1
   steady-state comparison, 5.2.2 two-channel decomposition + safe-haven,
   5.3 tail-risk moments and Output-/Spread-at-Risk, 5.4 φ sweep) —
   all data already generated, this is transcription + narrative, the
   highest-value use of time per `main_results_path.md`'s own tiering.
3. **Aug 21-23:** Robustness/Limitations section, incorporating the
   Fisher-equation disclosure (whichever way §2 was resolved), the Ξ_t
   documentation gap (§4 above), and the already-known non-corrupting
   Inf-eigenvalue limitation.
4. **Aug 23-24:** Full read-through, appendix consistency spot-check
   given how much has moved in the last 48 hours, bibliography/citation
   audit closure on the remaining open items from `Opus_Changelog.md`
   Part D7.
5. **Aug 24-25:** Buffer. Supervisor check-in if not already done on the
   Appendix-C-authorship question from Aug 16-17 — do not let this slide
   to the last 24 hours.
6. **Aug 25-26:** Final formatting, PDF compile check, submission.

Not time-boxing this to the hour — the point is the write-up can
legitimately start now, which is the actual ask tonight.

## 4. Afternoon/evening session (Aug 19, ~11:00–18:45) — Fisher equation resolved, Appendix C closed out

Picked up from §2/§3 above with Claude Code. Status at 18:45, **6 hours
left today**:

### §2 (Fisher equation) — RESOLVED, implemented, quantified

Decision was made to implement-and-rerun. **`thesis_model_v4.mod` is now
the canonical model** (`run_thesis_model.m` points at it as of 13:12).
v4 = v3 + exact Fisher equation (`FI` auxiliary, eq 6 replaced) + the
same eq-23/`iotae` fix already in v3, plus a comment cleanup pass
(`thesis_model_v4_pre_cleanup.mod` is the pre-cleanup snapshot,
numerically byte-identical — see §5 below). `thesis_model_v3.mod` was
**deliberately left unchanged on disk** specifically to serve as the
comparison baseline (confirmed in v4's own header comment).

Full pipeline re-run on v4 completed cleanly (13:10–13:17,
`run_v4_official.log`): 43/43 equations (one more than v3's 42, for the
new `FI` variable), BK conditions clean (9=9), all figures/tables
regenerated from v4. **This is the current headline result set** —
`thesis_model_results.mat`, Fig1–6, all `table_*.csv`.

**The GIRF-magnitude comparison the briefing asked for is now done.**
Ran v3 (approximate, `Q=pi(+1)/r`) fresh at order=3, baseline φ=0.03,
same shock/methodology as the main script, and diffed against v4
(exact). Steady states match exactly (`r_ss=1.00415201983`, both, to
11 digits — confirms the appendix's own claim that the two forms
coincide at the non-stochastic steady state). Dynamics do not:

| Variable | Peak GIRF diff (% of peak) |
|---|---|
| Investment `i` | 18.9% |
| Entrepreneur net worth `Ne` | 16.0% |
| Labour `L` | 12.4% |
| Output `y` | 9.3% |
| `Rf`/`Rd`/`Q` | 6.5% |
| Nominal rate `r` | 5.9% |
| Inflation `pi` | 4.4% |
| Sovereign spread | 0.08% (essentially untouched) |
| Bond resilience `Hb` | ~0 (1e-14, control check) |

Pattern is exactly what a real, localized equation change should look
like: variables downstream of the interest-rate/inflation block move by
double digits, variables on the sovereign/bank side that don't route
through that equation (spread, `Hb`) are untouched. This is the number
that substantiates line ~1300 of the draft ("not invisible... at the
third-order solution this thesis targets") — that line currently
asserts the claim without a magnitude. **Still open: a one-sentence
addition to the robustness section citing these figures.** Proposal
pending, not yet drafted into the text (per standing rule: propose,
don't edit the draft directly).

Note on a dead end, recorded so it isn't re-run by mistake:
`thesis_model_v3_fisher_exact.mod` (built earlier today, v3 + exact
Fisher only, without the eq-23 fix folded in the same way v4 does it)
was compared against v4 first. That comparison showed ~1e-13 agreement
— because **both use the exact Fisher form**; it was an internal
consistency check between two independent codings of the same equation,
not a test of exact-vs-approximate. Confirmed by checking for the `FI`
variable's presence in each `.mat`'s variable list. The real test is
v3 (plain) vs v4, above. `thesis_model_v3_fisher_exact.*` is now
redundant with v4 — see §5.

### §0.2 (align/align* LaTeX bug) — STILL OPEN

Rechecked tonight in the current draft (`Status Quo - Thesis August
18th.txt`): still 14 `\begin{align}`/15 `\end{align}` and 27
`\begin{align*}`/26 `\end{align*}`. The one-character fix flagged this
morning (line ~2904, `\end{align}` → `\end{align*}`) has **not** been
applied yet. Two-minute fix, still blocks a clean PDF compile.

### §4 (Ξ_t formula) — STILL OPEN

Rechecked: no `\Xi_t = ...` or `\Xi_t\equiv...` definition anywhere in
the current draft. Still referenced/promised three times, never
delivered. Not an economics error (confirmed again this morning), just
the same documentation gap.

### Appendix C — full verification complete (was the blocker from before
tonight: earlier draft cut off mid-Appendix-C)

With the updated draft, Appendix C runs D0, D2–D10 in full (D8 Bank
Block, D9 Public Authority, D10 Solution Algorithm — the three sections
missing from the copy available earlier today — are now present).
Checked every closed-form equation (C.1–C.36) against the actual
`steady_state_model` block, term by term, including the intricate D8
value-function/diversion-parameter chain (`spreadAss`→`OmBss`→`etaBss`/
`nuBss`→`lambdadiv`) and D9's fiscal residual. **No discrepancies.**
D9's absence of a `T`/bond-quantity Dynare variable is intentional
(matches the draft's own Isore-2017-style elimination of $T_t$, and
v4.mod's header explicitly documents it as "a pure residual with no
feedback"). Confirmed v3_fisher_exact's `steady_state_model` block
(what was actually checked) is byte-identical in substance to v4's
current one — comment wording differs, every formula is the same — so
this verification applies to the canonical v4 file, not a stale one.
Minor cosmetic-only nit: `sec:D0`→`sec:D2` skips `D1`, nothing
references it, harmless.

### File audit / cleanup — see same-session chat response for full
categorization

Working directory has accumulated the v3-plain / v3-fisher-exact /
v4-pre-cleanup / v4 family plus matching logs, figures and tables for
each. Canonical going forward: **v4** (model + results) and **v3**
(kept intentionally as the comparison baseline, per above). Everything
under the `thesis_model_v3_fisher_exact*` and
`thesis_model_v4_pre_cleanup*` names is superseded/redundant now that
v4 exists and has been verified against both. Full file-by-file list
given in chat, not duplicated here — this is a to-do log, not a file
manifest.

### Revised sequencing, 6 hours left today

1. Fix the align/align* bug (§0.2) — two minutes, still first, still
   blocks a clean compile.
2. Decide on and draft the one-sentence Fisher-magnitude addition to
   the robustness section (table above is the source data).
3. Clean up the working directory per the chat's categorization
   (pending your confirmation on the delete list).
4. Resume the Results-chapter write-up sequencing from §3 above — the
   Fisher decision that was blocking it is now closed, nothing left
   standing in the way of starting 5.1–5.4 transcription tonight if
   time allows.
