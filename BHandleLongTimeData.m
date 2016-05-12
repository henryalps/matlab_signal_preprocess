function BHandleLongTimeData(shift, len)
%% 获取所有的有效数据组及特征，并写入到csv文件，同时将特征附加到mat文件
% INPUT
%   shift - 数据组名称在整体中的偏移，用于并行处理
%   len - 本批处理的数据总量

matNames = BGetNamesFromFile('alllongtimematnames');

for i=shift:shift+len
    try
    sigs = load(matNames{i});
    % 0 将NaN替换为0
    sigs = BReplaceAllNanInSigsInStruct(sigs, 0);
    % 3 计算pwtt
    pwt=BGetPwttAdapter(sigs.ecg, sigs.rpos, sigs.ppgpeak);
    % 4 计算逐拍脉搏波特征
    [ppgfeature, ppgfeaturename] =...
        calculatePWFeaturesWithoutDic(sigs.ppg, sigs.ppgpeak, sigs.ppgvalley);
    % 5 确定所有的有效窗口，并得到对应的特征值和血压值                
    [features,featurenames,sbps,dbps] = BGetFeatureAndBpGroups(sigs.bp, sigs.ecg, sigs.ppg, ...
            sigs.sbpann, sigs.dbpann, sigs.rpos, sigs.ppgpeak, sigs.ppgvalley, ppgfeature, ppgfeaturename, pwt);
    % 6 写入到mat文件                
%                 writeinparfor(matNames{i},sigs.bp, sigs.ecg, sigs.ppg, sigs.bpann,...
%                         sbpann, dbpann, sigs.rpos, sigs.ppgpeak, sigs.ppgvalley, ppgfeature, ppgfeaturename, pwt)
     % 7 写入到csv文件
    data = [features;sbps;dbps]';
    name = [featurenames, 'sbps', 'dbps'];
    BWriteMats2CSV([matNames{i}(1:end-length('.mat')),'.csv'], data, name);
    disp(matNames{i})
    catch e
        disp([matNames{i} 'error: ' e.message])
        continue
    end
end

end

function writeinparfor(matname, bp, ecg, ppg, bpann,...
                        sbpann, dbpann, rpos, ppgpeak, ppgvalley, ppgfeature, ppgfeaturename, pwt)
save(matname, 'bp', 'bpann', 'sbpann', 'dbpann', 'ecg', 'rpos', 'ppg', 'ppgpeak',...
    'ppgvalley', 'pwt', 'ppgfeature', 'ppgfeaturename');
end