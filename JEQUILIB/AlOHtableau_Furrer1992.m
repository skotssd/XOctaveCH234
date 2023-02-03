% start of tableau (problem definition)
% you can change this part

Tableau=[...
%H      e        AlT      logK     phase     species1 
1       0        0          0        0        {'H'}
0       1        0          0        0        {'e '}
0       0        1          0        0        {'Al'}
-1      0        1          -5.00    0        {'AlOH'}
-2      0        1          -10.1    0        {'AlOH2'}
-3      0        1          -16.8    0        {'AlOH3'}
-4      0        1          -22.87   0        {'AlOH4'} 
-2      0        2          -7.7     0        {'Al2'}
-4      0        3          -13.84   0        {'Al3'}
-32     0        13         -98.73   0        {'Al13'}
-3      0        1          -8.77    1        {'Gibbsite'} 
];

%input totals and pH and pe
AlT=1e-6; T=[AlT]; pH=6; 
pe=20.75-pH; % oxic
%pe=-pH; % reducing

% end of tableau.  ------------------ % ----------------------------------------------
% no changes below this line --------------------------------------------------------

[KSOLID,ASOLID,SOLIDNAMES,KSOLUTION,ASOLUTION,SOLUTIONNAMES]=processtableau(Tableau,pH,pe);
flag1=2; flag2=1; % default to logX solution scheme with analtyical derivatives
database=[]; % deacivated PHREEQC solver.
[SPECIESCONCS,SPECIATIONNAMES,MASSERR,X]=returnspeciationRE(KSOLID,ASOLID,SOLIDNAMES,KSOLUTION,ASOLUTION,SOLUTIONNAMES,T,flag1,flag2,database);

% this will generate the outputs

for k=1:size(SPECIESCONCS,1)
      txt=[SPECIATIONNAMES(k,:),'=SPECIESCONCS(k)'];
      eval(txt)
end

