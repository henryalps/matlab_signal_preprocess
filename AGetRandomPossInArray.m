function idx = AGetRandomPossInArray(arraylen, idxlen)
%% 随机获取长度为arraylen数组中一系列随机的index，位置所占长度为idxlen
% OUTPUT
% pos - [1×数组长度] 逻辑数组，true表示取该位置
idx = false(1, arraylen);
randpos = randperm(arraylen);
idx(randpos(1:idxlen)) = true;
end