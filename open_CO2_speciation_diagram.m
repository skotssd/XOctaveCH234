% some housekeeping stuff
register_graphics_toolkit("gnuplot");
available_graphics_toolkits();
graphics_toolkit("gnuplot")
clear
figure(1); clf; figure(2); clf
% end of housekeeping

%plot -s 600,500 -f 'svg'
Ka1=10^-6.3;Ka2=10^-10.3;KH=10^-1.5;PCO2=10^-3.5;
pH=2:0.1:12; H=10.^-pH;
H2CO3=KH*PCO2*ones(size(pH));
HCO3=(Ka1*KH*PCO2)./H;
CO3=(Ka1*KH*PCO2*Ka2)./(H.^2);
figure(1);
semilogy(pH,H2CO3,'b','linewidth',2)
hold on
semilogy(pH,HCO3,'g','linewidth',2)
semilogy(pH,CO3,'m','linewidth',2)
semilogy(pH,H2CO3+HCO3+CO3,'k-','linewidth',2)
xlabel('pH'); ylabel('log[CO2 species (M)]');
legend('H2CO3','HCO3','CO3','CT','location','northwest')
set(gca,'linewidth',2);
title('Distribution diagram, Open CO2 system')

%plot -s 600,500 -f 'svg'
figure(2)
plot(pH,H2CO3,'b','linewidth',2)
hold on
plot(pH,HCO3,'g','linewidth',2)
plot(pH,CO3,'m','linewidth',2)
plot(pH,H2CO3+HCO3+CO3,'k-','linewidth',2)
xlabel('pH'); ylabel('[CO2 species (M)]');
legend('H2CO3','HCO3','CO3','CT','location','northwest');
set(gca,'linewidth',2);
title('Distribution diagram, Open CO2 system')
axis([2 10 0 0.08])