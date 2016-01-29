function [features,featurenames,sbps,dbps] ...
    =  BGetFeatureAndBpGroups(bp, ecg, ppg, ...
        sbpann, dbpann, rpos, ppgpeaks, ppgonsets, ppgfeatures, ppgfeaturenames, pwt)
    %%
    % OUTPUT
    % features  [k*N]矩阵 k为特征数，N为窗口数
    % featurenames {k*1} 元胞数组 存储所有特征名
    % sbps/dbps [1*N]矩阵 N为窗口数 平均sbps/dbps
    
    segtimelen = 60; % 分段长度1min
    bpseglen = 5; % 血压量化间隔为5

    %% 在BP中找到所有合法的信号段位置 - 添加了SBP/DBP区分算法后试图取消该步骤，失败
     [pos,~] = getAllLegalSegPos(bp, {dbpann, sbpann}, segtimelen);
    %% 在ECG中找到所有合法的信号段位置
    [tmp,~] = getAllLegalSegPos(ecg, {rpos}, segtimelen);
     pos = tmp & pos;    
    %% 在PPG中找到所有合法的信号段位置 不使用PWT作为标准，因为PPG和ECG并未完全同步
    % - 添加了Onset位置估计算法后试图取消该步骤，失败
     [tmp,seglen] = getAllLegalSegPos(ppg, {ppgpeaks(:,1), ppgonsets(:,1)}, segtimelen);
     pos = tmp & pos;    
    %% 转化为绝对位置
    tmp = (0:length(tmp)) * seglen + 1;
    if length(tmp) >= 2
        tmp(2:end) = tmp(2:end) - 1;
    end
    pos = tmp(pos);
    %% 当最后一个窗口越界时，舍弃之
%     if pos(end) + seglen > length(bp)
%         pos = pos(1:end - 1);
%     end
    
    %% 对所有合法的信号段，分别获取特征-血压值对
    sbps = zeros(1, length(pos));
    dbps = sbps;
    % 特征排列顺序：{HR特征 PWTT PPG波形特征 PPG统计特征 }
    features = zeros(4 + 1 + 21 + 20, length(pos));
    for i=1:length(pos)
       %% 对每一个有效信号窗，计算窗内血压的均值
        bp_mean = bp(sbpann(sbpann > pos(i) & sbpann < pos(i) + seglen));
        if ~isempty(bp_mean)
            sbps(i) = mean(bp_mean);
        end
        bp_mean = bp(dbpann(dbpann > pos(i) & dbpann < pos(i) + seglen));
        if ~isempty(bp_mean)
            dbps(i) = mean(bp_mean);
        end
       %% 对每一个有效信号窗，计算窗内PWTT的均值
        pwtt_mean = replaceNanByZero(mean(pwt(pwt(:,1) > pos(i) & pwt(:,1) < pos(i) + seglen, 2)));
       %% 对每一个有效信号窗，获取窗内PPG波形特征均值
        ppgwfeatures = getLegalSigMeanValues(ppgfeatures, pos(i), pos(i) + seglen);
       %% 对每一个有效信号窗，计算窗内PPG统计特征。窗的帧宽度为5s。
        [ppgsfeatures, ppgsfeaturenames] = ...
        BGetAllStatisticFeaturesOfAWindow(ppg(pos(i):pos(i) + seglen), bpseglen * getSampleRate());
       %% 对每一个有效信号窗，计算HR特征
        validrpos = replaceNanByZero(rpos(rpos>pos(i) & rpos<pos(i) + seglen));
        [hr_miu, hr_delta, hr_iqr, hr_skew] ...
            = AGetStatisticParas(removeOutlier(diff(validrpos), 1, 10));
        features(:,i) = [hr_miu, hr_delta, hr_iqr, hr_skew,...
            pwtt_mean, ppgwfeatures(:)', ppgsfeatures(:)']' ;
    end
%     % 将血压值量化到以5为量化间隔的区间上，以便分类 - 换用随机森林拟合器后，取消量化
%     sbps = AGetDiscretedSig(sbps, bpseglen);
%     dbps = AGetDiscretedSig(dbps, bpseglen);
    featurenames = [{'hr_miu', 'hr_delta', 'hr_iqr', 'hr_skew'},{'pwtt_mean'},...
        ppgfeaturenames,ppgsfeaturenames];
end

function [pos,seglen] = getAllLegalSegPos(sig, marker, segtimelen)
%%
% sig - 时间长度为n分钟，总长度为n*60*SAMPLERATE的信号 
% marker - m个cell数组，每个数组的长度接近于约n*segtimelen*SAMPLERATE
% - 标定数据(每一个marker的值都对应于一个特征点在sig中的位置) m为标定数据的路数，比如血压有SBP与DBP两路标定。
% segtimelen - 把信号分为k段，每一段的时长都为segtimelen（秒）。若有超出，则丢弃。
   
    seglen = segtimelen * getSampleRate();
    segnum = floor(length(sig) / seglen);
    posrange = [(0:segnum - 1); (1:segnum)]' * seglen;
    
    % 初始化对比结果
    pos = ones(segnum, 1);
    for i=1:length(marker)
            % 1 将位置范围扩展为两个矩阵 lowRange/upRange
            lowRange = posrange(:,1) * ones(1, length(marker{i}));
            upRange = posrange(:,2) * ones(1, length(marker{i}));
            % 2 扩展为矩阵
            tmp = ones(segnum ,1) * marker{i}(:)';
            % 3 对比后确定在某一范围内的标定的数量
            tmp = sum((tmp >= lowRange) & (tmp < upRange), 2);
            tmp = tmp / segtimelen;
            % 4 某个位置范围可用的前提是范围内的所有标定都有足够数量
            pos = pos & (tmp >= Constants.THEROLD_ANN_LEN_MIN_SCALE_FRAME);
    end
end

function legalsigmeanvalue = getLegalSigMeanValues(sigcells, lowRange, upperRange)
%%
% INPUT 
% sigcells 元胞数组，每个元胞中都是一个?*2矩阵，第一列是位置，第二列是值
% OUTPUT N*1矩阵，每个元胞中特定范围数据的均值
    legalsigmeanvalue = zeros(length(sigcells), 1);
    for i=1:length(legalsigmeanvalue)
        tmp = sigcells{i};
        tmp = tmp((tmp(:,1)>lowRange) & (tmp(:,1)<upperRange),:);
        if ~isempty(tmp)
            legalsigmeanvalue(i) = mean(tmp(:,2));
        else
            legalsigmeanvalue(i) = 0;
        end
    end
end

function val = replaceNanByZero(val)
    val(isnan(val)) = 0;
end