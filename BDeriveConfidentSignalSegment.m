function [confidentPos] = BDeriveConfidentSignalSegment(origSig)
%% 求置信区间
[~,~,muci,~] = normfit(origSig);
%% 求全部处在置信区间内的数据段
confidentPos = (origSig >= muci(1)) && (origSig <= muci(2));
end