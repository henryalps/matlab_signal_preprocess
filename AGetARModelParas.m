function paras = AGetARModelParas(sig)
    tmp = ar(sig, 5);
    paras = tmp.a;
    paras = paras(2:end); %% 第一个参数就是当前时刻的系数，一般为1
end