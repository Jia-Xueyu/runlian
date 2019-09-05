function flag= notation(f1,f2)
tic;
R=audiorecorder(44100,24,1);
recordblocking(R,0.2);
myspeech=getaudiodata(R);
audiowrite('notation.wav',myspeech,44100);
%disp(myspeech);
sampleRate = 44100;  
flag=0;
f1=double(f1);
f2=double(f2);
dt = 1 / sampleRate; 
tr_width = 0.01 * pi;  
SimBitsNum = 0.2;                            % 模拟比特数
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

[H,Fs]=audioread('notation.wav');
H1 = filter(b1, 1, H);
%disp(H1);
H2 = filter(b2, 1, H);

sw1 = H1 .* H1;
sw2 = H2 .* H2;

hammingWinN = ceil(6 * pi / (0.001 * pi)) + 1;
LPF = fir1(hammingWinN, 0.005);
st1 = filter(LPF, 1, sw1);
st2 = filter(LPF, 1, sw2);
%disp(st1);
wav1=0;
wav2=0;
for i=1:length(st1),
    if wav1<abs(st1(i)),
        wav1=abs(st1(i));
    end;
end;
for i=1:length(st2),
    if wav2<abs(st2(i)),
        wav2=abs(st2(i));
    end;
end;
M=wav1;
X=wav2;
if M<X,
    temp=M;
    M=X;
    X=temp;
end;
if M-X>1000*X,%阈值判断，判断条件自己设定，不同电脑设备可能都不同，也可能受环境影响经常变化。
    flag=1;
end;
toc;
disp(wav1);
disp(wav2);
disp(toc-tic);
end

