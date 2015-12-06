function paras = AGetARModelParas(sig)
    tmp = ar(sig, 5);
    paras = tmp.a;
end