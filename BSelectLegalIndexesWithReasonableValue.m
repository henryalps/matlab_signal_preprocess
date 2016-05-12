function indexes = BSelectLegalIndexesWithReasonableValue(bp, indexes, type)
%%
%     if type == Constants.TYPE_SBP
%         indexes = indexes(bp(indexes) <= Constants.MAX_SBP & bp(indexes) >= Constants.MIN_SBP);
%     elseif type == Constants.TYPE_DBP        
%         indexes = indexes(bp(indexes) <= Constants.MAX_DBP & bp(indexes) >= Constants.MIN_DBP);
%     else
%     end
    bp = bp(:);
    [~, idx] = removeOutlier(bp(indexes), 1, 10);
    %% 将针对bp(indexes)的idx还原到bp上
    indexes = indexes(idx);
end
