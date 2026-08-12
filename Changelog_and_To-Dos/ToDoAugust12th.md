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

## 1. Critical — done for you already today

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

## 2. New, must-fix — the appendix is now the incomplete document, not the main text

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
- [ ] Two small typos surfaced while checking this: main text l.601/604,
      "Bankers **thrn** maximise" → "then"; "reduces to a leverage
      **gap**" → almost certainly "leverage **cap**". **Est.: 1 min.**
- [ ] The promoted "Lagged channel" paragraph's closing sentence (main
      text l.823) was hand-edited after promotion and is now
      ungrammatical ("It cnstruct this term silent for structural
      reasons..."), with three more typos (disaser-free, thorugh,
      pertubation, recquire). Content is right — it correctly carries the
      Flag 1 precision fix from yesterday. Clean replacement text is in
      `main_writing.md` Part 4, ready to paste in. **Est.: 3 min.**

## 3. Calibration research — your five flagged parameters, reviewed against real euro-area literature

You flagged `chi^e`, `E[R^K]/R^S`, `QK/N^e`, `sigma^e`, `R^S/R^d` as
needing euro-area references. Findings below are from primary-source PDFs
downloaded and grepped directly today (not search-engine summaries — one
of those was actually checked and turned out to be wrong, see the note at
the end of this section).

- [ ] **`R^S/R^d` (bank loan spread) — you don't need new research here,
      NAWM II already has it, it's a decision, not a search.** Re-verified
      directly against the ECB WP 2200 PDF text today (line 4230-4231 of
      the extracted text): *"the steady-state leverage ratio Φ equals 6,
      and the retail lending rate spread over the deposit rate, RI − R,
      equals 2.17 percentage points"* — annualised. NAWM II's wholesale
      banking friction is the same Gertler-Karadi leverage mechanism this
      thesis uses, so it's a structurally matched target, not an analogy.
      2.17pp annual ≈ **`R^S/R^d` ≈ 1.0054** quarterly gross (vs. your
      current 1.0020 ≈ 80bp). **Worth noting before you decide:** your
      *current* 120bp entrepreneur premium (`E[R^K]/R^S`=1.0030) plus your
      current 80bp bank spread compound to almost exactly 200bp annual
      total wedge between `E[R^K]` and `R^d` — which is the classic BGG
      single-friction target, split cleanly across your two frictions.
      Swapping in NAWM II's 217bp bank spread alone, without also
      revisiting the entrepreneur premium, pushes the total wedge to
      ~337bp, breaking that property. Not wrong, but a conscious call, not
      a free swap. **Est.: this is a judgment call, not a research task —
      budget 10 min to decide, then update `.mod` + table together.**
- [ ] **`chi^e` (EFP elasticity w.r.t. leverage) — real euro-area estimate
      exists and it's meaningfully lower than your current 0.05.**
      \textcite{Gelain2010} (ECB WP 1171, Bayesian-estimated on euro-area
      AWM data, 1980-2008) reports a posterior mean of **0.0276** (90% CI:
      0.0118-0.0427) for exactly this parameter. Your current 0.05 is
      literally the generic BGG/US prior mean, not a euro-area number —
      Gelain's own paper says so explicitly ("these values are lower than
      the BGG calibrated one for the US (0.05) but still in line with it
      given the probability interval"). A second, independent euro-area
      estimate is cited *within* Gelain's own literature review: Queijo
      von Heideken (2005, revised 2008) reports 0.05 → 0.04 for the euro
      area — consistent direction, doesn't quite have a primary-verified
      citation from me yet (see note below), but worth chasing if you
      want a second source. **Recommendation: revise `chi^e` toward
      0.025-0.04** (Gelain's posterior range) if you want the euro-area-
      grounded number; cite `\textcite{Gelain2010}`. **Est.: 5 min to
      decide + update, then a Dynare re-solve.**
- [ ] **`sigma^e` (entrepreneur survival) — your current 0.975 is already
      well-supported, just needs a better citation.** Gelain (2010) used
      0.975 as his own prior mean and his posterior estimate came back at
      0.9769 (90% CI: 0.9630-0.9918) — euro-area data doesn't move this
      one. **Recommendation: keep 0.975, re-cite to `\textcite{Gelain2010}`
      instead of/alongside the generic BGG-style dagger.** **Est.: 2 min,
      no `.mod` change needed.**
- [ ] **`QK/N^e` (entrepreneur leverage target) — same story as
      `sigma^e`.** Gelain (2010) calibrates (not estimates) K/NW = 2 —
      identical to your current target — as an input to his euro-area
      Bayesian estimation, and it's the target used throughout the BGG
      literature. This isn't an independent euro-area *estimate* of
      leverage the way `chi^e`/`sigma^e` are, but it is a case of the same
      number being used successfully (i.e., not rejected by the data) in
      a euro-area estimation exercise — worth saying that precisely rather
      than overclaiming it as "euro-area evidence." **Recommendation:
      keep 2.0, cite `\textcite{Gelain2010}` with the honest caveat above
      rather than just the BGG dagger.** **Est.: 2 min.**
- [ ] **`E[R^K]/R^S` (entrepreneur premium, ≈120bp) — no direct euro-area
      re-estimate found; reframe rather than replace.** Gelain (2010)'s
      own target is a 200bp steady-state risk spread — but that's BGG's
      *single*-friction premium (entrepreneur-to-riskless directly); this
      thesis splits the same total wedge across two frictions
      (entrepreneur EFP + bank spread), and your current 120bp+80bp
      already recombine to ~200bp, i.e. the classic target, honestly
      split. **Recommendation: keep 120bp, but change the framing in text
      to "the two frictions jointly recover the standard 200bp BGG target"
      rather than presenting 120bp as if it should independently match
      literature values calibrated for a single-friction model** — because
      it won't, and a careful reader will notice the apparent gap if it's
      not explained. **Est.: 10 min, prose only, no `.mod` change.**
- [ ] **Once any of the above changes are made to `.mod`: re-run Dynare
      before citing new numbers anywhere** (order=1 quick check ~1 min,
      order=3 pruning ~15s once solving) — don't batch this with other
      unrelated edits so it stays traceable which change did what.

Note on research method, for the record: an initial WebSearch summary
claimed NAWM II calibrates to "leverage ratio of 8 and spread of 70bp" —
this is **wrong**, and I only caught it by downloading the actual ECB WP
2200 PDF and grepping the real table text (Φ=6, 217bp, confirmed twice,
once in prose and once in the calibration table itself). Search-engine
summaries of PDFs are not reliable enough to calibrate a parameter from
directly — worth keeping in mind if you do further literature checks
yourself.

## 4. Table 2 has a LaTeX header bug

- [ ] `tab:calibration_frictions`'s `\endfirsthead` declares 4 columns
      (Parameter/Description/Model Value/Source, l.1026) but its
      `\endhead` (the header repeated on continuation pages, l.1032)
      declares 5 (Parameter/Description/Full model/BGG model/GK model) —
      leftover from an earlier three-model-comparison table design that
      was simplified but the continuation header wasn't updated to match.
      If the table spans a page break, the second page's header will be
      visibly wrong/misaligned. **Est.: 2 min** — copy `\endfirsthead`'s
      header row into `\endhead`.

## 5. Carried forward, still open (unchanged from `ToDoAugust11th.md` §4)

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
