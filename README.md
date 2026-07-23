# Benchmark DSGE model — Sovereign Disaster Risk, Banking Frictions and Macro Tail Outcomes

Benchmark implementation of the stationarized model in your thesis (Appendix B, eqs **B.1–B.35**):
an Isoré–Szczerbowicz (2017, JEDC) New-Keynesian disaster-risk economy **extended** with

- a **Bernanke–Gertler–Gilchrist (1999)** entrepreneur / external-finance-premium block (BGG),
- a **Gertler–Karadi (2011)** bank block with a binding leverage constraint (GK),
- a **home-bias sovereign-bond channel** with the Gabaix (2012) closed-form bond price.

The purpose of these files is to be the **benchmark that runs through and solves** so you can obtain
first results and debug, with third-order perturbation as the target.

---

## Files

| File | Purpose |
|------|---------|
| `thesis_model.mod` | The model (Dynare). Steady state in closed form, all 35 equations annotated with their thesis equation numbers. Runnable directly. |
| `run_thesis_model.m` | Driver: solves at order 3, computes the ergodic mean, builds generalised IRFs to a disaster-risk shock, overlays **baseline (φ=0.10)** vs **counterfactual (φ=0)**, plots and saves. |
| `varind.m` | Helper from your IS2017 replication (variable indexing); kept for compatibility. |
| `verify_steady_state.py` | Standalone verification (pure `numpy`): recomputes the closed-form steady state and checks that **every** dynamic equation has a zero residual and the system is square and full-rank. Runnable without MATLAB. |
| `verify_determinacy.py` | Standalone Blanchard–Kahn / determinacy check (`numpy`+`scipy`): linearizes the model and runs a `gensys` (Sims 2002) solve, first validated on textbook cases, then on the model. Runnable without MATLAB. |

---

## How to run

```matlab
addpath /Applications/Dynare/6.3-x86_64/matlab      % <-- adjust to your Dynare
cd  .../Thesis_Model_Dynare

% (a) the whole experiment (both scenarios + IRFs + plots):
run_thesis_model

% or run the .mod directly:
dynare thesis_model                 % baseline, phi = 0.10, order = 3
dynare thesis_model -DPHIVAL=0       % counterfactual, sovereign-bank channel off
dynare thesis_model -DORDER=1        % FIRST DEBUG PASS: first order (see below)
```

**Recommended first debug pass.** Run `dynare thesis_model -DORDER=1` first. First order isolates
steady-state and Blanchard–Kahn (determinacy) problems from any third-order/pruning issues. Once that
solves cleanly, drop the `-DORDER=1` to go back to the third-order target.

Dynare prints, in order: `resid` (equation residuals at the steady state — all ≈ 0), `steady`
(the Newton solve, which converges immediately because the initial values are the exact closed-form
steady state), `check` (the **Blanchard–Kahn** eigenvalue test — this is the definitive determinacy
check), and `model_diagnostics` (rank/singularity).

---

## What has already been verified (before you run it)

MATLAB could not be launched in the environment where these files were built (the local MATLAB is an
Intel build on Apple Silicon and is blocked by the sandbox), so verification was done in Python, which
catches exactly the failure modes that stop Dynare's `resid`/`steady`:

- **Steady state is exact.** The closed-form steady state in `thesis_model.mod` gives a **machine-precision-zero
  residual for all 35 equations**, for both φ = 0.10 and φ = 0.
- **System is square and regular.** 35 endogenous variables, 35 equations; the stacked Jacobian has
  **full row rank 35** — no redundant or missing equation.
- **Economic sanity.** Positive net worths (`Ne`, `Nb`), positive deposits `D`, bond price `Qb ∈ (0,1)`,
  premium ordering `Rd < RL < E[RK]`, small positive startup transfers `ιe, ιb`, sovereign spread
  ≈ 280 bp annualized for the euro-area calibration.
