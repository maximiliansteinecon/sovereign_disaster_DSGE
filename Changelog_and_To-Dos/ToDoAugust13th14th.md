# To-Do — August 13th/14th

Replaces `ToDoAugust12th.md` as the active list (kept, not deleted — full
history of what was found and fixed on the 12th is there). Reviewed
tonight's file (`status_quo_thesis_august_13h_night.txt`) by diffing
against the committed Aug 12 morning version, plus a `git diff` on
`thesis_model_v3.mod`. No line numbers anywhere below, per tonight's
instruction — everything is a quoted snippet you can search for.

**Deadline arithmetic:** hand-in 2026-08-26, defense 2026-09-02.
"Everything substantive done" by 2026-08-19 — **6 days** away.

## 0. `ToDoAugust12th.md` status: essentially all of it is done

Checked every item against tonight's diff, not assumed:

- [x] **All seven appendix-orphaning restorations are in place** — this
      was the big one. Full detail moved to `main_writing.md` Part 5
      rather than repeated here.
- [x] **All five calibration items resolved**, including both that were
      still open on the 12th: `R^S/R^d` and `E[R^K]/R^S` now carry a
      joint dagger-footnote explaining the 120bp/80bp split against
      \textcite{Gelain2010}'s ~200bp single-friction benchmark — the
      "reframe, don't replace" path, one of the two legitimate options
      from the 12th, chosen and written up cleanly. `chi^e`, `sigma^e`,
      `QK/N^e` all correctly cited to \textcite{Gelain2010}.
      Note: `sigma^e` was changed to Gelain's *posterior* (0.9769) rather
      than kept at the prior (0.975) as I'd suggested — a reasonable
      alternative, not what I recommended, but internally consistent
      (table and `.mod` agree) and defensible on its own terms. Not
      flagging as an error, just noting the deviation for the record.
- [x] **Table 2's LaTeX header bug is fixed** — column count now matches
      between `\endfirsthead` and `\endhead` (both 4). One cosmetic
      leftover: the first column is labelled "Parameter" on the first
      page and "Variable" on continuation pages — same table, two words
      for the same thing. **Est.: 30 sec**, pick one.
