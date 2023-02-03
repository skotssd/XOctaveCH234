% some housekeeping stuff
register_graphics_toolkit ("gnuplot");
available_graphics_toolkits ();
graphics_toolkit ("gnuplot")
clear
figure(1);clf; figure(2); clf; figure(3); clf
% end of housekeeping

%plot -s 600,600 -f 'svg'
Kw=1e-14; pH=2:0.1:12; H=10.^-pH; OH=Kw./H; ClT=0.01;
Na=OH+ClT-H;
figure(1)
plot(Na,pH,'linewidth',2); xlabel('[Na^+]'); ylabel('pH')
set(gca,'fontsize',11,'linewidth',2)
title('HCl titrated with NaOH')

%plot -s 600,600 -f 'svg'
beta=diff(Na)./diff(pH);
n=size(pH,2); pHder=pH(1:n-1)+diff(pH);
figure(2)
plot(pHder,beta,'linewidth',2)
xlabel('pH'); ylabel('\beta')
set(gca,'linewidth',2,'fontsize',11)
title('Buffer capacity versus pH')

%plot -s 600,600 -f 'svg'
figure(3)
plot(pHder,log10(beta),'linewidth',2)
xlabel('pH'); ylabel('log(\beta)')
set(gca,'linewidth',2,'fontsize',11)
title('Buffer capacity versus pH')