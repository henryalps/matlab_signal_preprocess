function [segPos, segLen] = BDevideSegment(confidentPos)
%% BDevideSegment??????????????????????????????????????????true?????????????????????
    confidentPos = [confidentPos(:); false];

    segPos = zeros(1,length(confidentPos));
    segLen = segPos;
    
    index = 1;
    count = confidentPos(1);
    
    for pos =  2:length(confidentPos)
        if confidentPos(pos)
            if confidentPos(pos - 1)
                count = count + 1;
            else
                index = pos;
                count = 1;
            end
        else
            if confidentPos(pos - 1)
                segPos(pos) = index;
                segLen(pos) = count;
            end
        end        
    end
    
    segPos = segPos(segLen>0);
    segLen = segLen(segLen>0);
end