function TAnalysisMetadata( file_name )
%TANALYSISMETADATA 分析一组元数据
close all

meta_data = load(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, Constants.METADATA_FOLDER_NAME, file_name));
meta_data = meta_data.meta;
% 替换空值
empty_pos = cellfun(@isempty, meta_data);
meta_data(empty_pos) = {-1};

%% 所有有效数据的位置
all_valid = cell2mat(meta_data(:,12));
meta_data_valid = meta_data(all_valid, :);
% all_valid = cell2mat(meta_data(:,10)) == 0 &cell2mat(meta_data(:,11)) == 1 & cell2mat(meta_data(:,12));
meta_data = meta_data(cell2mat(meta_data(:,10)) == 0 &cell2mat(meta_data(:,11)) == 1 &~empty_pos(:, 5), :);
all_valid = true(length(meta_data), 1);

%% MSE的均值与方差
mse_statistics = [mean(cell2mat(meta_data_valid(:, 4))) std(cell2mat(meta_data_valid(:, 4)))];

%% 6小时测试集的位置
test_six_hour_strong_corr = (cell2mat(meta_data_valid(:,11)) == 3 & cell2mat(meta_data_valid(:,7)));
meta_data_valid_six_hour_pos = meta_data_valid(test_six_hour_strong_corr, :);
[~, indexes] = sort(cell2mat(meta_data_valid_six_hour_pos(:, 2)), 'descend');

% saveLongTimeComparationPics(meta_data(all_valid, 1));

%% 6小时测试集的相关性
test_six_hour = cell2mat(meta_data_valid(:,11)) == 3;
test_six_hour_corrs = meta_data_valid(test_six_hour, 2);

%% 1小时测试集的相关性
test_one_hour_corrs = meta_data(all_valid, 2);

%% 符合各类bhs标准的数据的位置
all_bhs = getAllBHSPoss(meta_data, all_valid);

%% 各类bhs标准数据量计数
bhs_count = [sum(all_bhs{1}) sum(all_bhs{2}) sum(all_bhs{3}) sum(all_bhs{4})] / sum(all_valid);

%% 达到aami标准的数据在所有的数据中所占的比例
aami_scale = sum(cell2mat(meta_data(all_valid, 9))) / sum(all_valid);

%% 各种时间比例对应的数据位置
time_scale_pos = getAllTimeScalePoss(meta_data, all_valid);

%% 各种时间比例对应的bhs比例
bhs_scale = getAllTimeScaleBHSScale(meta_data, all_valid, time_scale_pos);

%% 各种时间比例对应的符合aami的比例
ammi_scale = getAllTimeScaleAmmiScale(meta_data, all_valid, time_scale_pos);

%% 强相关数据数量
strong_corr_num =  sum(cell2mat(meta_data(all_valid, 7)));

%% 各种时间比例对应的误差和相关性
[mses, corrs] = getMeanMSEAndCorr(meta_data, all_valid, time_scale_pos);

%% 训练集极差与ca均方误差的关系曲线
mplot(cell2mat(meta_data(all_valid, 13)), cell2mat(meta_data(all_valid, 4)),1);

%% 测试集极差与均方误差的关系曲线
mplot(cell2mat(meta_data(all_valid, 5)), cell2mat(meta_data(all_valid, 4)),2);

%% 训练集极差/测试集极差与均方误差的关系曲线
mplot(cell2mat(meta_data(all_valid, 13))./cell2mat(meta_data(all_valid, 5)), cell2mat(meta_data(all_valid, 4)),3);

%% 训练集极差与相关性的关系曲线
mplot(cell2mat(meta_data(all_valid, 13)), cell2mat(meta_data(all_valid, 2)),4);

%% 测试集极差与相关性的关系曲线
mplot(cell2mat(meta_data(all_valid, 5)), cell2mat(meta_data(all_valid, 2)),5);

%% 训练集极差/测试集极差与相关性的关系曲线
mplot(cell2mat(meta_data(all_valid, 13))./cell2mat(meta_data(all_valid, 5)), cell2mat(meta_data(all_valid, 2)),6);

meta_data = meta_data(all_valid,:);
%% 保存到mat文件
save(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, Constants.METADATA_FOLDER_NAME, ['0_' file_name '.mat']), 'meta_data');

