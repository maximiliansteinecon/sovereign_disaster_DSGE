# To-Do — August 11th

Carries forward everything unresolved from `ToDoAugust10th.md` (kept
intact). Reviewed today's evening update
(`status_quo_thesis_august_10th_evening.txt`) by diffing against the
morning version, not re-reading from scratch. Every item below is
time-stamped with an honest estimate of how long it will actually take —
use these to plan tomorrow, not as a schedule I'm imposing.

**Deadline arithmetic:** hand-in 2026-08-26, defense 2026-09-02.
"Everything substantive done" by 2026-08-19 — **8 days** from tomorrow.

## 1. Genuine progress today, verified against the diff — no action needed

Typo fixes (undertanding, standardtandard, leisre, regrads, againts),
the `Isore2013`→`Isore2017` sourcing fix, the duplicate-sentence removal,
the orphaned em-dash fragment removal, and `Delta^b` 0.3→0.37 in the
prose are all confirmed done. The banking-block paragraph and the
EIS paragraph are both integrated, in your own words, matching the
substance of what was discussed. Good session.

## 2. New, must-fix — found today, ~10-15 min total

- [ ] **`beta_0` contradiction is back, in a new and more confusing
      form.** Table now reads `$\beta_0$ = 0.9985`, sourced to
      `\textcite{Bernanke1999, Gertler2011}`. The prose then says *"I
      follow the exact specification ($\beta_0=0.9985$)... However,
      choosing a discount value with \textcite{Isore2017} $\beta_0=0.99$
      as in \textcite{Isore2017}, we can confirm their argument..."* —
      this reads as using both values at once. **Checked directly
      against `thesis_model_v3.mod` right now: it still has
      `beta0 = 0.99`.** So the table's 0.9985 doesn't match what's
      actually implemented. Recommend reverting the table to 0.99 /
      `\textcite{Isore2017}` and cutting the confusing "However" sentence
      entirely — you already have a clean one-liner for this
      ("\textcite{Isore2017} argue this parameter plays no severe role
      in the results and we confirm so for our set-up") a few lines
      below; you don't need both. **Est.: 5 min.**
- [ ] **Table 1's footnote lost a clause and now reads as a broken
      sentence:** *"...themselves attribute each value. euro-area-specific
      estimates; replacing these with euro-area data-derived target
      moments is ongoing work..."* — the sentence introducing
      "euro-area-specific estimates" (something like "$^\dagger$Values so
      marked are currently generic US/BGG-literature targets rather
      than...") appears to have been deleted along with the banking-block
      table rows, but this trailing half-sentence was left behind.
      **Est.: 5 min** — either restore the missing clause (if the
      $^\dagger$ system still applies to Table 2) or cut the dangling
      fragment.
- [ ] **Confirm intentional: the entire "Banking, entrepreneur & sovereign
      block" section (8 rows: `Delta^b` through `sigma^b`) was removed
      from Table 1.** This is very likely a deliberate cleanup now that
      the same rows live in Table 2 (`tab:calibration_frictions`) —
      consistent with your own "I will clean overlaps out" plan — but
      flagging so it's a conscious check, not an assumption. **Est.: 2 min**
      to confirm Table 2 still has all 8 rows (it did as of Aug 6) and
      Table 1's own intro sentence doesn't still promise banking-block
      content it no longer contains.

## 3. Your in-progress work: paper-vs-`.mod` calibration comparison

You said you're mid-way through comparing the document's calibration
against `thesis_model_v3.mod` and confirming it still solves. Not
independently re-verified by me today beyond the `beta_0` spot-check
above (found because it was directly relevant to the contradiction).
**Est.: unknown — depends how far through you are; budget 30-60 min to
finish a full parameter-by-parameter pass if not already done,** and
ping me for a fresh Dynare solve-check once you've made any `.mod`
changes (order=1 quick check ~1 min, order=3 pruning ~15s once solving).

## 4. Carried forward from `ToDoAugust10th.md`, still open

- [ ] `phipi`/`phiy` Source column citation → `\textcite{Isore2017}`
      (value itself already confirmed correct). **Est.: 2 min.**
- [ ] NAWM II citation (`Coenen2018` or similar key) not yet added to
      `bibliography.bib`; `sigma^b`/`R^S/R^d` re-citation and the
      loan-spread-target decision (80bp vs. NAWM II's ~217bp) not yet
      made. **Est.: 15 min to add the citation + LaTeX sentence; the
      spread-target decision itself is a judgment call, not a time cost.**
- [ ] `Havranek2015` citation not yet added to `bibliography.bib`.
      **Est.: 5 min.**
- [ ] Investment shape difference vs. IS2017 (`Qtob`/`QS` sign check) —
      not investigated. **Est.: 30-45 min (needs a Dynare run + IRF
      inspection).**
- [ ] Re-verify two-channel finding's magnitude (0.00769) at final
      calibration before citing in 5.2.2. **Est.: 15 min (one Dynare run
      + read-off), but only once calibration is truly final — don't do
      this twice.**
- [ ] Safe-haven/flight-to-quality citation still missing. **Est.: 20-30
      min literature search + one sentence.**
- [ ] `\subsection{Main Results}` — outline exists, no content.
      **Est.: this is not a to-do item, it's the Results chapter itself —
      see the master roadmap in `ToDoAugust6th.md` §5 for the real time
      budget (days, not minutes).**

## 4a. New, found while building `main_writing.md` — precision fix, not a bug

- [ ] **The "lagged channel is silent" caveat (appendix l.1877, and the
      Limitations section l.747/755) is correct but locates the cause
      imprecisely.** Re-verified directly against the live `.mod` just now:
      `Rb = 1/Qb(-1);` (line 509) has no `x`/`Deltab` term at all — same for
      `RK` (line 141, both explicitly commented `(x=0)`), and `Nb`'s law of
      motion inherits this through `Rb`. Current text attributes the silence
      to the solution method / no simulated path realising $x_t=1$. The
      sharper, more defensible statement: `Rb` and `RK` are coded at their
      disaster-free branch **by construction**, so the channel is absent
      from the solved system itself, not merely from the simulated paths —
      even a forced disaster draw wouldn't activate it as coded. Full
      proposed replacement clause is in `main_writing.md`, Part 3, Flag 1.
      **Est.: 10 min** (it's a drop-in paragraph, already written).

## 5. Today's big task — see `main_writing.md` (new file) and the chat response

Full "what belongs in the main text vs. the appendix" analysis is in
`main_writing.md`, not duplicated here. That task doesn't get a minutes
estimate — it's a structural writing decision, not a checklist item; see
the sequencing note at the end of `main_writing.md` for how to pace
actually writing it.
