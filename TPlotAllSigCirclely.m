function matNamesSelectedByDistribute1=TPlotAllSigCirclely()
    newNewMatNames=load('newNewMatNames.mat');
    newNewMatNames= newNewMatNames.newNewMatNames;
    matNamesSelectedByDistribute1 = ones(1,length(newNewMatNames))*true;
    for i = 1:length(newNewMatNames)
        tmp = load(newNewMatNames{i});
        TPlogAllSig(tmp.bp,tmp.ecg,tmp.ppg,tmp.bpann,tmp.rpos,tmp.tm);
        disp(newNewMatNames{i})
        pause
    end
  
end