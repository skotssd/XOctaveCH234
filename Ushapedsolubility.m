% some housekeeping stuff
register_graphics_toolkit("gnuplot");
available_graphics_toolkits();
graphics_toolkit("gnuplot")
clear
figure(1); clf; figure(2); clf
% end of housekeeping

%plot -s 600,500 -f 'svg'
pH=2:0.1:12;
Ksp=10^-38.8;
B1=10^-2.19;
B2=10^-5.7;
B4=10^-21.6;
Kw=1e-14;
logFe=log10(Ksp./Kw^3)-3*pH; Fe=10.^logFe;
logFeOH=log10(B1*Ksp/Kw^3)-2*pH; FeOH=10.^logFeOH;
logFeOH2=log10(B2*Ksp/Kw^3)-pH; FeOH2=10.^logFeOH2;
logFeOH4=log10(B4*Ksp./Kw^3)+pH; FeOH4=10.^logFeOH4;
FeT=Fe+FeOH+FeOH2+FeOH4; logFeT=log10(FeT);
figure(1)
plot(pH,logFe,'linewidth',2,pH,logFeOH,'linewidth',2,pH,logFeOH2,'linewidth',2,...
pH,logFeOH4,'linewidth',2,pH,logFeT,'linewidth',2)
set(gca,'linewidth',2,'fontsize',12);
xlabel('pH','fontsize',12)
ylabel('log[species]','fontsize',12)

% plot over a more narrow range
figure(2)
plot(pH,logFe,'linewidth',2,pH,logFeOH,'linewidth',2,pH,logFeOH2,'linewidth',2,...
pH,logFeOH4,'linewidth',2,pH,logFeT,'linewidth',2)
set(gca,'linewidth',2,'fontsize',12);
xlabel('pH','fontsize',12)
ylabel('log[species]','fontsize',12)
legend('Fe^{3+}','FeOH^{2+}','Fe(OH)_2^+','Fe(OH)_4^-','Fe_T','location','north');
axis([2 10 -11 -3])
legend('Fe^{3+}','FeOH^{2+}','Fe(OH)_2^+','Fe(OH)_4^-','Fe_T','location','southwest')