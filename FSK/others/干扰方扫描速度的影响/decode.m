function WavFinal = decode( sw1,sw2,SimBitsNum,bitSampleNum )
Wav1=zeros(1,SimBitsNum);
Wav2=zeros(1,SimBitsNum);
WavFinal=zeros(1,SimBitsNum);
for i=1:SimBitsNum,
    Wav1(i)=sum(sw1((i-1)*bitSampleNum+1 : i*bitSampleNum))/bitSampleNum;
    Wav2(i)=sum(sw2((i-1)*bitSampleNum+1 : i*bitSampleNum))/bitSampleNum;
end;
for i=1:SimBitsNum,
    if Wav1(i)<=Wav2(i),
        WavFinal(i)=1;
    else
        WavFinal(i)=0;
    end;
end; 
end

