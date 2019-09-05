count=1;
name1='1718';
name2='1819';
name3='1920';
name4='2021';
flag=1;
f1 = 20000;                                    % 载频1的模拟频率(Hz)
f2 = 21000;  
index=1;
Bits=[1 1 0 1 1 0 0 1 1 1 0 1 1 0 1 0 0 1 1 1 1 0 1 1 1 1 1 0 1 0 1 0 0 0 0 1 1 0 1 0 0 0 1 1 0 0 0 1 1 1 0 1 1 0 0 0 1 0 1 0 1 0 1 1 1 1 1 0 0 0 1 0 1 0 1 0 0 0 1 0 0 1 1 1 1 0 1 1 0 1 0 0 1 1 1 0 1 0 0 0];
while count<=10,
    filename=['infor',num2str(flag),'_',name4,'.wav'];
    count=count+1;
    flag=flag+1;
    sampleRate = 44100;                          % 采样率
    dt = 1 / sampleRate;                        % 采样时间间隔
    SimBitsNum =25;                            % 模拟比特数
    bitTime = 1;                                % 1bit持续的时间
    bitSampleNum = sampleRate * bitTime;        % 1bit的采样点数
    totalTime = bitTime * SimBitsNum;           % 总时间
    totalSampleNum = sampleRate * totalTime;    % 采样点的个数
    t = 0:dt:(totalTime - dt);                  % SimBitsNum个比特所持续的时间
    t = t';                                     % 转置成列向量'
    % 产生发送比特
    validation=[1 1 1 0 1 1 1 0 1 1 1];
    
    w1 = 2 * pi * f1 * dt / pi;                 % 载频1的数字频率/pi 在设计FIR滤波器时使用
    w2 = 2 * pi * f2 * dt / pi;                 % 载频2的数字频率/pi 在设计FIR滤波器时使用
    SNR = 2;                                    % 信噪比（单位：dB）
    ap = 0.1;                                   % 通带最大波动
    as = 60;                                    % 阻带最小衰减
    tr_width = 0.01 * pi;  
    %sendBits=[1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];%发送50个1比特
    BitAll=Bits(index:index+9);
    sendBits=[1 1 1 1 1 BitAll(1) 1 BitAll(2) 1 BitAll(3) 0 BitAll(4) 1 BitAll(5) 1 BitAll(6) 1 BitAll(7) 0 BitAll(8) 1 BitAll(9) 1 BitAll(10) 1];
    index=index+10;
    %sendBits = [1 BitAll(InfoLine(count),index:index+19)];    % 模拟发送的比特
    sendBitsReverse = ~sendBits;
    % 抽样
    % 注意：此处使用了矩阵相乘
    display(sendBits);
    %sendBits
    sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
    sendBitsSample = sendBitsSample(:);                 % 转换成列向量
    sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
    sendBitsReverseSample = sendBitsReverseSample(:);   % 转换成列向量

    fsk1 = sendBitsSample .* cos(2 * pi * f1 .* t);
    fsk2 = sendBitsReverseSample .* cos(2 * pi * f2 .* t);
    fsk = fsk1 + fsk2;
    path=['./information/',filename];
    audiowrite(path,fsk,44100);
    %soundsc(fsk,sampleRate);
end;