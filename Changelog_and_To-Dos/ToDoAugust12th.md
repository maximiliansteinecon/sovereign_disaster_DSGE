# To-Do — August 12th

Carries forward everything unresolved from `ToDoAugust11th.md` (kept
intact). Reviewed today's file
(`status_quo_thesis_august_11th_evening.txt`) by diffing against the
committed Aug 10 evening version (retrieved via `git show 8df884a:...`,
since the Aug 10 evening file itself was deleted from the working tree),
plus a `git diff` on `thesis_model_v3.mod`. Every item is time-stamped.

**Deadline arithmetic:** hand-in 2026-08-26, defense 2026-09-02.
"Everything substantive done" by 2026-08-19 — **7 days** from today.

## 0. Good news — real progress since Aug 10 evening, verified against the diff

- [x] Blocks A, B and C from `main_writing.md` were all implemented —
      Banking Block, Market Clearing, and Household FOCs are now genuinely
      present in the main text, not just promised. The Banker Value
      Function and Λ^M derivations were correctly *not* dragged into the
      main text — only the condensed result made it in, exactly per the
      Block A recommendation. This is a real, substantial writing session.
- [x] `beta_0` is now **numerically** consistent: `.mod` has
      `beta0 = 0.9985` and the table also shows `0.9985` — the
      table-vs-`.mod` mismatch flagged for two days running is resolved.
      (The *prose* still needs a cleanup — see §1.)
- [x] `Delta^b`, the duplicate-sentence, the orphaned em-dash fragment,
      "In regrads to" → "In regards to", "have relied solely on" — all
      confirmed still fixed, no regression.
- [x] Seven `.mod` parameters recalibrated to Coenen et al. (2018) NAWM II
      values: `delta0` (0.02→0.025), `alpha` (0.33→0.36), `upsilon`
      (6→3.85), `muz` (0.005→0.003), `piss` (1.005→1.00475), `rhor`
      (0.85→0.93), `sigma_b` (0.94→0.95). Dynare re-solved successfully
      (`thesis_model_results.mat` regenerated). `sigma_b=0.95` matches
      NAWM II's own value exactly — verified again today, see §3.

## 1. CRITICAL — found while verifying your Aug 12 morning edits — now fixed and re-verified

- [x] **`chi^e` decimal error, fixed and confirmed.** Re-checked directly
      against both files just now: `thesis_model_v3.mod` line 235 reads
      `chie = 0.0276;` and the calibration table (l.1044) reads `0.0276`
      — both correct, matching Gelain (2010)'s posterior mean exactly.
      `thesis_model_results.mat` (03:47) is timestamped *after*
      `thesis_model_v3.mod` (03:46), confirming Dynare was re-solved with
      the corrected value, not the stale 0.00276 one — good, that's the
      right order of operations.
- [x] **The Notes-paragraph "0.5" typo is also fixed** — l.1055 now
      correctly reads "after an initial calibration of 0.05".
- [ ] Smaller, same edit: the Notes paragraph rewrite also dropped the
      only place `R^S/R^d` had a citation at all (it used to read "...
      $R^S/R^d$ follows \textcite{Rannenberg2016}'s 'double
      accelerator'..."; the row's own Source cell is still blank). Not
      urgent, but as it stands `R^S/R^d` now has no citation anywhere in
      the table. **Est.: 1 min** — restore the clause, or fill the row's
      own Source cell instead.

## 2. Critical — done for you already today

- [x] **`bibliography.bib` was missing the `Coenen2018` key entirely**,
      despite the calibration table now citing `\textcite{Coenen2018}`
      **nine times** (l.931, 988, 994, 996, 997, 1002, 1005, 1050, plus
      the footnote on l.996). This would have failed to compile cleanly —
      every one of those nine citations would render as an undefined
      reference. **Fixed just now**: added a verified `@techreport` entry
      for Coenen, Karadi, Schmidt & Warne (2018), ECB Working Paper 2200,
      to `bibliography.bib`. Also added `Gelain2010` (ECB WP 1171),
      needed for §3 below. Both entries verified directly against the
      primary-source PDFs (downloaded and checked today), not guessed.
      **Est.: 0 min — already done.**

