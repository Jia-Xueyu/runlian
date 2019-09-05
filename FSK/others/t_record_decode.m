function value = t_record_decode(F1,F2 )
tic;
value=zeros(1,5);
adoption=0;
F1=double(F1);
F2=double(F2);
R=audiorecorder(44100,8,1);
t1=toc;
display(t1);
disp('Start speaking.')
recordblocking(R,8);
disp('End of Recording.');
myspeech=getaudiodata(R);
audiowrite('record.wav',myspeech,44100);

sampleRate = 44100;                          % ������
dt = double(1 / sampleRate);
tr_width = double(0.01 * pi);  
SimBitsNum = 8;                            % ģ�������
bitTime = 1;                                % 1bit������ʱ��
bitSampleNum = sampleRate * bitTime;        % 1bit�Ĳ�������
totalTime = bitTime * SimBitsNum;           % ��ʱ��
totalSampleNum = sampleRate * totalTime; 
t = 0:dt:(totalTime - dt);                  % SimBitsNum��������������ʱ��
t = t'; 
w1 = double(2 * F1 * dt);                % ��Ƶ1������Ƶ��/pi �����FIR�˲���ʱʹ��
w2 = double(2 * pi * F2 * dt / pi); 
hammingWinN = ceil(6 * pi / tr_width) + 1;
temp=double([max(w1-0.02, 0) w1+0.02]);
b1 = fir1(hammingWinN, temp);
b2 = fir1(hammingWinN, double([w2-0.02 w2+0.02]));
band=[17000 18000;18000 19000;19000 20000;20000 21000];

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
signal=[];
if WavFinal(1)==1&&WavFinal(2)==1&&WavFinal(3)==1&&WavFinal(4)==1,
    adoption=1;
    display('change signal');
else
    display('no change signal');
    adoption=0;
end;
for i=5:SimBitsNum,
    signal=[signal,WavFinal(i)];
end;

if signal(1)==0 &&signal(2)==0,
    s_f1=band(1,1);
    s_f2=band(1,2);
elseif signal(1)==0&&signal(2)==1,
    s_f1=band(2,1);
    s_f2=band(2,2);
elseif signal(1)==1&&signal(2)==0,
    s_f1=band(3,1);
    s_f2=band(3,2);
else
    s_f1=band(4,1);
    s_f2=band(4,2);
end;

if signal(3)==0 &&signal(4)==0,
    r_f1=band(1,1);
    r_f2=band(1,2);
elseif signal(3)==0&&signal(4)==1,
    r_f1=band(2,1);
    r_f2=band(2,2);
elseif signal(3)==1&&signal(4)==0,
    r_f1=band(3,1);
    r_f2=band(3,2);
else
    r_f1=band(4,1);
    r_f2=band(4,2);
end;
value(1)=s_f1;
value(2)=s_f2;
value(3)=r_f1;
value(4)=r_f2;
value(5)=adoption;
end

