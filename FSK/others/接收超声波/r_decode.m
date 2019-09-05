function WavFinal = r_decode(N)
N=double(N);
f1=20000;
f2=21000;
file=['record',num2str(N),'.wav'];
WavFinal=[];
if exist(file,'file')==2,
    sampleRate = 44100;                          % 采样率
    dt = 1 / sampleRate; 
    tr_width = 0.01 * pi;  
    SimBitsNum = 8;                            % 模拟比特数
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

    [H,Fs]=audioread(file);
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
    Wav1=zeros(1,SimBitsNum);%Wav1为20kHz的波形
    Wav2=zeros(1,SimBitsNum);%Wav2为21kHz的波形
    WavFinal=zeros(1,SimBitsNum);%WavFinal为最终传递的比特流信号
    for i=1:SimBitsNum,
        Wav1(i)=sum(st1((i-1)*44100+1 : i*44100))/44100;
        Wav2(i)=sum(st2((i-1)*44100+1 : i*44100))/44100;
    end;
    for i=1:SimBitsNum,
        if Wav1(i)>Wav2(i)+1e-5,
            WavFinal(i)=1;
        else
            WavFinal(i)=0;
        end;
    end;
end
disp(WavFinal);
end

