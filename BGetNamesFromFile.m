function names = BGetNamesFromFile(fileName)
%% read lines from a file to a cell
% input 
%  - fileName: String   all files' name are listed in this file, one name perline
% output
%  - names: cell String array   names of yaml file
    fid = fopen(fileName);
    
    tline = fgetl(fid);
    i = 1;
    while ischar(tline)
        names{i} = tline;
        i = i+1;
        tline = fgetl(fid);
    end

    fclose(fid);
end