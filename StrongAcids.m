% some housekeeping stuff
register_graphics_toolkit ("gnuplot");
available_graphics_toolkits ();
graphics_toolkit ("gnuplot")
clear
figure(1); clf
% end of housekeeping

%plot -s 800,800 -f 'svg'
logClT=-9:0.1:-2; ClT=10.^logClT;
Kw=1e-14;
for i=1:size(logClT,2)
    a=1; b=-ClT(i); c=-Kw;
    t=roots([a b c]);
    H=t(real(t)>0&imag(t)==0);
    pHexact(i)=-log10(H);
end
plot(logClT,pHexact,'linewidth',2)
set(gca,'linewidth',2,'fontsize',12)
xlabel('logCl_T','fontsize',12)
ylabel('pH','fontsize',12)
title('solve full quadratic (exact solution)','fontsize',14)

%plot -s 800,800 -f 'svg'
for i=1:size(logClT,2)
    H=ClT(i);
    pHapprox(i)=-log10(H);
end
hold on
plot(logClT,pHapprox,'g','linewidth',2)
legend('exact','approx')
set(gca,'linewidth',2,'fontsize',12)
xlabel('logCl_T','fontsize',12)
ylabel('pH','fontsize',12)
title('exact and approx solution','fontsize',14)