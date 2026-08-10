# To-Do — August 10th

Carries forward everything unresolved from `ToDoAugust6th.md` (kept
intact, not deleted). You were on a writing break Aug 7-9; this reviews
what actually changed in `status_quo_thesis_august_6th_morning.txt`
since Aug 6 (diffed against git, not re-read from scratch) and adds
today's calibration-section findings.

**Deadline arithmetic, recomputed today:** hand-in **2026-08-26**,
defense **2026-09-02**. Everything substantive still needs to be
functionally done by **2026-08-19**. That's **9 days** from today — down
from 13 on Aug 6. The clock is now genuinely tight; see the resequenced
plan in §4.

## 0. Good news first — real progress since Aug 6, verified against the diff

- [x] **Abstract is written** (was empty since 2026-08-01). Claims
      amplification "monotonic in home-bias exposure for consumption,
      investment, and spreads" — this is accurate and matches the
      verified 2026-08-05 phi-sweep finding exactly. Two typos to fix:
      `\noident` -> `\noindent` (currently a broken LaTeX command, will
      not compile as written) and "We develope" -> "We develop".
- [x] **Limitations section drafted, and it correctly incorporates the
      2026-08-05 long-duration-bond feasibility analysis** — the
      "disaster never realises" caveat, the archived derivation pointer,
      and the reasoning for why it wasn't implemented are all there,
      close to verbatim to what was discussed. This closes the
      "no realised default" sentence to-do item from `ToDoAugust6th.md`
      §3 — tick it there too. Three small issues in this section, not
      urgent: `\Deltaᵇ` is a broken LaTeX command (a literal Unicode
      superscript character, not `\Delta^b` — will not compile);
      `\rho_\beta` risks confusion with the discount factor `\beta_0` —
      consider `\rho_b` instead, matching the archived derivation's own
      notation; `\frac{Q_bB}{Q_b}$` reads as a literal fraction where the
      original point was "every equation touching both `$Q^b_tb^b_t$` and
      `$Q^b_t$`" — as currently written it changes the meaning.
- [x] **Results chapter outline sketched** (subsection skeleton, no
      content yet) — matches the Tier 1/2/2b/3 structure from the master
      roadmap closely. Good sign the roadmap is being followed.
- [x] **A second calibration table added** (`tab:calibration_frictions`,
      "Full model" vs. "BGG model" vs. "GK model") — a genuinely useful,
      not-previously-discussed addition showing the nested-model
      calibration explicitly. No issues found.

## 1. Calibration section — MUST FIX before continuing, found today

These are correctness/consistency problems, independent of the
values being placeholders — a placeholder should still be internally
consistent.

