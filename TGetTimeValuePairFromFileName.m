function [ pairs ] = TGetTimeValuePairFromFileName( file_name, bp_type )
%TGETTIMEVALUEPAIRFROMFILENAME 根据文件名找到对应的测试信号起始与结束位置，返回时间-值序列
%   此处显示详细说明
if bp_type == Constants.TYPE_SBP
    load(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, ...
        Constants.METADATA_FOLDER_NAME, 'sbpmeta.mat'))
        meta = sbp_meta;
     load(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV,...
         Constants.FOLDER_NAME_EST_RESULT_ALL_FEATURE,...
         Constants.SBP_FOLDER_NAME, ...
         Constants.APPENDIX_LF, [file_name, '.mat']));
     est_lf_all = est;
     
     load(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV,...
         Constants.FOLDER_NAME_EST_RESULT_ALL_FEATURE,...
         Constants.SBP_FOLDER_NAME, ...
         Constants.APPENDIX_RF, [file_name, '.mat']));     
     est_rf_all = est;
     
     load(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV,...
         Constants.FOLDER_NAME_EST_RESULT_LESS_FEATURE,...
         Constants.SBP_FOLDER_NAME, ...
         Constants.APPENDIX_LF, [file_name, '.mat']));     
     est_lf_less = est;
     
else    
    load(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, ...
        Constants.METADATA_FOLDER_NAME, 'dbpmeta.mat'))    
          meta = dbp_meta;
     load(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV,...
         Constants.FOLDER_NAME_EST_RESULT_ALL_FEATURE,...
         Constants.DBP_FOLDER_NAME, ...
         Constants.APPENDIX_LF, [file_name, '.mat']));     
     est_lf_all = est;
     
     
     load(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV,...
         Constants.FOLDER_NAME_EST_RESULT_ALL_FEATURE,...
         Constants.DBP_FOLDER_NAME, ...
         Constants.APPENDIX_RF, [file_name, '.mat']));     
     est_rf_all = est;
     
     load(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV,...
         Constants.FOLDER_NAME_EST_RESULT_LESS_FEATURE,...
         Constants.DBP_FOLDER_NAME, ...
         Constants.APPENDIX_LF, [file_name, '.mat']));     
     est_lf_less = est;
     
end

for i=1:size(meta,1)
    if strcmp(meta{i, 1},strcat(file_name, '.csv')) == 1
        mat_name = meta{i, 9};
        test_start = meta{i,5};
        test_end = meta{i,6};
        break;
    end
end

load(mat_name);
if bp_type ==  Constants.TYPE_SBP
    nums =sbpnums;
else
    nums = dbpnums;
end
times = nums(test_start:test_end, 1);
pairs=[times(:)'; orig; est_lf_all; est_rf_all; est_lf_less];

end
