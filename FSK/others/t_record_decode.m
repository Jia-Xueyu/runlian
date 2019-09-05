function value = t_record_decode(F1,F2 )
tic;
value=zeros(1,5);
adoption=0;
F1=double(F1);
F2=double(F2);
R=audiorecorder(44100,8,1);
t1=toc;
display(t1);
disp('Start speaking.')
recordblocking(R,8);
disp('End of Recording.');
myspeech=getaudiodata(R);
audiowrite('record.wav',myspeech,44100);

sampleRate = 44100;                          % 采样率
dt = double(1 / sampleRate);
tr_width = double(0.01 * pi);  
SimBitsNum = 8;                            % 模拟比特数
bitTime = 1;                                % 1bit持续的时间
bitSampleNum = sampleRate * bitTime;        % 1bit的采样点数
totalTime = bitTime * SimBitsNum;           % 总时间
totalSampleNum = sampleRate * totalTime; 
t = 0:dt:(totalTime - dt);                  % SimBitsNum个比特所持续的时间
t = t'; 
w1 = double(2 * F1 * dt);                % 载频1的数字频率/pi 在设计FIR滤波器时使用
w2 = double(2 * pi * F2 * dt / pi); 
hammingWinN = ceil(6 * pi / tr_width) + 1;
temp=double([max(w1-0.02, 0) w1+0.02]);
b1 = fir1(hammingWinN, temp);
b2 = fir1(hammingWinN, double([w2-0.02 w2+0.02]));
band=[17000 18000;18000 19000;19000 20000;20000 21000];

[H,Fs]=audioread('record.wav');
H1 = filter(b1, 1, H);
H2 = filter(b2, 1, H);

sw1 = H1 .* H1;
sw2 = H2 .* H2;
 
hammingWinN = ceil(6 * pi / (0.001 * pi)) + 1;
LPF = fir1(hammingWinN, 0.005);
st1 = filter(LPF, 1, sw1);
st2 = filter(LPF, 1, sw2);

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
signal=[];
if WavFinal(1)==1&&WavFinal(2)==1&&WavFinal(3)==1&&WavFinal(4)==1,
    adoption=1;
    display('change signal');
else
    display('no change signal');
    adoption=0;
end;
for i=5:SimBitsNum,
    signal=[signal,WavFinal(i)];
end;

if signal(1)==0 &&signal(2)==0,
    s_f1=band(1,1);
    s_f2=band(1,2);
elseif signal(1)==0&&signal(2)==1,
    s_f1=band(2,1);
    s_f2=band(2,2);
elseif signal(1)==1&&signal(2)==0,
    s_f1=band(3,1);
    s_f2=band(3,2);
else
    s_f1=band(4,1);
    s_f2=band(4,2);
end;

if signal(3)==0 &&signal(4)==0,
    r_f1=band(1,1);
    r_f2=band(1,2);
elseif signal(3)==0&&signal(4)==1,
    r_f1=band(2,1);
    r_f2=band(2,2);
elseif signal(3)==1&&signal(4)==0,
    r_f1=band(3,1);
    r_f2=band(3,2);
else
    r_f1=band(4,1);
    r_f2=band(4,2);
end;
value(1)=s_f1;
value(2)=s_f2;
value(3)=r_f1;
value(4)=r_f2;
value(5)=adoption;
end

