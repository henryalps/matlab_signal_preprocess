classdef Constants
    properties (Constant)
        THEROLD_STD = 0.1
        THEROLD_ANN_LEN_MIN_SCALE=0.5 % 标记一个窗口内的特征数组长度占总时间长度的最小比例                
        THEROLD_ANN_LEN_MIN_SCALE_FRAME=0.1 % 标记一帧内的特征数组长度占总时间长度的最小比例            
        THEROLD_PACE_TO_PACE_TIME = 30 * 60 % 标记逐拍数据时长的最小值 @@同步@@
        THEROLD_TOTAL_SET_WIN_TIME = 12 * 60 * 60 % 总数据时间长度不超过12小时
        THEROLD_TRAIN_SET_WIN_TIME = 6 * 60 * 60 % 令测试集时间长度为6小时(变量名有误)
        THEROLD_TRAIN_SET_WIN_TIME_MIN_SCALE = 0.1 % 测试集有效数据最低比例(变量名有误)
        
        TYEP_SBP = 0
        TYPE_DBP = 1
        TYPE_PPG_PEAK = 2
        
        % TODO 找到合法的血压范围
        MAX_SBP = 150
        MAX_DBP = 120
        
        MIN_SBP = 60
        MIN_DBP = 20
        
        METADATA_MAT_INFO_FILE_NAME = 'mats.mat'
        METADATA_FOLDER_NAME = 'metadata'
        SBP_FOLDER_NAME = 'sbpl6h' % @@同步@@
        DBP_FOLDER_NAME = 'dbpl6h' % @@同步@@
        APPENDIX_LONG_RECORD = '/home/test/WFDBDATA/3.new/'
        APPENDIX_LONG_RECORD_CSV = '/home/test/Herui-Matlab/data/csv-long'
        APPENDIX_PACE_2_PACE_LONG_CSV = '/home/test/Herui-Matlab/data/csv-pace-2-pace/long'
        APPENDIX_PACE_2_PACE_LONG_LONG_CSV = '/home/test/Herui-Matlab/data/csv-pace-2-pace/long-long'
        APPENDIX_TEST = '/home/henryalps/software/csv'
        APPENDIX_PICS = '/home/test/Herui-Matlab/PAPER/pics-LF'
        
        APPENDIX_LF = 'LF'
        APPENDIX_RF = 'RF'
        APPENDIX_NN = 'NN'
        
        MAX_HR = 180
        MIN_HR = 40
    end
end

