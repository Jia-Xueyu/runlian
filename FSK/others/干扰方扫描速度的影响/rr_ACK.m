function [s1,s2 ] = rr_ACK( rs_f1,rs_f2,sr_f1,sr_f2,dt,tr_width)
filename=['ACK_',num2str(rs_f1/1000),num2str(rs_f2/1000),'.wav'];
pause(5*0.003);%Ä£Äâ¼ÇÂ¼ACK
[H,Fs]=audioread(filename);

w1 = 2 * pi * sr_f1 * dt / pi;                 
w2 = 2 * pi * sr_f2 * dt / pi;
hammingWinN = ceil(6 * pi / tr_width) + 1;
b1 = fir1(hammingWinN, [max(w1-0.02, 0) w1+0.02]);
b2 = fir1(hammingWinN, [w2-0.02 w2+0.02]);
H1 = filter(b1, 1, H);
H2 = filter(b2, 1, H);

s1 = H1 .* H1;
s2 = H2 .* H2;

end

