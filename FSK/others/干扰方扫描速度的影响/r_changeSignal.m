function temp= r_changeSignal(F1,F2,t,r)
F1=double(F1);
F2=double(F2);
t=int32(t);
r=int32(r);
temp=[];
sampleRate = 44100;                          % 采样率
dt = 1 / sampleRate;                        % 采样时间间隔
SimBitsNum = 8;                            % 模拟比特数
bitTime = 1;                                % 1bit持续的时间
bitSampleNum = sampleRate * bitTime;        % 1bit的采样点数
totalTime = bitTime * SimBitsNum;           % 总时间
totalSampleNum = sampleRate * totalTime;    % 采样点的个数
t = 0:dt:(totalTime - dt);                  % SimBitsNum个比特所持续的时间
t = t';                                     % 转置成列向量'
w1 = 2 * pi * F1 * dt / pi;                 % 载频1的数字频率/pi 在设计FIR滤波器时使用
w2 = 2 * pi * F2 * dt / pi;                 % 载频2的数字频率/pi 在设计FIR滤波器时使用
SNR = 2;                                    % 信噪比（单位：dB）
ap = 0.1;                                   % 通带最大波动
as = 60;                                    % 阻带最小衰减
tr_width = 0.01 * pi;                       % 数字滤波器过渡带宽
% 产生发送比特
% sendBits = randi([0 1],[1, SimBitsNum]);
band=[17000 18000;18000 19000;19000 20000;20000 21000];

if t==1,
    bit1=[0 0];
elseif t==2,
    bit1=[0 1];
elseif t==3,
    bit1=[1 0];
else
    bit1=[1 1];
end;
if r==1,
    bit2=[0 0];
elseif r==2,
    bit2=[0 1];
elseif r==3,
    bit2=[1 0];
else
    bit2=[1 1];
end;
sendBits = [1,1,0,1,bit1,bit2];             % 信号比特
sendBitsReverse = ~sendBits;

sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
sendBitsSample = sendBitsSample(:);                 % 转换成列向量
sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
sendBitsReverseSample = sendBitsReverseSample(:);   % 转换成列向量
% FSK调制
fsk1 = sendBitsSample .* cos(2 * pi * F1 .* t);
fsk2 = sendBitsReverseSample .* cos(2 * pi * F2 .* t);
fsk = fsk1 + fsk2;
sound(fsk,sampleRate);
end

