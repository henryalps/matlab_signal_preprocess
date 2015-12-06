function [miu,delta,iqrg,skew] = AGetStatisticParas(sig)
    miu = mean(sig);
    delta = std(sig,1);
    iqrg = iqr(sig);
    skew = skewness(sig);
end