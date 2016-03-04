function [ sig_len_list ] = TGetSigLenList( mat_name_list )
%TGETSIGLENLIST 获取mat_name_list中记录的mat文件对应的信号长度
%并将其保存到mat文件内。mat文件名为total_len，矩阵的第一列为总秒数，第二列为总分数，第三列为总小时数。
%   mat_name_list - 一个cell数组，里面是文件名列表
%   sig_len_list - 数组对应的各个文件对应的信号长度
sig_len_list = zeros(length(mat_name_list), 3);
for i = 1:length(mat_name_list)
    try
        load(mat_name_list{i})
        sig_len_list(i, 1) = length(bp) / getSampleRate();
        sig_len_list(i, 2) = sig_len_list(i, 1) / 60;
        sig_len_list(i, 3) = sig_len_list(i, 2) / 60;
    catch e
        continue
    end
end
save('total_len.mat', 'sig_len_list');
end

