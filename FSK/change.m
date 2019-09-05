function signal = change(N )
    x=0;
    while true,
        x=randi(4);
        if x~=N,
            break;
        end;
    end;      
    band=[17000 18000;18000 19000;19000 20000;20000 21000];
    xf=band(x,1);
    yf=band(x,2);
    sampleRate = 44100;                          % ������
    dt = 1 / sampleRate;                        % ����ʱ����
    SimBitsNum = 2;                            % ģ�������
    bitTime = 1;                                % 1bit������ʱ��
    bitSampleNum = sampleRate * bitTime;        % 1bit�Ĳ�������
    totalTime = bitTime * SimBitsNum;           % ��ʱ��
    totalSampleNum = sampleRate * totalTime;    % ������ĸ���
    t = 0:dt:(totalTime - dt);                  % SimBitsNum��������������ʱ��
    t = t';                                     % ת�ó�������'
    w1 = 2 * pi * xf * dt / pi;                 % ��Ƶ1������Ƶ��/pi �����FIR�˲���ʱʹ��
    w2 = 2 * pi * yf * dt / pi;                 % ��Ƶ2������Ƶ��/pi �����FIR�˲���ʱʹ��
    SNR = 2;                                    % ����ȣ���λ��dB��
    ap = 0.1;                                   % ͨ����󲨶�
    as = 60;                                    % �����С˥��
    tr_width = 0.01 * pi;                       % �����˲������ɴ���
    % �������ͱ���
    % sendBits = randi([0 1],[1, SimBitsNum]);
    if x==1,
        sendBits=[0 0];
    elseif x==2,
        sendBits=[0 1];
    elseif x==3,
        sendBits=[1 0];
    else
        sendBits=[1 1];
    end;
    sendBitsReverse = ~sendBits;
    sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
    sendBitsSample = sendBitsSample(:);                 % ת����������
    sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
    sendBitsReverseSample = sendBitsReverseSample(:);   % ת����������
    % FSK����
    fsk1 = sendBitsSample .* cos(2 * pi * xf .* t);
    fsk2 = sendBitsReverseSample .* cos(2 * pi * yf .* t);
    fsk = fsk1 + fsk2;
    audiowrite('signal.wav',fsk,sampleRate);
    
    noisePower  = 10^(-SNR/10);
    noise       = sqrt(noisePower) * (randn(length(fsk), 1));
    fskSigWithNoise = fsk + noise;
 
    hammingWinN = ceil(6 * pi / tr_width) + 1;
    b1 = fir1(hammingWinN, [max(w1-0.02, 0) w1+0.02]);
    b2 = fir1(hammingWinN, [w2-0.02 w2+0.02]);
 
    % �˲�
    H1 = filter(b1, 1, fskSigWithNoise);
    H2 = filter(b2, 1, fskSigWithNoise);
 
    % ���
    % ʹ����ɽ���ķ���
    sw1 = H1 .* H1;
    sw2 = H2 .* H2;
 
 
    % ��Ƶ�ͨ�˲���
    hammingWinN = ceil(6 * pi / (0.001 * pi)) + 1;
    % LPF = fir1(hammingWinN, 0.05);
    % freqz( dfilt.dffir(LPF));
    % title('��ͨ�˲���')
    LPF = fir1(hammingWinN, 0.005);
    % LPF = fir1(101, [2/800 10/800]);
    % ������ͨ�˲���
    st1 = filter(LPF, 1, sw1);
    st2 = filter(LPF, 1, sw2);
 
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
    if WavFinal==[0 0]
        signal=band(1,:);
    elseif WavFinal==[0 1],
        signal=band(2,:);
    elseif WavFinal==[1 0],
        signal=band(3,:);
    else
        signal=band(4,:);
    end;
end

