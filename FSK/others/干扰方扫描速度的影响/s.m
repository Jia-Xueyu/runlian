count=1;
name1='1718';
name2='1819';
name3='1920';
name4='2021';
flag=1;
f1 = 20000;                                    % ��Ƶ1��ģ��Ƶ��(Hz)
f2 = 21000;  
index=1;
Bits=[1 1 0 1 1 0 0 1 1 1 0 1 1 0 1 0 0 1 1 1 1 0 1 1 1 1 1 0 1 0 1 0 0 0 0 1 1 0 1 0 0 0 1 1 0 0 0 1 1 1 0 1 1 0 0 0 1 0 1 0 1 0 1 1 1 1 1 0 0 0 1 0 1 0 1 0 0 0 1 0 0 1 1 1 1 0 1 1 0 1 0 0 1 1 1 0 1 0 0 0];
while count<=10,
    filename=['infor',num2str(flag),'_',name4,'.wav'];
    count=count+1;
    flag=flag+1;
    sampleRate = 44100;                          % ������
    dt = 1 / sampleRate;                        % ����ʱ����
    SimBitsNum =25;                            % ģ�������
    bitTime = 1;                                % 1bit������ʱ��
    bitSampleNum = sampleRate * bitTime;        % 1bit�Ĳ�������
    totalTime = bitTime * SimBitsNum;           % ��ʱ��
    totalSampleNum = sampleRate * totalTime;    % ������ĸ���
    t = 0:dt:(totalTime - dt);                  % SimBitsNum��������������ʱ��
    t = t';                                     % ת�ó�������'
    % �������ͱ���
    validation=[1 1 1 0 1 1 1 0 1 1 1];
    
    w1 = 2 * pi * f1 * dt / pi;                 % ��Ƶ1������Ƶ��/pi �����FIR�˲���ʱʹ��
    w2 = 2 * pi * f2 * dt / pi;                 % ��Ƶ2������Ƶ��/pi �����FIR�˲���ʱʹ��
    SNR = 2;                                    % ����ȣ���λ��dB��
    ap = 0.1;                                   % ͨ����󲨶�
    as = 60;                                    % �����С˥��
    tr_width = 0.01 * pi;  
    %sendBits=[1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];%����50��1����
    BitAll=Bits(index:index+9);
    sendBits=[1 1 1 1 1 BitAll(1) 1 BitAll(2) 1 BitAll(3) 0 BitAll(4) 1 BitAll(5) 1 BitAll(6) 1 BitAll(7) 0 BitAll(8) 1 BitAll(9) 1 BitAll(10) 1];
    index=index+10;
    %sendBits = [1 BitAll(InfoLine(count),index:index+19)];    % ģ�ⷢ�͵ı���
    sendBitsReverse = ~sendBits;
    % ����
    % ע�⣺�˴�ʹ���˾������
    display(sendBits);
    %sendBits
    sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
    sendBitsSample = sendBitsSample(:);                 % ת����������
    sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
    sendBitsReverseSample = sendBitsReverseSample(:);   % ת����������

    fsk1 = sendBitsSample .* cos(2 * pi * f1 .* t);
    fsk2 = sendBitsReverseSample .* cos(2 * pi * f2 .* t);
    fsk = fsk1 + fsk2;
    path=['./information/',filename];
    audiowrite(path,fsk,44100);
    %soundsc(fsk,sampleRate);
end;