function entropy = AGetEntropy(sig)
    sig = sig.^2;
    sig = sig/sum(sig);
    %from stackoverflow 22075285
    entropy = sum(- sig.*log2(sig));
end