function [features, featureNames] = ...
    BGetAllStatisticFeaturesOfAWindow(sigInWin, frameLen)
%% 对一个长度任意的窗口，将其以frameLen为单位分为k帧，再以帧为最小单位计算一系列统计参数
% INPUT
% sigInWin 1*N / N*1 矩阵 
    featureNames = {'kte_miu', 'kte_delta', 'kte_iqr', 'kte_skew',...
        'h_miu','h_delta','h_iqr','h_skew',...
        'loge_ar_1','loge_ar_2','loge_ar_3','loge_ar_4','loge_ar_5',...
        'loge_delta','loge_iqr',...
        'ppg_fed_ar_1','ppg_fed_ar_2','ppg_fed_ar_3','ppg_fed_ar_4','ppg_fed_ar_5'};
    features=zeros(1,length(featureNames));
    %% 1 将信号分段
     sigInWin = sigInWin(1:floor(length(sigInWin) / frameLen) * frameLen);
     segs = reshape(sigInWin, frameLen, []);
    %% 2 对每一段信号求KTE
     ktes = AGetKTE(segs);
    %% 3 对KTE矩阵的每一列，计算4个统计值，得到4组统计值
     [miu,delta,iqrg,skew] = AGetStatisticParas(ktes);
    %% 4 对每组统计值求均值
    features(1:4) = [mean(miu), mean(delta), mean(iqrg), mean(skew)];
    %% 5 对每一段信号求归一化补零FFT TODO 根据frameLen动态计算FFT长度
    ffts = fft(segs, 1024);
    normffts = (abs(ffts)).^2 ./(ones(size(ffts, 1), 1) * (sum(abs(ffts).^2)));
    %% 6 对每一段信号的FFT求熵值
    h_s = AGetEntropy(normffts); % 每一列都是一个信号段的熵值
    %% 7 对所有熵值求统计参数
    [miu,delta,iqrg,skew] = AGetStatisticParas(h_s');
    features(5:8) = [miu,delta,iqrg,skew];
    %% 8 对每一段信号平方求和后求log值,再求序列的ar系数以及统计参数。
    segs = log2(sum(segs.^2));
    features(9:13) = AGetARModelParas(segs);
    [~,delta,iqrg,~] = AGetStatisticParas(h_s');
    features(14:15) =[delta,iqrg];
    %% 9 对整个信号求频谱包络，再求包络的ar系数
    envelop = abs(sigInWin) / length(sigInWin);
    envelop = abs(hilbert(envelop(1:floor(length(envelop)/2))));
    features(16:20) = AGetARModelParas(envelop);
end