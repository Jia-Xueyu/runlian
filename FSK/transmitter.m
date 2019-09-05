clc,clear
close all
% 系统配置
%假设有10条信息,每条信息有200个比特信息，传输器首先会传输某条信息的比特流，当遇到某条件传输特定比特流ones(zeros(1,20)),代表要切换信息源
%当然每每条信息都和信号信息不一样
%每次传递21比特，形式为[B infor],B表示标志位，1是信息，0是信号。infor就是20位信息比特流
BitAll = unifrnd(0,1,10,240);%(0,1)均匀分布中随机抽取一些数
for i=1:10
    for j=1:240
        if BitAll(i,j)>=0.5 BitAll(i,j) = 1;
        else BitAll(i,j) = 0;
        end;
    end;
end;
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
sendBits = [0 1 0 1 0 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 1 0];             % 信号比特
sendBitsReverse = ~sendBits;
% 抽样
% 注意：此处使用了矩阵相乘
sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
sendBitsSample = sendBitsSample(:);                 % 转换成列向量
sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
sendBitsReverseSample = sendBitsReverseSample(:);   % 转换成列向量
% FSK调制
fsk1 = sendBitsSample .* cos(2 * pi * f1 .* t);
fsk2 = sendBitsReverseSample .* cos(2 * pi * f2 .* t);
fsk = fsk1 + fsk2;
sound(fsk,sampleRate)
filename = ('changeSignal.wav');
audiowrite(filename,fsk,sampleRate)
subplot(211)
plot(fsk)
axis([0 totalSampleNum min(fsk)-0.2 max(fsk)+0.2]);
grid on
title('FSK调制之后的时域波形')