f1=17000;
f2=18000;
sampleRate = 44100;                          % ������
dt = 1 / sampleRate;                        % ����ʱ����
SimBitsNum = 9;                            % ģ�������
bitTime = 1;                                % 1bit������ʱ��
bitSampleNum = sampleRate * bitTime;        % 1bit�Ĳ�������
totalTime = bitTime * SimBitsNum;           % ��ʱ��
totalSampleNum = sampleRate * totalTime;    % ������ĸ���
t = 0:dt:(totalTime - dt);                  % SimBitsNum��������������ʱ��
t = t'; 
w1 = 2 * pi * f1 * dt / pi;                 % ��Ƶ1������Ƶ��/pi �����FIR�˲���ʱʹ��
w2 = 2 * pi * f2 * dt / pi;                 % ��Ƶ2������Ƶ��/pi �����FIR�˲���ʱʹ��
SNR = 2;                                    % ����ȣ���λ��dB��
ap = 0.1;                                   % ͨ����󲨶�
as = 60;                                    % �����С˥��
tr_width = 0.01 * pi;  
%ack=[0 1 0 0 1];%��һλ��ʾδ��Ƶ
signal=[1 1 1 1 1];
filename='disturb.wav';
sendBits=[1 1 1 1 signal];
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
path=['./ACK/',filename];
audiowrite(path,fsk,sampleRate);
%sound(fsk,sampleRate);

