function BAddHR2Mat()
POOL = parpool('local',8);
matNames = load('matNames.mat');
matNames = matNames.matNames;
newMatNames = ones(length(matNames)) * true;
parfor i = 1:length(matNames)
    tmp = load(matNames{i});%matNames{i}
    tmp.ecg = BRemoveNan(tmp.ecg);
    try
        rpos = AHRDetection(tmp.ecg);
        saveInParfor(matNames{i},tmp.bp,tmp.bpann,tmp.ecg,rpos,tmp.ppg,tmp.tm)
    catch e   
        newMatNames(i) = false;
    end
end
newMatNames = matNames{newMatNames};
save('newMatNames.mat','newMatNames');
delete(POOL)
end

function saveInParfor(fileName,bp,bpann,ecg,rpos,ppg,tm) 
    save(fileName,'bp','bpann','ecg','rpos','ppg','tm');
end