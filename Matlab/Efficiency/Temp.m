for i = 1:1:PackageNumber
    a = 1;   
    b = 1;
    c = 1 
    max(max(PadData(i,:,:)));
    [row, col]=find(PadData(i,:,:)==max(max(PadData(i,:,:))));
    x_hit=ceil(col(1)/18);
    y_hit=mod(col(1),18);
    if(PadData(i,y_hit,x_hit) == 3)
        for j = 1:1:15   
            for k = 1:1:15
                m=abs(k-x_hit);
                n=abs(j-y_hit);
                if(m==1 && n==1)


                end
            end
            b;
            if(b==0) 
                count=count+1;
            break; 
            end
        end
    end
end