function getOrigSigBat(siginfo)
	load(siginfo);
    load('pos.mat');
	for i=1:length(dataFileName)
		sampleRate = getSampleRate...
			(getNameWithoutPrefix(dataFileName{i}),...
				whichOneIsECG(i),...
				whichOneIsPPG(i),...
				whichOneIsBP(i));
		if sampleRate~=-1
			enhancedRdmat(dataFileName{i},...
				whichOneIsECG(i),...
				whichOneIsPPG(i),...
				whichOneIsBP(i),...
				ECGGain(i),PPGGain(i),BPGain(i),...
				ECGBaseline(i),PPGBaseline(i),BPBaseline(i),...
				sampleRate);
		end
		save('pos.mat','i');
	end
end

function enhancedRdmat(filename,...
	ecgPos, ppgPos, abpPos,...
	ecgGain, ppgGain, abpGain,...
	ecgBaseline, ppgBaseline, abpBaseline,...
	sampleRate)
	load(filename);
	ecg=calcOrigVal(val(ecgPos,:),ecgGain,ecgBaseline);
	ppg=calcOrigVal(val(ppgPos,:),ppgGain,ppgBaseline);
	bp=calcOrigVal(val(abpPos,:),abpGain,abpBaseline);
	tm=linspace(0,(length(ecg)-1)/sampleRate,length(ecg));
    try
        bpann=getABPAnn(getNameWithoutPrefix(filename));
    catch e
        bpann=[];
    end
	save(filename,'ecg','ppg','bp','bpann','tm');%FUNCTION SAVE would override the original
end

function ann = getABPAnn(signame)
    wabp(signame);
    [ann,~]=rdann(signame,'wabp');
    ann=ann';
end

function nameWithoutPrefix = getNameWithoutPrefix(nameWithPrefix)
	nameFrag=strsplit(nameWithPrefix,'.');
	if length(nameFrag)>1
		nameWithoutPrefix=nameFrag{1};
	else
		nameWithoutPrefix=nameWithPrefix;
	end
end

% Get the samplerate from .hea file
% IF one of sample rate in ECG/PPG/ABP 
%  doesn't equal to others, return -1
function sampleRate = getSampleRate(sigName,...
	ecgPos, ppgPos, abpPos)
	sampleRate = -1;
	[~, sampleRates] = wfdbdesc(sigName);
	disp(sigName);
	if sampleRates(ecgPos)==sampleRates(ppgPos)...
		&& sampleRates(ppgPos)==sampleRates(abpPos)
		sampleRate=sampleRates(ecgPos);
	end
end

function origVal=calcOrigVal(sig,sigain,baseline)
	%% 从读取到的信号值、信号基线以及增益三者中计算信号的原始值
	% copy from original rdmat
	defGain=200; %Default value for missing gains
	wfdbNaN=-32768; %This should be the case for all WFDB signal format types currently supported by RDMAT
	if sigain==0
		sigain=defGain;
	end
	sig(sig==wfdbNaN)=NaN;
	origVal = (sig - baseline)/sigain;
end
