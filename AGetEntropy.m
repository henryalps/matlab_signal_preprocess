function entropy = AGetEntropy(sig)
%% 对每一列求熵
    sig = sig.^2;
    sig = sig./(ones(size(sig,1),1) * sum(sig));
    %from stackoverflow 22075285
    entropy = sum(- sig.*log2(sig));
end