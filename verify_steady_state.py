"""
CORRECTED, square (33 eq / 33 var), flow-consistent GK+BGG closure.
Computes the closed-form steady state, checks all dynamic residuals at SS,
and checks that the stacked Jacobian has full row rank = 33 (square & regular).
"""
import numpy as np
np.set_printoptions(suppress=True, linewidth=200)

# ------------------------- PARAMETERS -------------------------
delta0=0.02; upsilon=6.0; alpha=0.33; muz=0.005; phipi=1.6; phiy=0.4; rhor=0.85
psitilde=2.0; zeta=0.6; gamma=3.8; tau=2.0; varpi=2.33; Deltak=0.22
rhotheta=0.9; sigtheta=0.6; beta0=0.99; piss=1.005; thetass=0.009; uss=1.0
# banking / entrepreneur / sovereign
import os
Deltab=0.30; chie=0.05; premE=1.0030; sprL=1.0020; levE=2.0; tau_e=0.975
phi=float(os.environ.get('PHI','0.10')); lam=4.0; sigma_b=0.94
psi=1.0-(1.0-psitilde)/(1.0+varpi); chi=1.0-(1.0-gamma)/(1.0-psi)
EFPtot=sprL*premE   # total wedge E[RK]/Rd used in the real block

# ------------------------- STEADY STATE -------------------------
betathetass=beta0*((1-thetass+thetass*np.exp((1-gamma)*np.log(1-Deltak)))**(1/(1-chi)))
Qss=betathetass*np.exp((1-psi)*muz)/((1-thetass*Deltak)*np.exp(muz))
rss=piss/Qss; Rfss=1.0/Qss; Rdss=Rfss
RLss=sprL*Rdss                        # loan rate
ERKss=premE*RLss                      # expected return on capital = RL*premium (=EFPtot*Rd)
RKtildess=ERKss/(1-thetass*Deltak)    # disaster-free capital return
pkrss=RKtildess-(1-delta0); eta=pkrss/delta0
piresetss=(((piss)**(1-upsilon)-zeta)/(1-zeta))**(1/(1-upsilon))
mcss=((upsilon-1)/upsilon)*(1/piss)*((1-zeta*Qss*(1-thetass*Deltak)*np.exp(muz)*piss**upsilon)
      /(1-zeta*Qss*(1-thetass*Deltak)*np.exp(muz)*piss**(upsilon-1)))*piresetss
klss=(mcss*alpha/pkrss)**(1/(1-alpha)); wss=mcss*(1-alpha)*klss**alpha
omegass=((1-zeta)*piresetss**(-upsilon)*piss**upsilon)/(1-zeta*piss**upsilon)
clss=(1/omegass)*klss**alpha-klss*(np.exp(muz)-1+delta0)
lss=1/(1+(varpi/wss)*clss); kss=klss*lss; ktildess=kss; css=clss*lss
ylss=clss+klss*(np.exp(muz)-1+delta0); yss=ylss*lss; iss=yss-css
X1ss=yss*mcss/(1-zeta*Qss*(1-thetass*Deltak)*np.exp(muz)*piss**upsilon)
X2ss=yss/(1-zeta*Qss*(1-thetass*Deltak)*np.exp(muz)*piss**(upsilon-1))
vss=(css*(1-lss)**varpi)**(1-psi)/(1-betathetass*np.exp(muz*(1-psi)))
Qtobss=1.0; RKss=RKtildess
Ness=kss/levE; s0=premE*(1.0/levE)**(chie)     # premium: ERK/RL = s0*(Ne/Qk)^(-chie)
iotae=Ness-tau_e*(RKss*kss-RLss*(kss-np.exp(-muz)*Ness))
QLss=kss-Ness; Ass=QLss/(1-phi); QbBss=phi*Ass; Nbss=Ass/lam; Dss=Ass-Nbss
LambdaM=(1-Deltak)**(-gamma); Hbss=1-thetass*Deltab*LambdaM
Qbss=Hbss/Rfss; Rbss=1.0/Qbss
iotab=Nbss-sigma_b*np.exp(-muz)*((RLss-Rdss)*QLss+(Rbss-Rdss)*QbBss+Rdss*Nbss)

# check premium identity at SS
print("Checks:")
print("  ERK/RL = premE ?      ", np.isclose(ERKss/RLss,premE), ERKss/RLss)
print("  s0*(Ne/Qk)^-chie=prem?", np.isclose(s0*(Ness/(Qtobss*kss))**(-chie),premE))
print("  iotae, iotab          ", round(iotae,5), round(iotab,5))
print("  Ne,Nb,QL,D,Qb > 0     ", Ness>0,Nbss>0,QLss>0,Dss>0,0<Qbss<1)
print("  RL<ERK (entrep prem)  ", RLss<ERKss, "  Rd<RL:", Rdss<RLss)

