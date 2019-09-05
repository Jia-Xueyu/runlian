function temp= r_changeSignal(F1,F2,t,r)
F1=double(F1);
F2=double(F2);
t=int32(t);
r=int32(r);
temp=[];
sampleRate = 44100;                          % ������
dt = 1 / sampleRate;                        % ����ʱ����
SimBitsNum = 8;                            % ģ�������
bitTime = 1;                                % 1bit������ʱ��
bitSampleNum = sampleRate * bitTime;        % 1bit�Ĳ�������
totalTime = bitTime * SimBitsNum;           % ��ʱ��
totalSampleNum = sampleRate * totalTime;    % ������ĸ���
t = 0:dt:(totalTime - dt);                  % SimBitsNum��������������ʱ��
t = t';                                     % ת�ó�������'
w1 = 2 * pi * F1 * dt / pi;                 % ��Ƶ1������Ƶ��/pi �����FIR�˲���ʱʹ��
w2 = 2 * pi * F2 * dt / pi;                 % ��Ƶ2������Ƶ��/pi �����FIR�˲���ʱʹ��
SNR = 2;                                    % ����ȣ���λ��dB��
ap = 0.1;                                   % ͨ����󲨶�
as = 60;                                    % �����С˥��
tr_width = 0.01 * pi;                       % �����˲������ɴ���
% �������ͱ���
% sendBits = randi([0 1],[1, SimBitsNum]);
band=[17000 18000;18000 19000;19000 20000;20000 21000];

if t==1,
    bit1=[0 0];
elseif t==2,
    bit1=[0 1];
elseif t==3,
    bit1=[1 0];
else
    bit1=[1 1];
end;
if r==1,
    bit2=[0 0];
elseif r==2,
    bit2=[0 1];
elseif r==3,
    bit2=[1 0];
else
    bit2=[1 1];
end;
sendBits = [1,1,0,1,bit1,bit2];             % �źű���
sendBitsReverse = ~sendBits;

sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
sendBitsSample = sendBitsSample(:);                 % ת����������
sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
sendBitsReverseSample = sendBitsReverseSample(:);   % ת����������
% FSK����
fsk1 = sendBitsSample .* cos(2 * pi * F1 .* t);
fsk2 = sendBitsReverseSample .* cos(2 * pi * F2 .* t);
fsk = fsk1 + fsk2;
sound(fsk,sampleRate);
end

