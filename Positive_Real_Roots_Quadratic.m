% some housekeeping stuff
register_graphics_toolkit ("gnuplot");
available_graphics_toolkits ();
graphics_toolkit ("gnuplot")
clear
% end of housekeeping

%plot -s 600,500 -f 'svg'
MgT=0.04492e-6; Kw=1e-14;
a=1;
b=2*MgT;
c=-Kw;
t=roots([a b c]); %finds the roots
t=t(imag(t)==0); %sets any imaginary roots to zero
% display the positive real root

t=t(t>0)

% take minus log in case that might be useful (pH for example)

pt=-log10(t)

%plot -s 600,500 -f 'svg'

x=[-10*t:t/10:t*10];
y=a*x.^2+b.*x+c;

plot(x,y,'b-','linewidth',2)
hold on
plot([t t],[min(y)-0.1*max(y) max(y)],'r','linewidth',2)
plot(x,zeros(size(x)),'k','linewidth',2)
