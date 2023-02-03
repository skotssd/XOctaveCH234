% some housekeeping stuff
register_graphics_toolkit("gnuplot");
available_graphics_toolkits();
graphics_toolkit("gnuplot")
clear

pKa=4; % you can change this value

%plot -s 600,500 -f 'svg'
Ka=10^-pKa;
pH=2:0.2:12; H=10.^-pH;
alphaHL=H./(Ka+H);
alphaL=Ka./(Ka+H);
plot(pH,alphaHL,'linewidth',2,pH,alphaL,"linewidth", 2)
set(gca,'linewidth',2,'fontsize',12)
xlabel('pH')
ylabel('alpha')
legend('HA','A^-')