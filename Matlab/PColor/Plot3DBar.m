% function Plot3DBar(x, y, z)
% x,y为2维坐标，z为x,y对应的数据
x = 1:1:8;
y = 1:1:8;
z = C;
    m = length(x);
    n = length(y);
    [zm, zn] = size(z);
    if zm ~= m || zn ~= n
        error('Wrong Data');
    end
    dx = (x(2) - x(1))/6;
    dy = (y(2) - y(1))/6;
    XStart = x(1) - 3*dx;
    XEnd = x(m) + 3*dx;
    YStart = y(1) - 3*dy;
    YEnd = y(n) + 3*dy;
    X = XStart:dx:XEnd;
    Y = YStart:dy:YEnd;
    M = length(X);
    N = length(Y);
    Z = zeros(M,N);
    for i = 1:(M-2)
        for j = 1:(N-2)
            Z(i,j) = z(round(XStart + i*dx),round(YStart + j*dy));
        end
    end
    figure
    surf(Y,X,Z,Z,'FaceColor','interp');
    colormap(summer)
% end
