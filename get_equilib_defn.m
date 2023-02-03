function [KSOLUTION,ASOLUTION,SOLUTIONNAMES] = get_equilib_defn 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from NIST K values

logKw=-14; 
logKFFeIIIOH=11.81;
logKFFeIIIOH2=22.4;
logKFFeIIIOH3=30.2;
logKFFeIIIOH4=34.4;
logKFFeIII2OH2=25.10;
logKFFeIII3OH4=49.7;

Tableau=[...
%H	  FeIII        logK                           species
 1	  0	            0                              {'H'}
 0	  1	            0                              {'FeIII'}
-1	  0	            logKw                          {'OH'}
-1    1             logKFFeIIIOH+logKw             {'FeIIIOH'}
-2    1             logKFFeIIIOH2+2*logKw          {'FeIIIOH2'}
-3    1             logKFFeIIIOH3+3*logKw          {'FeIIIOH3'}
-4    1             logKFFeIIIOH4+4*logKw          {'FeIIIOH4'}
-2    2             logKFFeIII2OH2+2*logKw         {'FeIII2OH2'}
-4    4             logKFFeIII3OH4+4*logKw         {'FeIII3OH4'}
];

n=size(Tableau,2);
ASOLUTION=cell2mat(Tableau(:,1:n-2));
KSOLUTION=cell2mat(Tableau(:,n-1));
SOLUTIONNAMES=strvcat(Tableau(:,n));

end