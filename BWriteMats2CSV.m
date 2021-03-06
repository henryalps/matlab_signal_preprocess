function BWriteMats2CSV(csvfilename, datamat, namecell)
%% ??????????????????????????????csv?????? 
% reference: https://ths1104geek.wordpress.com/2014/04/14/write-data-to-a-txt-or-csv-file-with-matlab/
% datamat [k*n] ????????? ??????????????????????????????-?????????
% namecell {1*k} ???????????????????????????????????????/???????????????
% ???????????????
% =======??????=======
% <><><><><><><><><>
% <><><datamat<><><>
% <><><><><><><><><>
% FILEPATH = '/home/test/Herui-Matlab/data/csv';%'/home/test/Herui-Matlab/data/csv'; % '/mnt/code/matlab/data/csv';
FILEPATH = Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV; %APPENDIX_PACE_2_PACE_LONG_CSV
if ~exist(FILEPATH,'dir') 
%     error(['WRITE CSV FAIL! directory does not exist: ',FILEPATH]);
    return
end
csv_filename = fullfile(FILEPATH, csvfilename);
if exist(csv_filename,'file') 
%     error(['WRITE CSV FAIL! file exist:',csv_filename]);

end
%% write to csv file
% namecell{1} = ['%', namecell{1}];
dlmwrite(csv_filename,strjoin(namecell,','),''); %write header to csv_filename
dlmwrite(csv_filename,datamat,'-append','delimiter',',','precision',16); %append the data to csv_filename

end