function [startpos, stoppos] = TGetLongestTenMinuteSegment(pos)
%% 用于找到一个时间窗的起始位置和结束位置，使得在该窗内的数据点数最多
WIN_LEN = Constants.THEROLD_PACE_TO_PACE_TIME * getSampleRate();
winlen = zeros(1, length(pos));
winEnd = 0;
for i = 1:length(winlen)
    %% 发现窗口移动到数据边缘之后，就停止
    if pos(i) + WIN_LEN > pos(end) && winEnd >= pos(end) 
        break
    end
    winEnd = pos(i) + WIN_LEN;
    winlen(i) = sum(pos <= winEnd) - i + 1;
end
if winEnd == 0
    startpos = -1;
    return
end
[maxWinLen, maxWinPos] = max(winlen);
startpos = maxWinPos;
stoppos = maxWinPos + maxWinLen - 1;
end