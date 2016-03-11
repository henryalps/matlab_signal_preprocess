%% 将测试集的极差与标准差添加到meta文件内
cd /home/test/Herui-Matlab/data/csv-pace-2-pace/long-long/metadata
load 'sbpmeta.mat'
for i=1:size(sbp_meta,1)
    load(sbp_meta{i, 9})
    sbp_meta{i, 10} = sbpnums(sbp_meta{i, 4}:sbp_meta{i, 5}, end-1);
    sbp_meta{i, 11} = std(sbp_meta{i,10});
    sbp_meta{i, 10} = max(sbp_meta{i,10}) - min(sbp_meta{i,10});
end
save('sbpmeta.mat', 'sbp_meta')
return

%% 算错的测试集长度重新计算
cd /home/test/Herui-Matlab/data/csv-pace-2-pace/long-long/metadata
load 'dbpmeta.mat'
for i=1:size(dbp_meta,1)
    load(dbp_meta{i, end})
    dbp_meta{i, 8} = dbpnums(dbp_meta{i, 6}, 1) - dbpnums(dbp_meta{i, 5}, 1);
end
save('dbpmeta.mat', 'dbp_meta')

%% 试图将放错位置的sbp文件移到正确位置
currentDir = pwd;
cd(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV)
cd(Constants.METADATA_FOLDER_NAME)
load('sbpmeta.mat')
% cd(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV)
% for i = 0:length(sbp_meta) / 10 - 1
%     try
%         movefile(fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, Constants.DBP_FOLDER_NAME,'test', sbp_meta{i*10 + 1}),...
%             fullfile(Constants.APPENDIX_PACE_2_PACE_LONG_LONG_CSV, Constants.SBP_FOLDER_NAME,'test', sbp_meta{i*10 + 1}))
%     catch e
%         continue
%     end
% end
cd(currentDir)
return

%% 将长时数据的长度保存到mat文件
currentDir = pwd;
cd /home/test/WFDBDATA/3.new
matNames = BGetNamesFromFile('alllongtimematnames');
TGetSigLenList(matNames);
cd(currentDIr)
return

%% 测试逐拍特征提取代码
names = load('cextractfeature.mat');
names = names.cextractfeature;
sigs = load(names{1});        
%% 0 根据瞬时心率的正常范围进一步筛选出所有有正常瞬时心率的心搏节拍
rpos = sigs.rpos;
drpos = diff(rpos) / getSampleRate();
rpos = rpos(1:end - 1);
rpos = rpos(drpos < 60 / Constants.MIN_HR & drpos > 60 / Constants.MAX_HR);
lrpos = rpos;
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
% 把有效的血压节cd拍对应的心搏节拍/PPG节拍筛选出来
lpwt = lpwt(union(irpossbp, irposdbp), :); 

[~, legalppgpos, ~] = intersect(sigs.ppgpeak(:,1), lpwt(:,3));
[features,featureNames]  = calculatePWFeaturesWithoutDic(sigs.ppg, sigs.ppgpeak(legalppgpos,:), sigs.ppgvalley(legalppgpos,:));
%%% 可能有些拍并没有特征，需要逐个特征去辨识
ppgfeatures = features;
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
features = mergedppgfeatures;
%% 找到所有的合法心搏节拍对应的血压节拍
[~, irposdbp, ifeatdbp] = intersect(rdbp, features(:,1));
[~, irpossbp, ifeatsbp ] = intersect(rsbp, features(:,1));
%% 4 写入到csv文件
features = [features, zeros(size(features,1), 2)];
features(ifeatsbp, end-1) = sigs.bp(lsbpann(iannpossbp(irpossbp), 3));
features(ifeatdbp, end) = sigs.bp(ldbpann(iannposdbp(irposdbp), 3)); 

name = cell (1, 3 + length(featureNames));
name(1) = {'rpeakpos'};
name(2:length(featureNames) + 1) = featureNames(1:end);
name(end-1:end) = {'sbps', 'dbps'};

BWriteMats2CSV([names{1}(1:end-length('.mat')),'.csv'], features, name);
return

