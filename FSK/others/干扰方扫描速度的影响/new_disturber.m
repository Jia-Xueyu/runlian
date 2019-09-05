function fskSig = new_disturber(f1,f2,t,send_every,bitSampleNum )
temp=ones(1,2*send_every+1);
sendBits = temp; 
sendBitsReverse = ~sendBits;

sendBitsSample = (ones(1, bitSampleNum))' * sendBits; %'
sendBitsSample = sendBitsSample(:);                 % 转换成列向量
sendBitsReverseSample = (ones(1, bitSampleNum))' * sendBitsReverse; %'
sendBitsReverseSample = sendBitsReverseSample(:);   % 转换成列向量


fsk1 = sendBitsSample .* cos(2 * pi * f1 .* t);
fsk2 = sendBitsReverseSample .* cos(2 * pi * f2 .* t);
fskSig = fsk1 + fsk2;
end

