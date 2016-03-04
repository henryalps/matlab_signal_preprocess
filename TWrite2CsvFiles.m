function TWrite2CsvFiles(pathAppendix, datatypestr, nums, name, filename)
%% 将一组逐拍数据分成训练集与测试集后写入到csv文件内
% pathAppendix - csv路径前缀
% datatypestr - ‘sbp'/'dbp'
% nums - 数据
% names - 数据名称
% filename - 带csv的文件名称
[sbpStart, sbpEnd] = TGetLongestTenMinuteSegment(nums(:,1));
    if sbpStart ~= -1 
        %% 分别将训练集与剩下的测试集写入到csv文件内
        BWriteMats2CSV(fullfile(pathAppendix, datatypestr, 'train', filename), nums(sbpStart:sbpEnd, :), name);
        BWriteMats2CSV(fullfile(pathAppendix, datatypestr, 'test', filename), getTestSet(nums, sbpStart, sbpEnd), name);    
    end
end

function testsetnums = getTestSet(nums, trainStart, trainEnd)
    indexArray = true(1, length(nums));
    indexArray(trainStart:trainEnd) = false;
    testsetnums = nums(indexArray,:);
end