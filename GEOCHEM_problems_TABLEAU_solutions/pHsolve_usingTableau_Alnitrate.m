
TABLEAU=[...
%H+   Al3+ logK
1        0       0         %H
0        1       0         %Al3+
-1      0       -14      %OH
-1      1       -5       %AlOH2+
0.03  0.01   0         %TOTALS 
];

% now take TABLEAU apart --------------------------------------------------

[N,M]=size(TABLEAU);

ASOLUTION=TABLEAU(1:N-1,1:M-1);
KSOLUTION=TABLEAU(1:N-1,M);
T=TABLEAU(N,1:M-1)'; T(T==0)=1e-30;

format short e

X=T./10; [xans,masserr,J,C] = nl_massbalancerrnosolid_NR(X,ASOLUTION,KSOLUTION,T);

concs=C
pH=-log10(C(1))