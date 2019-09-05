R=audiorecorder(44100,24,1);
disp('Start speaking.')
recordblocking(R,24);
disp('End of Recording.');
myspeech=getaudiodata(R);
audiowrite('myvoice.wav',myspeech,44100);


