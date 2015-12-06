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

%% write test data into data file
% save('testdata.mat','bp','dbpann',...
%     'sbpann','ecg','ppg','rpos','tm');

%% use Peak detection althoriagm
res = detectPeaksInPulseWave(ppg');