%% 测试有效R波筛选代码
% drpos = diff(rpos) / getSampleRate();
% rpos = rpos(1:end - 1);
% rpos = rpos(drpos < 60 / Constants.MIN_HR & drpos > 60 / Constants.MAX_HR);
% return

%% 绘制cextractfeature数组对应的文件内的bp信号的前200点
% names = load('cextractfeature.mat');
% names = names.cextractfeature;
% for i = 1:length(names)
%     if strcmp(names{i}, 'a44089_0012m.mat')
%         load(names{i})
%         disp(names{i})
%         close all
%         figure
%         plot(bp,'linewidth',2)
%         pause
%     end
% end

%% 获得每个subject_id的信号的数量
% for i=1:length(data)
%     disp(i)
%     if ~isnan(data{i,1})
%         try
%             ids(index) = data{i,1};
%         catch e            
%         end        
%         index = index +1;
%     end
% end
% ids = ids - min(ids) + 1;
% tmp = zeros(1, max(ids));
% for i=1:length(ids)
%     tmp(ids(i)) = tmp(ids(i))+1;
% end
% tmp = tmp(tmp~=0);
% ids = zeros(2, max(tmp) -min(tmp) +1);
% for i=1:length(ids)
%     ids(1,i) = min(tmp) + i -1;
%     ids(2,i) = sum(tmp == ids(1,i));
% end

% ids = tmp;
% ids = ids - min(ids) + 1;
% tmp = zeros(1, max(ids));
% for i=1:length(ids)
%     tmp(ids(i)) = tmp(ids(i))+1;
% end
% subject_id_distribute = ids;
% 
% save('subject_id_distribute.mat', 'subject_id_distribute')

%% 生成sbp与dbp相关系数
% sbp_corrs = [0.32590046844784076, 0.50423042281358421, 0.079922774400731561, 0.31579726093079363, 0.0038081149621862179, 0.50455392797983223, 0.44563344498542051, 0.30895298369951307, 0.321538519894909, 0.21674444708305773]
% dbp_corrs=[0.20704335425926765, 0.35246228772770183, 0.31830895139209525, 0.20179624348244499, 0.32055946162412446, 0.2959571728990153, 0.52106126775920603, 0.37160919866782544, 0.11997726217887658, 0.093037341834807649]
% return

%% 整理1.new/下的所有mat文件，找到被误恢复为val的/未提取特征的/提取特征的，
% 分别把名字存储到3个mat下
cd /mnt/data/2.new
matNames = BGetNamesFromFile('allmatnames');
indexa = 1;
indexb = 1;
indexc = 1;
auncarefullyrestored = {};
bunextractfeature = {};
cextractfeature = {};
for i = 1:length(matNames)
    try
        tmp = load(matNames{i});
        test = tmp.bp;
        try 
            test = tmp.ppgfeature;
            cextractfeature{indexc} = matNames{i};
            indexc = indexc  + 1;
        catch e
            bunextractfeature{indexb} = matNames{i};
            indexb = indexb + 1;
        end
    catch e
        auncarefullyrestored{indexa} = matNames{i};
        indexa = indexa + 1;
    end
end
save('auncarefullyrestored.mat', 'auncarefullyrestored');
save('bunextractfeature.mat', 'bunextractfeature');
save('cextractfeature.mat', 'cextractfeature');
return

%% 获取被剔除掉的信号名，并存储到unselectedMatNames.mat内
% unselectedMatNames = cell(1, length(matNamesSelectedByBpAndPpg) - length(matNamesSelectedByDistribute1));
% index = 1;
% for i=1:length(matNamesSelectedByDistribute1)
%       if(~isempty(find(strncmp(matNamesSelectedByDistribute1{i}, matNamesSelectedByBpAndPpg, length(matNamesSelectedByDistribute1{i})),1))) 
%                 continue
%       else
%           unselectedMatNames{index} = matNamesSelectedByDistribute1{i};
%           index = index + 1;
%       end
% end
% save('unselectedMatNames.mat', 'unselectedMatNames');
% return