disp('debug')
end

function saveLongTimeComparationPics(csv_file_names)
set(0,'DefaultFigureVisible', 'off');
for index =  1:length(csv_file_names)
    mat_name = strrep(csv_file_names{index}, 'csv', 'mat');
    try
            load(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, 'results', Constants.DBP_FOLDER_NAME, 'RF', mat_name))
    catch e
        continue
    end
    fig = figure;
    plot(orig, 'o-'), hold on, plot(est, 'go-'), title([mat_name ,  ' ' , length(orig)])
    saveFigure(fig, Constants.APPENDIX_PICS, strrep(mat_name, '.mat',''));
    close all
end
set(0,'DefaultFigureVisible', 'on');
end

function pos = getValidataPos(meta_data)
    pos = false(size(meta_data, 1),1);
    for i = 1:length(pos)
        pos = meta_data(12);
    end
end

function poss = getAllBHSPoss(meta_data, valid_pos)
%% poss:长度为4的cell数组，1-4分别存放A/B/C/未达标这几种血压的位置序列
    poss = cell(1, 4);
    bhs_types = cell2mat(meta_data(:, 8));
    poss{1} = bhs_types == 0;
    poss{2} = bhs_types == 1;
    poss{3} = bhs_types == 2;
    poss{4} = bhs_types == 3;
end

function poss = getAllTimeScalePoss(meta_data, valid_pos)
%% poss:4*4数组，位置（i，j）存放i-1类别训练集，j-1类别测试集的位置序列, 行数与训练集长度成正比，列数与测试集长度成正比
    train_time_len = cell2mat(meta_data(:,10));
    test_time_len = cell2mat(meta_data(:,11));
    poss = cell(4);
    for col = 1:4
        for row = 1:4
            poss{col, row} = (train_time_len == col - 1) & (test_time_len == row - 1);
        end
    end
end

function bhscales = getAllTimeScaleBHSScale(meta_data, valid_pos, time_scale_pos)
%% bhscales:与time_sacle_pos大小相同的cell数组, 每个元素长度为4
    bhscales = cell(size(time_scale_pos));
    for col = 1:size(time_scale_pos, 1)
        for row = 1:size(time_scale_pos, 2)
            scales = zeros(1,4);
            for scale_index = 1:length(scales)                
                scales(scale_index) = sum(cell2mat(meta_data(time_scale_pos{col, row} & valid_pos, 8)) == scale_index - 1);
            end
            bhscales{col,row} = scales / sum(time_scale_pos{col, row} & valid_pos);            
        end
    end
end

function ammiscales = getAllTimeScaleAmmiScale(meta_data, valid_pos, time_scale_pos)
%% ammiscales:与time_sacle_pos大小相同的矩阵
    ammiscales = zeros(size(time_scale_pos));
    for col = 1:size(time_scale_pos, 1)
        for row = 1:size(time_scale_pos, 2)
              ammiscales(col ,row) = sum(cell2mat(meta_data(time_scale_pos{col, row} & valid_pos, 9)))  / sum(time_scale_pos{col, row}& valid_pos);
        end
    end
end

function [mses, corrs] = getMeanMSEAndCorr(meta_data, valid_pos, time_scale_pos)
%% mses/corrs:与time_sacle_pos大小相同的矩阵
    mses = zeros(size(time_scale_pos));
    corrs = mses;
    for col = 1:size(time_scale_pos, 1)
        for row = 1:size(time_scale_pos, 2)
              mses(col ,row) = mean(cell2mat(meta_data(time_scale_pos{col, row} & valid_pos, 4))) ;
              corrs(col ,row) = mean(cell2mat(meta_data(time_scale_pos{col, row} & valid_pos, 2))) ;
        end
    end
end

function mplot(x,y,figurenum)
 [~, xpos] = removeOutlier(x(:),1,1);
 [~, ypos] = removeOutlier(y(:),1,1);
 x=x(xpos&ypos);
 y=y(xpos&ypos);
 x=mapminmax(x(:)',0,1);
 y=mapminmax(y(:)',0,1);
 figure(figurenum)
 plot(x,y,'o')
end
