function fskSigWithNoise = S_send( f1,f2,t,send_every,validation,Bits,index,SNR,bitSampleNum)
    temp=[];
    for i=1:send_every,
        temp=[temp validation(i),Bits(index)];
        index=index+1;
    end;
    temp=[temp validation(send_every+1)];
    sendBits = temp; 
    sendBitsReverse = ~sendBits;

    sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
    sendBitsSample = sendBitsSample(:);                 % 转换成列向量
    sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
    sendBitsReverseSample = sendBitsReverseSample(:);   % 转换成列向量
 

    fsk1 = sendBitsSample .* cos(2 * pi * f1 .* t);
    fsk2 = sendBitsReverseSample .* cos(2 * pi * f2 .* t);
    fsk = fsk1 + fsk2;

    % 添加噪声
    % ====== AWGN noise ======
    rate=1;
    noisePower  = rate*10^(-SNR/10);
    noise       = sqrt(noisePower) * (randn(length(fsk), 1));
    fskSigWithNoise = fsk + noise;

end

