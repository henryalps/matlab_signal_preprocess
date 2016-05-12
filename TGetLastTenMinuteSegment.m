function [ startpos, stoppos ] = TGetLastTenMinuteSegment( pos )
%% 用于找到一个数据末端的长度特定的时间窗
WIN_LEN = Constants.THEROLD_TRAIN_SET_WIN_TIME * getSampleRate();
minWinPos = pos(end) - WIN_LEN;
minWinPos = sum(pos < minWinPos);
startpos = minWinPos;
stoppos = length(pos);
end

