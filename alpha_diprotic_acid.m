% some housekeeping stuff
register_graphics_toolkit("gnuplot");
available_graphics_toolkits();
graphics_toolkit("gnuplot")
clear
% end of housekeeping
%plot -s 600,500 -f 'svg'
pKa1=4; pKa2=8;
Ka1=10^-pKa1; Ka2=10^-pKa2;
pH=2:0.1:12; H=10.^-pH;

denominator=H.^2+Ka1*H+Ka1*Ka2;
alphaH2A=(H.^2)./denominator;
alphaHA=(Ka1*H)./denominator;
alphaA=1-alphaH2A-alphaHA;

plot(pH,alphaH2A,'linewidth',2,pH,alphaHA,'linewidth',2,pH,alphaA,'linewidth',2)
set(gca,'fontsize',12,'linewidth',2)
legend('H_2A','HA^-','A^{2-}')
title('Distribution Diagram for H2A')
xlabel('pH'); ylabel('\alpha','fontsize',16)

hold on
plot([pKa1 pKa1],[0 1],'k:','linewidth',2)
plot([pKa2 pKa2],[0 1],'k:','linewidth',2)
plot([2 12],[0.5 0.5],'k:','linewidth',2)