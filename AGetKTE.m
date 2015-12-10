function kte = AGetKTE(data)
    %% 对data矩阵的每一列求KTE值
    if size(data,1)==1 && size(data,2)>1
        data=data';
    end
    kte = data(2:end-1,:).^2 - data(1:end-2,:).*data(3:end,:);
end