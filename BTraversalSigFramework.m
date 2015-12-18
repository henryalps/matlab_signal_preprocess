function BTraversalSigFramework(filename)
%% filename:the file which save all the signal name 's name
%     POOL = parpool('local',4);
    WHICHONE = 3;% Select Running function
    % 1 - Select signal with method 1
    % 2 - 获取所有的有效数据组及特征，并写入到csv文件，同时将特征附加到mat文件
    % 3 - 对出现错误的数据组，分析错误原因，解决错误后，再采取同2一致的做法
    matNames = load(filename);    

    %% --BEFORE-- %%
    switch WHICHONE
        case 1
            matNames = matNames.newMatNames;%newNewMatNames;
        case 2
            matNames = matNames.matNamesSelectedByBpAndPpg;
            matNames{1} = matNames{2};
            winNums = zeros(1,length(matNames)); % 某个mat所对应的有效窗口数量
            errorMatNames = matNames;
            index = 1;
        case 3
            matNames = matNames.errorMatNames;
    end
    
    forSave = true(1,length(matNames)); %this variable may not use

     %% --PROCESS-- %%
    for i=1:length(matNames)
        sigs = load(matNames{i});
        try
        switch WHICHONE
            case 1
                if ~BSimplelySelectSigByDistribute(sigs.bp,sigs.ecg,sigs.ppg,...
                    sigs.bpann,sigs.rpos,sigs.tm)
                    forSave(i)=false;
                    close all
                    xlowerlim = 1;
                    xupperlim = 2000;
                    figure
                    subplot(3,1,1)
                    plot(sigs.bp)
                    xlim([xlowerlim,xupperlim])
                    subplot(3,1,2)
                    plot(sigs.ecg)
                    xlim([xlowerlim,xupperlim])
%                     hold on
%                     plot(sigs.rpos,sigs.ecg(sigs.rpos),'*r');
                    subplot(3,1,3)
                    plot(sigs.ppg)
                    xlim([xlowerlim,xupperlim])
                    pause
                end
            case 2   
            case 3
                % 0 将NaN替换为0
                sigs = BReplaceAllNanInSigsInStruct(sigs, 0);
                % 1 求收缩-舒张压并确定数据组是否可用
                [sbpann, dbpann, islegal ] = AExtractSbpAndDbpFromBp(sigs.bp, sigs.bpann, sigs.tm);
                if ~islegal
                    forSave(i) = false;
                    continue
                end
                % 2 求PPG波峰-波谷并确定数据组是否可用
                [onsets, peaks, islegal] = BGetOnsetsAndPeaksOfPPG(sigs.ppg, sigs.tm);
                if ~islegal
                    forSave(i) = false;
                    continue
                end
                % 3 计算pwtt
                pwt=BGetPwttAdapter(sigs.ecg, sigs.rpos, peaks);
                % 4 计算逐拍脉搏波特征
                [ppgfeature, ppgfeaturename] =...
                    calculatePWFeaturesWithoutDic(sigs.ppg, peaks, onsets);
                % 5 确定所有的有效窗口，并得到对应的特征值和血压值                
                [features,featurenames,sbps,dbps] = BGetFeatureAndBpGroups(sigs.bp, sigs.ecg, sigs.ppg, ...
                        sbpann, dbpann, sigs.rpos, peaks, onsets, ppgfeature, ppgfeaturename, pwt);
                % 6 写入到mat文件
                writeinparfor(matNames{i},sigs.bp, sigs.ecg, sigs.ppg, sigs.bpann,...
                        sbpann, dbpann, sigs.rpos, peaks, onsets, ppgfeature, ppgfeaturename, pwt, sigs.tm)
                % 7 写入到csv文件
                data = [features;sbps;dbps]';
                name = [featurenames, 'sbps', 'dbps'];
                BWriteMats2CSV([matNames{i}(1:end-length('.mat')),'.csv'], data, name);
                % 8 计量窗口总数
                winNums(i) = numel(sbps);           
        end
        catch e
            disp(e)
            errorMatNames{index} = matNames{i};
            index = index+1;
            continue
        end
    end

    %% --AFTER-- %%
    switch WHICHONE
        case 1
            matNamesSelectedByDistribute1 = matNames{forSave};
            save('matNamesSelectedByDistribute1.mat','matNamesSelectedByDistribute1');
        case 2
            matNamesSelectedByBpAndPpg = matNames(forSave);
            winNums = winNums(forSave);
            save('matNamesSelectedByBpAndPpg.mat', 'matNamesSelectedByBpAndPpg', 'winNums');
    end
    
%     delete(POOL)
end

function writeinparfor(matname, bp, ecg, ppg, bpann,...
                        sbpann, dbpann, rpos, ppgpeak, ppgvalley, ppgfeature, ppgfeaturename, pwt, tm)
save(matname, 'bp', 'bpann', 'sbpann', 'dbpann', 'ecg', 'rpos', 'ppg', 'ppgpeak',...
    'ppgvalley', 'pwt', 'ppgfeature', 'ppgfeaturename', 'tm');
end