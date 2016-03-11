function TWrite2CsvFiles(pathAppendix, datatypestr, nums, name, filename)
%% 将一组逐拍数据分成训练集与测试集后写入到csv文件内
% pathAppendix - csv路径前缀
% datatypestr - ‘sbp'/'dbp'
% nums - 数据
% names - 数据名称
% filename - 带csv的文件名称
data_seged = breakDataIntoSegments(nums);
for i = 1:length(data_seged)
    nums = data_seged{i};
    [sbpStart, sbpEnd] = TGetShortestTenMinuteSegment(nums(:,1));
    if sbpStart ~= -1 
        %% 分别将测试集与剩下的训练集写入到csv文件内
        BWriteMats2CSV(fullfile(pathAppendix, datatypestr, 'test', strcat(num2str(i), filename)), nums(sbpStart:sbpEnd, :), name);
        BWriteMats2CSV(fullfile(pathAppendix, datatypestr, 'train', strcat(num2str(i), filename)), getTestSet(nums, sbpStart, sbpEnd), name);    
    end
end
end

function data_seged = breakDataIntoSegments(data)
%% 将信号以THEROLD_TOTAL_SET_WIN_TIME为时间单位进行拆分，
 %  如果一段信号长度没有达到THEROLD_TRAIN_SET_WIN_TIME，则舍弃之
 rang = data(end, 1) - data(1, 1);
 if mod(rang, Constants.THEROLD_TOTAL_SET_WIN_TIME * getSampleRate()) >= Constants.THEROLD_TRAIN_SET_WIN_TIME * getSampleRate()
     data_seged = cell(ceil(rang/(Constants.THEROLD_TOTAL_SET_WIN_TIME * getSampleRate())), 1);
 else
     data_seged = floor(ceil(rang/(Constants.THEROLD_TOTAL_SET_WIN_TIME * getSampleRate())), 1);
 end
 pos_last = 1;
 for i = 1:length(data_seged)
     pos = sum(data(:,1) < Constants.THEROLD_TOTAL_SET_WIN_TIME * getSampleRate() * i);
     data_seged{i} = data(pos_last:pos, :);
     pos_last = pos;
 end
end

function testsetnums = getTestSet(nums, trainStart, trainEnd)
    indexArray = true(1, length(nums));
    indexArray(trainStart:trainEnd) = false;
    testsetnums = nums(indexArray,:);
end