function temp=t_record(N)
temp=[];
N=double(N);
R=audiorecorder(44100,24,1);
disp('Start speaking.')
recordblocking(R,8);
disp('End of Recording.');
myspeech=getaudiodata(R);
filename=['signal',num2str(N),'.wav'];
audiowrite(filename,myspeech,44100);
end

