classdef Constants
    properties (Constant)
        THEROLD_STD = 0.1
        THEROLD_ANN_LEN_MIN_SCALE=0.6 % 标记长度占总时间长度的最小比例
        
        TYEP_SBP = 0
        TYPE_DBP = 1
        
        % TODO 找到合法的血压范围
        MAX_SBP = 150
        MAX_DBP = 120
        
        MIN_SBP = 60
        MIN_DBP = 20
    end
end

