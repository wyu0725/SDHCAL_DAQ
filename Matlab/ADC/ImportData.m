function InitialData = ImportData()
%%% This function inport the *.dat file with UI interface
% The data is imported in ubit2 structure
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
        InitialData = fread(fid,'ubit16','ieee-be');%Big-endian ording
        %Size = length(importdata);
        fclose(fid);%close file
    end
end
end
