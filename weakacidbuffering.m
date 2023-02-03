% some housekeeping stuff
register_graphics_toolkit ("gnuplot");
available_graphics_toolkits ();
graphics_toolkit ("gnuplot")
clear
figure(1); clf; figure(2); clf; figure(3); clf
% end of housekeeping

%plot -s 600,500 -f 'svg'
Kw=1e-14; pH=3.38:0.1:12; H=10.^-pH; OH=Kw./H; AcT=0.01; Ka=10^-4.75;
Na=OH+(AcT*Ka)./(Ka+H)-H;
figure(1);
plot(Na,pH,'linewidth',2); xlabel('[Na^+]'); ylabel('pH')
set(gca,'fontsize',11,'linewidth',2)
title('HAc titrated with NaOH (dashed line = just water)')
axis([0 0.02 2 12])

% add strong strong for comparison
pHs=2:0.1:12; Hs=10.^-pHs; OHs=Kw./Hs; Nas=OHs+AcT-Hs; 
hold on; plot(Nas,pHs,'k--','linewidth',2)

%plot -s 600,500 -f 'svg'
beta=diff(Na)./diff(pH);
n=size(pH,2); pHder=pH(1:n-1)+diff(pH);
figure(2)
plot(pHder,beta,'linewidth',2)
xlabel('pH'); ylabel('\Beta')
set(gca,'linewidth',2,'fontsize',11)
title('Weak acid buffer capacity versus pH')
axis([3.38 12 0 0.02])

%plot -s 600,500 -f 'svg'
figure(3)
plot(pHder,log10(beta),'linewidth',2)
xlabel('pH'); ylabel('log(\Beta)')
set(gca,'linewidth',2,'fontsize',11)
title('Weak acid buffer capacity (dashed line just water)')
axis([3.38 12 -8 -1.5])
hold on
betas=diff(Nas)./diff(pHs);
n=size(pHs,2); pHders=pHs(1:n-1)+diff(pHs);
plot(pHders,log10(betas),'k--','linewidth',2)