# ------------------------- VARIABLE / RESIDUAL SETUP -------------------------
spreadss=1.0/Qbss-Rfss; levss=(QLss+QbBss)/Nbss
VAR=['theta','betatheta','y','c','i','L','k','u','ktilde','w','Pkr','Q','pi','pireset',
 'X1','X2','Omega','mc','v','r','Qtob','Rf','Rd','RL','RK','Ne','QL','QbB','Nb','Qb','Hb','Rb','D',
 'spread','lev']
SS={'theta':thetass,'betatheta':betathetass,'y':yss,'c':css,'i':iss,'L':lss,'k':kss,
 'u':uss,'ktilde':ktildess,'w':wss,'Pkr':pkrss,'Q':Qss,'pi':piss,'pireset':piresetss,
 'X1':X1ss,'X2':X2ss,'Omega':omegass,'mc':mcss,'v':vss,'r':rss,'Qtob':Qtobss,'Rf':Rfss,
 'Rd':Rdss,'RL':RLss,'RK':RKss,'Ne':Ness,'QL':QLss,'QbB':QbBss,'Nb':Nbss,'Qb':Qbss,
 'Hb':Hbss,'Rb':Rbss,'D':Dss,'spread':spreadss,'lev':levss}
idx={v:i for i,v in enumerate(VAR)}; ssv=np.array([SS[v] for v in VAR])

def residuals(xl,x0,xp):
    d=lambda n,a:a[idx[n]]
    theta=d('theta',x0);betatheta=d('betatheta',x0);y=d('y',x0);c=d('c',x0);i=d('i',x0)
    L=d('L',x0);k=d('k',x0);u=d('u',x0);ktilde=d('ktilde',x0);w=d('w',x0);Pkr=d('Pkr',x0)
    Q=d('Q',x0);pi=d('pi',x0);pireset=d('pireset',x0);X1=d('X1',x0);X2=d('X2',x0)
    Omega=d('Omega',x0);mc=d('mc',x0);v=d('v',x0);r=d('r',x0);Qtob=d('Qtob',x0);Rf=d('Rf',x0)
    Rd=d('Rd',x0);RL=d('RL',x0);RK=d('RK',x0);Ne=d('Ne',x0);QL=d('QL',x0);QbB=d('QbB',x0)
    Nb=d('Nb',x0);Qb=d('Qb',x0);Hb=d('Hb',x0);Rb=d('Rb',x0);D=d('D',x0)
    c_p=d('c',xp);L_p=d('L',xp);v_p=d('v',xp);Pkr_p=d('Pkr',xp);u_p=d('u',xp)
    Qtob_p=d('Qtob',xp);X1_p=d('X1',xp);X2_p=d('X2',xp);pi_p=d('pi',xp);RK_p=d('RK',xp)
    theta_l=d('theta',xl);k_l=d('k',xl);Omega_l=d('Omega',xl);r_l=d('r',xl)
    Qtob_l=d('Qtob',xl);Ne_l=d('Ne',xl);RL_l=d('RL',xl);QL_l=d('QL',xl)
    QbB_l=d('QbB',xl);Nb_l=d('Nb',xl);Qb_l=d('Qb',xl)
    R=[]
    R.append(-np.log(theta)+(1-rhotheta)*np.log(thetass)+rhotheta*np.log(theta_l))              #1 theta
    R.append(-v+(c*(1-L)**varpi)**(1-psi)+betatheta*np.exp((1-psi)*muz)*(v_p**(1-chi))**(1/(1-chi))) #2 value
    R.append(-betatheta+beta0*((1-theta+theta*np.exp((1-gamma)*np.log(1-Deltak)))**(1/(1-chi)))) #3 betatheta
    R.append(-Q*(1-theta*Deltak)*np.exp(muz)+(c_p/c)**(-psi)*((1-L_p)/(1-L))**(varpi*(1-psi))*betatheta*np.exp((1-psi)*muz)*v_p**(-chi)/(v_p**(1-chi))**(-chi/(1-chi))) #4 SDF
    R.append(-(1-L)/c+varpi/w)                                                                   #5 cons-leis
    R.append(-Q+pi_p/r)                                                                          #6 fisher/deposit
    R.append(-Rf+1.0/Q)                                                                          #7 riskfree
    R.append(-Rd+Rf)                                                                             #8 deposit mkt
    R.append(-Qtob+1.0/(1-tau*(i/k_l-iss/kss)))                                                  #9 tobin Q
    R.append(-k+((1-delta0*u**eta)*k_l+(i/k_l-tau/2*((i/k_l-iss/kss)**2))*k_l)/np.exp(muz))      #10 capital LoM
    R.append(-y+ktilde**alpha*L**(1-alpha)/Omega)                                                #11 production
    R.append(-w+mc*(1-alpha)*(ktilde/L)**alpha)                                                  #12 wage
    R.append(-Pkr+mc*alpha*(ktilde/L)**(alpha-1))                                                #13 rental
    R.append(-ktilde+u*k_l)                                                                      #14 ktilde
    R.append(-pireset+pi*upsilon/(upsilon-1)*X1/X2)                                              #15 reset pi
    R.append(-Omega+(1-zeta)*pireset**(-upsilon)*pi**upsilon+zeta*pi**upsilon*Omega_l)           #16 dispersion
    R.append(-(pi**(1-upsilon))+(1-zeta)*pireset**(1-upsilon)+zeta)                              #17 agg pi
    R.append(-X1+y*mc+zeta*Q*(1-theta*Deltak)*np.exp(muz)*X1_p*pi_p**upsilon)                    #18 X1
    R.append(-X2+y+zeta*Q*(1-theta*Deltak)*np.exp(muz)*X2_p*pi_p**(upsilon-1))                   #19 X2
    R.append(-Pkr+Qtob*delta0*eta*u**(eta-1))                                                    #20 util FOC
    R.append(-RK+(Pkr*u+Qtob*(1-delta0*u**eta))/Qtob_l)                                          #21 RK realized
    R.append(-(1-theta*Deltak)*RK_p+RL*s0*(Ne/(Qtob*k))**(-chie))                                #22 capital demand (BGG): E[RK]=RL*prem
    R.append(-Ne+tau_e*(RK*Qtob_l*k_l-RL_l*(Qtob_l*k_l-np.exp(-muz)*Ne_l))+iotae)                #23 entrep NW
    R.append(-QL+Qtob*k-Ne)                                                                      #24 entrep BS
    R.append(-QbB+phi/(1-phi)*QL)                                                                #25 home bias
    R.append(-(QL+QbB)+lam*Nb)                                                                   #26 leverage (binding)
    R.append(-Nb+sigma_b*np.exp(-muz)*((RL-Rd)*QL_l+(Rb-Rd)*QbB_l+Rd*Nb_l)+iotab)                #27 bank NW (earns RL)
    R.append(-(QL+QbB)+Nb+D)                                                                     #28 bank BS -> D
    R.append(-Hb+1-theta*Deltab*LambdaM)                                                         #29 resilience
    R.append(-Qb+Hb/Rf)                                                                          #30 bond price
    R.append(-Rb+1.0/Qb_l)                                                                       #31 bond return
    R.append(-r+rhor*r_l+(1-rhor)*(phipi*(pi-piss)+phiy*(y-yss)+rss))                            #32 taylor
    R.append(-y+c+i)                                                                             #33 resource
    spread=d('spread',x0); lev=d('lev',x0)
    R.append(-spread+1.0/Qb-Rf)                                                                  #34 spread (reporting)
    R.append(-lev+(QL+QbB)/Nb)                                                                   #35 lev (reporting)
    return np.array(R)