%% 这部分代码把以‘文件名.dat'格式记录的cell数组转换为'文件名'格式的cell数组
% clear
% filename = 'alldata';
% appendix = '.mat';
% res = load(filename);
% data = getfield(res, filename);
% 
% for i = 1:length(data(:,1))
%     splitres = strsplit(data{i, 5}, '.');
%     data{i, 5} = splitres{1};
% end
% 
% save(strcat(filename, appendix), 'data');
% return

%% 测试读取文件为一系列字符串的函数

% fid = fopen('currentnames');
% tline = fgetl(fid);
% i = 1;
% while ischar(tline)
%     yamlnames{i} = tline;
%     i = i+1;
%     tline = fgetl(fid);
% end
% fclose(fid);
% return;

%% 测试影响envelop速度的因素
% sig =rand(100000,1);
% hilbetlen = 50000;
% meanval = 0;
% for i=1:10
%     tic
%     envelope(sig, hilbetlen, 'peak');
%     meanval = meanval + toc;
% end
% meanval = meanval/i
% return

%% 测试代码
% for i=1:10
%     switch i
%         case 1
%         case 2
%             break
%     end
%     disp(i)
% end
% return

%% 绘制信号和包络
% close all
% [upe,downe]=envelope(bp,30,'peak');
% figure
% plot(bp)
% hold on
% % plot(upe,'g--')
% % plot(downe,'b--')
% plot((upe+downe)/2, 'r--')
% return

%% 包络算法，未考虑边界条件
% close all
% fs=30;
% t=0:1/fs:200;
% x6=sin(2*pi*2*t)+sin(2*pi*4*t);
% x66 = hilbert(x6);
% xx = abs(x66+j*x6);
% % figure(1)
% % hold on
% % plot(t,x6);
% % plot(t,xx,'r')
% % xlim([0 5])
% % hold off
% d = diff(x6);
% n = length(d);
% d1 = d(1:n-1);
% d2 = d(2:n);
% indmin = find(d1.*d2<0 & d1<0)+1;
% indmax = find(d1.*d2<0 & d1>0)+1;
% envmin = spline(t(indmin),x6(indmin),t);
% envmax = spline(t(indmax),x6(indmax),t);
% figure
% hold on
% % plot(t,x6);
% plot(t,envmin,'r');
% plot(t,envmax,'m');
% hold off
% xlim([0 5])
% return

%% plot dbp estimate result
% clear
% load('matNamesSelectedByDistribute1.mat');
% load(matNamesSelectedByDistribute1{4})
% [sbpann, dbpann,islegal ] = AExtractSbpAndDbpFromBp(bp, bpann, tm);
% close all
% figure
% plot(bp)
% hold on
% plot(sbpann,bp(sbpann),'*r');
% plot(dbpann,bp(dbpann),'og');
% return

%% just plot bp
% close all
% figure
% plot(bp)
% hold on
% plot(bpann, bp(bpann), '*r');
% return

%% plot ppg
% close all
% figure
% plot(ppg(1:1000))
% return

