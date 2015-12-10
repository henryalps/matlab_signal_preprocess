function [sbpann,dbpann,isLegal] = AExtractSbpAndDbpFromBp(bp, bpann,tm)
    %% 将本来在一个数组中的收缩/舒张压位置分散到两个数组中。
    %% 数组中可能只有舒张压位置，也可能只有收缩压位置
    % OUTPUT
    % sbpann [n*1] 收缩压
    % dbpann [m*1] 舒张压
    % isLegal 1*1 bool 信号是否有效
    
    % 1 获取血压的‘合理’最大与最小值
    [minbp, maxbp,isLegal] = AGetConfidentMinAndMaxBySegment(bp);
    isLegal = ~isLegal;
    if ~isLegal
        return
    end
    
    % 2 计算bpann混合数组的标准差
    annstd = std(bp(bpann), 1);
    
    % 3 将标准差与血压极差×阈值进行对比，如果偏大，则说明数组中同时有两种血压，否则说明只有一种
    if annstd  > (maxbp - minbp) * Constants.THEROLD_STD
        % 3.5 如果同时有两种，那么利用包络将两种血压分离开，再用较长者的长度筛选一下，确定是否有效
        [bpevpup, bpevpdown] = envelope(bp,30,'peak');
        bpevp = (bpevpup + bpevpdown) / 2;
        bpevp = bpevp(bpann);
        sbpann = bp(bpann) > bpevp;
        dbpann = ~sbpann;
        
        sbpann = bpann(sbpann);
        dbpann = bpann(dbpann);
        if max(length(sbpann), length(dbpann)) < tm(end)
            isLegal = false;
            return
        end
        
        if length(sbpann) > length(dbpann)
            [sbpann, dbpann] = BDistractSbpAndDbpFromBp(bp, sbpann, Constants.TYEP_SBP);
        else
            [sbpann, dbpann] = BDistractSbpAndDbpFromBp(bp, dbpann, Constants.TYPE_DBP);
        end
    else
        % 4 如果偏小，说明只有一种血压，直接输入分离方法
        [sbpann, dbpann] = BDistractSbpAndDbpFromBp(bp, bpann);
    end 
end