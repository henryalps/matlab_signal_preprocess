function [sbpann,dbpann] = BDistractSbpAndDbpFromBp(bp, bppos, varargin)
%% 将本来在一个数组中的收缩/舒张压位置分散到两个数组中。该方法针对的是只检出了DBP（或SBP）的信号，使用最简单的极值方式在两个DBP间寻找SBP（或在两个SBP间寻找DBP）
% INPUT
% varargin = Constants.TYEP_SBP/TYEP_DBP
% OUTPUT
% s/dbpann [1*N]矩阵 RT
%% 确定检出的是DBP还是SBP
type = Constants.TYPE_DBP; % 默认认为是检出了DBP，因为只检出DBP的信号比只检出了SBP的信号多
if numel(varargin) == 0
    [bpmin, bpmax] = AGetConfidentMinAndMaxBySegment(bp);
    [tbpmin, tbpmax] = AGetConfidentMinAndMaxBySegment(bp(bppos));
    if bpmax - tbpmin >= tbpmin - bpmin % 说明更加偏向于bp底端，认为是舒张压
            type = Constants.TYPE_DBP;
    else
        if bpmax - tbpmax <= tbpmax - bpmin % 说明更加偏向于bp顶端，认为是收缩压
            type = Constants.TYPE_SBP;
        end
    end
else
    type = varargin(1);
    type = type{1};
end
%% 先分段
[segpos, seglength] = BDevideSegment(BDeriveConfidentSignalSegment(bp(bppos)));
%% 剔除掉那些只有一个点的数据段
segpos = segpos(seglength > 1);
seglength=seglength(seglength > 1)-1;%segend = segstart + length - 1

typeapos = ones(1,length(bppos))*NaN;
typeaindex = 1;
typebpos = typeapos;
typebindex = 1;
%% 开始寻找两个数据点之间的最大（或最小值）
for i=1:length(segpos)
    for j=0:seglength(i) - 1
        typeapos(typeaindex) = bppos(segpos(i)  + j);
        if type == Constants.TYPE_DBP            
            [~ , typebpos(typebindex)] = max(bp(bppos(segpos(i) + j):bppos(segpos(i) + j + 1)));
        else            
            [~ , typebpos(typebindex)] = min(bp(bppos(segpos(i) + j):bppos(segpos(i) + j + 1)));
        end
        typebpos(typebindex) = typebpos(typebindex) + typeapos(typeaindex) - 1;
        % 找到两个最大点后，就开始反向更新typea的值
        if j >= 1
            if type == Constants.TYPE_DBP            
                [~ , typeapos(typeaindex)] = min(bp(typebpos(typebindex - 1):typebpos(typebindex)));
            else            
                [~ , typeapos(typeaindex)] = max(bp(typebpos(typebindex - 1):typebpos(typebindex)));
            end            
            typeapos(typeaindex ) = typeapos(typeaindex ) + typebpos(typebindex - 1)  - 1;
        else
            typeapos(typeaindex) = NaN; % 将该段首位对应的typea值去掉，因其可能不是最大或最小值
        end
        typebindex = typebindex + 1;        
        typeaindex = typeaindex + 1;
    end
    
    % 将typea掐头去尾
%     typeapos(typeaindex) = bppos(segpos(i) + seglength(i));
%     typeaindex = typeaindex + 1;
    
end

typeapos=typeapos(~isnan(typeapos));
typebpos=typebpos(~isnan(typebpos));

if type == Constants.TYPE_DBP
    dbpann = typeapos;
    sbpann = typebpos;
else
    dbpann = typebpos;
    sbpann = typeapos;
end

%% 最后把不合法值剔除掉
sbpann = BSelectLegalIndexesWithReasonableValue(bp, sbpann, Constants.TYEP_SBP);
dbpann = BSelectLegalIndexesWithReasonableValue(bp, dbpann, Constants.TYPE_DBP);

end