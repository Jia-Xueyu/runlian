function temp=t_send(F1,F2,index,BitAll)
F1=double(F1);
F2=double(F2);
%index=1;%ĳ����Ϣ����Ŀ�ʼλ�ã���Ϊһ����Ϣ���ᴫ��һ�Σ���Ҫ����־λ����´ο�ʼ�ĵط�
sampleRate = 44100;                          % ������
dt = 1 / sampleRate;                        % ����ʱ����
SimBitsNum = 25;                            % ģ�������,��һλ��Ϊ���ý��շ���֪ͨ����ʼ��¼
bitTime = 1;                                % 1bit������ʱ��
bitSampleNum = sampleRate * bitTime;        % 1bit�Ĳ�������
totalTime = bitTime * SimBitsNum;           % ��ʱ��
totalSampleNum = sampleRate * totalTime;    % ������ĸ���
t = 0:dt:(totalTime - dt);                  % SimBitsNum��������������ʱ��
t = t';                                     % ת�ó�������'                                 % ��Ƶ2��ģ��Ƶ��(Hz)
% �������ͱ���
% sendBits = randi([0 1],[1, SimBitsNum]);
temp=[];
validation=[0 1 1 0 1 1 1 0 1 1 1];
w1 = 2 * pi * F1 * dt / pi;                 % ��Ƶ1������Ƶ��/pi �����FIR�˲���ʱʹ��
w2 = 2 * pi * F2 * dt / pi;                 % ��Ƶ2������Ƶ��/pi �����FIR�˲���ʱʹ��
SNR = 2;                                    % ����ȣ���λ��dB��
ap = 0.1;                                   % ͨ����󲨶�
as = 60;                                    % �����С˥��
tr_width = 0.01 * pi;  
sendBits=[1 1 0 1 1 BitAll(1,index) 1 BitAll(1,index+1) 1 BitAll(1,index+2) 0 BitAll(1,index+3) 1 BitAll(1,index+4) 1 BitAll(1,index+5) 1 BitAll(1,index+6) 0 BitAll(1,index+7) 1 BitAll(1,index+8) 1 BitAll(1,index+9) 1];

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
fsk1 = sendBitsSample .* cos(2 * pi * F1 .* t);
fsk2 = sendBitsReverseSample .* cos(2 * pi * F2 .* t);
fsk = fsk1 + fsk2;
audiowrite('information.wav',fsk,44100);
sound(fsk,44100);
pause(SimBitsNum);
end

