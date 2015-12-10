function [miu,delta,iqrg,skew] = AGetStatisticParas(sig)
%% 对矩阵的每一列求四个统计学特征
    if isempty(sig)
        sig = 0;
    end
    miu = mean(sig,1);
    delta = replaceNanWithZero(std(sig,1));
    iqrg = replaceNanWithZero(iqr(sig));
    skew = replaceNanWithZero(skewness(sig));
    skew(isnan(skew))=0;
end

function dataWithoutNan = replaceNanWithZero(data)
    dataWithoutNan = data;
    dataWithoutNan(isnan(dataWithoutNan))=0;
end