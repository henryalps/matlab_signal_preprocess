% clear all
% load 'matNames.mat'
% newMatNames = matNames;
% for i=1:length(matNames)
%     tmp = load(matNames{i});
%     if ~isfield(tmp,'rpos')
%         newMatNames{i}='';
%     end
% end
% legalPos = newMatNames~='';
% newMatNames = newMatNames{legalPos};
% 
% save('newMatNames.mat','newMatNames')

%% This line can find all the postion in newMatNames which not equals ''
%% But it error again cause the newMatNames{LOGICAL INDEX} not work
% legalPos = ~cellfun(@isempty, newMatNames);
% newMatNames = newMatNames{legalPos};
% 
% save('newMatNames.mat','newMatNames')

newMatNames = matNames(legalPos);
save('newMatNames.mat','newMatNames')