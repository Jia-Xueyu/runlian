function temp = broadcast( filename )
[H,Fs]=audioread(filename);
temp=[];
sound(H,Fs);
end

