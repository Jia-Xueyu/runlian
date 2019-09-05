function value = r_record_decode(f1,f2)
clear value;
tic;
f1=double(f1);
f2=double(f2);
value=[];
infor=[];
validation=[];
adoption=0;
R=audiorecorder(44100,24,1);
t1=toc;
display(t1);
disp('Start speaking.')
recordblocking(R,24);
disp('End of Recording.');
myspeech=getaudiodata(R);
audiowrite('record.wav',myspeech,44100);

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
w1 = 2 * pi * f1 * dt / pi;                 % ��Ƶ1������Ƶ��/pi �����FIR�˲���ʱʹ��
w2 = 2 * pi * f2 * dt / pi; 
hammingWinN = ceil(6 * pi / tr_width) + 1;
b1 = fir1(hammingWinN, [max(w1-0.02, 0) w1+0.02]);
b2 = fir1(hammingWinN, [w2-0.02 w2+0.02]);

[H,Fs]=audioread('record.wav');
H1 = filter(b1, 1, H);
H2 = filter(b2, 1, H);

sw1 = H1 .* H1;
sw2 = H2 .* H2;
 
hammingWinN = ceil(6 * pi / (0.001 * pi)) + 1;
LPF = fir1(hammingWinN, 0.005);
st1 = filter(LPF, 1, sw1);
st2 = filter(LPF, 1, sw2);

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

for i=4:SimBitsNum,
        if mod(i-3,2)==0,
            infor=[infor WavFinal(i)];
        else
            validation=[validation WavFinal(i)];
        end;
end;
if WavFinal(1)==0&&WavFinal(2)==0&&WavFinal(3)==0,
    adoption=1;
else
    adoption=0;
end
value=[value infor];
value=[value validation];
value=[value adoption];
end

