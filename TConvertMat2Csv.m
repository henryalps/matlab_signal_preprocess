function TConvertMat2Csv()
%TCONVERTMAT2CSV 把mat文件都写入到csv文件，并保存元数据到metadata
set_time_len = [30 * 60, 60 * 60, 3 * 60 * 60, 6 * 60 * 60, 24 * 60 * 60] * getSampleRate(); %训练/测试集长度
load(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, ...
    Constants.METADATA_FOLDER_NAME, Constants.METADATA_MAT_INFO_FILE_NAME));
sbp_meta = {};
dbp_meta = {};
% for train_len = 1:length(set_time_len)
%     for test_len = 1:length(set_time_len)
train_len = 1;
test_len = 2;
    for index = 1:length(matNames)
        sigsName = matNames{index};
        sigsName = sigsName(1:end-length('.mat'));
        %% 先处理sbp
         try
            if sbpLen(index) ~= 0
            mat_file_path = fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV_OLD, 'sbpmat', matNames{index});
            sig = load(mat_file_path);
            sig = sig.sbpnums;
            isended = false;
            test_end = 0;
            while ~isended
                train_start = test_end + 1;                                
                csv_name = strcat(sigsName, '_', num2str(set_time_len(train_len)) , '_', num2str(set_time_len(test_len)) , '_',num2str(train_start), '.csv');
                [train_start, train_end, test_start, test_end, isended, islegal] = getSetsPos(sig, train_start, set_time_len(train_len), set_time_len(test_len));
                if isended || ~islegal
                    continue
                end             
                BWriteMats2CSV(fullfile(Constants.SBP_FOLDER_NAME, 'train', csv_name), sig(train_start:train_end,:), featureNames);
                
                BWriteMats2CSV(fullfile(Constants.SBP_FOLDER_NAME, 'test', csv_name), sig(test_start:test_end,:), featureNames);
                csv_file_path = fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, ...
                    Constants.DBP_FOLDER_NAME, 'sbp');
                % sig = sig(:, 1:end -1); % 这是为了求训练集极差的方便
                sbp_meta = [sbp_meta; getOneMetaGroup(csv_name, train_start, train_end, test_start, test_end, sig(:, 1:end -1), mat_file_path, csv_file_path)];        
            end
            end
         catch e
             disp(e.message)
             continue
         end
        %% 再处理dbp
        try
            if dbpLen(index) ~= 0
            mat_file_path = fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV_OLD, 'dbpmat', matNames{index});
            sig = load(mat_file_path);
            sig = sig.dbpnums;
            isended = false;
            test_end = 0;
            while ~isended
                train_start = test_end + 1;                                
                csv_name = strcat(sigsName, '_', num2str(set_time_len(train_len)) , '_', num2str(set_time_len(test_len)) , '_', num2str(train_start), '.csv');                
                [train_start, train_end, test_start, test_end, isended, islegal] = getSetsPos(sig, train_start, set_time_len(train_len), set_time_len(test_len));
                if isended || ~islegal
                    continue
                end
                BWriteMats2CSV(fullfile(Constants.DBP_FOLDER_NAME, 'train', csv_name), sig(train_start:train_end,:), featureNames);
                
                BWriteMats2CSV(fullfile(Constants.DBP_FOLDER_NAME, 'test', csv_name), sig(test_start:test_end,:), featureNames);
                csv_file_path = fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, ...
                    Constants.DBP_FOLDER_NAME, 'dbp');
                dbp_meta = [dbp_meta; getOneMetaGroup(csv_name, train_start, train_end, test_start, test_end, sig, mat_file_path, csv_file_path)];
            end
            end
        catch e
            disp(e.message)
            continue
        end
    end
    disp('debug')
%     end
% end
save(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, Constants.METADATA_FOLDER_NAME, 'sbpmeta.mat'), 'sbp_meta');
save(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, Constants.METADATA_FOLDER_NAME, 'dbpmeta.mat'), 'dbp_meta');
end

function [train_start, train_end, test_start, test_end, is_ended, is_legal] = getSetsPos(set, train_start, train_len, test_len)
%% 获取数组set中从train_start开始的一组训练集长度为train_len,测试集长度为test_len的数据
% 要求set的第一列为时间戳
    is_legal = false;
    is_ended = true;
    train_end = train_start; test_start = train_start; test_end = train_start;
    if (train_start >= size(set, 1) ) || (set(end, 1) - set(train_start,1) < train_len + test_len)  % 如果整体长度不够的话，直接返回 
        return
    end
    set = set(train_start:end, :);
    train_end = sum(set(:, 1) < set(1,1) + train_len);
    if train_end < 2
        is_ended = size(set, 1) <= 1;
        test_end = train_start + train_end - 1;        
        return
    end
    test_start = train_end + 1;
    test_end = sum(set(:,1) < set(test_start,1) + test_len);
    if test_end < test_start + 2      
        is_ended = test_end >= size(set, 1);
        test_end = test_end + train_start -1;
        return
    end
    is_ended = test_end >= size(set, 1);
    train_end = train_start + train_end - 1;
    test_start = train_start + test_start - 1;
    test_end = train_start + test_end - 1;
    is_legal = true;
end


function one_meta_group = getOneMetaGroup(csv_name, train_start, train_end, test_start, test_end, sig, sigsName, csv_path)
        one_meta_group = cell(1,9);
        one_meta_group{1} = csv_name; % 第一个位置存放文件名        
        one_meta_group{2} = csv_path; % 二位置存放csv文件路径
        one_meta_group{3} = train_start; % 三到六位置依次存放训练/测试集的起始和结束位置
        one_meta_group{4} = train_end;
        one_meta_group{5} = test_start;
        one_meta_group{6} = test_end;
        one_meta_group{7} = sig(train_end, 1) - sig(train_start, 1); % 七到八位置存放训练/测试集的时长               
        one_meta_group{8} = sig(test_end, 1) - sig(test_start, 1);
        one_meta_group{9} = sigsName; % 九位置存放mat路径   
        one_meta_group{10} = max(sig(train_start:train_end, end)) - min(sig(train_start:train_end, end)); %十至十一位置存放均值与标准差-需保证最后一列为训练集
        one_meta_group{11} = std(sig(train_start:train_end, end));
end
