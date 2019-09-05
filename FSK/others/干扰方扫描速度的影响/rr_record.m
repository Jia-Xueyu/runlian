function [sw1,sw2] = rr_record( tr_width,f1,f2,dt,record_time,fskSigWithNoise )
w1 = 2 * pi * f1 * dt / pi;               
w2 = 2 * pi * f2 * dt / pi; 
hammingWinN = ceil(6 * pi / tr_width) + 1;
b1 = fir1(hammingWinN, [max(w1-0.02, 0) w1+0.02]);
b2 = fir1(hammingWinN, [w2-0.02 w2+0.02]);

if record_time>0,
    pause(record_time);%接收声音的时间
end;

% 滤波
H1 = filter(b1, 1, fskSigWithNoise);
H2 = filter(b2, 1, fskSigWithNoise);

% 解调
% 使用相干解调的方法
sw1 = H1 .* H1;
sw2 = H2 .* H2;

end

