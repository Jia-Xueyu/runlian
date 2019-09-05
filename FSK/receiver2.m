% 添加噪声
% ====== AWGN noise ====== 
%noisePower  = 10^(-SNR/10);
%noise       = sqrt(noisePower) * (randn(length(fsk), 1));
%fskSigWithNoise = fsk + noise;
%subplot(212)
%plot(fskSigWithNoise)
%axis([0 totalSampleNum min(fskSigWithNoise)-0.2 max(fskSigWithNoise)+0.2]);
%grid on
%title('添加噪声之后的时域波形')
% 绘制添加噪声前后的信号幅度谱
%figure
%subplot(211)
%plot((0:totalSampleNum-1)*(2/totalSampleNum), abs(fft(fsk)) / sqrt(totalSampleNum))
%grid on
%title('未加噪声的FSK调制信号的幅度谱')
%subplot(212)
%plot((0:totalSampleNum-1)*(2/totalSampleNum), abs(fft(fskSigWithNoise)) / sqrt(totalSampleNum))
%grid on
%title('添加噪声的FSK调制信号的幅度谱')
 
% 设计两个带通数字滤波器
%hammingWinN = ceil(6 * pi / tr_width) + 1;
%b1 = fir1(hammingWinN, [max(w1-0.02, 0) w1+0.02]);
%b2 = fir1(hammingWinN, [w2-0.02 w2+0.02]);
%freqz( dfilt.dffir(b1));
%title('f1滤波器')
%freqz( dfilt.dffir(b2));
%title('f2滤波器')
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
f1 = 18000;                                    % 载频1的模拟频率(Hz)
f2 = 19000;                                   % 载频2的模拟频率(Hz)
w1 = 2 * pi * f1 * dt / pi;                 % 载频1的数字频率/pi 在设计FIR滤波器时使用
w2 = 2 * pi * f2 * dt / pi; 
hammingWinN = ceil(6 * pi / tr_width) + 1;
b1 = fir1(hammingWinN, [max(w1-0.02, 0) w1+0.02]);
b2 = fir1(hammingWinN, [w2-0.02 w2+0.02]);
% 滤波
[H,Fs]=audioread('disturb.wav');
H1 = filter(b1, 1, H);
H2 = filter(b2, 1, H);
figure
subplot(211)
plot(t, H1);
grid on
xlabel('t')
ylabel('幅度')
title('滤波之后的时域波形（fc = 18000Hz）')
subplot(212)
plot(t, H2);
grid on
xlabel('t')
ylabel('幅度')
title('滤波之后的时域波形（fc = 19000Hz）')
 
% 解调
% 使用相干解调的方法
sw1 = H1 .* H1;
sw2 = H2 .* H2;
 
figure
subplot(211)
plot(t, sw1)
title('经过相乘器H1后的波形比特1')
xlabel('t')
ylabel('幅度')
grid on
 
subplot(212)
plot(t, sw2)
title('经过相乘器H2后的波形比特0')
xlabel('t')
ylabel('幅度')
grid on
 
% 相乘之后的幅度谱
figure
subplot(211)
plot((0:totalSampleNum-1)*(2/totalSampleNum), abs(fft(sw1)) / sqrt(totalSampleNum))
grid on
title('sw1x')
subplot(212)
plot((0:totalSampleNum-1)*(2/totalSampleNum), abs(fft(sw2)) / sqrt(totalSampleNum))
grid on
title('sw2x')
 
% 设计低通滤波器
hammingWinN = ceil(6 * pi / (0.001 * pi)) + 1;
% LPF = fir1(hammingWinN, 0.05);
% freqz( dfilt.dffir(LPF));
% title('低通滤波器')
LPF = fir1(hammingWinN, 0.005);
% LPF = fir1(101, [2/800 10/800]);
freqz(dfilt.dffir(LPF));
% 经过低通滤波器
title('低通滤波器')
st1 = filter(LPF, 1, sw1);
st2 = filter(LPF, 1, sw2);
figure
subplot(211)
plot(t, st1)
title('经过低通滤波器后的波形1')
xlabel('t')
ylabel('幅度')
grid on
 
subplot(212)
plot(t, st2)
title('经过低通滤波器后的波形2')
xlabel('t')
ylabel('幅度')
grid on

%因为经过处理的波形是矩形波形图，所以单位时间内各取样点的值浮动不会太大，
%可以把所有的取样点值和取平均值作为这个单位时间内的幅度值，以此对比两个波形图来判断这个时间段传播的是1还是0比特
Wav1=zeros(1,SimBitsNum);%Wav1为19kHz的波形
Wav2=zeros(1,SimBitsNum);%Wav2为18kHz的波形
WavFinal=zeros(1,SimBitsNum);%WavFinal为最终传递的比特流信号
for i=1:SimBitsNum,
    Wav1(i)=sum(st1((i-1)*44100+1 : i*44100))/44100;
    Wav2(i)=sum(st2((i-1)*44100+1 : i*44100))/44100;
end;
for i=1:SimBitsNum,
    if Wav1(i)>Wav2(i),
        WavFinal(i)=1;
    else
        WavFinal(i)=0;
    end;
end;
WavFinal
%if WavFinal==[0 ones(1,SimBitsNum)],
%    transmitterFunction([0 zeros(1,SimBitsNum)]);
%end;
% 判决
%delay = 1.5;        % 由滤波器产生的时延，单位为符号，该数值是从图上直接观察到的
% 确定判决时刻
%judgePoint = (bitSampleNum/2 + delay * sampleRate : bitSampleNum : totalSampleNum);
%judgeFinal = (st1(judgePoint) > 0.3)'; %'
%judgeNum = length(judgeFinal);      % 最后可以完整判断的符号的数量
%errorRate = length(find(xor(sendBits(1 : judgeNum), judgeFinal) == 1)) / judgeNum;
%fprintf('系统误码率为 %d\n', errorRate)