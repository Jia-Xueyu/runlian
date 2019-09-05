function BitAll = information( )
BitAll = unifrnd(0,1,1,500);%模拟1条信息，每条信息有100个比特，每次传输器传输10个比特

for j=1:500
    if BitAll(1,j)>=0.5 BitAll(1,j) = 1;
    else BitAll(1,j) = 0;
    end;
end;


end

