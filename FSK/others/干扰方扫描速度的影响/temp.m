
close all
% ϵͳ����
sampleRate = 210000;                          % ������
dt = 1 / sampleRate;                        % ����ʱ����
SimBitsNum = 5;                            % ģ�������
bitTime = 0.003;                                % 1bit������ʱ��
bitSampleNum = sampleRate * bitTime;        % 1bit�Ĳ�������
totalTime = bitTime * SimBitsNum;           % ��ʱ��
totalSampleNum = sampleRate * totalTime;    % ������ĸ���
t = 0:dt:(totalTime - dt);                  % SimBitsNum��������������ʱ��
t = t';                                     % ת�ó�������'
f1 = 18000;                                    % ��Ƶ1��ģ��Ƶ��(Hz)
f2 = 19000;                                   % ��Ƶ2��ģ��Ƶ��(Hz)
w1 = 2 * pi * f1 * dt / pi;                 % ��Ƶ1������Ƶ��/pi �����FIR�˲���ʱʹ��
w2 = 2 * pi * f2 * dt / pi;                 % ��Ƶ2������Ƶ��/pi �����FIR�˲���ʱʹ��
SNR = 100;                                    % ����ȣ���λ��dB��
ap = 0.1;                                   % ͨ����󲨶�
as = 60;                                    % �����С˥��
tr_width = 0.01 * pi;                       % �����˲������ɴ���
% �������ͱ���
% sendBits = randi([0 1],[1, SimBitsNum]);
sendBits = [1 0 0 0 0];           % ģ�ⷢ�͵ı���
sendBitsReverse = ~sendBits;
% ����
% ע�⣺�˴�ʹ���˾������
sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
sendBitsSample = sendBitsSample(:);                 % ת����������
sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
sendBitsReverseSample = sendBitsReverseSample(:);   % ת����������
 
% FSK����
fsk1 = sendBitsSample .* cos(2 * pi * f1 .* t);
fsk2 = sendBitsReverseSample .* cos(2 * pi * f2 .* t);
fsk = fsk1 + fsk2;
filename = ('ACK_1819.wav');
audiowrite(filename,fsk,sampleRate)
