function isLegal = BIsSignalLegal(bp, ecg, ppg, rpos)
    isLegal = BIsSignalMostlyEffective(bp) && ...
        BIsSignalMostlyEffective(ecg) &&...
        BIsSignalMostlyEffective(ppg) &&...
        BIsEcgPosLegal(rpos);
end

function isLegal = BIsSignalMostlyEffective(sig)
    THEROLD = 0.4;
    isLegal = true;
    %% 先把所有的NaN替换掉
    sig = BRemoveNan(sig);
    %% 求一阶差分零值数
    d1 = (len(diff(sig)~=0)) ;
    %% 若一阶差分的非零率小于阈值，说明大部分数据为无效数据
    if d1/len(sig) < THEROLD
        isLegal = false;
        return
    end
end

function isLegal = BIsBPPosLegal(bppos)
    config = BReadConfig();
    isLegal = length(bppos) > config.timelength;
end

function isLegal = BIsEcgPosLegal(rpos)
    isLegal = BIsBPPosLegal(rpos);
end