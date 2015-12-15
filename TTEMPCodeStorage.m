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