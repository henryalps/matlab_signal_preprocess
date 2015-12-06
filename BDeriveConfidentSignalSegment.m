function [confidentPos] = BDeriveConfidentSignalSegment(origSig)
%% 求置信区间
% [~,~,muci] = ttest(origSig);
muci = [prctile(origSig,5) prctile(origSig,95)];
%% %% 求全部处在置信区间内的数据段
confidentPos = (origSig >= muci(1)) & (origSig <= muci(2));
end