function [startpos, stoppos] = TGetShortestTenMinuteSegment( pos )
%TGETSHORTESTTENMINUTESEGMENT Summary of this function goes here
%   Detailed explanation goes here
%% 用于找到一个时间窗的起始位置和结束位置，使得在该窗内的数据点数最多
WIN_LEN = Constants.THEROLD_PACE_TO_PACE_TIME * getSampleRate();
winlen = zeros(1, length(pos)) + length(pos);
winEnd = 0;
for i = 1:length(winlen)
    %% 发现窗口移动到数据边缘之后，就停止
    if pos(i) + WIN_LEN > pos(end) && winEnd >= pos(end) 
        break
    end
    winEnd = pos(i) + WIN_LEN;
    tmp = sum(pos <= winEnd) - i + 1;
    if tmp > Constants.THEROLD_TRAIN_SET_WIN_TIME * Constants.THEROLD_TRAIN_SET_WIN_TIME_MIN_SCALE
        winlen(i) = tmp;
    end
end
if winEnd == 0
    startpos = -1;
    return
end
[minWinLen, minWinPos] = min(winlen);
startpos = minWinPos;
stoppos = minWinPos + minWinLen - 1;
end

