function [peaks,onsets] = TUsePeakDetector4BPPeaks(abp,ppg)
    abp = abp(:);
    ppg = ppg(:);
    
    DATA = [abp ppg];
    HEADER = {'abp','ppg'};
    FS = getSampleRate();
    
    tmp = detect_sqi(DATA,HEADER,FS);
end