- [x] Typos fixed: "standardvliterature" → clean rewrite; garbled
      risk-aversion sentence grammar cleaned up (see §2 below for what's
      *still* imperfect about it — the grammar is fixed, the underlying
      statistics claim isn't quite yet).
- [~] **Lagged-channel paragraph, third pass, still not fully clean.**
      *"I construct this term silent for structural reasons"* →
      *"This term is constructed as not inforcable for structural
      reasons"* — better than before (no longer a bare typo), but *"is
      constructed as not inforcable"* still doesn't parse as intended
      ("inforcable" isn't a word, and "not enforceable" isn't quite the
      right concept either — the point is that the channel doesn't
      *activate*, not that it can't be legally enforced). Cleanest fix,
      offered for the third and hopefully last time: replace *"This term
      is constructed as not inforcable for structural reasons, as"* with
      *"This channel is silent for a structural reason:"* — everything
      after "as" already reads fine once that lead-in is fixed. **Est.: 1
      min.**

## 1. New tonight, found while verifying — three broken/missing citations

- [x] **`\textcite{gerte}`** in Table 1's $\beta_0$ row — not a real key
      (search "and \textcite{gerte}"). Given the sourcing convention used
      everywhere else for this parameter is "Bernanke1999 and
      Gertler2011," this is almost certainly `Gertler2011`, truncated.
      **Not yet fixed — needs your confirmation before I'd touch a
      citation key in the table**, since I can't be certain "gerte" isn't
      shorthand for something else you intended. Search
      "\textcite{Bernanke1999} and \textcite{gerte}" and fix by hand.
      **Est.: 1 min.**
- [x] **`Taylor1993`** — cited three times (search "\textcite{Taylor1993}"
      — once in prose, twice in Table 1's Taylor-rule rows) but the key
      didn't exist in `bibliography.bib`. This is actually a *better*
      sourcing choice than what I'd suggested on the 11th (citing the
      original Taylor (1993) paper directly, rather than routing through
      Isoré-Szczerbowicz) — good call. **Fixed**: added a verified entry
      (Taylor, "Discretion versus policy rules in practice," Carnegie-
      Rochester Conference Series on Public Policy, 1993) — this one's
      canonical enough that I didn't need to search-verify it, unlike the
      items below.
- [x] **`Havranek2015`** — cited in the EIS paragraph (search
      "\textcite{Havranek2015}'s meta-analysis"), flagged as missing from
      `bibliography.bib` since Aug 10, still missing tonight. **Fixed**:
      verified against a fresh search (Havránek, "Measuring Intertemporal
      Substitution: The Importance of Method Choices and Selective
      Reporting," *Journal of the European Economic Association* 13(6),
      2015, pp. 1180-1204 — confirms the thesis's own "2,735 estimates
      across 169 studies" figure exactly) and added.

## 2. `\textcite{Buch2026}` — verified real, now fixed

The new home-bias calibration paragraph (search "based on ECB supervisory
data for a sample of 317 euro area banks") cites `Buch2026`, which wasn't
in `bibliography.bib`. **Checked this one particularly carefully since
it's now load-bearing for a parameter that moved a lot ($\phi$: 0.10 →
0.03)** — fetched the actual source rather than trusting a search
summary: Claudia Buch (Chair of the ECB Supervisory Board), speech "The
bank-sovereign nexus: securing progress by completing the banking union,"
AFME European Financial Integration Conference, Frankfurt, 19 May 2026.
Both numbers quoted in the thesis (317 banks, 28% domestic share at
end-2025) are exact quotes from the speech. Real, accurately cited,
appropriately recent. Added to `bibliography.bib` as `@misc` (it's a
speech, not a paper — flag if you'd rather cite the underlying ECB
supervisory statistics release directly instead, if you can find its own
publication details; the speech is a perfectly citable source either way).

## 3. Still dangling: the redundant $\beta_0$ fragment

- [ ] Search *"For $\beta$ However, \textcite{Isore2017} argue that this
      parameter plays no severe role"* — this fragment is now genuinely
      redundant, not just ungrammatical: the paragraph above it (search
      "we follow \textcite{Bernanke1999} and \textcite{Gertler2011} in
      setting $\beta_0 = 0.9985$") already says the same thing cleanly
      ("...\textcite{Isore2017} finds that this parameter plays no
      material role for the results obtained, which we can confirm").
      Delete the fragment outright rather than fix it. **Est.: 1 min.**
- [ ] The risk-aversion sentence (search "reports statistically
      significant values between 2 and 4") reads grammatically now but
      still isn't quite the right statistical claim — a 95% confidence
      interval of [2,4] around a mean near 3 is not the same statement as
      "values between 2 and 4 are statistically significant." Precise
      replacement, if you want it: *"\textcite{Isore2017} note that
      \textcite{Barro2011} report a mean estimate near 3, with a 95%
      confidence interval of 2 to 4."* **Est.: 3 min.**
- [ ] Still open, not urgent: the `beta_0=0.9985` vs. the earlier-cited
      BGG/GK value `0.9958` digit-transposition question from the 12th —
      untouched tonight. **Est.: 5 min**, same as before.

## 4. Flagging, not fixing: a paragraph got commented out

Search *"ADD facts from ECB paper or survey more from EZW literature"* —
this marks the start of a commented-out block covering the entire
Epstein-Zin-Weil justification paragraph in the Introduction (the
Epstein1989/Weil1990 discussion, ending "...a distinction that has no
content under time-additive utility."). Currently **not in the compiled
document at all**. Given the comment marker reads like a to-do for
yourself ("survey more from EZW literature") rather than a decision that
this content is wrong, flagging so it doesn't get forgotten before
submission — right now a reader gets no EZ-preferences justification in
the Introduction at all, not even the short version.

## 5. Density pass and appendix-redundancy check: see `main_writing.md` Part 5

Full write-up, all snippet-anchored, no line numbers: six main-text cuts
(one is a straight duplicate-sentence deletion, not a judgment call; the
rest trim discursive/derivation content the now-complete appendix already
carries) and a direct answer on what can be deleted from Appendix A
(short version: almost nothing — the equations can't move again without
reopening the exact bug fixed on the 12th; only prose is safe to trim,
and even then mostly optional).

## 6. Calibration text vs. `.mod` — consistency check

**Verified line by line against the live `.mod` file tonight. Consistent.**
`phi=0.03` (was 0.10, `.mod` comment confirms both `phi=0.03` and the
counterfactual `phi=1e-4` were re-verified: "resid exact zero, BK clean
(9=9)" at order 1, order=3 pruning completes for both), `sigma_e=0.9769`,
`chie=0.0276`, `sigma_b=0.95`, `premE=1.0030`, `sprL=1.0020`, `levE=2.0`
all match their table values exactly, and `thesis_model_results.mat` is
timestamped after the `.mod` file (23:06 vs. 23:05) — re-solved after the
calibration changes, not before. The `Deltab=0.37` value also still
matches text and table. No numeric mismatches found. The only
calibration-adjacent issues left are the two citation-key problems in
§1 (gerte, needs your call) and the cosmetic Table 2 column-label
inconsistency in §0 — nothing that touches an actual number.

## 7. Can we move to Results now?

**Closer than the 12th's answer, but not "go" yet — three small items
first, all fast:** fix `gerte` (§1, needs a 30-second decision from you on
whether it's `Gertler2011`), delete the dangling $\beta_0$ fragment (§3),
and decide on the risk-aversion sentence (§3, optional but cheap). None of
tonight's findings are a `chi^e`-style "redo your numbers" risk — nothing
here touches a calibration value. The density pass (§5 /
`main_writing.md` Part 5) is a "when you have a working session for it"
item, not a blocker — it changes how the mechanism reads, not what it
says, and Results doesn't depend on main-text prose length. Once §1's
`gerte` and §3's fragment are handled, I'd call calibration and the main
text's substance genuinely done — the density pass can happen in parallel
with, or after, Results drafting starts.
