N=1024;

fs=1024;

t=0:1/fs:(N-1)/fs;

x=sin(200*pi*t);
z=(rand (1, N)-0.5)*2;
%原始波形

figure

plot(t,x)%%%波形

set(gca,'xlim',[0,0.2],'ylim',[-1.3,1.3])

title('waveform of transmitter')
xlabel('time(s)','FontSize',14);
ylabel('amplitude','FontSize',14);

figure

plot(t,z)%%%波形

set(gca,'xlim',[0,0.2],'ylim',[-1.3,1.3])

title('waveform of jammer')
xlabel('time(s)','FontSize',14);
ylabel('amplitude','FontSize',14);

%逆变换后时域图

b=(x+z)/2;

figure

plot(t,b)

set(gca,'xlim',[0,0.2],'ylim',[-1.3,1.3])

title('waveform of receiving')
xlabel('time(s)','FontSize',14);
ylabel('amplitude','FontSize',14);



