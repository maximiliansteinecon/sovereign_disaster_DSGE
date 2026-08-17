# Ledger — Main Text (§2) vs. Appendix A

Source: `Status_Quo_August17th.txt`, 3951 lines.
Zones: **MAIN** 195–925 · **APP-A** 1099–2625 · **APP-B** 2626–3108 · **APP-C** 3109–3796

Every line number below is keyed to the file as delivered. They drift after the
first edit — work **bottom-up** (highest line number first) and they stay valid.

---

## 0. Verdict in one line

The A→main promotion was done by full duplication and never cleaned up: **34
labels are defined twice**, **33 prose blocks are byte-identical in both
places**, **17 more have silently diverged**, and one entire ~80-line Appendix
block (the old Fisher derivation) was superseded but never deleted. The
document does not currently compile without `Label multiply defined` errors.

---

## 1. Duplicate `\label` ledger — 34 hard errors

**Rule to standardise on:** the `\label` lives in the **main text** (that is what
the reader cites). Appendix A keeps its `\tag{A.x.y.z}` and drops the `\label`.
Two exceptions, both marked below.

The appendix already gets this right in exactly one place — `\label{app:SDF}`
at L1248 — which is the pattern to copy where an appendix-internal reference
is genuinely needed.

### 1a. Equation labels — delete from Appendix A (25 items)

| # | label | MAIN (keep) | APP-A (delete `\label{...}` here) |
|---|---|---|---|
| 1 | `eq:SDF` | 284 | **1226** |
| 2 | `eq:aggregator` | 349 | **1344** |
| 3 | `eq:resale_price` | 390 | **1461** |
| 4 | `eq:prod_process` | 396 | **1472** |
| 5 | `eq:reset_inflation` | 415 | **1564** |
| 6 | `eq:aux1` | 423 | **1572** |
| 7 | `eq:aux2` | 425 | **1574** |
| 8 | `eq:inflation_rate` | 436 | **1592** |
| 9 | `eq:omega` | 441 | **1609** |
| 10 | `eq:agg_production` | 448 | **1634** |
| 11 | `eq:A3_EFP` | 533 | **1786** |
| 12 | `eq:A3_indiff` | 605 | **1873** |
| 13 | `eq:A3_homebias` | 660 | **2072** |
| 14 | `eq:A3_bondprice` | 744 | **2176** |
| 15 | `eq:A4_govBC` | 836 | **2305** |
| 16 | `eq:A4_taylor` | 858 | **2420** |
| 17 | `par:return_on_capital` | 493 | **1747** |
| 18 | `par:A313` | 513 | **1766** |
| 19 | `par:A314` | 562 | **1815** |
| 20 | `par:A315` | 583 | **1841** |
| 21 | `par:capital_market_clearing` | 596 | **1856** |
| 22 | `par:A321` | 628 | **1899** |
| 23 | `par:A324` | 652 | **2059** |
| 24 | `par:A325` | 666 | **2081** |
| 25 | `par:A334` | 751 | **2199** |

