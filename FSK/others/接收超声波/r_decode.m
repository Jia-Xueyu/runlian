function WavFinal = r_decode(N)
N=double(N);
f1=20000;
f2=21000;
file=['record',num2str(N),'.wav'];
WavFinal=[];
if exist(file,'file')==2,
    sampleRate = 44100;                          % ������
    dt = 1 / sampleRate; 
    tr_width = 0.01 * pi;  
    SimBitsNum = 8;                            % ģ�������
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

    [H,Fs]=audioread(file);
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
    Wav1=zeros(1,SimBitsNum);%Wav1Ϊ20kHz�Ĳ���
    Wav2=zeros(1,SimBitsNum);%Wav2Ϊ21kHz�Ĳ���
    WavFinal=zeros(1,SimBitsNum);%WavFinalΪ���մ��ݵı������ź�
    for i=1:SimBitsNum,
        Wav1(i)=sum(st1((i-1)*44100+1 : i*44100))/44100;
        Wav2(i)=sum(st2((i-1)*44100+1 : i*44100))/44100;
    end;
    for i=1:SimBitsNum,
        if Wav1(i)>Wav2(i)+1e-5,
            WavFinal(i)=1;
        else
            WavFinal(i)=0;
        end;
    end;
end
disp(WavFinal);
end

