function BCalcPace2PaceData(shift, len)
%% 计算逐拍脉搏波特征组 - 血压值对，并存入csv文件
matNames = load('cextractfeature.mat');
matNames = matNames.cextractfeature;
for i=shift:shift+len-1
    try
        sigs = load(matNames{i});        
       %% 0 根据瞬时心率的正常范围进一步筛选出所有有正常瞬时心率的心搏节拍
        lrpos = getLegalRpos(sigs.rpos);
       %% 1 重新计算pwt，现在计算出的pwt结果为三列：
        % [ecg的r波位置 pwt值 对应的ppg波峰位置 ]
        lpwt=BGetPwttAdapter(sigs.ecg, lrpos(:,1), sigs.ppgpeak);        
       %% 2 根据pwt的存在性确认合法的血压节拍
        ldbpann = BGetPwttAdapter(sigs.ecg, lrpos(:,1), sigs.dbpann');
        lsbpann = BGetPwttAdapter(sigs.ecg, lrpos(:,1), sigs.sbpann');
       %% 3 取dbpann与sbpann对应合法节拍的并集，计算特征，并保存到csv文件
        [rdbp, irposdbp, iannposdbp] = intersect(lpwt(:,1), ldbpann(:,1));
        [rsbp, irpossbp, iannpossbp] = intersect(lpwt(:,1), lsbpann(:,1));
        %%% 取所有的脉搏波合法节拍，计算特征
        % 把有效的血压节拍对应的心搏节拍/PPG节拍筛选出来
        lpwt = lpwt(union(irpossbp, irposdbp), :); 
        [~, legalppgpos, ~] = intersect(sigs.ppgpeak(:,1), lpwt(:,3));
        [features,featureNames]  = calculatePWFeaturesWithoutDic(sigs.ppg, sigs.ppgpeak(legalppgpos,:), sigs.ppgvalley(legalppgpos,:));
        %%% 可能有些拍并没有特征，需要逐个特征去辨识
        features = getMergedPPGFeatures(features,lpwt);
        %% 找到所有的合法心搏节拍对应的血压节拍
        [~, irposdbp, ifeatdbp] = intersect(rdbp, features(:,1));
        [~, irpossbp, ifeatsbp] = intersect(rsbp, features(:,1));
        features = [features, zeros(size(features,1), 4)];
        %% 筛选每一合法拍所对应的心率
        [~, irposhr, ~] = intersect(lrpos(:,1), features(:, 1));
        features(:, end - 3) = lrpos(irposhr, 2);
        %% 筛选出每一合法节拍所对应的pwt
        [~, irpospwt, ~] = intersect(lpwt(:,1), features(:,1));
        features(:, end - 2) = lpwt(irpospwt, 2);
        features(ifeatsbp, end-1) = sigs.bp(lsbpann(iannpossbp(irpossbp), 3));
        features(ifeatdbp, end) = sigs.bp(ldbpann(iannposdbp(irposdbp), 3)); 

        %% 4 写入到csv文件
        name = cell (1, 5 + length(featureNames));
        name(1) = {'rpeakpos'};
        name(2:length(featureNames) + 1) = featureNames(1:end);
        name(end-3:end) = {'hr', 'pwtt', 'sbps', 'dbps'};
        BWriteMats2CSV([matNames{i}(1:end-length('.mat')),'.csv'], features, name);
    catch e
        disp([matNames{i} 'error: ' e.message])
        continue
    end
end
end

function rpos = getLegalRpos(rpos)
%% 获取合法的心搏节拍对应的ｒ波位置序列，以及这些ｒ波位置所对应的心率值
    rpos = rpos(:);
    drpos = getSampleRate() * 60 ./ diff(rpos); % 这个就是心率了
    rpos = [rpos(1:end - 1) drpos];
    rpos = rpos(drpos >= Constants.MIN_HR & drpos <= Constants.MAX_HR, :);
end

function mergedppgfeatures = getMergedPPGFeatures(ppgfeatures, lpwt)
    %% getMergedPPGFeatures用于获取那些全部脉搏波特征都存在的节拍，
     %     并返回这些节拍对应的r波位置以及特征序列
     pos = ppgfeatures{1};
     pos = pos(:, 1);
     for idex=2:length(ppgfeatures)
         tmp = ppgfeatures{idex};
         tmp = tmp(:,1);
         pos = intersect(tmp, pos);
     end
     mergedppgfeatures = zeros(length(pos), length(ppgfeatures) + 1);
    % 找到有效的PPG波峰位置对应的R波波峰位置，并存储到结果的第一列内
    [~, pPpgPeakIndex, ~] = intersect(lpwt(:,3), pos);
    mergedppgfeatures(:, 1) = lpwt(pPpgPeakIndex, 1);
     for idex=1:length(ppgfeatures)
         tmp = ppgfeatures{idex};
         [~, idx, ~] = intersect(tmp(:,1), pos);
         mergedppgfeatures(:, idex + 1) = tmp(idx, 2);
     end         
end