
clc,clear
close all
% 系统配置
sampleRate = 210000;                          % 采样率
AllNum=20000;
send_every=200;
Bits = round(rand(1, AllNum)); 
dt = 1 / sampleRate;                        % 采样时间间隔
SimBitsNum = send_every*2+1;                            % 模拟比特数
bitTime = 0.003;                                % 1bit持续的时间
bitSampleNum = sampleRate * bitTime;        % 1bit的采样点数
totalTime = bitTime * SimBitsNum;           % 总时间
totalSampleNum = sampleRate * totalTime;    % 采样点的个数
t = 0:dt:(totalTime - dt);                  % SimBitsNum个比特所持续的时间
t = t';                                     % 转置成列向量'
SNR = 70;                                    % 信噪比（单位：dB）
ap = 0.1;                                   % 通带最大波动
as = 60;                                    % 阻带最小衰减
tr_width = 0.01 * pi;                       % 数字滤波器过渡带宽
% 产生发送比特
validation=round(rand(1, send_every+1));
record_time=bitTime*SimBitsNum;
band=[17000 18000;18000 19000;19000 20000;20000 21000];
% sendBits = randi([0 1],[1, SimBitsNum]); 
index=1;
Final=[];
ss_f1 = 17000;                                 
ss_f2 = 18000; 
sr_f1=18000;
sr_f2=19000;

rs_f1=18000;
rs_f2=19000;
rr_f1=17000;
rr_f2=18000;
count=1;
change_count=1;
scan_speed=0.5;
disturb=1;
fre=0;
tic;
while true,
    if index>=AllNum,
        break;
    end;                             
    
    fskSigWithNoise = S_send( ss_f1,ss_f2,t,send_every,validation,Bits,index,SNR,bitSampleNum);%发出音频，结合噪音
    index=index+send_every;
     time=0;
    
    %干扰方
    if disturb==1,
        flag=0;
        while time<record_time,
            if ss_f1==16000+fre*1000,
                flag=1;
                break;
            else
                time=time+scan_speed;
                pause(scan_speed);
            end;
            fre=randi(4,1,1);
        end;
        if flag==1,
            fskSig = new_disturber(ss_f1,ss_f2,t,send_every,bitSampleNum );
            tt=time/record_time;
            for i=1:tt*length(fskSig),
                fskSig(i)=0;
            end;
            fskSigWithNoise=fskSigWithNoise+fskSig;
        end;
    end;
         
    [sw1,sw2]=rr_record( tr_width,rr_f1,rr_f2,dt,record_time-time,fskSigWithNoise );%接收方记录
    
    WavFinal=decode(sw1,sw2,SimBitsNum,bitSampleNum);%解码
    
    %提取信息和验证码
    V=[];
    F=[];
    for i=1:SimBitsNum,
        if mod(i,2)==0,
            F=[F WavFinal(i)];
        else
            V=[V WavFinal(i)];
        end
    end
    
    disp(length(find(xor(V, validation) == 1))/length(validation));

    %判断
    fprintf('ACK count %d\n', count);
    count=count+1;
    Final=[Final F];
    while true,
        [s1,s2]=rr_ACK( rs_f1,rs_f2,sr_f1,sr_f2,dt,tr_width);
        ACK = decode( s1,s2,5,bitSampleNum );
        if ACK==[0,0,0,0,0];
            break;
        end; 
    end;    
    
end;
        
toc;
throughput=AllNum/toc;
fprintf('throughput is %d\n', throughput)
e2 = length(find(xor(Bits, Final) == 1)) / AllNum;
fprintf('ber is %d\n', e2)