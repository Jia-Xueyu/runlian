% �������
% ====== AWGN noise ====== 
%noisePower  = 10^(-SNR/10);
%noise       = sqrt(noisePower) * (randn(length(fsk), 1));
%fskSigWithNoise = fsk + noise;
%subplot(212)
%plot(fskSigWithNoise)
%axis([0 totalSampleNum min(fskSigWithNoise)-0.2 max(fskSigWithNoise)+0.2]);
%grid on
%title('�������֮���ʱ����')
% �����������ǰ����źŷ�����
%figure
%subplot(211)
%plot((0:totalSampleNum-1)*(2/totalSampleNum), abs(fft(fsk)) / sqrt(totalSampleNum))
%grid on
%title('δ��������FSK�����źŵķ�����')
%subplot(212)
%plot((0:totalSampleNum-1)*(2/totalSampleNum), abs(fft(fskSigWithNoise)) / sqrt(totalSampleNum))
%grid on
%title('���������FSK�����źŵķ�����')
 
% ���������ͨ�����˲���
%hammingWinN = ceil(6 * pi / tr_width) + 1;
%b1 = fir1(hammingWinN, [max(w1-0.02, 0) w1+0.02]);
%b2 = fir1(hammingWinN, [w2-0.02 w2+0.02]);
%freqz( dfilt.dffir(b1));
%title('f1�˲���')
%freqz( dfilt.dffir(b2));
%title('f2�˲���')
sampleRate = 44100;                          % ������
dt = 1 / sampleRate; 
tr_width = 0.01 * pi;  
SimBitsNum = 24;                            % ģ�������
bitTime = 1;                                % 1bit������ʱ��
bitSampleNum = sampleRate * bitTime;        % 1bit�Ĳ�������
totalTime = bitTime * SimBitsNum;           % ��ʱ��
totalSampleNum = sampleRate * totalTime; 
t = 0:dt:(totalTime - dt);                  % SimBitsNum��������������ʱ��
t = t'; 
f1 = 18000;                                    % ��Ƶ1��ģ��Ƶ��(Hz)
f2 = 19000;                                   % ��Ƶ2��ģ��Ƶ��(Hz)
w1 = 2 * pi * f1 * dt / pi;                 % ��Ƶ1������Ƶ��/pi �����FIR�˲���ʱʹ��
w2 = 2 * pi * f2 * dt / pi; 
hammingWinN = ceil(6 * pi / tr_width) + 1;
b1 = fir1(hammingWinN, [max(w1-0.02, 0) w1+0.02]);
b2 = fir1(hammingWinN, [w2-0.02 w2+0.02]);
% �˲�
[H,Fs]=audioread('disturb.wav');
H1 = filter(b1, 1, H);
H2 = filter(b2, 1, H);
figure
subplot(211)
plot(t, H1);
grid on
xlabel('t')
ylabel('����')
title('�˲�֮���ʱ���Σ�fc = 18000Hz��')
subplot(212)
plot(t, H2);
grid on
xlabel('t')
ylabel('����')
title('�˲�֮���ʱ���Σ�fc = 19000Hz��')
 
% ���
% ʹ����ɽ���ķ���
sw1 = H1 .* H1;
sw2 = H2 .* H2;
 
figure
subplot(211)
plot(t, sw1)
title('���������H1��Ĳ��α���1')
xlabel('t')
ylabel('����')
grid on
 
subplot(212)
plot(t, sw2)
title('���������H2��Ĳ��α���0')
xlabel('t')
ylabel('����')
grid on
 
% ���֮��ķ�����
figure
subplot(211)
plot((0:totalSampleNum-1)*(2/totalSampleNum), abs(fft(sw1)) / sqrt(totalSampleNum))
grid on
title('sw1x')
subplot(212)
plot((0:totalSampleNum-1)*(2/totalSampleNum), abs(fft(sw2)) / sqrt(totalSampleNum))
grid on
title('sw2x')
 
% ��Ƶ�ͨ�˲���
hammingWinN = ceil(6 * pi / (0.001 * pi)) + 1;
% LPF = fir1(hammingWinN, 0.05);
% freqz( dfilt.dffir(LPF));
% title('��ͨ�˲���')
LPF = fir1(hammingWinN, 0.005);
% LPF = fir1(101, [2/800 10/800]);
freqz(dfilt.dffir(LPF));
% ������ͨ�˲���
title('��ͨ�˲���')
st1 = filter(LPF, 1, sw1);
st2 = filter(LPF, 1, sw2);
figure
subplot(211)
plot(t, st1)
title('������ͨ�˲�����Ĳ���1')
xlabel('t')
ylabel('����')
grid on
 
subplot(212)
plot(t, st2)
title('������ͨ�˲�����Ĳ���2')
xlabel('t')
ylabel('����')
grid on

%��Ϊ��������Ĳ����Ǿ��β���ͼ�����Ե�λʱ���ڸ�ȡ�����ֵ��������̫��
%���԰����е�ȡ����ֵ��ȡƽ��ֵ��Ϊ�����λʱ���ڵķ���ֵ���Դ˶Ա���������ͼ���ж����ʱ��δ�������1����0����
Wav1=zeros(1,SimBitsNum);%Wav1Ϊ19kHz�Ĳ���
Wav2=zeros(1,SimBitsNum);%Wav2Ϊ18kHz�Ĳ���
WavFinal=zeros(1,SimBitsNum);%WavFinalΪ���մ��ݵı������ź�
for i=1:SimBitsNum,
    Wav1(i)=sum(st1((i-1)*44100+1 : i*44100))/44100;
    Wav2(i)=sum(st2((i-1)*44100+1 : i*44100))/44100;
end;
for i=1:SimBitsNum,
    if Wav1(i)>Wav2(i),
        WavFinal(i)=1;
    else
        WavFinal(i)=0;
    end;
end;
WavFinal
%if WavFinal==[0 ones(1,SimBitsNum)],
%    transmitterFunction([0 zeros(1,SimBitsNum)]);
%end;
% �о�
%delay = 1.5;        % ���˲���������ʱ�ӣ���λΪ���ţ�����ֵ�Ǵ�ͼ��ֱ�ӹ۲쵽��
% ȷ���о�ʱ��
%judgePoint = (bitSampleNum/2 + delay * sampleRate : bitSampleNum : totalSampleNum);
%judgeFinal = (st1(judgePoint) > 0.3)'; %'
%judgeNum = length(judgeFinal);      % �����������жϵķ��ŵ�����
%errorRate = length(find(xor(sendBits(1 : judgeNum), judgeFinal) == 1)) / judgeNum;
%fprintf('ϵͳ������Ϊ %d\n', errorRate)