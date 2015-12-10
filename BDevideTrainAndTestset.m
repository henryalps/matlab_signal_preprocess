function [trainsetpos, testsetpos] =BDevideTrainAndTestset(sbps, dbps, ratio)
%% 对一对收缩压与舒张压数组，随机生成一组训练集与测试集（或训练集与验证集）, 其中训练集在全部数据中所占比例为ratio。
%% 如果无法生成，则返回能生成的大于ratio的最小ratio'中的ratio'所对应的训练/测试（验证）集

% 1. numel 用来找到数组的长度（TODO 和length有何区别？）
% 2. tabulate 用来求矩阵中某一元素的出现频率分布表
% 3. cellstr 将字符数组转为cell
% 4. 用true()与false()来新建指定尺寸的逻辑数组
trainsetpos = false(1, length(sbps));
testsetpos = trainsetpos;
% 根据ratio计算理想的训练集与测试集大小
ideal_trainset_size = ceil(length(sbps) * ratio);
% 先把sbps和dbps组合成复数，再计算频数，最后在频数大于1的sbp-dbp组合中随机选取测试集
sbps = sbps(:);
dbps = dbps(:);
pairs = sbps + dbps * 1i;
% 因为tabulate无法对复数求频数，所以先将复数数组转化为字符串数组
pairs = num2str(pairs);
% 求频数并找到所有大于1的位置
tbl = tabulate(pairs);
% 将字符矩阵转换为cell
pairs = cellstr(pairs);
% 正序遍历一遍，保证训练集包含所有类别的数据
for i=1:length(tbl(:,2))
    poss = find((cellfun(@(x) strcmp(x, tbl{i,1}), pairs)) == true);
    % 随机选择一个位置，添加到训练集中
    trainsetpos(poss(randi(numel(poss)))) = true;
end
% 如果在正序遍历一遍后还没有达到理想的训练集大小，则直接在剩下的数据中取差值数量的数据加入到训练集内
diff_size = ideal_trainset_size - sum(trainsetpos);
if diff_size > 0
    poss = find(~trainsetpos);
    idx = randperm(numel(poss));
    trainsetpos(poss(idx(1:diff_size))) = true;
end
testsetpos(~trainsetpos) = true;
end