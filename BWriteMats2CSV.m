function BWriteMats2CSV(csvfilename, datamat, namecell)
%% 将矩阵以及顶栏写入到csv文件 
% reference: https://ths1104geek.wordpress.com/2014/04/14/write-data-to-a-txt-or-csv-file-with-matlab/
% datamat [k*n] 矩阵， 每一列都代表一组特征-分类组
% namecell {1*k} 元胞，每个元素都是一个特征/分类的名字
% 写入格式：
% =======顶栏=======
% <><><><><><><><><>
% <><><datamat<><><>
% <><><><><><><><><>
FILEPATH = '/mnt/code/matlab/data/csv';
if ~exist(FILEPATH,'dir') 
    error(['WRITE CSV FAIL! directory does not exist: ',FILEPATH]);
end
csv_filename = fullfile(FILEPATH, csvfilename);
if exist(csv_filename,'file') 
    error(['WRITE CSV FAIL! file exist:',csv_filename]);
end
%% write to csv file
% namecell{1} = ['%', namecell{1}];
dlmwrite(csv_filename,strjoin(namecell,','),''); %write header to csv_filename
dlmwrite(csv_filename,datamat,'-append','delimiter',',','precision',16); %append the data to csv_filename

end