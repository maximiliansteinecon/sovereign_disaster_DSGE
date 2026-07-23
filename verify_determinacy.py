"""
Blanchard-Kahn / determinacy check for thesis_model via Sims (2002) gensys,
on the numerically linearized system  A_m1 y_{t-1} + A_0 y_t + A_p1 E_t y_{t+1} = 0.

gensys canonical form (Sims 2002):  G0 s_t = G1 s_{t-1} + Psi eps_t + Pi eta_t
with s_t = [y_t ; xi_t],  xi_t = E_t y_{t+1},  and expectational errors eta_t:
   block 1 (model):        A_0 y_t + A_p1 xi_t = -A_m1 y_{t-1}
   block 2 (definition):   y_t = xi_{t-1} + eta_t
=> G0=[[A_0,A_p1],[I,0]], G1=[[-A_m1,0],[0,I]], Pi=[[0],[I]].
Determinate  <=>  eu = [1,1]  (existence & uniqueness).
"""
import numpy as np
from scipy.linalg import ordqz
np.set_printoptions(suppress=True, linewidth=160)

def gensys(G0, G1, Pi, div=1.0+1e-8):
    """Minimal Sims (2002) gensys. Returns eu=[existence, uniqueness]."""
    n = G0.shape[0]
    # complex generalized Schur, stable (|lambda|<div) sorted FIRST
    def sortfun(alpha, beta):
        # keep (stable) if |beta/alpha| < div  (alpha<->s_ii, beta<->t_ii here)
        return np.abs(beta) < div*np.abs(alpha)
    AA, BB, alpha, beta, Q, Z = ordqz(G0, G1, sort=sortfun, output='complex')
    # eigenvalues = beta/alpha ; count explosive (unstable)
    with np.errstate(divide='ignore', invalid='ignore'):
        ev = np.where(np.abs(alpha) > 0, np.abs(beta)/np.abs(alpha), np.inf)
    nstable = int(np.sum(ev < div))
    nunstable = n - nstable
    Qt = Q.conj().T
    Q1 = Qt[:nstable, :]; Q2 = Qt[nstable:, :]
    # eta has m = Pi.shape[1] columns
    Q2Pi = Q2 @ Pi
    # existence: columns of Q2 @ Psi in span(Q2 @ Pi); with Psi arbitrary we only
    # test the rank condition for uniqueness/existence via Q2Pi.
    # uniqueness: no extra stable-side expectational freedom.
    # Ranks:
    u, sv, vh = np.linalg.svd(Q2Pi) if Q2Pi.size else (None, np.array([]), None)
    rank_Q2Pi = int(np.sum(sv > 1e-9)) if sv.size else 0
    m = Pi.shape[1]
    # existence: rank[Q2Pi] == rank[Q2Pi | Q2Psi]; with generic Psi this holds iff
    #   nunstable <= m and Q2Pi has full row rank (rows can be spanned).
    existence = 1 if (nunstable == rank_Q2Pi) else 0
    # uniqueness: the stable block imposes no left-over expectational error, i.e.
    #   number of expectational errors pinned == m  => rank condition on Q1 side.
    Q1Pi = Q1 @ Pi
    # standard gensys uniqueness: no q in row space of Q1Pi orthogonal to Q2Pi row space
    if Q2Pi.size and rank_Q2Pi < min(Q2Pi.shape):
        pass
    # uniqueness test (Sims): rank[Q2Pi] == rank[[Q1Pi;Q2Pi]] ?  -> then unique
    stacked = np.vstack([Q1Pi, Q2Pi])
    rank_stacked = int(np.sum(np.linalg.svd(stacked, compute_uv=False) > 1e-9))
    uniqueness = 1 if (rank_stacked == rank_Q2Pi) else 0
    return [existence, uniqueness], nstable, nunstable, ev