## 3. New, must-fix — the appendix is now the incomplete document, not the main text

Full evidence and line-by-line restoration list is in `main_writing.md`
Part 4 (new section, added today) — not duplicated here in full, this is
just the actionable checklist.

- [ ] **Seven equations that used to live in Appendix A were cut, not
      duplicated, when Blocks A/B/C were promoted** — they now exist only
      in the main text, and the appendix's own Stationarization and
      Non-Stochastic Steady State sections (the parts that pin what Dynare
      actually solves) reference them without defining them anywhere in
      the appendix. This is the mirror image of the Aug 10/11 problem,
      not a duplication problem — only one equation (the leverage
      constraint, `eq:A323`) actually ended up duplicated, and that
      duplication is correct, leave it. **Restore, per `main_writing.md`
      Part 4's five numbered insertion points:** Bank Balance Sheet
      Identity + the `Banks with Sovereign Bond Holdings` subsubsection
      header (fixes a nesting problem too — two bank paragraphs currently
      sit under `Entrepreneurs`); Home-Bias Portfolio Identity; Bank Net
      Worth Accumulation; Asset-Specific Resilience; Sovereign Bond Price;
      Sovereign Bond Gross Return + spread; the β(θ_t) and Risk-Free-Rate
      paragraphs in appendix Households; Labour/Capital, Sovereign Bond,
      and Loan Market Clearing in appendix Model Closing Conditions.
      **Est.: 45-60 min** — it's copy-paste-back of text you already wrote
      once (it's what Block A/B/C promoted *from*), not new writing.
- [x] Two small typos, confirmed fixed, verified against the diff: main
      text l.601 "thrn"→"then", l.604 "gap"→"cap". Exactly as recommended.
- [ ] **The "Lagged channel" paragraph (l.823) is 80% fixed, not fully.**
      Verified against the diff: `disaser-free`→`disaster-free`,
      `thorugh`→`through`, and `pertubation`→`perturbation` are all
      correctly fixed. Two things still wrong: `recquire` was changed to
      **`reqcuire`** — still not "require", just a different typo now.
      And the grammar issue wasn't actually fixed: `"It cnstruct this term
      silent"` became `"I construct this term silent"` — the typo
      (cnstruct→construct) is gone, but "I construct this term silent"
      still doesn't parse as a sentence. Smallest fix that respects your
      own edit rather than reintroducing my longer Part 3/4 rewrite:
      change *"I construct this term silent for structural reasons"* to
      *"This channel is silent for structural reasons"* (delete "I
      construct this term", keep everything after "silent" unchanged),
      and fix reqcuire→require. **Est.: 2 min.**

## 4. Calibration research — status: 3 of 5 done, 2 still open

You flagged `chi^e`, `E[R^K]/R^S`, `QK/N^e`, `sigma^e`, `R^S/R^d` as
needing euro-area references. Findings are from primary-source PDFs
downloaded and grepped directly (not search-engine summaries — one of
those was checked and turned out to be wrong, see the note at the end of
this section). Re-verified against the `.mod` file just now: `sigma_e`
and `levE` are untouched (correct — see below), `sprL` and `premE` are
also untouched (still open, nothing to catch there yet).

**Done:**

- [x] **`chi^e`** — adopted Gelain (2010)'s euro-area posterior (0.0276,
      90% CI 0.0118-0.0427) in place of the generic BGG/US prior (0.05),
      cited to `\textcite{Gelain2010}`. Decimal transcription slip caught
      and fixed (§1). A second, independent euro-area estimate sits inside
      Gelain's own literature review — Queijo von Heideken (2005, revised
      2008): 0.05 → 0.04 — worth chasing yourself for a second citation if
      you want one; I don't have a primary-verified reference for it.
