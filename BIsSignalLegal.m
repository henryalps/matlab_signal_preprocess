function isLegal = BIsSignalLegal(sig)
    THEROLD = 0.3;
    %% 先把所有的NaN替换掉
    
    %% 求一阶差分零值数
    d1 = (len(diff(sig)~=0)) ;
    %% 若一阶差分的非零率小于阈值，说明大部分数据为无效数据
    if d1/len(sig) < THEROLD
        isLegal = FALSE;
        return
    end
end