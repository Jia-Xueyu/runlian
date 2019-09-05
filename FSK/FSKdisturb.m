clc,clear
close all

BitAll = unifrnd(0,1,1,1000);%ģ��1����Ϣ��ÿ����Ϣ��1000�����أ�ÿ�δ���������10������

for j=1:1000
    if BitAll(1,j)>=0.5 BitAll(1,j) = 1;
    else BitAll(1,j) = 0;
    end;
end;
infor=[];
index=1;%ĳ����Ϣ����Ŀ�ʼλ�ã���Ϊһ����Ϣ���ᴫ��һ�Σ���Ҫ����־λ����´ο�ʼ�ĵط�
sampleRate = 44100;                          % ������
dt = 1 / sampleRate;                        % ����ʱ����
SimBitsNum = 21;                            % ģ�������
bitTime = 1;                                % 1bit������ʱ��
bitSampleNum = sampleRate * bitTime;        % 1bit�Ĳ�������
totalTime = bitTime * SimBitsNum;           % ��ʱ��
totalSampleNum = sampleRate * totalTime;    % ������ĸ���
t = 0:dt:(totalTime - dt);                  % SimBitsNum��������������ʱ��
t = t';                                     % ת�ó�������'
f1 = 18000;                                    % ��Ƶ1��ģ��Ƶ��(Hz)
f2 = 19000;                                   % ��Ƶ2��ģ��Ƶ��(Hz)
% �������ͱ���
% sendBits = randi([0 1],[1, SimBitsNum]);
validation=[0 1 1 0 1 1 1 0 1 1 1];
band=[17000 18000;18000 19000;19000 20000;20000 21000];
ss=0;%��ʾ�Ƿ��Ƶ
count=2;
location=2;
speed=0;
F1=18000;
F2=19000;
T=2;
while index<=991,
    w1 = 2 * pi * f1 * dt / pi;                 % ��Ƶ1������Ƶ��/pi �����FIR�˲���ʱʹ��
    w2 = 2 * pi * f2 * dt / pi;                 % ��Ƶ2������Ƶ��/pi �����FIR�˲���ʱʹ��
    SNR = 2;                                    % ����ȣ���λ��dB��
    ap = 0.1;                                   % ͨ����󲨶�
    as = 60;                                    % �����С˥��
    tr_width = 0.01 * pi;  
    sendBits=[0 BitAll(1,index) 1 BitAll(1,index+1) 1 BitAll(1,index+2) 0 BitAll(1,index+3) 1 BitAll(1,index+4) 1 BitAll(1,index+5) 1 BitAll(1,index+6) 0 BitAll(1,index+7) 1 BitAll(1,index+8) 1 BitAll(1,index+9) 1];

    %sendBits = [1 BitAll(InfoLine(count),index:index+19)];    % ģ�ⷢ�͵ı���
    sendBitsReverse = ~sendBits;
    % ����
    % ע�⣺�˴�ʹ���˾������
    display(BitAll(1,index:index+9));
    %sendBits
    sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
    sendBitsSample = sendBitsSample(:);                 % ת����������
    sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
    sendBitsReverseSample = sendBitsReverseSample(:);   % ת����������

    disturb=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
    %disturb=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
    %disturb=[0 0 0 0 0 0 0 1 1 1 1 1 1 1 0 1 1 1 1 0 0];
    disturbReverse=~disturb;
    
    DisBitsSample = (ones(1, bitSampleNum))' * disturb; %'
    DisBitsSample = DisBitsSample(:);                 % ת����������
    DisBitsReverseSample = (ones(1, bitSampleNum))' * disturbReverse; %'
    DisBitsReverseSample = DisBitsReverseSample(:); 
    temp1=DisBitsSample .* cos(2 * pi * F1 .* t);
    temp2=DisBitsReverseSample .* cos(2 * pi * F2 .* t);
    % FSK����
    fsk1 = sendBitsSample .* cos(2 * pi * f1 .* t)+1.2*temp1;
    fsk2 = sendBitsReverseSample .* cos(2 * pi * f2 .* t)+1.2*temp2;
    fsk = fsk1 + fsk2;
    %sound(fsk,sampleRate);
    audiowrite('send.wav',fsk,sampleRate);

   
    noise       = 20* (randn(length(fsk), 1));%sqrt(noisePower) * (randn(length(fsk), 1));
    fskSigWithNoise = fsk + noise;
 
    hammingWinN = ceil(6 * pi / tr_width) + 1;
    b1 = fir1(hammingWinN, [max(w1-0.02, 0) w1+0.02]);
    b2 = fir1(hammingWinN, [w2-0.02 w2+0.02]);
 
    % �˲�
    H1 = filter(b1, 1, fskSigWithNoise);
    H2 = filter(b2, 1, fskSigWithNoise);
 
    % ���
    % ʹ����ɽ���ķ���
    sw1 = H1 .* H1;
    sw2 = H2 .* H2;
 
 
    % ��Ƶ�ͨ�˲���
    hammingWinN = ceil(6 * pi / (0.001 * pi)) + 1;
    % LPF = fir1(hammingWinN, 0.05);
    % freqz( dfilt.dffir(LPF));
    % title('��ͨ�˲���')
    LPF = fir1(hammingWinN, 0.005);
    % LPF = fir1(101, [2/800 10/800]);
    % ������ͨ�˲���
    st1 = filter(LPF, 1, sw1);
    st2 = filter(LPF, 1, sw2);
 
    Wav1=zeros(1,SimBitsNum);%Wav1Ϊ19kHz�Ĳ���
    Wav2=zeros(1,SimBitsNum);%Wav2Ϊ18kHz�Ĳ���
    WavFinal=[];%WavFinalΪ���մ��ݵı������ź�
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