%% plot ppg detection result
% close all
% clear
% load('matNamesSelectedByDistribute1.mat');
% load(matNamesSelectedByDistribute1{20})
% % [ppgpeakpos,ppgonsetpos] = detectPeakAndOnsetsInBPWave(ppg');
% % tpeaks = detetectPeaksInPulseWave(ppg', 60); 
% % [ppgpeakpos,ppgonsetpos] = BDistractSbpAndDbpFromBp(ppg, tpeaks(:,1),Constants.TYPE_PPG_PEAK);
% [onsets, peaks] = BGetOnsetsAndPeaksOfPPG(ppg, tm);
% figure
% plot(ppg)
% hold on
% plot(peaks(:,1), ppg(peaks(:,1)),'or');
% plot(onsets(:,1), ppg(onsets(:,1)),'*g');
% return

%% 在同一个图中画3种信号及其标定
clear
bunextractfeature = load('cextractfeature.mat');
bunextractfeature = bunextractfeature.cextractfeature;
for i = 1:length(bunextractfeature)
    close all
    load(bunextractfeature{i})
    xlowerlim = 1;
    xupperlim = 2000;
    figure
    subplot(3,1,1)
    plot(tm, bp)
    xlim([tm(xlowerlim),tm(xupperlim)])
    title(bunextractfeature{i})
    hold on
    [sbpann, dbpann, ~] = AExtractSbpAndDbpFromBp(bp, bpann, tm);
    plot(tm(sbpann),bp(sbpann),'*r');
    plot(tm(dbpann),bp(dbpann),'og');
    subplot(3,1,2)
    plot(tm, ecg)
    xlim([tm(xlowerlim),tm(xupperlim)])
    hold on
    plot(tm(rpos),ecg(rpos),'*r');
    subplot(3,1,3)
    plot(tm, ppg)
    xlim([tm(xlowerlim),tm(xupperlim)])
    hold on
    [ppgvalley, ppgpeak, isLegal] = BGetOnsetsAndPeaksOfPPG(ppg, tm);
    plot(tm(ppgpeak(:,1)), ppg(ppgpeak(:,1)),'*r');
    ppgvalley = ppgvalley(ppgvalley(:,1)>0);
    plot(tm(ppgvalley(:,1)), ppg(ppgvalley(:,1)),'og');
    
    figure    
    subplot(3,1,1)
    plot(tm,bp)
    xlim([tm(xlowerlim),tm(xupperlim)])
    title(bunextractfeature{i})
    
    subplot(3,1,2)
    plot(tm,ecg)
    xlim([tm(xlowerlim),tm(xupperlim)])
    
    subplot(3,1,3)
    plot(tm,ppg)
    xlim([tm(xlowerlim),tm(xupperlim)])
    
    figure
    plot(tm,ecg, 'b')
    hold on
    plot(tm(rpos),ecg(rpos),'bo');
    hold on
    plot(tm,ppg, 'r')
    hold on
    plot(tm(ppgpeak(:,1)), ppg(ppgpeak(:,1)),'*r');
    xlim([tm(xlowerlim),tm(xupperlim)])
    pause
end
return

%% 计算逐拍脉搏波特征
%features = calculatePWFeatures(ppg, peaks,onsets,[],[]);

%% write test data into data file
% save('testdata.mat','bp','dbpann',...
%     'sbpann','ecg','ppg','rpos','tm');

%% use Peak detection althoriagm
% res = detectPeaksInPulseWave(ppg');

%% 求包络的AR系数
% sigInWin=[1:100];
% envelop = abs(sigInWin) / length(sigInWin);
%     envelop = abs(hilbert(envelop(1:floor(length(envelop)/2))));
%     features(16:20) = AGetARModelParas(envelop);
%     return;

%% 对一组测试信号，计算所有特征-血压组，并写入到csv文件中
clear all
load('testdata.mat');
TRAIN_RATIO = 0.8;
%% 1 计算逐拍脉搏波特征
[ppgwfeatures, ppgwfeaturenames] =...
    calculatePWFeaturesWithoutDic(ppg, peaks, onsets);
%% 2 计算pwtt
pwt=BGetPwttAdapter(ecg, rpos, peaks);
%% 3 确定所有的有效窗口，并得到对应的特征值和血压值
[features,featurenames,sbps,dbps] = BGetFeatureAndBpGroups(bp, ecg, ppg, ...
        sbpann, dbpann, rpos, peaks, onsets, ppgwfeatures, ppgwfeaturenames, pwt);
%% 4 写入到csv文件中 - 注意sbps/dbps的顺序
data = [features;dbps;sbps]';
featurenames = [featurenames, 'sbps', 'dbps'];
% 在保证训练集涵盖所有的测试集类别前提下，划分训练集与测试集并写入到文件
% [trainpos, testpos] = BDevideTrainAndTestset(sbps,dbps,0.8);
% if sum(trainpos) == 0 || sum(testpos) == 0
%     error('Cannot distract trainset or testset!')
% end
% BWriteMats2CSV('train.csv', data(trainpos,:), featurenames);
% BWriteMats2CSV('test.csv', data(testpos,:), featurenames);
% 随机划分训练集与测试集并写入到文件
trainsetlen = ceil(TRAIN_RATIO * size(data, 1));
trainpos = AGetRandomPossInArray(size(data, 1), trainsetlen);
BWriteMats2CSV('train.csv', data(trainpos,:), featurenames);
BWriteMats2CSV('test.csv', data(~trainpos,:), featurenames);