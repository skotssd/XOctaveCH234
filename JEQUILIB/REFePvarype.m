% simulate reducing conditions increase pH
% just Fe, P

clear

FeT=1e-3; CT=0; PT=1e-3; MgT=0; NT=0; AAT=0; OxT=0; ASF=0.2; 
pH=6; pelow=-pH; pehigh=20.75-pH; perange=pelow:0.5:pehigh;

for i=1:length(perange)

[HFO(i),Siderite,Strengite(i),Struvite,Vivianite(i),MgOxs,FeIIOxs,HFOP(i),solP(i),solFe(i),MASSERROR(i)]=RE_FeCPNMgAAOxsystem_solvers(pH,perange(i),FeT,CT,PT,NT,MgT,AAT,OxT,ASF);

end

figure(1)
plot(perange,(HFOP)./PT,perange,(Vivianite*2)./PT,perange,Strengite./PT,perange,solP./PT, ...
    perange,HFOP./PT+(Vivianite*2)./PT+Strengite./PT+solP./PT)
legend('HFO-P','Vivianite','Strengite','solP','P_T')

figure(2)
plot(perange,MASSERROR)

