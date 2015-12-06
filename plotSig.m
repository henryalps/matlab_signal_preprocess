% fp = fopen('yamlog');
% tline = fgetl(fp);
% matNames = {};
% index = 1;
% while ischar(tline)
%     matNames{index} = [tline '.mat'];
%     tline = fgetl(fp);
%     index = index + 1;
% end
% save('matNames');

load('newMatNames.mat');
for i = 1:length(matNames)
    close all
    disp(matNames{i});
    load(matNames{i});%matNames{i}
%     bp = BRemoveNan(bp(1:500));
    try
        detectPeakAndOnsetsInBPWave(bp');
%         pos = AHRDetection(bp);
        figure
        plot(ppg)
%         hold on 
%         plot(bpann,bp(bpann),'*');
        pause
    catch e
        disp(e)
    end
end

