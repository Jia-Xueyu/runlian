
clc,clear
close all
% ϵͳ����
sampleRate = 210000;                          % ������
AllNum=20000;
send_every=200;
Bits = round(rand(1, AllNum)); 
dt = 1 / sampleRate;                        % ����ʱ����
SimBitsNum = send_every*2+1;                            % ģ�������
bitTime = 0.003;                                % 1bit������ʱ��
bitSampleNum = sampleRate * bitTime;        % 1bit�Ĳ�������
totalTime = bitTime * SimBitsNum;           % ��ʱ��
totalSampleNum = sampleRate * totalTime;    % ������ĸ���
t = 0:dt:(totalTime - dt);                  % SimBitsNum��������������ʱ��
t = t';                                     % ת�ó�������'
SNR = 70;                                    % ����ȣ���λ��dB��
ap = 0.1;                                   % ͨ����󲨶�
as = 60;                                    % �����С˥��
tr_width = 0.01 * pi;                       % �����˲������ɴ���
% �������ͱ���
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
    
    fskSigWithNoise = S_send( ss_f1,ss_f2,t,send_every,validation,Bits,index,SNR,bitSampleNum);%������Ƶ���������
    index=index+send_every;
     time=0;
    
    %���ŷ�
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
         
    [sw1,sw2]=rr_record( tr_width,rr_f1,rr_f2,dt,record_time-time,fskSigWithNoise );%���շ���¼
    
    WavFinal=decode(sw1,sw2,SimBitsNum,bitSampleNum);%����
    
    %��ȡ��Ϣ����֤��
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

    %�ж�
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