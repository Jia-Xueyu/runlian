clc,clear
close all
%也可以在信号里编号，跳转到特定编号的信息源里
%例如，[zeros(1,23) 1]代表跳转到编号为1的信息源



BitAll = unifrnd(0,1,10,230);%模拟10条信息，每条信息有200个比特，每次传输器传输23个比特
for i=1:10
    for j=1:230
        if BitAll(i,j)>=0.5 BitAll(i,j) = 1;
        else BitAll(i,j) = 0;
        end;
    end;
end;
InfoLine=randperm(10);%随机顺序
index=1;%某条信息传输的开始位置，因为一条信息不会传输一次，需要个标志位标记下次开始的地方
sampleRate = 44100;                          % 采样率
dt = 1 / sampleRate;                        % 采样时间间隔
SimBitsNum = 24;                            % 模拟比特数
bitTime = 1;                                % 1bit持续的时间
bitSampleNum = sampleRate * bitTime;        % 1bit的采样点数
totalTime = bitTime * SimBitsNum;           % 总时间
totalSampleNum = sampleRate * totalTime;    % 采样点的个数
t = 0:dt:(totalTime - dt);                  % SimBitsNum个比特所持续的时间
t = t';                                     % 转置成列向量'
f1 = 20000;                                    % 载频1的模拟频率(Hz)
f2 = 21000;                                   % 载频2的模拟频率(Hz)
w1 = 2 * pi * f1 * dt / pi;                 % 载频1的数字频率/pi 在设计FIR滤波器时使用
w2 = 2 * pi * f2 * dt / pi;                 % 载频2的数字频率/pi 在设计FIR滤波器时使用
SNR = 2;                                    % 信噪比（单位：dB）
ap = 0.1;                                   % 通带最大波动
as = 60;                                    % 阻带最小衰减
tr_width = 0.01 * pi;                       % 数字滤波器过渡带宽
% 产生发送比特
% sendBits = randi([0 1],[1, SimBitsNum]);
SignalTrans=[0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1];
sendBits = SignalTrans;
sendBitsReverse = ~sendBits;
    % 抽样
    % 注意：此处使用了矩阵相乘
receiveBits=sendBits;
receiveBits
sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
sendBitsSample = sendBitsSample(:);                 % 转换成列向量
sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
sendBitsReverseSample = sendBitsReverseSample(:);   % 转换成列向量
 
    % FSK调制
fsk1 = sendBitsSample .* cos(2 * pi * f1 .* t);
fsk2 = sendBitsReverseSample .* cos(2 * pi * f2 .* t);
fsk = fsk1 + fsk2;
%sound(fsk,sampleRate)