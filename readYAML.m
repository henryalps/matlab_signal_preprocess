function readYAML(fileName)
%% readYAML(fileName) is used to read all the files listed in the file with 'fileName',
%% and extact the data infomation 
% POOL = parpool('local',8);
names = BGetNamesFromFile(fileName);
dataFileName = cell(length(names), 1);
% 记录着所有有效的数据文件的位置
effectiveDataFileNames = true(1, length(dataFileName));
% 得到目前已经处理过的数据
currentnames = BGetNamesFromFile(strcat(Constants.APPENDIX_LONG_RECORD, 'currentnames'));
for i=1:length(names)
    try        
          %% 1.读取fileName中记录的每一个yaml文件名所对应的一组数据，获得abp，ecg和ppg
           [dataFileName{i},...
            ecgPos, ppgPos, abpPos,...
            ecgGain, ppgGain, abpGain,...
            ~,~,~,...
            ecgBaseline, ppgBaseline, abpBaseline] = analysisYAML(names{i});
            % 如果发现已经检测到了这个文件，就直接跳过
            if(~isempty(find(strncmp(dataFileName{i}, currentnames, length(dataFileName{i})),1))) 
                continue
            end
            % 加载文件并转换为真实值
            dataTmp = load(dataFileName{i});
            ecg=calcOrigVal(dataTmp.val(ecgPos,:),ecgGain,ecgBaseline);
            ppg=calcOrigVal(dataTmp.val(ppgPos,:),ppgGain,ppgBaseline);
            bp=calcOrigVal(dataTmp.val(abpPos,:),abpGain,abpBaseline);
            tm=linspace(0,(length(ecg)-1)/getSampleRate(),length(ecg));
           %% 2.先用ecg的等值段长度筛选一次
           [~,~,isLegal] = AGetConfidentMinAndMaxBySegment(ecg);
           if ~isLegal               
                effectiveDataFileNames(i) = false;
                continue
           end           
          %% 3.再对每一组数据的abp获取sbp与dbp
            recordName = strsplit(names{i}, 'm.');
            bpann =load([recordName{1} '.bpann']);            
            [sbpann, dbpann, islegal ] = AExtractSbpAndDbpFromBp(bp, bpann, tm);
           %% 4.再用s/dbp数据筛选一次
            if ~islegal
                effectiveDataFileNames(i) = false;
                continue
            end            
            
           %% 5.再对每一组数据的ecg检测r - 这一步可能会有异常
           rpos = AHRDetection(ecg);
            %% 6.再用r波筛选一次
            if length(rpos) /tm(end) <= Constants.THEROLD_ANN_LEN_MIN_SCALE
                effectiveDataFileNames(i) = false;
                continue;
            end

            %% 7.再检测脉搏波的峰谷
            [ppgvalley, ppgpeak, islegal] = BGetOnsetsAndPeaksOfPPG(ppg, tm);
            
            %% 8.再用脉搏波峰谷筛选一次
                if ~islegal
                    effectiveDataFileNames(i) = false;
                    continue
                end
           
            %% 9.将数据写入到mat文件
            saveInParfor(recordName{1}, bp, sbpann, dbpann, ecg, rpos, ppg, ppgpeak, ppgvalley);
    catch e
        disp([names{i},' error: ',e.message])
        effectiveDataFileNames(i) = false;
        continue
    end
end
%% 10 将有效的名字写入到名字记录文件
save(strcat(Constants.APPENDIX_LONG_RECORD,'matNames.mat'), dataFileName(effectiveDataFileNames));
% delete(POOL);
end

function saveInParfor(matName, bp, sbpann, dbpann, ecg, rpos, ppg, ppgpeak, ppgvalley) 
    save(strcat(Constants.APPENDIX_LONG_RECORD,matName,'.mat'), ...
        'bp', 'sbpann', 'dbpann', 'ecg', 'rpos', 'ppg', 'ppgpeak', 'ppgvalley');
end

%% input: yaml file name
% output:
% *pos *'s position in the mat file
% *amp 
function [filename, ecgpos, ppgpos, bppos, ...
    ecgamp, ppgamp, bpamp,...
    ecgres, ppgres, bpres,...
    ecgbl, ppgbl, bpbl] = analysisYAML(name)
    try
        yamlStruct = ReadYaml(name);
        fields = fieldnames(yamlStruct);
              
        if length(fields) >= 1
            field = getfield(yamlStruct, fields{1});
            filename = field.File;        
            for i = 1:length(fields)
                field = getfield(yamlStruct, fields{i});
                switch getType(field.Description)
                    case 1
                        ecgamp = getGain(field.Gain);
                        ecgres = field.ADCZero;
                        ecgbl = field.Baseline;
                        ecgpos = i;
                    case 2                
                        ppgamp = getGain(field.Gain);
                        ppgres = field.ADCZero;
                        ppgbl = field.Baseline;
                        ppgpos = i;
                    case 3
                        bpamp = getGain(field.Gain);
                        bpres = field.ADCZero;
                        bpbl = field.Baseline;
                        bppos = i;
                end
            end
        end
    catch e
        throw(e)
    end
end

%%
% input : typeName which might be ECG II/PLETH/BP
% output
%  type - int
% 1 - ECG II
% 2 - PLETH
% 3 - BP
% -1 - others
function type = getType(typeName)
    if strcmp(typeName, 'ii')==1 || strcmp(typeName,'II')==1 ...
            || strcmp(typeName, 'ecg ii')==1 || strcmp(typeName,'ECG II')==1
        type = 1;
    elseif strcmp(typeName, 'pleth')==1||strcmp(typeName,'PLETH')==1
        type=2;
    elseif strcmp(typeName, 'abp')==1||strcmp(typeName,'ABP')==1
        type = 3;
    else
        type = -1;
    end
end

%%
%input
%  gainStr - String - The "Gain" field in the struct, which may include unit
% output
%  gain - double - Gain value.
function gain = getGain(gainStr)
    gain = str2double(regexpi(gainStr, '[.\d]+','match'));
end

function origVal=calcOrigVal(sig,sigain,baseline)
	%% 从读取到的信号值、信号基线以及增益三者中计算信号的原始值
	% copy from original rdmat
	defGain=200; %Default value for missing gains
	wfdbNaN=-32768; %This should be the case for all WFDB signal format types currently supported by RDMAT
	if sigain==0
		sigain=defGain;
	end
	sig(sig==wfdbNaN)=NaN;
	origVal = (sig - baseline)/sigain;
end

function ann = getABPAnn(signame)
    %% 获取血压值
    wabp(signame);
    [ann,~]=rdann(signame,'wabp');
    ann=ann';
end