# ---------------- validate gensys on a textbook case  y_t = a E_t y_{t+1} ----
def toy(a):
    A_m1=np.array([[0.0]]); A_0=np.array([[1.0]]); A_p1=np.array([[-a]])
    n=1; I=np.eye(n); Z=np.zeros((n,n))
    G0=np.block([[A_0,A_p1],[I,Z]]); G1=np.block([[-A_m1,Z],[Z,I]]); Pi=np.vstack([Z,I])
    return gensys(G0,G1,Pi)
print("VALIDATION 1  y_t = a E_t y_{t+1}:")
for a in [0.5, 0.95, 1.5]:
    eu,ns,nu,ev = toy(a)
    print(f"  a={a:<4}  eu={eu}  (expect [1,1] iff |a|<1)   stable={ns} unstable={nu}")

def nk(phi_pi, phi_x=0.125, sigma=1.0, beta=0.99, kappa=0.1):
    # 3-eq NK model [x, pi, i]; determinate iff Taylor principle holds
    A0=np.array([[1.0,0.0,1/sigma],[-kappa,1.0,0.0],[-phi_x,-phi_pi,1.0]])
    Ap1=np.array([[-1.0,-1/sigma,0.0],[0.0,-beta,0.0],[0.0,0.0,0.0]])
    Am1=np.zeros((3,3)); I=np.eye(3); Z=np.zeros((3,3))
    G0=np.block([[A0,Ap1],[I,Z]]); G1=np.block([[-Am1,Z],[Z,I]]); Pi=np.vstack([Z,I])
    return gensys(G0,G1,Pi)[0]
print("VALIDATION 2  textbook 3-eq NK (Taylor principle):")
for pp in [1.5, 0.8]:
    print(f"  phi_pi={pp}: eu={nk(pp)}  (expect [1,1] iff phi_pi>1)")

# ---------------- linearize thesis_model & run gensys ------------------------
import io, contextlib
ns_={}
with contextlib.redirect_stdout(io.StringIO()):
    exec(open('verify_steady_state.py').read(), ns_)
residuals = ns_['residuals']; ssv = ns_['ssv']; VAR = ns_['VAR']
n=len(VAR)

def jac_blocks():
    Am1=np.zeros((n,n)); A0=np.zeros((n,n)); Ap1=np.zeros((n,n)); h=1e-6
    for j in range(n):
        step=h*max(1.0,abs(ssv[j]))
        for (blk,M) in [('l',Am1),('0',A0),('p',Ap1)]:
            a=[ssv.copy(),ssv.copy(),ssv.copy()]; b=[ssv.copy(),ssv.copy(),ssv.copy()]
            m={'l':0,'0':1,'p':2}[blk]; a[m][j]+=step; b[m][j]-=step
            M[:,j]=(residuals(*a)-residuals(*b))/(2*step)
    return Am1,A0,Ap1
A_m1,A_0,A_p1=jac_blocks()

I=np.eye(n); Z=np.zeros((n,n))
G0=np.block([[A_0,A_p1],[I,Z]])
G1=np.block([[-A_m1,Z],[Z,I]])
Pi=np.vstack([Z,I])
eu,ns,nu,ev = gensys(G0,G1,Pi)

# how many variables are genuinely forward-looking (appear with +1)?
nf = int(np.sum(np.any(np.abs(A_p1)>1e-8,axis=0)))
nlag = int(np.sum(np.any(np.abs(A_m1)>1e-8,axis=0)))
print("\nTHESIS MODEL (phi=%.2f):"%ns_['phi'])
print(f"  # endogenous variables      : {n}")
print(f"  # appear with a LEAD (+1)    : {nf}")
print(f"  # appear with a LAG (-1)     : {nlag}")
print(f"  gensys eu = {eu}   ->  {'DETERMINATE (unique stable RE solution)' if eu==[1,1] else 'NOT determinate'}")
finite_ev = ev[np.isfinite(ev)]
near = np.sort(finite_ev[(finite_ev>0.5)&(finite_ev<2.0)])
print(f"  finite |eigenvalues| in (0.5,2.0): {np.round(near,4)}")
print(f"  (none should sit exactly on the unit circle |lam|=1 -> BK well-posed)")
