function temp = voice( file,length )
temp=[];
length=double(length);
[H,Fs]=audioread(file);
sound(H,44100);
pause(length);
end

