% load('newMatNames.mat');
% matNames = newMatNames;
% newNewMatNames = ones(1,length(matNames));
% for i = 1:length(matNames)
%     load(matNames{i});%matNames{i}
%     if ~BIsSignalLegal(bp,ecg,ppg,rpos)
%         newNewMatNames(i) = 0;
%     end
% end
newNewMatNames = matNames(logical(newNewMatNames));
save('newNewMatNames.mat','newNewMatNames');