Plus `par:bank_bond:euler` (MAIN 691 / APP-A **2111**) and
`par:asset_specific_resilience` (MAIN 719 / APP-A **2128**) — same treatment.
Also `par:A512` (888/**2514**), `par:A513` (908/**2533**),
`par:loan_clearing` (915/**2540**).

### 1b. Section labels — **rename**, do not delete (3 items)

Appendix A cross-references its own sections, so deleting these breaks
appendix-internal `\ref`s. Rename the appendix copy instead:

| label | MAIN (keep) | APP-A line | rename appendix copy to |
|---|---|---|---|
| `sec:households` | 232 | **1123** | `appsec:households` |
| `sec:int_good` | 372 | **1385** | `appsec:int_good` |
| `sec:A3.2` | 619 | **1890** | `appsec:A3.2` |

Renaming `sec:households` → `appsec:households` also fixes undefined-reference
item (a) in §3 below, since `appsec:households` is already referenced seven times
and defined nowhere. **Do this one first — it is two fixes in one edit.**

### 1c. The one that runs the other way — `eq:A323`

`eq:A323` is labelled **only in Appendix A** (L2039). The main-text leverage
constraint at L644–648 carries `\tag{2.4.8}` and **no label**, so all seven
main-text `\eqref{eq:A323}` calls (L577, 624, 663, 700, 794, 811, 916) currently
send the reader into the appendix for an equation that is printed on the same
main-text page. This is the single worst offender against "readable in one pass."

**Insert — main text, `\paragraph{Bank Balance Sheet Identity}`, replacing L644–648:**

```latex
\begin{equation}
    \,Q_t S_{j,t}+Q^b_t B^b_{j,t}
    \;\leq\;
    \lambda_t\,N^b_{j,t}
  \tag{2.4.8}
  \label{eq:A323}
\end{equation}
```

**Delete — Appendix A, L2039:** change `\begin{equation}\tag{A.3.2.3}\label{eq:A323}`
to `\begin{equation}\tag{A.3.2.3}`.

---

## 2. Stale block — delete the second Fisher derivation from Appendix A.4

The Fisher derivation was relocated to **A.1.7** (Households, L1301). The old
A.4 copy was never removed. Evidence: `\tag{A.4.2}` appears **twice** in
Appendix A (L2350 Fisher, L2419 Taylor rule), and `eq:A4_fisher` is defined
three times (MAIN 318, APP-A 1301, APP-A 2351).

**Delete — Appendix A, `\subsection{Public Authority}`.**

- First snippet to delete (L2321): `We are then left with determining the Fisher equation and the Taylor`
- Last snippet to delete (L2401): `$R^f_t$ is the sovereign spread of \eqref{eq:A3_spread}.`

That is L2321–2401 inclusive, i.e. everything from the bridge sentence down to
and including `\paragraph{Fisher Equation}` and its full derivation, stopping
immediately **before** the `% ---` rule at L2402 and `\paragraph{Taylor Rule}` at L2403.

**Insert in its place** — one bridge sentence, so A.4 still reads continuously:

```latex
The nominal rate $r_t$ that appears in the constraint above is pinned down by
the no-arbitrage condition~\eqref{eq:A4_fisher}, derived in
paragraph~\ref{par:A17}; only the policy rule that sets it is stated here.
```

**Then retag the Taylor rule.** L2419: `\tag{A.4.2}` → `\tag{A.4.3}`. The
equation-inventory table at L2609–2610 and the Appendix B table at L3080/3086
already number it A.4.3 and the Fisher equation A.4.2 — both tables are now
stale for a second reason: A.4.2 no longer exists. Update L2609 to read A.1.7
and L3086 likewise.

---

## 3. Undefined references — 7 items

| ref | called from | fix |
|---|---|---|
| `appsec:households` | 460, 598, 714, 1674, 1858, 2330, 3247 | see §1b — rename APP-A L1123 |
| `eq:A3_NB` | 793, 794, 1833, 2238, 2239 | → `eq:Bank_Net_worth` |
| `sec:limitations` | 548 | → `sec:limitation` (actual label, L1067) |
| `sec:market_clearing` | 304, 1297, 1331 | no such label; nearest is `secmain:marketclosing` (L876) |
| `sec:detrending` | 297, 1286 | → `sec:Stationarization` (L2626) |
| `eq:capital` | 2556, 2565 | probably `eq:A3_LOM` (L1695, currently unreferenced) — **verify** |
| `par:A511` | 3087 | no deposit-clearing paragraph label exists; add one or drop the row |

---

## 4. Main-text equation numbering

Three appendix-style tags survive in the main text, and two numbers are swapped.

| line | now | should be |
|---|---|---|
| 407 | `\tag{A.2.8a}` | `\tag{2.3.7}` |
| 443 | `\tag{2.3.13}` | `\tag{2.3.12}` |
| 449 | `\tag{2.3.12}` | `\tag{2.3.13}` |
| 537 | `\tag{A.3.1.3}` | `\tag{2.4.3}` |
| 588 | `\tag{A.3.1.5}` | `\tag{2.4.5}` |

**2.4.11 is missing entirely** — see §5.

---

## 5. Missing from the main text: the bond Euler (2.4.11)

`eq:A3_bondeuler` is referenced three times in the main text (L714, 716, 738)
and displayed only in Appendix A (L2118–2122). A main-text-only reader meets
"Equation (A.3.3.1) is the equilibrium bond pricing condition" without ever
having seen it. This is also why the tag sequence jumps 2.4.10 → 2.4.12.

**Insert — main text, `\paragraph{Equilibrium Bond Pricing Condition}`,
between L700 (ends `...at the fixed composition ratio $\phi$.`) and L702
(begins `Since bankers bankers are owned...`):**

```latex
The bond is therefore priced by an unconstrained marginal investor who
discounts at the household stochastic discount factor $\mathcal{M}_{t,t+1}$
of~\eqref{eq:SDF}:
%
\begin{equation}
  \mathbb{E}_t\!\left[\mathcal{M}_{t,t+1}\, R^b_{t+1}\right] = 1
  \tag{2.4.11}
  \label{eq:A3_bondeuler}
\end{equation}
%
A bank whose leverage constraint binds values an extra unit of any asset above
its household-SDF price, so \eqref{eq:A3_bondeuler} is an assumption about who
the marginal holder is, not an implication of the bank's problem. It is the
pricing-side counterpart of treating $\phi$ as a balance-sheet characteristic
rather than a portfolio choice. The two remarks that make this precise are in
paragraph~\ref{par:bank_bond:euler}.
```

Then delete `\label{eq:A3_bondeuler}` from Appendix A (find it near L2121).

---

## 6. Diverged duplicates — reconcile before deduplicating

33 prose blocks are byte-identical between MAIN and APP-A. These 17 are not.
Where they disagree, the **appendix version is the correct one** in every case
below except the last.

| # | MAIN | APP-A | what differs | keep |
|---|---|---|---|---|
| 1 | 723–727 | 2132–2137 | `\tilde\Lambda^M` vs `\tilde\Lambda^M_t` | **APP-A** |
| 2 | 671–681 | 2086–2096 | `+ \iota` vs `+ \iota_t` | **APP-A** |
| 3 | 609–610 | 1878–1879 | appendix adds the $f\equiv1$ nesting sentence and proper `\eqref`s; main text says "in the next susection" | **APP-A** |
| 4 | 851–859 | 2413–2421 | $\bar r$ ordering inside the bracket (cosmetic) | either, pick one |
| 5 | 279–287 | 1243–1251 | appendix correctly uses distinct `app:SDF` | **both fine** |
| 6 | 656 | 2063 | appendix carries the Basel/HQLA institutional sentence, main text has the compressed version at 654 | **MAIN** (appendix detail stays down) |
| 7 | 348 | 1343 | "perfect competition" vs "**monopolistic** competition" for the final-good firm | **MAIN** — appendix L1343 is wrong |

Item 7 is a genuine economic error, not a style difference: the final-good
aggregator is competitive and zero-profit. Fix APP-A L1343.

Remaining diverged pairs (mechanical, tag/label only): 237–242↔1132–1137,
297–298↔1286, 342–343↔1336–1337, 377↔1385–1387, 400–402↔1476–1478,
410–411↔1486, 422–425↔1571–1574, 460↔1673–1674, 498–502↔1752–1756,
630–637↔1901–1908, 668–669↔2083–2084, 738↔2147.

---

## 7. Algebra that should move **down** into Appendix A

Two main-text passages carry derivation grind that Appendix A already does
better and more completely. Both are safe to delete from the main text.

### 7a. Final-good zero-profit / price-index algebra

**Delete — main text, `\subsubsection{Final Good Production}`.**
- First snippet: `The final-good firm makes zero profit, so $p_tY_t=\int_0^1 p_{j,t}Y_{j,t}\,dj$.`
- Last snippet: `p_t=\left(\int_0^1 p_{j,t}^{1-\nu}\,dj\right)^{\!\frac{1}{1-\nu}}` (through its `\end{equation*}`)

That is L358–370. Appendix A L1348–1382 carries the full FOC derivation.
Nothing is lost.

**Insert in its place:**

```latex
Zero profit for the aggregator then pins the price index at
$p_t=\bigl(\int_0^1 p_{j,t}^{1-\nu}dj\bigr)^{1/(1-\nu)}$; the derivation is in
paragraph~\ref{appsec:finalgoodprod}.
```

### 7b. The $\Omega$ integral chain

**Delete — main text, `\paragraph{Profit Maximisation}`.**
- First snippet: `With the Calvo-Pricing assumption, the inflation rate can be written in aggregated terms of $\Omega$:`
- Last snippet: `is leveled with $\Omega$ as price distortion measure due to relative dispersion in relative prices from sticky prices.`

That is L439–452. The main-text version is also defective on its own terms:
L442 writes `\Omega =` with no time subscript on the left but `\Omega_{t-1}` on
the right, drops the `dj` in two integrals, and contains the stray chain
`= p_t^\nu\int_0^1 p_t^{-\nu}` which is not an identity. Appendix A L1600–1636
is clean.

**Insert in its place:**

```latex
Sticky prices leave the cross-section of relative prices dispersed. Collecting
that dispersion in $\Omega_t\equiv\int_0^1(p_{j,t}/p_t)^{-\nu}dj\geq1$, which
obeys its own Calvo recursion (paragraph~\ref{appsec:agginflation}), the
aggregate production function is
%
\begin{equation}\label{eq:agg_production}
  Y_t=\frac{\tilde{K}_t^{\alpha}(z_tL_t)^{1-\alpha}}{\Omega_t}
  \tag{2.3.12}
\end{equation}
%
with $\Omega_t=1$ only when every firm charges $p_t$.
```

Note this also repairs L449, where the current main-text version drops the `dj`
and writes $\Omega$ without its subscript.

---

## 8. Appendix-A-only content — confirmed correct, leave it there

Roughly 110 prose blocks in Appendix A have no main-text counterpart. Spot-checked
and correctly placed:

- **A.1** household Lagrangian, envelope condition, $D_t$ FOC (L1163–1238); the
  $\beta(\theta_t)$ certainty-equivalent algebra (L1261–1275); the Fisher
  collapse-condition proof (L1301, now the only copy); capital-goods producer
  problem (L1304–1331)
- **A.2** final-good FOC chain (L1350–1382); cost-min Lagrangian and $mc^*$
  (L1404–1454); the full Calvo intertemporal problem, FOC, and $\Xi_1/\Xi_2$
  construction (L1492–1574); $\Omega_t$ recursion and aggregate production
  (L1596–1638)
- **A.3.1** idiosyncratic draw $\omega_{j,t+1}$ and CSV setup (L1676); capital
  law of motion and disaster timing (L1680–1705); linearity-in-$K^n$ free-entry
  argument (L1863–1871)
- **A.3.2** the entire banker value-function block (L1914–2055): Bellman,
  guess-and-verify linearity, $\bar R^{ex}$, $\Omega^b_t$, diversion condition,
  $\lambda_t=\nu^b_t/(\theta^b-\eta^b_t)$
- **A.3.3** Gabaix decomposition (L2153–2179); the $\Lambda^M$ closed form and
  $\mathcal{E}(\theta_t)$ normalisation (L2244–2273)
- **A.4** GBC step-by-step deflation (L2294–2319)
- **A.5** the full $\Xi_t$-cancellation proof for $Y_t=C_t+I_t$ (L2462–2508) —
  this is the load-bearing one; the main text states the result in one line at
  L880–884 and correctly defers
- **A.5** the non-detrended equation-system inventory table (L2555–2620)

This is the right division. Do not move any of it up.

---

## 9. Smaller fixes found in passing

**Main text**

| line | issue |
|---|---|
| 262 | `\label{eq:CP_profit}` sits **after** `\end{equation}` — attaches to the wrong counter |
| 289 | editorial note pasted into the running text: `...becomes time-varying: 2.3 (S) Three paragraphs are duplicated verbatim, and one of them has already diverged}` — delete from `2.3 (S)` to the closing brace |
| 300 | `\begin{equation*}\label{eq:riskfree_rate}` — `equation*` + `\label`; referenced at 304, 332, so `\eqref` prints a wrong number. Change to `equation` |
| 385–392 | same problem for `\tag{2.3.4}` / `eq:resale_price` (`\eqref`'d at 463) |
| 441 | same problem for `align*` + `eq:omega` (resolved by §7b) |
| 460 | "in period $t=1$" → `$t+1$` |
| 462 | "reaslized" → "realised" |
| 564 | `$\iota_t^e = \iota_t^ez_t$` — circular. Appendix L1828 has it right: `$\iota^e_t\equiv\iota^ez_t$` |
| 609 | "susection" → "subsection"; `\lambda` → `\lambda_t` |
| 656 | "assets.Formally" → "assets. Formally" |
| 669 | "startup transfers $\iota_t^e$ to newly entering **bankers**" — that is the entrepreneur symbol; should be $\iota_t$ (or $\iota^b_t$), matching the equation at 679 |
| 683 | prose says $(R^S_{t-1}-R^d_t)$ and $(R^b_t-R^d_t)$; equation 2.4.10 has $R^d_{t-1}$ throughout |
| 700 | `A_{j,t} = \lambda N^b_{j,t}` → `\lambda_t` |
| 702 | "Since bankers bankers" |
| 738 | "by theconditional" |
| 740–745 | **the bond-price equation has no left-hand side** — see below |
| 798 | `(1\phi)R^S_t` → `(1-\phi)`; "at all, A $N^b_t$ is" → "as"; `\nu_t,\eta_t` → `\nu^b_t,\eta^b_t` |
| 824 | "requires $x_t=1$to be" |
| 831 | "issues one-period nominal bonds $B_{t+1}$ at the beginning of period $t+1$" contradicts the equation at 834, which uses $B^b_t$/$B^b_{t-1}$; Appendix L2294 has the correct statement ("at the end of period $t$: a quantity $B^b_t$") |
| 839 | "where $p_t$ is the aggregate price level" — $p_t$ does not appear in 2.5.1 |
| 918 | `equation*` + `\label{eq:loanmarketclearing}`, `\eqref`'d at 610, 813, 922 → change to `equation` |

**The bond-price equation, L740–745.** As written it reads
$(1-\theta_t\Delta^b\tilde\Lambda^M_t)/R^f_t = H^b_t/R^f_t$ — a tautology. The
left-hand side `Q^b_t =` is missing, and `align*` is being used for a single
line with a `\tag` and a `\label`.

**Replace L740–745 with:**

```latex
\begin{equation}
   Q^b_t \;=\; \frac{H^b_t}{R^f_t}
   \;=\; \frac{1-\theta_t\,\Delta^b\,\tilde\Lambda^M_t}{R^f_t}
   \tag{2.4.13}
   \label{eq:A3_bondprice}
\end{equation}
```

**Appendix A**

| line | issue |
|---|---|
| 1343 | "monopolistic competition" → "perfect competition" (see §6 item 7) |
| 2350 | duplicate `\tag{A.4.2}` — removed by §2 |
| 2419 | `\tag{A.4.2}` → `\tag{A.4.3}` |
| 2609 | inventory row "A.4.2 Fisher equation" → "A.1.7" |
| 1879 | `\lambda` → `\lambda_t` (same fix as main text L609) |

---

## 10. Suggested order of execution

1. §1b rename (fixes 3 duplicates + 7 dangling `appsec:households` refs at once)
2. §2 delete the stale Fisher block (removes 1 duplicate label, 1 duplicate tag)
3. §1a delete the remaining appendix `\label`s, **bottom-up from L2540**
4. §1c add `\label{eq:A323}` to main text, remove from appendix
5. §3 remaining undefined references
6. §5 insert the bond Euler; §7 move the two algebra blocks down
7. §4 renumber; §6 reconcile the diverged pairs; §9 copy-edits
8. Recompile twice and re-run the label check — no `multiply defined`, no `??`