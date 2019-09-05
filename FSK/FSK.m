clc,clear
close all
%音频=信息+验证码
%每两位验证码比特之间有一位信息比特
%有4个预备频段.17khZ-18khZ,18khZ-19khZ,19khZ-20khZ,20khZ-21khZ
%初始化发送频段为18khZ-19khZ,接收频段为20-21khZ

BitAll = unifrnd(0,1,1,1000);%模拟1条信息，每条信息有1000个比特，每次传输器传输10个比特

for j=1:1000
    if BitAll(1,j)>=0.5 BitAll(1,j) = 1;
    else BitAll(1,j) = 0;
    end;
end;
infor=[];
index=1;%某条信息传输的开始位置，因为一条信息不会传输一次，需要个标志位标记下次开始的地方
sampleRate = 44100;                          % 采样率
dt = 1 / sampleRate;                        % 采样时间间隔
SimBitsNum = 21;                            % 模拟比特数
bitTime = 1;                                % 1bit持续的时间
bitSampleNum = sampleRate * bitTime;        % 1bit的采样点数
totalTime = bitTime * SimBitsNum;           % 总时间
totalSampleNum = sampleRate * totalTime;    % 采样点的个数
t = 0:dt:(totalTime - dt);                  % SimBitsNum个比特所持续的时间
t = t';                                     % 转置成列向量'
f1 = 18000;                                    % 载频1的模拟频率(Hz)
f2 = 19000;                                   % 载频2的模拟频率(Hz)
% 产生发送比特
% sendBits = randi([0 1],[1, SimBitsNum]);
validation=[0 1 1 0 1 1 1 0 1 1 1];
band=[17000 18000;18000 19000;19000 20000;20000 21000];
ss=0;%表示是否变频
count=2;
location=2;
speed=0;
F1=18000;
F2=19000;
T=2;
while index<=991,
    w1 = 2 * pi * f1 * dt / pi;                 % 载频1的数字频率/pi 在设计FIR滤波器时使用
    w2 = 2 * pi * f2 * dt / pi;                 % 载频2的数字频率/pi 在设计FIR滤波器时使用
    SNR = 2;                                    % 信噪比（单位：dB）
    ap = 0.1;                                   % 通带最大波动
    as = 60;                                    % 阻带最小衰减
    tr_width = 0.01 * pi;  
    sendBits=[0 BitAll(1,index) 1 BitAll(1,index+1) 1 BitAll(1,index+2) 0 BitAll(1,index+3) 1 BitAll(1,index+4) 1 BitAll(1,index+5) 1 BitAll(1,index+6) 0 BitAll(1,index+7) 1 BitAll(1,index+8) 1 BitAll(1,index+9) 1];

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

    disturb=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
    disturbReverse=~disturb;
    if ss==1,
        speed=speed+1;
        if mod(speed,4)==0,
            while true,
                N=randi(4);
                if location~=N,
                    T=N
                    break;
                end;
            end;
        end;
        F1=band(T,1);
        F2=band(T,2);
        %count=count+1;
        %F1=band(mod(count-1,4)+1,1);
        %F2=band(mod(count-1,4)+1,2);
    %else
        %F1=band(mod(count-1,4)+1,1);
        %F2=band(mod(count-1,4)+1,2);
    end;
    count
    F1
    F2
    DisBitsSample = (ones(1, bitSampleNum))' * disturb; %'
    DisBitsSample = DisBitsSample(:);                 % 转换成列向量
    DisBitsReverseSample = (ones(1, bitSampleNum))' * disturbReverse; %'
    DisBitsReverseSample = DisBitsReverseSample(:); 
    temp1=DisBitsSample .* cos(2 * pi * F1 .* t);
    temp2=DisBitsReverseSample .* cos(2 * pi * F2 .* t);
    % FSK调制
    fsk1 = sendBitsSample .* cos(2 * pi * f1 .* t)+temp1;
    fsk2 = sendBitsReverseSample .* cos(2 * pi * f2 .* t)+temp2;
    fsk = fsk1 + fsk2;
    %sound(fsk,sampleRate);
    audiowrite('send.wav',fsk,sampleRate);

    %if sendBits == SignalTrans filename=('changeSignal.wav');
    %else filename = ('test.wav');
    %end;
    %audiowrite(filename,fsk,sampleRate)
 
    % 添加噪声
    % ====== AWGN noise ====== 
    %noisePower  = 10^(-SNR/10);
    noise       = 20* (randn(length(fsk), 1));%sqrt(noisePower) * (randn(length(fsk), 1));
    fskSigWithNoise = fsk + noise;
 
    hammingWinN = ceil(6 * pi / tr_width) + 1;
    b1 = fir1(hammingWinN, [max(w1-0.02, 0) w1+0.02]);
    b2 = fir1(hammingWinN, [w2-0.02 w2+0.02]);
 
    % 滤波
    H1 = filter(b1, 1, fskSigWithNoise);
    H2 = filter(b2, 1, fskSigWithNoise);
 
    % 解调
    % 使用相干解调的方法
    sw1 = H1 .* H1;
    sw2 = H2 .* H2;
 
 
    % 设计低通滤波器
    hammingWinN = ceil(6 * pi / (0.001 * pi)) + 1;
    % LPF = fir1(hammingWinN, 0.05);
    % freqz( dfilt.dffir(LPF));
    % title('低通滤波器')
    LPF = fir1(hammingWinN, 0.005);
    % LPF = fir1(101, [2/800 10/800]);
    % 经过低通滤波器
    st1 = filter(LPF, 1, sw1);
    st2 = filter(LPF, 1, sw2);
 
    Wav1=zeros(1,SimBitsNum);%Wav1为19kHz的波形
    Wav2=zeros(1,SimBitsNum);%Wav2为18kHz的波形
    WavFinal=[];%WavFinal为最终传递的比特流信号
    val=[];
    temp=zeros(1,SimBitsNum);
    for i=1:SimBitsNum,
        Wav1(i)=sum(st1((i-1)*44100+1 : i*44100))/44100;
        Wav2(i)=sum(st2((i-1)*44100+1 : i*44100))/44100;
    end;
    for i=1:SimBitsNum,
        if Wav1(i)>Wav2(i),
            temp(i)=1;
        else
            temp(i)=0;
        end;
    end;
    for i=1:SimBitsNum,
        if mod(i,2)==0,
            WavFinal=[WavFinal temp(i)];
        else
            val=[val temp(i)];
        end;
    end;
    infor=[infor WavFinal];
    if val==validation,
        index=index+10;
        display(WavFinal);
        ss=1;
        display('no disturbing');
    else
        ss=0;
        changesignal=change(location);
        f1=changesignal(1);
        f2=changesignal(2);
        if f1==17000,
            location=1;
        elseif f1==18000,
            location=2;
        elseif f1==19000,
            location=3;
        else
            location=4;
        end;
        index=index+10;
        display(WavFinal);
        display('disturbing');
    end;
end;
result=(BitAll==infor);
count=0;
for i=result,
    if i==1,
        count=count+1;
    end;
end;
display(count);