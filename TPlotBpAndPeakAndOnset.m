load('newMatNames.mat');
for i = 1:length(matNames)
    close all
    disp(matNames{i});
    load(matNames{i});%matNames{i}
%     bp = BRemoveNan(bp(1:500));
%     [bppeaks,bponsets]=detectPeakAndOnsetsInBPWave(bp');
    if ~(isempty(bppeaks) || isempty(bponsets))
        figure
        plot(bp)
        hold on
%         plot(bppeaks(:,1),bppeaks(:,2),'*r');
%         plot(bponsets(:,1),bponsets(:,2),'*g');
        plot(bpann,bp(bpann),'*')
        pause
    end
end