classdef Constants
    properties (Constant)
        THEROLD_STD = 0.1
        THEROLD_ANN_LEN_MIN_SCALE=0.5 % 标记一个窗口内的特征数组长度占总时间长度的最小比例                
        THEROLD_ANN_LEN_MIN_SCALE_FRAME=0.1 % 标记一帧内的特征数组长度占总时间长度的最小比例    
        TYEP_SBP = 0
        TYPE_DBP = 1
        TYPE_PPG_PEAK = 2
        
        % TODO 找到合法的血压范围
        MAX_SBP = 150
        MAX_DBP = 120
        
        MIN_SBP = 60
        MIN_DBP = 20
    end
end

