function [sbppos,dbppos] = BDistractSbpAndDbpFromBp(bp, bppos)
%% 该方法针对的是只检出了DBP的信号，使用最简单的极值方式在两个DBP间寻找SBP
[segpos, seglength] = BDevideSegment(BDeriveConfidentSignalSegment(bp(bppos)));
%% 剔除掉那些只有一个点的数据段
segpos = segpos(seglength > 1);
seglength=seglength(seglength > 1)-1;%segend = segstart + length - 1

sbppos = ones(1,length(bppos))*NaN;
sbpindex = 1;
dbppos = sbppos;
dbpindex = 1;
%% 开始寻找SBP
for i=1:length(segpos)
    for j=1:seglength(i) - 1
        sbppos(sbpindex) = bppos(segpos(i)  + j);
        [~ , dbppos(dbpindex)] = max(bp(bppos(segpos(i) + j):bppos(segpos(i) + j + 1)));
        dbppos(dbpindex) = dbppos(dbpindex) + sbppos(sbpindex) - 1;
        sbpindex = sbpindex + 1;
        dbpindex = dbpindex + 1;
    end
    sbppos(sbpindex) = bppos(segpos(i) + seglength(i));
    sbpindex = sbpindex + 1;
end

sbppos=sbppos(~isnan(sbppos));
dbppos=dbppos(~isnan(dbppos));

end