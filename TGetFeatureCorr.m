function [ corr_mat, p_mat ] = TGetFeatureCorr( valid_feature_name, valid_feature_val,  all_data,  all_feature_names )
%TGETFEATURECORR 此处显示有关此函数的摘要
%   此处显示详细说明
data_mat = [];
for i=1:size(valid_feature_name,1)
    pos = find(cellfun(@(s) strcmp(s, strtrim(valid_feature_name(i,:))) == 1, all_feature_names));
    tmp = all_data(:, pos);
    data_mat = [data_mat, tmp];
end

mat_len = size(data_mat, 2);
corr_mat = zeros(mat_len);
p_mat = zeros(mat_len);
for i=1:mat_len
    for j=1:mat_len
        [corr_mat(i,j), p_mat(i,j)] = corr(data_mat(:,i), data_mat(:,j));
    end
end
end

