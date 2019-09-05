function temp=t_send(F1,F2,index,BitAll)
F1=double(F1);
F2=double(F2);
%index=1;%某条信息传输的开始位置，因为一条信息不会传输一次，需要个标志位标记下次开始的地方
sampleRate = 44100;                          % 采样率
dt = 1 / sampleRate;                        % 采样时间间隔
SimBitsNum = 25;                            % 模拟比特数,多一位是为了让接收方的通知它开始记录
bitTime = 1;                                % 1bit持续的时间
bitSampleNum = sampleRate * bitTime;        % 1bit的采样点数
totalTime = bitTime * SimBitsNum;           % 总时间
totalSampleNum = sampleRate * totalTime;    % 采样点的个数
t = 0:dt:(totalTime - dt);                  % SimBitsNum个比特所持续的时间
t = t';                                     % 转置成列向量'                                 % 载频2的模拟频率(Hz)
% 产生发送比特
% sendBits = randi([0 1],[1, SimBitsNum]);
temp=[];
validation=[0 1 1 0 1 1 1 0 1 1 1];
w1 = 2 * pi * F1 * dt / pi;                 % 载频1的数字频率/pi 在设计FIR滤波器时使用
w2 = 2 * pi * F2 * dt / pi;                 % 载频2的数字频率/pi 在设计FIR滤波器时使用
SNR = 2;                                    % 信噪比（单位：dB）
ap = 0.1;                                   % 通带最大波动
as = 60;                                    % 阻带最小衰减
tr_width = 0.01 * pi;  
sendBits=[1 1 0 1 1 BitAll(1,index) 1 BitAll(1,index+1) 1 BitAll(1,index+2) 0 BitAll(1,index+3) 1 BitAll(1,index+4) 1 BitAll(1,index+5) 1 BitAll(1,index+6) 0 BitAll(1,index+7) 1 BitAll(1,index+8) 1 BitAll(1,index+9) 1];

%sendBits = [1 BitAll(InfoLine(count),index:index+19)];    % 模拟发送的比特
sendBitsReverse = ~sendBits;
% 抽样
% 注意：此处使用了矩阵相乘
display(BitAll(1,index:index+9));
%sendBits
sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
sendBitsSample = sendBitsSample(:);                 % 转换成列向量
sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
sendBitsReverseSample = sendBitsReverseSample(:);   % 转换成列向量
fsk1 = sendBitsSample .* cos(2 * pi * F1 .* t);
fsk2 = sendBitsReverseSample .* cos(2 * pi * F2 .* t);
fsk = fsk1 + fsk2;
audiowrite('information.wav',fsk,44100);
sound(fsk,44100);
pause(SimBitsNum);
end

