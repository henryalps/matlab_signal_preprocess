function [onsets, peaks, isLegal] =BGetOnsetsAndPeaksOfPPG(ppg, tm)
onsets = [];
peaks = [];
ppg = ppg(:);
%% 判断截止失真是否存在
[~, ~,isLegal] = AGetConfidentMinAndMaxBySegment(ppg);
isLegal = ~isLegal;
if ~isLegal
    return
end
%% 先检测波峰
tpeaks = detetectPeaksInPulseWave(ppg, 60); 
%% 根据长度判断是否需要这组数据
isLegal = length(tpeaks) >= Constants.THEROLD_ANN_LEN_MIN_SCALE * tm(end);
if ~isLegal
    return
end
%% 再检测波谷
[peaks,onsets] = BDistractSbpAndDbpFromBp(ppg, tpeaks(:,1),Constants.TYPE_PPG_PEAK);
peaks = [peaks', ppg(peaks)];
onsets = [onsets' ppg(onsets)];
end