function BitAll = information( )
BitAll = unifrnd(0,1,1,500);%ģ��1����Ϣ��ÿ����Ϣ��100�����أ�ÿ�δ���������10������

for j=1:500
    if BitAll(1,j)>=0.5 BitAll(1,j) = 1;
    else BitAll(1,j) = 0;
    end;
end;


end

