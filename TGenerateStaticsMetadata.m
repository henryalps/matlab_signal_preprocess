function TGenerateStaticsMetadata(alth_type_str, feature_all_or_part)
%TGENERATESTATICSMETADATA 为实验结果生成统计元数据
%% 读取已有的元数据：sbp_meta dbp_meta, 它们里面存储了测试/训练集长度，以及csv文件名称
dbp_meta_data = load(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, Constants.METADATA_FOLDER_NAME, 'dbpmeta.mat'));
sbp_meta_data = load(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, Constants.METADATA_FOLDER_NAME, 'sbpmeta.mat'));
dbp_meta_data = dbp_meta_data.dbp_meta;
sbp_meta_data = sbp_meta_data.sbp_meta;

%% 读取每一组测试-训练集对应的实际/估计结果
dbp_meta = generateMetadata(dbp_meta_data, alth_type_str, Constants.DBP_FOLDER_NAME, feature_all_or_part);
sbp_meta = generateMetadata(sbp_meta_data, alth_type_str, Constants.SBP_FOLDER_NAME, feature_all_or_part);

%% 将计算出的参数存储到文件内，对于不同的机器学习方法和不同的血压类型使用不同的文件名称
meta = dbp_meta;
save(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, Constants.METADATA_FOLDER_NAME, [feature_all_or_part, '_', alth_type_str, '_', Constants.DBP_FOLDER_NAME]), 'meta')
meta = sbp_meta;
save(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, Constants.METADATA_FOLDER_NAME, [feature_all_or_part, '_', alth_type_str, '_', Constants.SBP_FOLDER_NAME]), 'meta')

end

function metadata_all_group = generateMetadata(meta_data, alth_type, blood_type_path, feature_all_or_part)
metadata_all_group = {};
for i=1:size(meta_data, 1)
    %% 如果发现训练/测试集长度为0，则跳过这一组数据
    if meta_data{i, 7} == 0 || meta_data{i, 8} == 0
        continue
    end
    file_path = fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, feature_all_or_part, blood_type_path, alth_type, strrep(meta_data{i, 1}, 'csv', 'mat'));
    metadata_one_group = generateMetadataForOneGroup(file_path);
    metadata_one_group{1} = meta_data{i,1};
    
    metadata_one_group{10} = getTimeLenType(meta_data{i, 7});    
    metadata_one_group{11} = getTimeLenType(meta_data{i, 8});
    
    metadata_one_group{13} = meta_data{i, 10};
    metadata_one_group{14} = meta_data{i, 11};
    metadata_all_group = [metadata_all_group; metadata_one_group];
end
end

function metadata_one_group = generateMetadataForOneGroup(file_path)    
    metadata_one_group = cell(1, 14);
    try
        est = load(file_path);
    catch e
        % 10. 是否存在训练结果
        metadata_one_group{12} = false;
        return
    end
    metadata_one_group{12} = true;
    orig = est.orig;
    est = est.est;
    
    % 求相关需要使用列向量
    orig = orig(:);
    est = est(:);
    %% 为每一组实际/估计结果计算参数：
    %-1: csv文件名称
    % 0. 相关性
    % 1. p值
    [metadata_one_group{2}, metadata_one_group{3}] = corr(orig, est);
    % 2. 均方误差MSE
    metadata_one_group{4} = sqrt(mse(orig,est));
    % 3. 测试集实际结果的极差
    metadata_one_group{5} = max(orig) - min(orig);
    % 4. 测试集实际结果的标准差
    metadata_one_group{6}  = std(orig);
    % 5. 相关性/p值是否大于0.6以及小于0.05
    metadata_one_group{7} = metadata_one_group{2} >= 0.6 && metadata_one_group{3} <= 0.05;
    % 6. BHS结果分类(A=0, B=1, C=2, 否=3)
    metadata_one_group{8} = getBHSType(orig, est);
    % 7. 是否符合AAMI(true/false)
    metadata_one_group{9} = isReachedAAMI(orig, est);
    % 8. 训练集时长类别（30/1/3/6 - 0/1/2/3）{10}
    % 9. 测试集时长类别（30/1/3/6 - 0/1/2/3 取最接近的）    {11}
    % 10. 是否存在训练结果 {12}
    % 11. 训练集的极差 {13}
    % 12. 训练集的标准差 {14}
end

function time_len_type = getTimeLenType(time_len)    
train_set_time_len = [30 * 60, 60 * 60, 3 * 60 * 60, 6 * 60 * 60] * getSampleRate(); %测试集长度列表
[~, time_len_type] = min(abs(train_set_time_len - time_len)) ;
time_len_type = time_len_type - 1;
end

function reach_aami = isReachedAAMI(org, est)
    org = abs(org-est);
    reach_aami = mean(org)<=10 && std(org)<=5;
end

function class = getBHSType(org, est)
    a = sum(abs(org - est) <= 5) / length(org) * 100;    
    b = sum(abs(org - est) <= 10) / length(org) * 100;
    c = sum(abs(org - est) <= 15) / length(org) * 100;
    if a>=60 && b>=85 && c>=95
        class = 0;
        return
    end
    if a>=50 && b>=75 && c>=90
        class = 1;
        return
    end
    if a>=40 && b>=65 && c>=85
        class = 2;
        return
    end
    class = 3;
end

