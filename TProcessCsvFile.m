function TProcessCsvFile()
%% 处理生成的csv文件，分别对sbp与dbp划分训练与测试集
% cd /mnt/code/matlab/data/csv-pace-2-pace/long
cd /home/test/Herui-Matlab/data/csv-pace-2-pace/long
names = BGetNamesFromFile('names.txt');
for i=1:length(names)
    try
        nums =  csv2cell(names{i});
        name = nums(1,:);
        nums = cell2mat(nums(2:end, :));
        % 默认倒数第二列为sbp，最后一列为dbp。舍弃所有取值为0的数据。
        sbpnums = nums(nums(:,end-1)~=0,:);
        dbpnums = nums(nums(:,end)~=0,:);
        write2CsvFiles('sbp', sbpnums, name, names{i}); 
        write2CsvFiles('dbp', dbpnums, name, names{i});
    catch e
        disp(e)
        disp(names{i})
        continue
    end
end
end

function write2CsvFiles(datatypestr, nums, name, filename)
[sbpStart, sbpEnd] = TGetLongestTenMinuteSegment(nums(:,1));
    if sbpStart ~= -1 
        %% 分别将训练集与剩下的测试集写入到csv文件内
        BWriteMats2CSV(fullfile(datatypestr, 'train', filename), nums(sbpStart:sbpEnd, :), name);
        BWriteMats2CSV(fullfile(datatypestr, 'test', filename), getTestSet(nums, sbpStart, sbpEnd), name);    
    end
end

function testsetnums = getTestSet(nums, trainStart, trainEnd)
    indexArray = true(1, length(nums));
    indexArray(trainStart:trainEnd) = false;
    testsetnums = nums(indexArray,:);
end