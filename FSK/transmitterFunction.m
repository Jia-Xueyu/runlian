function fsk = transmitterFunction( sendBits )
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
% ϵͳ����
sampleRate = 44100;                          % ������
dt = 1 / sampleRate;                        % ����ʱ����
SimBitsNum = 21;                            % ģ�������
bitTime = 1;                                % 1bit������ʱ��
bitSampleNum = sampleRate * bitTime;        % 1bit�Ĳ�������
totalTime = bitTime * SimBitsNum;           % ��ʱ��   
t = 0:dt:(totalTime - dt);                  % SimBitsNum��������������ʱ��
t = t';                                     % ת�ó�������'
f1 = 18000;                                    % ��Ƶ1��ģ��Ƶ��(Hz)
f2 = 19000;                                   % ��Ƶ2��ģ��Ƶ��(Hz)                    % �����˲������ɴ���

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
sound(fsk,sampleRate)
filename = ('backSignal.wav');
audiowrite(filename,fsk,sampleRate)
delete('changeSignal.wav');
end

