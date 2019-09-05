sampleRate = 44100;                          % ������
dt = 1 / sampleRate;                        % ����ʱ����
SimBitsNum = 20;                            % ģ�������
bitTime = 1;                                % 1bit������ʱ��
bitSampleNum = sampleRate * bitTime;        % 1bit�Ĳ�������
totalTime = bitTime * SimBitsNum;           % ��ʱ��
totalSampleNum = sampleRate * totalTime;    % ������ĸ���
t = 0:dt:(totalTime - dt);                  % SimBitsNum��������������ʱ��
t = t';                                     % ת�ó�������'
f1 = 20000;                                    % ��Ƶ1��ģ��Ƶ��(Hz)
f2 = 21000;                                   % ��Ƶ2��ģ��Ƶ��(Hz)
% �������ͱ���

w1 = 2 * pi * f1 * dt / pi;                 % ��Ƶ1������Ƶ��/pi �����FIR�˲���ʱʹ��
w2 = 2 * pi * f2 * dt / pi;                 % ��Ƶ2������Ƶ��/pi �����FIR�˲���ʱʹ��
SNR = 2;                                    % ����ȣ���λ��dB��
ap = 0.1;                                   % ͨ����󲨶�
as = 60;                                    % �����С˥��
tr_width = 0.01 * pi;  
%sendBits=[1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];%����50��1����
sendBits=ones(1,20);
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
sound(fsk,sampleRate);