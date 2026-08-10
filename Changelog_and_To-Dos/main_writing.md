# Main Text vs. Appendix A — What a Publishable Paper Would Move Up

Reference file: `status_quo_thesis_august_10th_evening.txt` (3456 lines).
All line numbers below are keyed to that file. Re-check line numbers after
any edit shifts the file — they will drift.

This document answers two questions, in order:

1. **Does everything currently in the main-text "Theoretical Model" section
   (lines 192-586) earn its place there?**
2. **What currently lives only in Appendix A that a publishable paper would
   put in the main text, with exact start/end pointers, what to promote
   verbatim vs. condense vs. leave behind, and where the prose needs a
   bridge sentence to keep flowing?**

Overlaps between the promoted main-text content and the appendix are
**intentional and left alone**, per your instruction — you'll deduplicate
once the main text is rewritten. Nothing here recommends deleting
anything from the appendix.

---

## Part 1 — Verdict on the current main text, section by section

| Section (main text) | Lines | Verdict |
|---|---|---|
| The Disaster State | 195-230 | **Belongs, as-is.** No appendix analogue exists for this section (it's a primitive declaration, not a derivation) — nothing to promote, nothing to cut. |
| Households | 231-264 | **Incomplete.** States the utility function and budget constraint correctly, then defers *everything* — including three equations used constantly later (the SDF, labour supply, deposit Euler) — to "Appendix A" without showing the reader the results. See Block C. |
| Firms — Final Good Production | 270-287 | **Belongs, as-is.** Clean punchline-only presentation, derivation correctly deferred. |
| Firms — Intermediate Good Production | 288-370 | **Belongs, but disproportionately detailed.** This is the *most* derivation-heavy main-text subsection in the document — it already carries the Calvo maximisation setup and both auxiliary recursions (Ξ₁, Ξ₂), which is more machinery than Households or Entrepreneurs get. Not wrong, nothing contradicts, no action required — flagging only because it makes the *thinness* of the Banking gap (next row) more visible by contrast: the paper currently explains sticky-price algebra in more depth than it explains its own novel banking mechanism. |
| **Entrepreneurs and Banking Sector** | 371-531 | **Title over-promises; section under-delivers.** The `\subsection` is titled "Entrepreneurs *and Banking Sector*" but contains only one `\subsubsection{Entrepreneurs}` (375-531) and zero banking content. Worse: the Entrepreneurs text itself **cites four bank equations by number that are never shown anywhere in the main text** — `eq:A323` (leverage constraint, l.442, 479, 522), `eq:A3_bankBS` (bank balance sheet, l.494), `eq:A3_Bank_Value` (bank net worth, l.522), `eq:A3_homebias` (home-bias identity, l.522) — and states the paper's own central causal claim without showing its mechanics: *"This is the channel through which a sovereign loss on bank balance sheets raises the cost of credit to entrepreneurs"* (l.523). A main-text-only reader cannot verify this sentence. This is the largest single gap in the document. See **Block A**. |
| Public Authority | 532-577 | **Belongs, as-is, and already consistent.** Verified word-for-word identical to its appendix counterpart (1888-1956, minus one appendix-only clarifying paragraph, see Part 3 note below). No promotion needed — this section shows how the split *should* look everywhere else. |
| Market Clearing | 578-585 | **Empty.** The subsection header exists, one paragraph *promises* to "derive the good market and reinstate the labour, capital services as well as sovereign bond market clearing conditions" (l.580) — and then the section ends. Zero equations follow. The resource constraint $Y_t=C_t+I_t$, which every later Results discussion will implicitly rely on, is not stated anywhere in the main text. See **Block B**. |

**Bottom line on Task (c):** nothing currently in the main text is wrong, redundant, or wordy enough to cut. The problem is entirely one of omission, concentrated in exactly one subsection (Entrepreneurs and Banking Sector) and one empty stub (Market Clearing), with a smaller omission in Households. Sections that already show the promoted/appendix split done correctly (Public Authority, Final Good Production) are useful templates for how to write the fix.

---

## Block A — Banking Block (the big one)

**Source:** Appendix `\subsubsection{Banks with Sovereign Bond Holdings}` (1422-1676) and `\subsubsection{Disaster Transmission Mechanism}` (1677-1887), both inside `\subsection{Banking Block}` (1249-1887).

**Destination:** main text, inside `\subsection{Entrepreneurs and Banking Sector}` (371-531), as two new `\subsubsection`s immediately after the existing Entrepreneurs content ends (after line 531, before `\subsection{Public Authority}` at line 532) — mirroring the appendix's own A.3.1 → A.3.2 → A.3.3 order.

Do **not** promote this block wholesale — at 465 lines it would roughly double the length of the Theoretical Model section on its own and bury the two paragraphs that actually matter (the two-channel finding) under a full Bellman-equation proof. Publishable-paper convention here is: **state the setup and every result the rest of the paper depends on; leave the "prove the value function is linear" derivation grind in the appendix.**

### A.1 — Bank setup and balance sheet

- **Promote in full:** l.1425-1428 (the setup paragraph: deposits, net worth, two asset classes, the Gertler (2011) moral-hazard motivation for the leverage constraint) and l.1431-1441 (Bank Balance Sheet Identity, eq. A.3.2.1). Fourteen lines, no derivation, directly resolves the `eq:A3_bankBS` forward-reference at main-text l.494.

### A.2 — Leverage constraint: condense the derivation, keep the result

- **Leave in appendix (derivation grind):** l.1450-1602 — the full Banker Value Function Bellman equation, the linear-value-function verification (l.1497-1573), and the diversion-constraint algebra (l.1579-1599). This is exactly the kind of "show your work" proof that belongs in an appendix, structurally equivalent to the household Lagrangian the main text already correctly defers.
- **Promote, condensed to ~3-4 sentences:** the *logic*, not the algebra — bankers maximise continuation value subject to a moral-hazard incentive constraint; because both the value function and the constraint are linear in net worth and assets (proved in Appendix, eq. A.3.2.2), the constraint reduces to a leverage cap.
- **Promote in full:** the result itself, l.1604-1608 (eq. A.3.2.3, `eq:A323`):
  $$Q_t S_{j,t} + Q^b_t B^b_{j,t} \;\le\; \lambda_t N^b_{j,t}$$
  This is the single most-referenced-but-never-shown equation in the current main text (three forward references without a definition). Promoting just this equation and its one-sentence intuition (l.1600-1602) closes most of the gap on its own.

### A.3 — Home bias and bank net worth

- **Promote in full:** Home-Bias Portfolio Identity, l.1622-1641 (eq. A.3.2.4, `eq:A3_homebias`) — this is short, institutionally motivated (Basel zero-risk-weighting, l.1625), and directly resolves another standing forward-reference (main-text l.522).
- **Promote in full:** Bank Net Worth Accumulation, l.1648-1666 (eq. A.3.2.5, `eq:A3_Bank_Value`) — resolves the last of the four forward-referenced-but-unshown equations.

### A.4 — Disaster Transmission Mechanism: this is the thesis's actual contribution

- **Promote, condensed:** Equilibrium Bond Pricing Condition (l.1683-1706) and Asset-Specific Resilience (l.1709-1737) — keep the setup sentence and the two named results (eq. A.3.3.1 `eq:A3_bondeuler`, eq. A.3.3.2 `eq:A3_resil`), but **leave the "Derivation of Closed Form Λ^M" subparagraph (l.1738-1761) fully in the appendix** — it is a pure algebra derivation of one intermediate object and is not referenced again outside this subsection.
- **Promote in full:** Sovereign Bond Price (l.1763-1798, eq. A.3.3.3 `eq:A3_bondprice`) and Sovereign Bond Gross Return through the spread definition (l.1806-1845, eq. A.3.3.4-A.3.3.6) — the spread (`eq:A3_spread`) is the object the Spread-at-Risk results in Section 5 will report against, so it needs to be main-text-visible before Results uses it.
- **Promote in full, unabridged:** l.1847-1877 — the two-channel paragraphs themselves (**Immediate channel: perceived risk**, l.1849-1852; **Lagged channel: realised default**, l.1854-1877, including the causal-chain display). This is the paper's central novel finding. It currently exists in only one place in the entire 3456-line document. **Requires one precision fix before promotion — see Part 3, Flag 1, below; fix it in the appendix copy first, then promote the fixed version.**

### Suggested bridge sentences

The existing Entrepreneurs text already ends on a natural hook (l.523): *"This is the channel through which a sovereign loss on bank balance sheets raises the cost of credit to entrepreneurs."* Insert, directly after it, before starting the new Banks subsubsection:

> *The mechanics of that channel — how bank leverage is determined and how it responds to sovereign risk — are developed next.*

The Entrepreneurs section's own "Capital Demand: Free-Entry Condition" paragraph (l.500-523) forward-references `eq:A3_Bank_Value`, `eq:A323`, and `eq:A3_homebias` before they exist anywhere in the main text — this is inherited unchanged from the appendix, which has the identical forward-reference issue (appendix l.1413-1414 references the same three equations before A.3.2 begins at l.1422). It's harmless to LaTeX (`\eqref` resolves at compile time regardless of physical order) but reads as unexplained equation numbers to a linear reader, and a main-text audience is less forgiving of that than an appendix audience. Recommend softening, not restructuring — change

> "Given $N^b_t$ from~\eqref{eq:A3_Bank_Value} the binding leverage constraint~\eqref{eq:A323} and the home-bias identity~\eqref{eq:A3_homebias} fix loan supply..."

to

> "Given bank net worth $N^b_t$, the binding leverage constraint, and the home-bias identity — all developed in the following subsection — loan supply is fixed at $Q_tS_t=(1-\phi)\lambda N^b_t$..."

i.e. name what the equations *are* in words at first mention, keep the `\eqref` numbers for the reader who wants to jump ahead. Apply the same light touch anywhere else in the promoted text that cites an equation number more than one paragraph before showing it.

---

## Block B — Market Clearing (fills the empty stub)

**Source:** Appendix `\subsection{Model Closing Conditions}` (1957-2064), specifically its four `\subsubsection`/`\paragraph` units.

**Destination:** main text `\subsection{Market Clearing}` (578-585), replacing the unfulfilled promise at l.580 with actual content.

This is smaller and more mechanical than Block A — good to do first, since it's low-risk (short, self-contained, nothing contradicts anything) and it removes an outright empty section, which is a worse look in a submitted thesis than a thin one.

- **Promote the intro paragraph in full:** l.1962 (already near-identical to the main text's own current l.580 — merge them, don't duplicate).
- **Good Market Clearing** (l.1964-2019): **leave the derivation in the appendix** (l.1974-2011 is a five-step substitution chain — government budget constraint → bank balance sheet → entrepreneur balance sheet → capital-goods producer identity — that is classic appendix "show your work"). **Promote:** the one-paragraph intuition (l.1966-1972: *"Every financial claim in this model... is held by one agent and owed by another... the aggregate resource constraint follows from going back only the flows that connect the financial layer to real production and consumption"*) and the final result, eq. A.5.1 (l.2012-2014): $Y_t = C_t + I_t$.
- **Labour and Capital Services Market Clearing** (l.2022-2039): **promote in full** — already short (18 lines), already clean, two equations (A.5.2, A.5.3) plus one grounding paragraph.
- **Sovereign Bond Market Clearing** (l.2042-2046): **promote in full** — it is one sentence.
- **Loan Market Clearing** (l.2049-2057): **promote in full** — nine lines, one equation (A.5.4, `eq:loanmarketclearing`), and it is *already forward-referenced by name* in the current main text (l.523: *"Loan-market clearing~\eqref{eq:loanmarketclearing} is the statement that these two routes to $Q_tS_t$ agree"*) — this is the fifth (and last) currently-dangling forward reference in the document, and promoting this paragraph closes it.

No bridge sentence needed — the existing l.580 intro paragraph already sets up exactly this sequence ("the good market and reinstate the labour, capital services as well as sovereign bond market clearing conditions"), it just needs the content to follow it that it already promises. One thing to fix while you're in there: l.580's promise omits loan-market clearing by name even though it's the equation your own Entrepreneurs section already forward-references — add "and loan market" to the list.

---

## Block C — Household first-order conditions, endogenous discount factor, risk-free rate

**Source:** Appendix `\subsection{Households}` (795-953), three sub-pieces.

**Destination:** main text `\subsection{Households}` (231-264), replacing the single deferring sentence at l.263 ("First-order optimality conditions are derived in Appendix~A").

Smallest and lowest-urgency of the three blocks — unlike Block A, the current main text doesn't cite any unshown equation by number here, it just defers, which is a legitimate (if minimal) choice. Worth doing because the SDF term $Q_{t,t+1}$ is used constantly from the Firms section onward (Calvo pricing, l.321-326) without the reader ever having seen where it comes from — but if time runs out before Aug 19, this is the block to cut first.

- **Leave in appendix:** the full Lagrangian, l.834-850 (mirrors the Banker Value Function situation in Block A — pure derivation).
- **Promote, condensed to the equation block plus 2-3 sentences of intuition:** l.883-894 — the three household FOCs: the Epstein-Zin SDF (A.1.1, `eq:SDF`), the labour-leisure condition (A.1.2, `eq:HHO_C`), the deposit Euler (A.1.3, `eq:HHO_Deposit_Euler`). Skip the derivation walk (l.852-881) and the moment-order technical note (l.896-899) — the latter is appendix-appropriate detail about which expectation operator applies where, not needed for a main-text reader.
- **Promote in full:** the Capital-Goods Producer's *own* maximisation problem and Tobin's Q result, l.910-921 (currently the main text only ever shows Tobin's Q pre-solved, embedded inside the Entrepreneurs section's consistency check at l.404-408, without ever showing where it comes from). Natural insertion point: right after the $\Pi_t^{cp}$ formula is introduced in the main text at l.260-261.
- **Promote in full:** **Endogenous Discount Factor β(θ_t)** paragraph, l.925-935 (eq. A.1.5, `eq:betatheta`) — this is a substantive modelling feature, not derivation grind: it is the mechanism by which Isoré-Szczerbowicz's own "perceived-risk-alone" result operates in this model, and the main text's Disaster State section already promises a comparison against IS2017 at $\phi=0$ (l.201) without ever showing the mechanism that comparison runs through. Trim the footnote (l.926, "symmetric productivity disaster") if space-constrained — it's a one-line aside.
- **Promote in full:** **Risk-Free Rate and Deposit Market** paragraph, l.936-947 — this states a genuine structural point of departure from IS2017 (households here save only through deposits, so $R^f_t$ is state-independent in a way IS2017's household bond return is not) that a publishable paper would want visible, not buried.
- **Leave in appendix:** "Capital Pricing: Moving from Household Euler to Entrepreneur Indifference" (l.948-951) — its content is already effectively present in the main text via the Entrepreneurs section's own l.520 discussion of the same IS2017-comparison point; promoting it too would be closer to the overlap the user is deliberately deferring cleanup on, so it's flagged here but not recommended for now.

---

## Part 3 — Consistency flags found during this pass

These surfaced while reading for the promotion pointers above, not from a separate audit — flagging because Block A promotes exactly the paragraph affected, and promoting an imprecise caveat into the main text is worse than leaving it imprecise in the appendix.

### Flag 1 — the "lagged channel is silent" explanation is correct but under-states its own case (precision fix, not a new bug)

Verified directly against the live `thesis_model_v3.mod` just now (2026-08-11): line 509 has `Rb = 1/Qb(-1);`, with the variable declaration at line 153 explicitly commented `% gross real *realised* bond return (x=0)`. There is no `x` or `Deltab` term in the coded equation at all — and the same is true of `RK` (line 141, identically commented `(x=0)`), and `Nb`'s law of motion (line 499) inherits this through `Rb`. This is not a new finding — it's consistent with, and sharpens, what you already independently wrote in the Limitations section (l.747, l.755: *"for the identical reason as the one-period bond, to actually make the lagged channel work"*) and what the appendix's own Disaster Transmission paragraph already says (l.1877: *"silent... under the perturbation-based solution method used here"*).

The current phrasing in both places attributes the silence to *the solution method* / *no simulated path realises $x_t=1$* — a sampling-path argument. The sharper and more defensible statement is structural: `Rb` and `RK` are coded at their disaster-free branch **by construction**, the same certainty-equivalent convention applied uniformly to both realised-return variables — so the channel is absent from the *solved system itself*, not merely from the set of paths that happen to get simulated. This distinction matters under committee questioning: the current wording invites "what if you forced a disaster draw?" as a follow-up, and the honest answer is "the coded `Rb` equation still wouldn't respond" — which the current text doesn't quite say, but easily could.

**Proposed replacement for appendix l.1877's final clause** (fix here first, then this is the version that gets promoted under Block A.4):

> *"...It is silent for a structural reason, not merely a sampling one: the realised returns $R^b_t$ and $R^K_t$ entering the model's solved recursions are both coded at their disaster-free ($x=0$) branch by construction — the identical certainty-equivalent treatment — so only the disaster probability $\theta_t$, not a realised default, propagates through the system under perturbation. Even a simulated path that happened to draw $x_t=1$ would not activate this channel as coded; doing so requires re-deriving $R^b_t$ and $N^b_t$ with an explicit realised-$x_t$ term and a solution method that admits discrete regime draws, as sketched for the long-term bond extension (Appendix~\ref{sec:LongTermBond})."*

This also ties the Limitations section's long-term-bond/MIT-shock discussion (l.747-757) and the Disaster Transmission Mechanism's own caveat together explicitly, where right now they say the same thing independently without cross-referencing each other.

### Flag 2 — minor: appendix Public Authority claims an explicit term that isn't displayed

Appendix l.1909: *"In this paper, $e^{x_t \ln(1-\Delta^b)}$ appears explicitly in equation~\eqref{eq:A4_govBC}..."* — but the displayed A.4.1 equation (both main-text l.540-543 and appendix l.1899-1903) is $T_t = R^b_t Q^b_{t-1}B^b_{t-1} - Q^b_t B^b_t$, with no visible exponential term; the haircut enters only implicitly, through $R^b_t$ (eq. A.3.3.4). Likely a leftover from describing the haircut by analogy with the capital-destruction process (eq. A.2.7, which *does* use the explicit $e^{x_{t+1}\ln(1-\Delta^k)}$ form). Low stakes — this paragraph is appendix-only and not currently a promotion candidate (Block A's caveat fix is the one that matters for the main text) — but worth a one-word fix ("implicitly," not "explicitly") whenever you're next in that paragraph.

### What checked out clean

- Appendix Entrepreneurs (1259-1421) vs. main-text Entrepreneurs (375-531): verified near-verbatim match, paragraph-for-paragraph, same order, same equation tags. No contradiction, no promotion needed — this pairing is what "already done correctly" looks like.
- Appendix Public Authority (1888-1956) vs. main-text Public Authority (532-577): identical apart from the one appendix-only paragraph in Flag 2. Fisher equation and Taylor rule match exactly, word for word, both places.
- Appendix Firms Profit Maximisation / Aggregated Inflation (1099-1226) vs. main text (316-368): confirmed the appendix version is pure algebra grind (the first-order-condition derivation, l.1133-1171) around the *same* final results already stated in the main text — nothing here needs to move.

---

## Sequencing note

Do these in the order **B → A → C**, not the order they're listed in the user's request:

1. **Block B (Market Clearing) first.** It's short, mechanical, self-contained, and turns an embarrassingly empty subsection into a complete one. Least likely to introduce a new error, most visible "quick win."
2. **Block A (Banking) second.** This is the substantive one — it's what actually makes the thesis's own central claim ("sovereign loss → bank balance sheets → credit cost") verifiable from the main text alone, which is the whole point of this exercise. Do Flag 1's precision fix *as part of* this block, not separately, since you'll have the paragraph open anyway.
3. **Block C (Households) last, and cuttable.** Genuinely lower-stakes than the other two — the current text doesn't misrepresent anything, it just defers. If the calendar gets tight before Aug 19, this is the one to leave for the review pass rather than force now.

Not time-boxed in minutes here on purpose — this is a structural writing decision about your own prose, not a mechanical checklist item, and you're the one who knows how fast you write. `ToDoAugust11th.md` §5 points here instead of duplicating a number.
