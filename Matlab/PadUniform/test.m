 clc;
clear

 MapData = cell(30, 30);
 [fid,~] = fopen('Pad_Order.txt','r');
 mapping = textscan(fid, '%s');
[a2, a3]=textread('1.txt','%s %f');
b=length(a2);
value=zeros(1,440);%440 depends on the length of value
vc=0;
total=0;

%fid=fopen('K:\dhcal\A\value.txt','a+');
for l=1:1:b
    if(a3(l) ~= 0)
            vc=vc+1;
            value(vc)=a3(l);
            total=value(vc)+total;
           % fprintf(fid,'%d\n',value(vc)); 
    end
end
M=total/vc
%fclose(fid);
stderr=std(value)
uni=stderr/M


for i = 1:1:30
    for j = 1:1:30
         MapData(i, j) = mapping{1}(j + 30*(i - 1));
    end
 end

amplitude=zeros(30,30);

counts=0;
for k=1:1:b  
    for m=1:1:30
        for n=1:1:30
            %a2(k);
            if(isequal(a2(k),MapData(m,n)))
                amplitude(m,n)=a3(k);
                counts=counts+1;
            end
        end
    end
 end
counts;
amplitude;

figure;
BarColor = bar3(amplitude,1);
xlim([0.5 30.5]);
ylim([0.5 30.5]);
xlabel('X(cm)');
ylabel('Y(cm)');
zlabel('Amplitude(V)');
saveas(gcf,['K:\dhcal\A\uniform\','uniform','.jpg']);
for k = 1:length(BarColor)
    zdata = BarColor(k).ZData;
    BarColor(k).CData = zdata;
    BarColor(k).FaceColor = 'interp';
end
colorbar;
hold on;
figure;
hist(value,20);
xlim([0.2 1]);
saveas(gcf,['K:\dhcal\A\uniform\','hist_dis','.jpg']);
