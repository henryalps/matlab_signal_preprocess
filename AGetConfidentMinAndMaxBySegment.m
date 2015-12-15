function [minVal,maxVal,hasCutoff] = AGetConfidentMinAndMaxBySegment(sig)
%% 通过分段+中位数的方式获取长时信号的合理最大与最小值
% OUTPUT
% 信号的‘合理’最大与最小值
% hasCutoff 1*1 bool 信号是否有严重截止失真
    SEGNUM = getSampleRate();
    THEROLD = 50; % 认为出现了截止失真的阈值
    sigSeg = buffer(sig, floor(length(sig)/SEGNUM));
    sigSeg = sigSeg(:, 1:SEGNUM)';
%     sig = sig(1:end - mod(end, SEGNUM));
%     sigSeg = reshape(sig, SEGNUM, length(sig) / SEGNUM);
    
    minVals = min(sigSeg,[],2);
    maxVals = max(sigSeg,[],2);
    
    %%判断截止失真
    tblmin = tabulate(minVals);
    tblmax = tabulate(maxVals);
    hasCutoff = max(tblmin(:,3)) >= THEROLD || max(tblmax(:,3)) >= THEROLD;  
    %
    
    minVal = median(minVals);
    maxVal = median(maxVals);
end