EQN=['theta','value','betatheta','SDF','cons_leis','fisher','riskfree','deposit_mkt','tobinQ',
 'capital_LoM','production','wage','rental','ktilde','reset_pi','dispersion','agg_pi','X1','X2',
 'util_FOC','RK_def','cap_demand','entrep_NW','entrep_BS','home_bias','leverage','bank_NW',
 'bank_BS','resilience','bond_price','bond_return','taylor','resource','spread','lev']

r0=residuals(ssv,ssv,ssv)
print("\n#eq=%d  #var=%d   max|resid at SS|=%.2e"%(len(r0),len(VAR),np.max(np.abs(r0))))
bad=[(EQN[i],r0[i]) for i in range(len(r0)) if abs(r0[i])>1e-9]
print("  nonzero residuals:", bad if bad else "NONE  -> PASS")

# stacked Jacobian rank (square regularity)
def jac():
    cols=[];h=1e-6
    for blk in ['l','0','p']:
        for j in range(len(VAR)):
            step=h*max(1.0,abs(ssv[j]))
            a=[ssv.copy(),ssv.copy(),ssv.copy()];b=[ssv.copy(),ssv.copy(),ssv.copy()]
            m={'l':0,'0':1,'p':2}[blk]; a[m][j]+=step; b[m][j]-=step
            cols.append((residuals(*a)-residuals(*b))/(2*step))
    return np.array(cols).T
J=jac()
print("  Jacobian rank = %d (need %d for square regular system)"%(np.linalg.matrix_rank(J,tol=1e-7),len(VAR)))

# report SS compactly
print("\nSteady state (key):")
for v in ['y','c','i','L','k','Ne','Nb','QL','QbB','D','RL','RK','Rf','Qb','Rb','pkr' if False else 'Pkr']:
    print("  %-6s %.5f"%(v,SS[v]))
print("  spread(annualized bp) ~ %.1f"%((1/Qbss-Rfss)*4*1e4))
