R=audiorecorder(44100,24,1);
disp('Start speaking.')
recordblocking(R,4);
disp('End of Recording.');
myspeech=getaudiodata(R);
audiowrite('temp.wav',myspeech,44100);
sampleRate = 44100;  
f1=20000;
f2=21000;
dt = 1 / sampleRate; 
tr_width = 0.01 * pi;  
SimBitsNum = 4;                            % 模拟比特数
bitTime = 1;                                % 1bit持续的时间
bitSampleNum = sampleRate * bitTime;        % 1bit的采样点数
totalTime = bitTime * SimBitsNum;           % 总时间
totalSampleNum = sampleRate * totalTime; 
t = 0:dt:(totalTime - dt);                  % SimBitsNum个比特所持续的时间
t = t'; 
w1 = 2 * pi * f1 * dt / pi;                 % 载频1的数字频率/pi 在设计FIR滤波器时使用
w2 = 2 * pi * f2 * dt / pi; 
hammingWinN = ceil(6 * pi / tr_width) + 1;
b1 = fir1(hammingWinN, [max(w1-0.02, 0) w1+0.02]);
b2 = fir1(hammingWinN, [w2-0.02 w2+0.02]);

[H,Fs]=audioread('temp.wav');
H1 = filter(b1, 1, H);
%disp(H1);
H2 = filter(b2, 1, H);

sw1 = H1 .* H1;
sw2 = H2 .* H2;

hammingWinN = ceil(6 * pi / (0.001 * pi)) + 1;
LPF = fir1(hammingWinN, 0.005);
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
Wav1=zeros(1,SimBitsNum);%Wav1为20kHz的波形
Wav2=zeros(1,SimBitsNum);%Wav2为21kHz的波形
WavFinal=zeros(1,SimBitsNum);%WavFinal为最终传递的比特流信号
for i=1:SimBitsNum,
    Wav1(i)=sum(st1((i-1)*44100+1 : i*44100))/44100;
    Wav2(i)=sum(st2((i-1)*44100+1 : i*44100))/44100;
end;
for i=1:SimBitsNum,
    disp(Wav1(i)-Wav2(i));
    %disp(Wav2(i));
    if Wav1(i)>Wav2(i)+1e-5,
        WavFinal(i)=1;
        
    else
        WavFinal(i)=0;
    end;
end;
disp(WavFinal);