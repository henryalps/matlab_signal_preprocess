function BCalcPace2PaceData(shift, len)
%% 计算逐拍脉搏波特征组 - 血压值对，并存入csv文件
matNames = load('cextractfeature.mat');
matNames = matNames.cextractfeature;
for i=shift:shift+len
    try
        sigs = load(matNames{i});        
       %% 0 根据瞬时心率的正常范围进一步筛选出所有有正常瞬时心率的心搏节拍
        lrpos = getLegalRpos(sigs.rpos);
       %% 1 重新计算pwt，现在计算出的pwt结果为三列：
        % [ecg的r波位置 pwt值 对应的ppg波峰位置 ]
        lpwt=BGetPwttAdapter(sigs.ecg, lrpos, sigs.ppgpeak);        
       %% 2 根据pwt的存在性确认合法的血压节拍
        ldbpann = BGetPwttAdapter(sigs.ecg, lrpos, sigs.dbpann');
        lsbpann = BGetPwttAdapter(sigs.ecg, lrpos, sigs.sbpann');
       %% 3 取dbpann与sbpann对应合法节拍的并集，计算特征，并保存到csv文件
        [rdbp, irposdbp, iannposdbp] = intersect(lpwt(:,1), ldbpann(:,1));
        [rsbp, irpossbp, iannpossbp] = intersect(lpwt(:,1), lsbpann(:,1));
        %%% 取所有的脉搏波合法节拍，计算特征
        legalppgpos = lpwt(union(irpossbp, irposdbp));
        [features,featureNames]  = calculatePWFeaturesWithoutDic(sigs.ppg, sigs.ppgpeak(legalppgpos,:), sigs.ppgvalley(legalppgpos,:));
        %%% 可能有些拍并没有特征，需要逐个特征去辨识
        features = getMergedPPGFeatures(features);
        [~, irposdbp, ifeatdbp] = intersect(rdbp, features(:,1));
        [~, irpossbp, ifeatsbp] = intersect(rsbp, features(:,1));
       %% 4 写入到csv文件
        features = [features, zeros(size(features,1), 2)];
        features(ifeatsbp, end-1) = sigs.bp(sigs.sbpann(lsbpann(iannpossbp(irpossbp), 1)));
        features(ifeatdbp, end) = sigs.bp(sigs.dbpann(ldbpann(iannposdbp(irposdbp), 1))); 
        
        name = [featureNames, 'sbps', 'dbps'];
        BWriteMats2CSV([matNames{i}(1:end-length('.mat')),'.csv'], features, name);
    catch e
        disp([matNames{i} 'error: ' e.message])
        continue
    end
end
end

function rpos = getLegalRpos(rpos)
    drpos = diff(rpos) / getSampleRate();
    rpos = rpos(1:end - 1);
    rpos = rpos(drpos < 60 / Constants.MIN_HR & drpos > 60 / Constants.MAX_HR);
end

function mergedppgfeatures = getMergedPPGFeatures(ppgfeatures)
    %% getMergedPPGFeatures用于获取那些全部脉搏波特征都存在的节拍，
     %     并返回这些节拍对应的r波位置以及特征序列
     pos = ppgfeatures{1};
     pos = pos(:, 1);ww
     for idex=2:length(ppgfeatures)
         tmp = ppgfeatures{idex};
         tmp = tmp(:,1);
         pos = intersect(tmp, pos);
     end
     mergedppgfeatures = zeros(length(pos), length(ppgfeatures) + 1);
     mergedppgfeatures(:,1) = pos;
     for idex=1:length(ppgfeatures)
         tmp = ppgfeatures{idex};
         [~, idx, ~] = intersect(tmp(:,1), pos);
         mergedppgfeatures(:, idex + 1) = tmp(idx, 2);
     end         
end