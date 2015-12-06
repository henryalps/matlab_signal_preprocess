function BTraversalSigFramework(filename)
%% filename:the file which save all the signal name 's name
    WHICHONE = 1;% Select Running function
    % 1 - Select signal with method 1
    matNames = load(filename);
    

    %% --BEFORE-- %%
    switch WHICHONE
        case 1
            matNames = matNames.newNewMatNames;
    end
    
    forSave = ones(1,length(matNames))*true; %this variable may not use

     %% --PROCESS-- %%
    for i=1:length(matNames)
        sigs = load(matNames{i});
        
        switch WHICHONE
            case 1
                if ~BSimplelySelectSigByDistribute(sigs.bp,sigs.ecg,sigs.ppg,...
                    sigs.bpann,sigs.rpos,sigs.tm)
                    forSave(i)=false;
                end
        end
    end

    %% --AFTER-- %%
    switch WHICHONE
        case 1
            matNamesSelectedByDistribute1 = matNames{forSave};
            save('matNamesSelectedByDistribute1.mat','matNamesSelectedByDistribute1');
    end
end