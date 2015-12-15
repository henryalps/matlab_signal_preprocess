function selected = BSimplelySelectSigByDistribute(bp,ecg,ppg,bpann,rpos,tm)
    selected = isBpLegalByBpann(bp,bpann,floor(tm(end)))...
        && isECGLegalByRPos(ecg,rpos,floor(tm(end)))...
        && isPPGLegalByMinAndMax(ppg);
end

function isLegal = isBpLegalByBpann(bp,bpann,timelen)
    %% 1. bpann length < timelen, illgal
    if length(bpann)<timelen
        isLegal = false;
        return
    end
    %% 2. confident min and max
    [minVal,maxVal] = AGetConfidentMinAndMaxBySegment(bp);
    isLegal = isSigLegalWithMinAndMax(minVal,maxVal);
    if ~isLegal
        return
    end
end

function isLegal = isECGLegalByRPos(ecg,rpos,timelen)
    %% 1. rpos length< timelen, illgal
    if length(rpos)<timelen
        isLegal = false;
        return
    end
    %% 2. confident min and max
    [minVal,maxVal] = AGetConfidentMinAndMaxBySegment(ecg);
    isLegal = isSigLegalWithMinAndMax(minVal,maxVal);
    if ~isLegal
        return
    end
    %% 3. If the ecg val on rpos changes too frequently, not legal
    if std(ecg(rpos),1) > (maxVal - minVal) * Constants.THEROLD_STD
        isLegal = false;
        return
    end
        
end

function isLegal = isPPGLegalByMinAndMax(ppg)
    [minVal,maxVal] = AGetConfidentMinAndMaxBySegment(ppg);
    isLegal = isSigLegalWithMinAndMax(minVal,maxVal);
end

function isLegal = isSigLegalWithMinAndMax(minVal,maxVal)
    isLegal = minVal ~= maxVal;        
end

