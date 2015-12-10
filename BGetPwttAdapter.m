function pwtt = BGetPwttAdapter(ecg, rpos, ppg_peak)
%% 得到PWTT
% INPUT
% ecg - 1*N / N*1向量 心电数据
% rpos - 1*M /M*1向量 R波的位置
% ppg_peak - P*2向量 第一列为PPG波峰（或10%,20%...90%点）的位置，第二列为数值

%% 1 处理输入信号使其可被原始方法所接受
ecg = ecg(:);
ecg_peak = [rpos(:), ecg(rpos)];

%% 2 计算PWT
[pwtt, ecg_peak_used, ppg_used] = ...
    computeTimeInterval(ecg_peak, ppg_peak, 0, 10000);

%% 3 去除统计异常点
pwtt = removeOutlier(pwtt, 2, 10);
end