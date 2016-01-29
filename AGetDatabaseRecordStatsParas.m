function AGetDatabaseRecordStatsParas(mat_names_file_name)
%% 统计下载且处理的数据的时间分布与人群分布
%% 在写这个方法时已经有的数据：
% - 筛出的546个segment，segment长度在7500（60s）~608000（81min）之间
% - 筛出的285个segment，segment长度在805875 （107min）～12281750（1637.6min）之间
% - 存储subject_id/segment_num/length对应关系的三个mat文件 shorttime/longtime/all
% data.mat
%
%
%
%% 加载记录被筛选出数据的名称的文件
load(mat_names_file_name)
%% 加载记录名称与subject_id关系的文件
load('alldata.mat')
times = cell2mat(data(:,4));
%% 获取数据的subject_id以及时长
timelen = zeros(2, max(times) - min(times) + 1);
POOL = parpool('local', 8);
parfor i=1:length(timelen)
    disp(i)
    timelen(:,i) = [i + min(times) - 1; ...
        sum(times==i + min(times) - 1)];;
end
save('timelen.mat','timelen');
delete(POOL)
%% 绘制时长分布图
%% 打印subject_id的统计结果，并绘制不同subject_id名下的数据段数分布图
%% 保存
end