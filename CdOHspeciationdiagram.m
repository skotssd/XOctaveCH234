% some housekeeping stuff
register_graphics_toolkit ("gnuplot");
available_graphics_toolkits ();
graphics_toolkit ("gnuplot")
clear
figure(1); clf
% end of housekeeping

%plot -s 600,500 -f 'svg'
logB1=4.1; logB2=7.7; logB3=10.3; logB4=12; Kw=1e-14;
B1=10^logB1; B2=10^logB2; B3=10^logB3; B4=10^logB4;
pH=6:0.1:14; H=10.^(-pH); OH=Kw./H;
denominator=1+B1*OH+B2*OH.^2+B3*OH.^3+B4*OH.^4;
alphaCd=1./denominator;
alphaCdOH=(B1*OH)./denominator;
alphaCdOH2=(B2*OH.^2)./denominator;
alphaCdOH3=(B3*OH.^3)./denominator;
alphaCdOH4=(B4*OH.^4)./denominator;

plot(pH,alphaCd,'b','linewidth',2)
hold on
plot(pH,alphaCdOH,'g','linewidth',2)
plot(pH,alphaCdOH2,'m','linewidth',2)
plot(pH,alphaCdOH3,'k','linewidth',2)
plot(pH,alphaCdOH4,'c','linewidth',2)
xlabel('pH'); ylabel('\alpha');
legend('Cd^{2+}','CdOH^+','Cd(OH)_2','Cd(OH)_3^-','Cd(OH)_4^{2-}','location','west')
set(gca,'linewidth',2)
title('Distribution diagram, Cd hydroxo complexation')

% add stepwise values (pH=pKa but we need to convert because we were given overall association constants)

plot([9.9 9.9],[0 1],'k:','linewidth',2)
plot([10.4 10.4],[0 1],'k:','linewidth',2)
plot([11.4 11.4],[0 1],'k:','linewidth',2)
plot([12.3 12.3],[0 1],'k:','linewidth',2)

