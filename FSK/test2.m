clc,clear
close all
%Ҳ�������ź����ţ���ת���ض���ŵ���ϢԴ��
%���磬[zeros(1,23) 1]������ת�����Ϊ1����ϢԴ



BitAll = unifrnd(0,1,10,230);%ģ��10����Ϣ��ÿ����Ϣ��200�����أ�ÿ�δ���������23������
for i=1:10
    for j=1:230
        if BitAll(i,j)>=0.5 BitAll(i,j) = 1;
        else BitAll(i,j) = 0;
        end;
    end;
end;
InfoLine=randperm(10);%���˳��
index=1;%ĳ����Ϣ����Ŀ�ʼλ�ã���Ϊһ����Ϣ���ᴫ��һ�Σ���Ҫ����־λ����´ο�ʼ�ĵط�
sampleRate = 44100;                          % ������
dt = 1 / sampleRate;                        % ����ʱ����
SimBitsNum = 24;                            % ģ�������
bitTime = 1;                                % 1bit������ʱ��
bitSampleNum = sampleRate * bitTime;        % 1bit�Ĳ�������
totalTime = bitTime * SimBitsNum;           % ��ʱ��
totalSampleNum = sampleRate * totalTime;    % ������ĸ���
t = 0:dt:(totalTime - dt);                  % SimBitsNum��������������ʱ��
t = t';                                     % ת�ó�������'
f1 = 20000;                                    % ��Ƶ1��ģ��Ƶ��(Hz)
f2 = 21000;                                   % ��Ƶ2��ģ��Ƶ��(Hz)
w1 = 2 * pi * f1 * dt / pi;                 % ��Ƶ1������Ƶ��/pi �����FIR�˲���ʱʹ��
w2 = 2 * pi * f2 * dt / pi;                 % ��Ƶ2������Ƶ��/pi �����FIR�˲���ʱʹ��
SNR = 2;                                    % ����ȣ���λ��dB��
ap = 0.1;                                   % ͨ����󲨶�
as = 60;                                    % �����С˥��
tr_width = 0.01 * pi;                       % �����˲������ɴ���
% �������ͱ���
% sendBits = randi([0 1],[1, SimBitsNum]);
SignalTrans=[0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1];
sendBits = SignalTrans;
sendBitsReverse = ~sendBits;
    % ����
    % ע�⣺�˴�ʹ���˾������
receiveBits=sendBits;
receiveBits
sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
sendBitsSample = sendBitsSample(:);                 % ת����������
sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
sendBitsReverseSample = sendBitsReverseSample(:);   % ת����������
 
    % FSK����
fsk1 = sendBitsSample .* cos(2 * pi * f1 .* t);
fsk2 = sendBitsReverseSample .* cos(2 * pi * f2 .* t);
fsk = fsk1 + fsk2;
%sound(fsk,sampleRate)