BitAll=information();
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
infor=[];
while index<=491,
    w1 = 2 * pi * f1 * dt / pi;                 % 载频1的数字频率/pi 在设计FIR滤波器时使用
    w2 = 2 * pi * f2 * dt / pi;                 % 载频2的数字频率/pi 在设计FIR滤波器时使用
    SNR = 0.1;                                    % 信噪比（单位：dB）
    ap = 0.1;                                   % 通带最大波动
    as = 60;                                    % 阻带最小衰减
    tr_width = 0.01 * pi;  
    %sendBits=infor(index:index+9);
    sendBits=[0 BitAll(1,index) 1 BitAll(1,index+1) 1 BitAll(1,index+2) 0 BitAll(1,index+3) 1 BitAll(1,index+4) 1 BitAll(1,index+5) 1 BitAll(1,index+6) 0 BitAll(1,index+7) 1 BitAll(1,index+8) 1 BitAll(1,index+9) 1];
    %sendBits = [1 BitAll(InfoLine(count),index:index+19)];    % 模拟发送的比特
    sendBitsReverse = ~sendBits;
    % 抽样
    % 注意：此处使用了矩阵相乘
    %display(sendBits);
    display(BitAll(1,index:index+9));
    %sendBits
    sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
    sendBitsSample = sendBitsSample(:);                 % 转换成列向量
    sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
    sendBitsReverseSample = sendBitsReverseSample(:);   % 转换成列向量

    
    fsk1 = sendBitsSample .* cos(2 * pi * f1 .* t);
    fsk2 = sendBitsReverseSample .* cos(2 * pi * f2 .* t);
    fsk = fsk1 + fsk2;
    %sound(fsk,sampleRate);
    audiowrite('send.wav',fsk,sampleRate);

    %if sendBits == SignalTrans filename=('changeSignal.wav');
    %else filename = ('test.wav');
    %end;
    %audiowrite(filename,fsk,sampleRate)
 
    % 添加噪声
    % ====== AWGN noise ====== 
    noisePower  = 10^(-SNR/10);
    noise       = 16* (randn(length(fsk), 1));%-11干扰或者7
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
    LPF = fir1(hammingWinN, 0.005);%0.005
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
    display(WavFinal);
    infor=[infor WavFinal];
    index=index+10;
end;
result=(BitAll==infor);
count=0;
for i=result,
    if i==1,
        count=count+1;
    end;
end;
display(count);