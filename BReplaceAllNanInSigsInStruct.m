function sig = BReplaceAllNanInSigsInStruct(sig, replaceVal)
%% 将结构体sig中所有类型为数组的属性中的nan都替换成replaceVal
    fields = fieldnames(sig);
    
    for index = 1:length(fields)
        tmpcellarray = getfield(sig, fields{index});
        try
            tmpcellarray(isnan(tmpcellarray)) = replaceVal;
            sig = setfield(sig, fields{index}, tmpcellarray);
        catch e
            continue
        end
    end
end