function disturb = disturber(N )
sampleRate = 44100;                          % 采样率
dt = 1 / sampleRate; 
tr_width = 0.01 * pi;  
SimBitsNum = 24;                            % 模拟比特数
bitTime = 1;                                % 1bit持续的时间
bitSampleNum = sampleRate * bitTime;        % 1bit的采样点数
totalTime = bitTime * SimBitsNum;           % 总时间
totalSampleNum = sampleRate * totalTime; 
t = 0:dt:(totalTime - dt);                  % SimBitsNum个比特所持续的时间
t = t'; 
band=[17000 18000;18000 19000;19000 20000;20000 21000];
f1=band(N,1);
f2=band(N,2);
w1 = 2 * pi * f1 * dt / pi;                 % 载频1的数字频率/pi 在设计FIR滤波器时使用
w2 = 2 * pi * f2 * dt / pi; 
hammingWinN = ceil(6 * pi / tr_width) + 1;
b1 = fir1(hammingWinN, [max(w1-0.02, 0) w1+0.02]);
b2 = fir1(hammingWinN, [w2-0.02 w2+0.02]);
% 滤波
[H,Fs]=audioread('changeSignal.wav');
H1 = filter(b1, 1, H);
H2 = filter(b2, 1, H);

end

