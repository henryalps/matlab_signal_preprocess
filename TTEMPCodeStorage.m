%% plot dbp estimate result
% close all
% figure
% plot(bp)
% hold on
% plot(sbpann,bp(sbpann),'*r');
% plot(dbpann,bp(dbpann),'og');
% return

%% plot ppg
% close all
% figure
% plot(ppg(1:1000))
% return

%% plot ppg detection result
% close all
% figure
% plot(ppg)
% hold on
% plot(ppgpeakpos(:,1), ppg(ppgpeakpos(:,1)),'or');
% return

%% 在同一个图中画3种信号及其标定
% close all
% xlowerlim = 500;
% xupperlim = 2000;
% figure
% subplot(3,1,1)
% plot(bp)
% xlim([xlowerlim,xupperlim])
% hold on
% plot(sbpann,bp(sbpann),'*r');
% plot(dbpann,bp(dbpann),'og');
% subplot(3,1,2)
% plot(ecg)
% xlim([xlowerlim,xupperlim])
% hold on
% plot(rpos,ecg(rpos),'*r');
% subplot(3,1,3)
% plot(ppg)
% xlim([xlowerlim,xupperlim])
% hold on
% plot(peaks(:,1), ppg(peaks(:,1)),'*r');
% onsets = onsets(onsets(:,1)>0);
% plot(onsets(:,1), ppg(onsets(:,1)),'og');
% return

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
load('testdata.mat');
TRAIN_RATIO = 0.8;
%% 1 计算逐拍脉搏波特征
[ppgwfeatures, ppgwfeaturenames] =...
    calculatePWFeaturesWithoutDic(bp, peaks, onsets);
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