- [x] **`sigma^e`** — value correctly left at 0.975 (Gelain's own prior
      mean; his posterior came back at 0.9769, 90% CI 0.9630-0.9918, so
      euro-area data doesn't move this one), re-cited to
      `\textcite{Gelain2010}` in place of the generic BGG dagger.
- [x] **`QK/N^e`** — value correctly left at 2.0 (Gelain's own calibration
      input, matching BGG, used successfully — i.e. not rejected by the
      data — in his euro-area Bayesian estimation), re-cited to
      `\textcite{Gelain2010}`. Note this is weaker evidence than `chi^e`/
      `sigma^e` — a target that worked, not an independent estimate — the
      table's phrasing should reflect that distinction if it doesn't
      already.

**Still open:**

- [ ] **`R^S/R^d` (bank loan spread) — a decision, not a research gap.**
      NAWM II (ECB WP 2200, verified directly against the PDF text,
      line 4230-4231): *"the steady-state leverage ratio Φ equals 6, and
      the retail lending rate spread over the deposit rate, RI − R, equals
      2.17 percentage points"* annualised — the same Gertler-Karadi
      leverage mechanism this thesis uses, so it's a structurally matched
      target, not an analogy. 2.17pp annual ≈ **`R^S/R^d` ≈ 1.0054**
      quarterly gross (vs. current `sprL=1.0020` ≈ 80bp — still
      unchanged, confirmed just now). **Before deciding:** current
      120bp entrepreneur premium + current 80bp bank spread already
      compound to almost exactly 200bp annual — the classic BGG
      single-friction target, split across your two frictions. Adopting
      217bp alone, without revisiting the entrepreneur premium, pushes the
      total to ~337bp, breaking that property. Not wrong, but a conscious
      call. **Est.: 10 min to decide, then update `.mod` + table
      together, then a Dynare re-solve — the one remaining calibration
      change that still needs one.**
- [ ] **`E[R^K]/R^S` (entrepreneur premium, ≈120bp) — reframe, don't
      replace; no `.mod` change.** No direct euro-area re-estimate exists
      for this split-friction object specifically (Gelain's 200bp target
      is BGG's *single*-friction premium, not directly comparable to your
      120bp piece of a two-friction split). Recommendation stands as
      given Aug 12 morning: keep 120bp, but reframe the prose to "the two
      frictions jointly recover the standard 200bp BGG target" rather than
      implying 120bp alone should match single-friction literature values
      — it won't, and an examiner will notice the apparent gap if it's
      unexplained. **Est.: 10 min, prose only.**

Note on research method, for the record: an initial WebSearch summary
claimed NAWM II calibrates to "leverage ratio of 8 and spread of 70bp" —
this is **wrong**, and I only caught it by downloading the actual ECB WP
2200 PDF and grepping the real table text (Φ=6, 217bp, confirmed twice,
once in prose and once in the calibration table itself). Search-engine
summaries of PDFs are not reliable enough to calibrate a parameter from
directly — worth keeping in mind if you do further literature checks
yourself.

## 5. Table 2 has a LaTeX header bug

- [ ] `tab:calibration_frictions`'s `\endfirsthead` declares 4 columns
      (Parameter/Description/Model Value/Source, l.1026) but its
      `\endhead` (the header repeated on continuation pages, l.1032)
      declares 5 (Parameter/Description/Full model/BGG model/GK model) —
      leftover from an earlier three-model-comparison table design that
      was simplified but the continuation header wasn't updated to match.
      If the table spans a page break, the second page's header will be
      visibly wrong/misaligned. **Est.: 2 min** — copy `\endfirsthead`'s
      header row into `\endhead`.

## 6. Carried forward, still open (unchanged from `ToDoAugust11th.md` §4)

`phipi`/`phiy` Source citation, `Havranek2015` bib entry, investment-shape
investigation, two-channel magnitude re-verification, safe-haven citation,
`\subsection{Main Results}` content — none of these were touched today,
see `ToDoAugust11th.md` for the full descriptions and estimates. Two
additions to that list:

- [ ] The garbled risk-aversion sentence flagged Aug 10 ("statistical
      significance between 2-4%") is **still unfixed**, verbatim, at
      l.929. **Est.: 5 min**, replacement text was already given in the
      Aug 10 chat response.
- [ ] l.929's own new sentence introducing the NAWM II swap has a typo
      ("standardvliterature") and an awkward possessive ("European Central
      Banks NAWM II calibrated model" → "the European Central Bank's
      NAWM II model"). **Est.: 2 min.**
- [ ] l.940, "For $\beta$ However, \textcite{Isore2017} argue..." is a
      dangling, ungrammatical fragment duplicating the sense already
      covered inside l.929's paragraph. Once l.929's "However, choosing a
      discount value with Isore2017 β_0=0.99..." sentence is rewritten to
      match the now-consistent 0.9985 (prose currently still narrates
      choosing 0.99, which no longer matches either the table or the
      `.mod`), this fragment at l.940 is almost certainly redundant and
      can be deleted rather than fixed. **Est.: 5 min total for both.**
- [ ] Worth a second look, not urgent: `beta_0=0.9985` and the
      previously-cited BGG/GK value of `0.9958` are digit-transpositions
      of each other. Could be intentional, could be a typo that propagated
      into the `.mod` file along with the table. Worth one direct check
      against the BGG (1999)/GK (2011) source before treating 0.9985 as
      final — five minutes now is cheaper than finding this during defense
      prep. **Est.: 5 min.**

Noted, not a to-do item: the messy indented outline block that used to sit
under `\subsection{Main Results}` (old l.1059-1064: a stray nested
`\subsection{Model Parametrisation}` etc.) was removed, and
`\label{sec:results}` now sits on `\subsection{Baseline Results}` instead.
Looks like an intentional cleanup, not a regression — flagging only so
it's a conscious observation, not a silent change.

## 7. Can we move to writing the Results section once this list is done?

**Updated answer, now that §1's hard blocker is cleared: closer than not.**
The one item that genuinely had to happen before any Results drafting —
the `chi^e` fix and re-solve — is done and verified. What's left below is
worth finishing first, but nothing left is a "redo your work" risk the
way the decimal error was.

- **Cleared: the `chi^e` decimal error (§1).** Fixed, re-verified in both
  files, and `thesis_model_results.mat` confirmed re-solved *after* the
  `.mod` fix (03:47 vs. 03:46) — correct order of operations. Nothing
  drafted from here forward needs to be redone on this account.
- **Soft blockers, still open, fast:** §2's lagged-channel cleanup
  (reqcuire→require, the "I construct this term" grammar) and the
  `R^S/R^d` citation gap in §1 — quick, but they touch the exact
  mechanism paragraphs Results will reference — cheaper to close now than
  to patch around later.
- **Not a Results blocker: §3, the appendix-orphaning restoration.**
  Results draws on the main text and the calibration table, not on
  Appendix A/B/C's internal cross-reference completeness. You said
  Appendix B and C get restructured during the correction/cleaning
  write-up phase — I'd extend that same logic to §3's fixes generically,
  including the Appendix-A-internal ones (the nesting problem, and the
  bank-equation references inside Appendix A's own Banking Block and
  Model Closing Conditions remnants). None of it is main-text-visible, so
  none of it affects what a reader of Results sees. The one argument for
  doing the Appendix-A-internal part (not B/C) sooner rather than later:
  it's small (restoring one header + a few short identities you already
  wrote once) and currently leaves Appendix A in a state where a bank
  paragraph structurally sits under "Entrepreneurs" — worth 45-60 minutes
  in a slow moment, but genuinely not something Results-writing depends
  on. Your call on sequencing either way.
- **Not a Results blocker: §5's table LaTeX header bug, §6's carried-
  forward items** (safe-haven citation, investment-shape investigation,
  `Havranek2015`, etc.) — cosmetic or independent of the numbers Results
  will report. Havranek2015 specifically matters once you're writing the
  EIS discussion, not before.
- **One thing NOT on this list yet that Results *does* depend on:** the
  `R^S/R^d` decision from §4 (whether to adopt NAWM II's ~217bp spread or
  keep 80bp) is still open. Either answer is fine, but pick one before
  drafting Results — the spread-at-risk and premium numbers you'll report
  depend on it, and re-deriving Results tables after a late spread change
  is the kind of rework worth avoiding.
