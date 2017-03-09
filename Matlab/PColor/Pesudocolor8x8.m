%% Pesudocolor Plot of 8*8 Square
% Read data from *.dat, and plot as hitmap

%--- Open file and Import data ---%
[FileName,PathName,FilterIndex] = uigetfile('*.dat','Select the file');
if FilterIndex
    filename = [PathName FileName];
    [fid,~] = fopen(filename,'r');
    if fid <= 0
        % There was an error--tell user
        str = ['File ' filename ' could not be opened.'];
        dlg_title = 'File Open Faild';
        errordlg(str, dlg_title,'modal');
    else
        %File opend successfully
        InitialData = fread(fid,'ubit2','ieee-be');%Big-endian ording
        fclose(fid);%close file
    end
end
% Read one pack
PackNo = 0;
header = 0;
for i=1:4
    header = header + InitialData(i)*4^(4-i);
end
BCID = 0;
for i = 5:16
    BCID = BCID + InitialData(i)*4^(16 - i);
end
Ch_data = zeros(64,1);
for i = 0:3
    k = 3 -i;
    for j = 1:16
        Ch_data(16*k + j) = bitand(InitialData(16 + j + i*16),1)*2  + bitand(InitialData(16 + j + i*16),2)/2;
    end
end

%----- Plot The Data -----%
X = 1:9;
Y = 1:9;
C = zeros(9,9);
for i = 1:9
    for j = 1:9        
        if (i == 9) || (j ==9)
            C(i,j) = 0;
        else
            C(i,j) = Ch_data((i - 1)*8 + j);
        end
    end
end
pcolor(C)
% coclormap summer
colormap(summer)
axis ij
axis square