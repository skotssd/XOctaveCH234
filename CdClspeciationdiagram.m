% some housekeeping stuff
register_graphics_toolkit ("gnuplot");
available_graphics_toolkits ();
graphics_toolkit ("gnuplot")
clear
figure(1);clf
% end of housekeeping

%plot -s 600,500 -f 'svg'
logB1=1.35; logB2=1.7; logB3=1.9; B1=10^logB1; B2=10^logB2; B3=10^logB3;
logCl=-3.5:0.1:0; Cl=10.^logCl;
denominator=1+B1*Cl+B2*Cl.^2+B3*Cl.^3;
alphaCd=1./denominator;
alphaCdCl=(B1*Cl)./denominator;
alphaCdCl2=(B2*Cl.^2)./denominator;
alphaCdCl3=(B3*Cl.^3)./denominator;

plot(logCl,alphaCd,'b','linewidth',2)
hold on
plot(logCl,alphaCdCl,'g','linewidth',2)
plot(logCl,alphaCdCl2,'m','linewidth',2)
plot(logCl,alphaCdCl3,'k','linewidth',2)
xlabel('log[Cl^-]'); ylabel('\alpha');
legend('Cd^{2+}','CdCl^+','CdCl_2','CdCl_3^-','location','west')
set(gca,'linewidth',2)
title('Distribution diagram, Cd chloro complexation')

% add stepwise values (well actually -1*stepwise K values.  when the two species are equal)

plot([-1.35 -1.35],[0 1],'k:','linewidth',2)
plot([-0.35 -0.35],[0 1],'k:','linewidth',2)
plot([-0.2 -0.2],[0 1],'k:','linewidth',2)

% and to determine predominant species

plot([log10(0.6) log10(0.6)],[0 1],'y-','linewidth',2); % seawater
plot([-3 -3],[0 1],'y-','linewidth',2); % freshwater