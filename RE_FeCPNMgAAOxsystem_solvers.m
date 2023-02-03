function [HFO,Siderite,Strengite,Struvite,Vivianite,MgOxs,FeIIOxs,HFOP,solP,solFe,MASSERR]=RE_FeCPNMgAAOxsystem_solvers(pH,pe,FeT,CT,PT,NT,MgT,AAT,OxT,ASF)

database=[]; flag1=2; flag2=1; ASFs=ASF; ASFw=ASF; HFOsT=0; HFOwT=0;

[HFO,Siderite,Strengite,Struvite,Vivianite,MgOxs,FeIIOxs,HFOP,solP,solFe,MASSERR]=REFeCPNMgAAOxtableau_SURF(pH,pe,FeT,CT,PT,NT,MgT,AAT,OxT,HFOsT,HFOwT,flag1,flag2,database);
HFOP=0; c=0; HFOtst=0; if HFO>0; HFOtst=1; end % so loop starts
while abs(HFOtst) > 1e-10 
    HFOcheck=HFO; c=c+1; HFOv(c)=HFO;
    HFOsT=ASFs*HFO; HFOwT=ASFw*HFO;
    [HFO,Siderite,Strengite,Struvite,Vivianite,MgOxs,FeIIOxs,HFOP,solP,solFe,MASSERR]=REFeCPNMgAAOxtableau_SURF(pH,pe,FeT,CT,PT,NT,MgT,AAT,OxT,HFOsT,HFOwT,flag1,flag2,database);
    HFOtst=(HFOcheck-HFO)./FeT; % make sure amount of HFO does not change with surface P equilib
    if c==20; HFOtst=0; disp('converge HFO problem'); end % prevent infinite loop
end
%if c>0; plot(HFOv,'ko'); end
if max(MASSERR)>1e-4; disp('PROBLEM !!!!'); 
    flag1=2; flag2=2;
    [HFO,Siderite,Strengite,Struvite,Vivianite,MgOxs,FeIIOxs,HFOP,solP,solFe,MASSERR]=REFeCPNMgAAOxtableau_SURF(pH,pe,FeT,CT,PT,NT,MgT,AAT,OxT,HFOsT,HFOwT,flag1,flag2,database);
    HFOP=0; c=0; HFOtst=0; if HFO>0; HFOtst=1; end % so loop starts
    while abs(HFOtst) > 1e-10 
        HFOcheck=HFO; c=c+1; HFOv(c)=HFO;
        HFOsT=ASFs*HFO; HFOwT=ASFw*HFO;
        [HFO,Siderite,Strengite,Struvite,Vivianite,MgOxs,FeIIOxs,HFOP,solP,solFe,MASSERR]=REFeCPNMgAAOxtableau_SURF(pH,pe,FeT,CT,PT,NT,MgT,AAT,OxT,HFOsT,HFOwT,flag1,flag2,database);
        HFOtst=(HFOcheck-HFO)./FeT; % make sure amount of HFO does not change with surface P equilib
        if c==20; HFOtst=0; disp('converge HFO problem'); end % prevent infinite loop
    end
end

MASSERR=max(MASSERR);

end
