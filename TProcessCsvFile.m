function TProcessCsvFile()
%% 处理生成的csv文件，分别对sbp与dbp划分训练与测试集
% cd /mnt/code/matlab/data/csv-pace-2-pace/long
currentPath = pwd;
pathAppendix  = Constants.APPENDIX_PACE_2_PACE_LONG_CSV;
cd(pathAppendix)
names = BGetNamesFromFile('names.txt');
for i=1:length(names)
    try
        nums =  csv2cell(names{i});
        name = nums(1,:);
        nums = cell2mat(nums(2:end, :));
        % 默认倒数第二列为sbp，最后一列为dbp。舍弃所有取值为0的数据。
        sbpnums = nums(nums(:,end-1)~=0,:);
        dbpnums = nums(nums(:,end)~=0,:);
        TWrite2CsvFiles(pathAppendix, 'sbp', sbpnums, name, names{i}); %'sbp'
        TWrite2CsvFiles(pathAppendix, 'dbp', dbpnums, name, names{i}); %'dbp'
    catch e
        disp(e)
        disp(names{i})
        continue
    end
end
cd(currentPath)
end