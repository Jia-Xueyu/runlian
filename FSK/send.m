clc,clear
close all
% ϵͳ����
%������10����Ϣ,ÿ����Ϣ��200��������Ϣ�����������Ȼᴫ��ĳ����Ϣ�ı�������������ĳ���������ض�������ones(zeros(1,20)),����Ҫ�л���ϢԴ
%��Ȼÿÿ����Ϣ�����ź���Ϣ��һ��
%ÿ�δ���21���أ���ʽΪ[B infor],B��ʾ��־λ��1����Ϣ��0���źš�infor����20λ��Ϣ������
BitAll = unifrnd(0,1,10,240);%(0,1)���ȷֲ��������ȡһЩ��
for i=1:10
    for j=1:240
        if BitAll(i,j)>=0.5 BitAll(i,j) = 1;
        else BitAll(i,j) = 0;
        end;
    end;
end;
sampleRate = 44100;                          % ������
dt = 1 / sampleRate;                        % ����ʱ����
SimBitsNum = 24;                            % ģ�������
bitTime = 1;                                % 1bit������ʱ��
bitSampleNum = sampleRate * bitTime;        % 1bit�Ĳ�������
totalTime = bitTime * SimBitsNum;           % ��ʱ��
totalSampleNum = sampleRate * totalTime;    % ������ĸ���
t = 0:dt:(totalTime - dt);                  % SimBitsNum��������������ʱ��
t = t';                                     % ת�ó�������'
f1 = 18000;                                    % ��Ƶ1��ģ��Ƶ��(Hz)
f2 = 19000;                                   % ��Ƶ2��ģ��Ƶ��(Hz)
w1 = 2 * pi * f1 * dt / pi;                 % ��Ƶ1������Ƶ��/pi �����FIR�˲���ʱʹ��
w2 = 2 * pi * f2 * dt / pi;                 % ��Ƶ2������Ƶ��/pi �����FIR�˲���ʱʹ��
SNR = 2;                                    % ����ȣ���λ��dB��
ap = 0.1;                                   % ͨ����󲨶�
as = 60;                                    % �����С˥��
tr_width = 0.01 * pi;                       % �����˲������ɴ���
% �������ͱ���
% sendBits = randi([0 1],[1, SimBitsNum]);
sendBits = [0 1 1 1 0 0 0 1 0 1 1 0 0 1 1 1 0 1 0 1 0 1 0 1];             % �źű���
sendBitsReverse = ~sendBits;
% ����
% ע�⣺�˴�ʹ���˾������
disturb=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
disturbReverse=~disturb;
sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
sendBitsSample = sendBitsSample(:);                 % ת����������
sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
sendBitsReverseSample = sendBitsReverseSample(:);   % ת����������
F1=18000;
F2=19000;
DisBitsSample = (ones(1, bitSampleNum))' * disturb; %'
DisBitsSample = DisBitsSample(:);                 % ת����������
DisBitsReverseSample = (ones(1, bitSampleNum))' * disturbReverse; %'
DisBitsReverseSample = DisBitsReverseSample(:); 
% FSK����
fsk1 = sendBitsSample .* cos(2 * pi * f1 .* t)+DisBitsSample .* cos(2 * pi * F1 .* t);
fsk2 = sendBitsReverseSample .* cos(2 * pi * f2 .* t)+DisBitsReverseSample .* cos(2 * pi * F2 .* t);
fsk = fsk1 + fsk2;
audiowrite('disturb.wav',fsk,sampleRate)
%sound(fsk,sampleRate)