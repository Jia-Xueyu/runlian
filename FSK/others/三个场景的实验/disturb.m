function temp= disturb(file,length)
while true,
    length=double(length);
    [H,Fs]=audioread(file);
    sound(H,44100);
    pause(length);
end
end

