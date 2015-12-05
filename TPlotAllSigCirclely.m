function TPlotAllSigCirclely()
    POOL = parpool('local',8);
    load('newNewMatNames.mat');
    newNewMatNames = {};
    matNamesSelectedByDistribute1 = ones(1,length(newNewMatNames));
    parfor i = 1:length(newNewMatNames)
        tmp = load(newNewMatNames{i});
        tmp = tmp.newNewMatNames;
%         TPlogAllSig(bp,ecg,ppg,bpann,rpos,tm);
%         disp(newNewMatNames{i})
        if ~BSimplelySelectSigByDistribute(tmp.bp,tmp.ecg,tmp.ppg,...
                tmp.bpann,tmp.rpos,tmp.tm)
%             disp('illegal');
            matNamesSelectedByDistribute1(i)=0;
        end
%         pause
    end
    matNamesSelectedByDistribute1 = newNewMatNames{logical(matNamesSelectedByDistribute1)};
    save('matNamesSelectedByDistribute1.mat','matNamesSelectedByDistribute1');
    delete(POOL)
end