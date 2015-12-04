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

load('matNames.mat');
for i = 1:length(matNames)
    close all
    disp(matNames{i});
    load(matNames{i});%matNames{i}
    ecg = BRemoveNan(ecg(1:500));
    try
        pos = AHRDetection(ecg);
        figure
        plot(ecg)
        hold on 
        plot(pos,ecg(pos),'*');
        pause
    catch e
        disp(e)
    end
end

