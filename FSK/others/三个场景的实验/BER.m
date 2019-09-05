a = load('./information_original.txt');
b=load('./information.txt');
c=(a==b);
count=0;
for i=1:100,
    if c(i)==0,
        count=count+1;
    end
end
disp(count/100);