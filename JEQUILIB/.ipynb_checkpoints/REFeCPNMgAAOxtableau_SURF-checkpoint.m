function [HFO,Siderite,Strengite,Struvite,Vivianite,MgOxs,FeIIOxs,HFOP,solP,solFe,MASSERR]=REFeCPNMgAAOxtableau_SURF(pH,pe,FeT,CT,PT,NT,MgT,AAT,OxT,HFOsT,HFOwT,flag1,flag2,database)

% input tableau.  change this part % ----------------------------------------------

% constants from PHREEQC database version 3.7.7-1
% struvite Ksp from Aseel's mfile
% strengite from minteq.v4.dat
% HFO surface complexes from minteq.v4.dat (just repeats strong and weak
% twice)
% AA from NIST.  redox potential from Harris 
%(convert to e based log by  Eo/59.2 *2
% Aseel looked up the AA and Ox values. including the Ksp of MG and Fe(II)
% oxalate pptes

Tableau=[...
    %H       %e      %FeIII      %CO3      %PO4  %NH3   %Mg2+   %DAA    %Ox    %HFOs    %HFOw    %logK    %phase   %name
    % component species identity matrix 
    1        0         0         0         0      0       0      0       0      0        0        0           0     {'H'}
    0        1         0         0         0      0       0      0       0      0        0        0           0     {'e'}
    0        0         1         0         0      0       0      0       0      0        0        0           0     {'FeIII'}
    0        0         0         1         0      0       0      0       0      0        0        0           0     {'CO3'}
    0        0         0         0         1      0       0      0       0      0        0        0           0     {'PO4'}
    0        0         0         0         0      1       0      0       0      0        0        0           0     {'NH3'}
    0        0         0         0         0      0       1      0       0      0        0        0           0     {'Mg'}
    0        0         0         0         0      0       0      1       0      0        0        0           0     {'DAA'}
    0        0         0         0         0      0       0      0       1      0        0        0           0     {'Ox'}
    0        0         0         0         0      0       0      0       0      1        0        0           0     {'HFOs'}
    0        0         0         0         0      0       0      0       0      0        1        0           0     {'HFOw'}
    % Kw
    -1       0         0         0         0      0       0      0       0      0        0        -14         0     {'OH'}
    % hydrolsis products of Fe
    -3       0         1         0         0      0       0      0       0      0        0        -4.891      1     {'HFO'}
    0        1         1         0         0      0       0      0       0      0        0        13.92       0     {'FeII'}
    -1       0         1         0         0      0       0      0       0      0        0        -2.19       0     {'FeIIIOH'}
    -2       0         1         0         0      0       0      0       0      0        0        -5.67       0     {'FeIIIOH2'}
    -3       0         1         0         0      0       0      0       0      0        0        -12.56      0     {'FeIIIOH3'}
    -4       0         1         0         0      0       0      0       0      0        0        -21.6       0     {'FeIIIOH4'}
    -2       0         2         0         0      0       0      0       0      0        0        -2.95       0     {'FeIII2OH2'}
    -4       0         3         0         0      0       0      0       0      0        0        -6.3        0     {'FeIII3OH4'}
    -1       1         1         0         0      0       0      0       0      0        0        -3.52       0     {'FeIIOH'}
    -2       1         1         0         0      0       0      0       0      0        0        -7.55       0     {'FeIIOH2'}
    -3       1         1         0         0      0       0      0       0      0        0        -17.98      0     {'FeIIOH3'}
   %phosphoric acid and strengite and vivianite
    1        0         0         0         1      0       0      0       0      0        0        12.346      0     {'HPO4'}
    2        0         0         0         1      0       0      0       0      0        0        19.553      0     {'H2PO4'}
    3        0         0         0         1      0       0      0       0      0        0        21.721      0     {'H3PO4'}
    0        0         1         0         1      0       0      0       0      0        0        23.2        1     {'Strengite'}
    0        3         3         0         2      0       0      0       0      0        0        75.06       1     {'Vivianite'}
    %carbonic acid and FeCO3(s)
    1        0         0         1         0      0       0      0       0      0        0       10.329      0     {'HCO3'}
    2        0         0         1         0      0       0      0       0      0        0       16.681      0     {'H2CO3'}
    0        1         1         1         0      0       0      0       0      0        0       23.91       1     {'Siderite'}
    0        1         1         1         0      0       0      0       0      0        0       17.4        0     {'FeIICO3'}
    1        1         1         1         0      0       0      0       0      0        0       25.349      0     {'FeIIHCO3'}
    % Fe-P soluble complexes
    1        0         1         0         1      0       0      0       0      0        0       17.776      0     {'FeIIIHPO4'}
    2        0         1         0         1      0       0      0       0      0        0       24.983      0     {'FeIIIH2PO4'}
    1        1         1         0         1      0       0      0       0      0        0       28.966      0     {'FeIIHPO4'}
    2        1         1         0         1      0       0      0       0      0        0       35.273      0     {'FeIIH2PO4'}
    % protonation ammonia
    1        0         0         0         0      1       0      0       0      0        0       9.252       0     {'HNH3'}
    % Mg soluble species
    -1       0         0         0         0      0       1      0       0      0        0       -11.44      0     {'MgOH'}
    0        0         0         1         0      0       1      0       0      0        0       2.98        0     {'MgCO3'}
    1        0         0         1         0      0       1      0       0      0        0       11.399      0     {'MgHCO3'}
    0        0         0         0         1      0       1      0       0      0        0       6.589       0     {'MgPO4'}
    1        0         0         0         1      0       1      0       0      0        0       15.216      0     {'MgHPO4'}
    2        0         0         0         1      0       1      0       0      0        0       21.066      0     {'MgH2PO4'}
    % Struvite
    0        0         0         0         1      1       1      0       0      0        0       13.26       1     {'Struvite'}
    % ascorbic acid reactions
    2        2         0         0         0      0       0      1       0      0        0       13.2        0     {'AAH2'}
    1        2         0         0         0      0       0      1       0      0        0       9.03        0     {'AAH'}
    0        2         0         0         0      0       0      1       0      0        0       -2.69       0     {'AA'}
    1        3         1         0         0      0       0      1       0      0        0       23.15       0     {'FeIIAAH'}
    2        3         1         0         0      0       0      1       0      0        0       25.75       0     {'FeIIAAH2'}
    2        4         1         0         0      0       0      2       0      0        0       24.42       0     {'FeIIIAAH2'}
    % oxalic acid reactions
    1        0         0         0         0      0       0      0       1      0        0       4.266       0     {'OxH'}
    2        0         0         0         0      0       0      0       1      0        0       5.536       0     {'OxH2'}
    0        0         1         0         0      0       0      0       1      0        0       9.53        0     {'FeIIIOx'}
    0        0         1         0         0      0       0      0       2      0        0       15.75       0     {'FeIIIOx2'}
    0        0         1         0         0      0       0      0       3      0        0       20.2        0     {'FeIIIOx3'}
    1        0         1         0         0      0       0      0       1      0        0       13.796      0     {'FeIIIHOx'}
    0        1         1         0         0      0       0      0       1      0        0       17.12       0     {'FeIIOx'}
    0        1         1         0         0      0       0      0       2      0        0       19.22       0     {'FeIIOx'}
    0        1         1         0         0      0       0      0       3      0        0       18.24       0     {'FeIIOx'}
    0        0         0         0         0      0       1      0       1      0        0       3.62        0     {'MgOx'}
    0        0         0         0         0      0       1      0       1      0        0       5.68        1     {'MgOxs'}
    0        1         1         0         0      0       0      0       1      0        0       19.49       1     {'FeIIOxs'}
    % surface complexes
    1        0         0         0         0      0       0      0       0      1        0       8.93        0     {'HFOsH'}
    2        0         0         0         0      0       0      0       0      1        0       16.22       0     {'HFOsH2'}
    1        0         0         0         0      0       0      0       0      0        1       8.93        0     {'HFOwH'}
    2        0         0         0         0      0       0      0       0      0        1       16.22       0     {'HFOwH2'}
    2        0         0         0         1      0       0      0       0      0        1       26.65       0     {'HFOwPO4'}
    3        0         0         0         1      0       0      0       0      0        1       34.32       0     {'HFOwHPO4'}
    4        0         0         0         1      0       0      0       0      0        1       40.22       0     {'HFOwH2PO4'}
    2        0         0         0         1      0       0      0       0      1        0       26.65       0     {'HFOsPO4'}
    3        0         0         0         1      0       0      0       0      1        0       34.32       0     {'HFOsHPO4'}
    4        0         0         0         1      0       0      0       0      1        0       40.22       0     {'HFOsH2PO4'}
 ];

T=[FeT; CT; PT; NT; MgT; AAT; OxT; HFOsT; HFOwT];

% remove any row and columns if component total conc is equal to zero
%size(Tableau)

INDEX=[];

if HFOsT==0 %10th entry
    Nentries=cell2mat(Tableau(:,10));
    indices = find(Nentries>=1);
    Tableau(indices,:) = [];
    INDEX=[INDEX 10];
    HFOP=0;
end

if HFOwT==0 %11th entry
    Nentries=cell2mat(Tableau(:,11));
    indices = find(Nentries>=1);
    Tableau(indices,:) = [];
    INDEX=[INDEX 11];
    HFOP=0;
end


if CT==0 %4th entry
    Nentries=cell2mat(Tableau(:,4));
    indices = find(Nentries>=1);
    Tableau(indices,:) = [];
    INDEX=[INDEX 4];
    Siderite=0;
end

if NT==0 %6th entry
    Nentries=cell2mat(Tableau(:,6));
    indices = find(Nentries>=1);
    Tableau(indices,:) = [];
    INDEX=[INDEX 6];
    Struvite=0;
end

if MgT==0 %7th entry
    Nentries=cell2mat(Tableau(:,7));
    indices = find(Nentries>=1);
    Tableau(indices,:) = [];
    INDEX=[INDEX 7];
    Struvite=0; MgOxs=0;
end

if AAT==0 %8th entry
    Nentries=cell2mat(Tableau(:,8));
    indices = find(Nentries>=1);
    Tableau(indices,:) = [];
    INDEX=[INDEX 8];
end

if OxT==0 %9th entry
    Nentries=cell2mat(Tableau(:,9));
    indices = find(Nentries>=1);
    Tableau(indices,:) = [];
    MgOxs=0; FeIIOxs=0;
    INDEX=[INDEX 9];
end

Tableau(:,INDEX)=[];

T(T==0)=[];


% end of tableau.  ------------------ % ----------------------------------------------

[KSOLID,ASOLID,SOLIDNAMES,KSOLUTION,ASOLUTION,SOLUTIONNAMES]=processtableau(Tableau,pH,pe);

[SPECIESCONCS,SPECIATIONNAMES,MASSERR,X]=returnspeciationRE(KSOLID,ASOLID,SOLIDNAMES,KSOLUTION,ASOLUTION,SOLUTIONNAMES,T,flag1,flag2,database);

for k=1:size(SPECIESCONCS,1)
      txt=[SPECIATIONNAMES(k,:),'=SPECIESCONCS(k);'];
      eval(txt)
end

if HFOwT>0; HFOP=HFOwPO4+HFOwHPO4+HFOwH2PO4+HFOsPO4+HFOsHPO4+HFOsH2PO4; end

solP=PT-(HFOP+2*Vivianite+Strengite+Struvite);
solFe=FeT-(HFO+3*Vivianite+Strengite+Siderite+FeIIOxs);

end