function result = AGetDiscretedSig(data, unit)
%% 对data以unit为单位长度进行离散化
% data [1*k / k*1]矩阵
% unit 1*1 大于0的数字
result = (floor(data / unit) + 0.5)* unit;
end