- [ ] **CRITICAL: `beta_0` is given two different values from two
      different sources in the same section.** Prose: *"In regrads to
      the discount factor $\beta_0$, I follow the exact specification
      ($\beta_0 = 0.9958$) by \textcite{Bernanke1999} and
      \textcite{Gertler2011}."* Table (a few lines later): `$\beta_0$ =
      0.99`, sourced to `\textcite{Isore2017}`. Pick one value and one
      source — as written this is a direct contradiction a reader hits
      within the same subsection.
- [ ] **CRITICAL: `Delta^b` is internally contradictory within one
      sentence, and contradicts the table.** Prose: *"\textcite{Cruces2013}
      document average haircuts of roughly $37\%$... supporting the
      calibration of $\Delta^b = 0.3$."* A 37% documented haircut cannot
      "support" a 0.3 (30%) calibration — and the table, the `.mod` file,
      and every result computed since 2026-08-02 use `Delta^b = 0.37`.
      This looks like a reversion of the exact fix made 2026-08-02
      (`Deltab` 0.30->0.37 to match this same Cruces-Trebesch citation).
      Fix the prose number to 0.37.
- [ ] Orphaned sentence fragment, reads as a broken paste: *"— most
      notably the disaster probability and severity from
      \textcite{Barro2006,Barro2008} -which we note where relevant,
      while following \textcite{Isore2017}'s exact numerical values
      throughout."* Starts with an em-dash, not attached to anything —
      this is a fragment of the citation-style template proposed
      2026-08-02, pasted in without being joined to a sentence. Either
      complete the sentence or delete the fragment.
- [ ] "Therefore, \ref{tab:calibration\_one} shows the calibration
      values with their sourcing from \textcite{Isore2013}..." appears
      **twice**, near-verbatim, a few lines apart. Also: this sentence
      cites `Isore2013` as the sourcing reference — should almost
      certainly be `Isore2017` (`Isore2013` is the inferior precursor
      throughout the rest of the document; citing it as the calibration
      table's source contradicts everything else already established).
- [ ] Typos/grammar, lower priority but real: "The standardtandard
      derivation" (corrupted word); "utility parameters have been solely
      relied on \textcite{Gourio2012}" (should be "rely solely on" or
      "have relied solely on"); "In regrads to" ("regards").
- [ ] Garbled paraphrase of the risk-aversion discussion: *"they argue
      that the literature finds values with statistical significance
      between 2-4\%"* — the actual IS2017 text (per
      `calibration_reference.md`) says Barro & Jin (2011) found "a mean
      close to 3, with a 95% confidence interval for values from 2 to
      4" — a confidence interval, not "statistical significance," and no
      "%" belongs on a risk-aversion coefficient. See §2 below for a
      clean replacement of this whole area (folded into the EIS
      paragraph's neighbourhood).

## 2. EIS paragraph — see chat response for the full LaTeX; tracked here for completion

- [ ] Insert the EIS paragraph (given in chat) at the point in the
      Utility Function discussion where the garbled risk-aversion
      sentence currently sits. **New citation needed:** `Havranek2015`
      is not in `bibliography.bib` — add it before compiling (Havránek
      et al. 2015, meta-analysis of EIS estimates — the paragraph's own
      empirical anchor).

## 3. Carried forward from `ToDoAugust6th.md`, still open

- [x] `phipi`=1.5, `phiy`=0.5 vs. IS2017's own table — RESOLVED, verified
      against `calibration_reference.md` directly. IS2017's own Table 1
      excerpt lists "Taylor rule inflation weight 1.5" and "Taylor rule
      output weight 0.5" explicitly — your values match IS2017's own
      calibration exactly. (Rannenberg2016 independently uses the same
      1.5/0.5, for what it's worth, but IS2017 is the citation that
      matters here since that's your proximate source throughout.) Only
      remaining action: change the table's Source column for these two
      rows from "standard Taylor-type rule" to `\textcite{Isore2017}`.
- [ ] Investment shape difference vs. IS2017 (Qtob/QS sign check) — not
      investigated yet.
- [ ] Sharpened gamma/psi(tilde)/tau/alpha-vs-IS2017 calibration check —
      **now largely happening naturally as you write this section** —
      close it out explicitly once the table's Source column is final.
- [ ] Re-verify the two-channel finding's cited magnitude (0.00769) at
      final calibration before writing 5.2.2.
- [ ] Safe-haven/flight-to-quality citation (e.g. Beber-Brandt-Kavajecz
      2009) — still not found anywhere in the current draft.
- [ ] `\subsection{Main Results}` — outline exists now, no content.

## 3a. Euro-area sourcing for the banking/entrepreneur block -- researched today (2026-08-10, later)

Real web research (WebSearch + direct PDF extraction, not memory) into
whether a euro-area-calibrated double-financial-accelerator paper
already exists.

- [x] **Found a genuine, strong match for the BANK/GK side:**
      Coenen, Karadi, Schmidt & Warne (2018), "The New Area-Wide Model
      II: An Extended Version of the ECB's Micro-Founded Model for
      Forecasting and Policy Analysis with a Financial Sector," ECB
      Working Paper No. 2200. Co-authored by Peter Karadi himself.
      Verified directly from the PDF (Table 3, p.87): steady-state bank
      leverage ratio $\Phi=6$; wholesale-banker survival rate
      $\theta=0.950$; retail lending rate spread over the deposit rate =
      **2.17 percentage points annualised**. These are real, ECB-published,
      euro-area-estimated targets directly comparable to `sigma_b` and
      `R^S/R^d` in your Table 2. **Action: cite this instead of the
      generic "Gertler2011-style leverage literature" dagger, and
      reconsider the loan-spread target** -- your current calibration
      (`R^S/R^d`=1.0020, ~80bp annual) is well below NAWM II's own
      euro-area estimate of ~217bp; this is a real empirical gap worth a
      conscious decision, not just a re-citation. `sigma_b`=0.94 vs.
      NAWM II's 0.950 is close enough not to worry about.
      **New `.bib` entry needed:** `CoenenKaradiSchmidtWarne2018` (or
      similar key).
- [ ] **NOT found: a euro-area paper combining BOTH BGG entrepreneurs
      AND a GK bank block together.** NAWM II has the bank side only
      (confirmed: zero occurrences of "entrepreneur" or "external
      finance premium" in the full text) -- no BGG-style firm friction
      at all. No other paper found in this session's search combines
      both frictions with euro-area calibration the way this thesis and
      Rannenberg (2016) do with US data. `Gerali2010` (already cited and
      already rejected in your lit review on structural grounds -- a
      capital-ratio penalty, not a microfounded leverage constraint) is
      euro-area-estimated and could still supply MOMENT targets (credit
      spread levels, leverage ratios) even though its structure doesn't
      map cleanly onto `chi^e`/`sigma^e` -- worth a look if you want a
      second opinion on the entrepreneur side, but not a clean citation
      match.
- [ ] **Entrepreneur-side (`chi^e`, `E[R^K]/R^S`, `QK/N^e`, `sigma^e`)
      still needs the European-data-equivalent route (Branch 2), not a
      ready-made paper.** Mapped Rannenberg's own US sources to euro-area
      equivalents, honestly flagged by confidence level:
      - Net worth / leverage of non-financial corporations (Rannenberg's
        FFA series) -> **ECB/Eurostat Quarterly Sector Accounts (QSA)**,
        non-financial corporations (S.11) balance sheet -- a real,
        standard, well-known euro-area data product. Confident this
        exists and is the right product; have NOT looked up exact series
        codes.
      - Loans to non-financial businesses (Rannenberg's FFA credit
        instruments series) -> **ECB Statistical Data Warehouse (SDW),
        MFI Balance Sheet Items (BSI) statistics**, loans to NFCs --
        same confidence level: real, standard product, exact series code
        not verified.
      - Cost of external finance (Rannenberg's Moody's Baa spread) ->
        **ECB's own published Composite Cost of Borrowing Indicator for
        NFCs** -- this is the closest direct euro-area analogue and is
        specifically designed for exactly this purpose; reasonably
        confident this is the right series, still worth confirming
        against the ECB's own SDW documentation before citing a number.
      This route is viable but requires you to actually pull the data
      (or find a paper that already reports the resulting moments) --
      not a one-citation fix the way the bank side turned out to be.

## 4. Resequenced plan, 9 days (2026-08-10 -> 2026-08-19)

- **Today/tomorrow (Aug 10-11):** fix §1's must-fix items, insert the
  EIS paragraph (§2), finish the calibration section and its Source
  column citations properly.
- **Aug 12-16:** Tier 1 (5.2.1, 5.2.2 with the two-channel decomposition,
  safe-haven check, and the IS2017 cross-check's four findings; 6.2 is
  already largely drafted, just needs the LaTeX fixes from §0 above).
  This is still the single highest-value block.
- **Aug 17-19:** Tier 2/2b sweeps and tail moments if time allows; cut
  Tier 3 immediately if not. Commit a checkpoint.
- **Aug 19-26:** review phase only.
- **Aug 26-Sep 2:** hand-in to defense prep.
