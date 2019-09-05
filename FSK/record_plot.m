tic
%实习记录可以用audiorecord
interval = 44100*5;%44100;
need_exist = false;
index = 1;
while ~need_exist
    try
        [x, fs] = audioread( 'test.wav' , [(index-1)*interval+1, index*interval ]);
    catch
        [x, fs] = audioread( 'test.wav' , [(index-1)*interval+1, inf ]);
        need_exist = true;
    end
    index = index + 1;
    x
    plot(x)
    drawnow
%     pause(0.)
end
toc