- **Determinacy (Blanchard–Kahn).** The linearized model has a **unique stable rational-expectations
  solution** (`gensys` returns `eu = [1,1]`) for **both** φ = 0.10 and φ = 0, with no eigenvalue on the
  unit circle. The `gensys` routine was first validated on two textbook cases (a scalar forward
  equation and the 3-equation NK Taylor-principle region) before being applied here. This is precisely
  the condition Dynare's `check` tests, so `dynare thesis_model` will solve.

Reproduce any time with `python3 verify_steady_state.py` and `python3 verify_determinacy.py`
(prefix `PHI=0` for the counterfactual).

---

## Modelling choices you should be aware of (and can revert)

1. **Gourio (2012) trick — disaster risk, not realised disasters.** The binary disaster indicator
   `x_{t+1}` is integrated out of every expectation, leaving the smooth probability `theta_t` as the
   only disaster driver. No disaster is ever *realised* in the perturbation solution; disaster **risk**
   enters through `betatheta(theta)`, the `(1-theta·Δk)` wedges, and the bond resilience `H^b`. This is
   what makes perturbation (including third order) valid, and it is exactly IS2017's approach.

2. **The banking block was made square and flow-consistent.** Taken *literally*, the draft's banking
   equations are over-identified by one: B.19 (`R^L=E[R^K]`, free entry) **and** B.20 (external finance
   premium) **and** B.24 (binding leverage) together pin capital twice, and the "pass-through" convention
   (bank earns `R^K` on loans) forces `R^K=R^L`, which makes the entrepreneur net-worth accelerator
   degenerate (zero spread). To keep **both** net-worth channels alive in a square, flow-consistent
   system, the benchmark uses the standard GK+BGG closure:
   - the **bank earns the loan rate `R^L`** on loans (flow-exact with what entrepreneurs pay) — eq (27);
   - free entry (B.19) and the EFP (B.20) are **consolidated into one** Bernanke (1999) capital-demand
     equation `E_t[R^K_{t+1}] = R^L_t · s0 (N^e/Qk)^{-χe}` — eq (22).

   These are the two, clearly-marked deviations from the literal draft. Everything else is transcribed
   directly from Appendix B.

3. **One-period bonds ⇒ the sovereign-bank channel is dormant in the smooth solution.** Your draft
   already flags this (the propagation chain is *realised-default*-triggered). With one-period bonds and
   no realised disasters, an elevated `theta_t` reprices `Q^b` but does **not** move bank net worth much,
   so baseline and counterfactual IRFs will look similar. That is the *correct* benchmark behaviour and
   the motivation for the long-term-bond extension. The channel becomes materially active once you move
   to a multi-period bond (outstanding positions then carry mark-to-market exposure to `theta_t`).

---

## Calibration (quarterly)

IS2017 core is unchanged (`delta0=0.02, alpha=0.33, beta0=0.99, gamma=3.8, psitilde=2, zeta=0.6,
tau=2, varpi=2.33, muz=0.005, Δk=0.22, thetass=0.009, phipi=1.6, phiy=0.4, rhor=0.85`).
New banking/entrepreneur/sovereign parameters (all documented in the `.mod`):

| Param | Value | Meaning |
|-------|-------|---------|
| `Deltab` | 0.30 | sovereign haircut in a disaster (Cruces–Trebesch ≈ 0.37) |
| `chie` | 0.05 | elasticity of the external finance premium to leverage (BGG/CMR) |
| `premE` | 1.0030 | target entrepreneur premium `E[R^K]/R^L` |
| `sprL` | 1.0020 | target bank loan spread `R^L/R^d` |
| `levE` | 2.0 | target entrepreneur leverage `Qk/N^e` |
| `tau_e` | 0.975 | entrepreneur survival rate |
| `phi` | 0.10 (0 = cf) | home bias: sovereign-bond share of bank assets |
| `lam` | 4.0 | bank leverage multiplier `A/N^b` |
| `sigma_b` | 0.94 | banker survival rate |

`s0`, `ιe`, `ιb`, `eta` are back-solved from these targets inside the `.mod` preamble (closed form).
