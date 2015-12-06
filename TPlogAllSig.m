function TPlogAllSig(bp,ecg,ppg,bpann,rpos,tm)
    close all
    figure
    subplot(3,1,1)
    plot(tm,bp),hold on,plot(tm(bpann),bp(bpann),'*r');
    subplot(3,1,2)
    plot(tm,ecg),hold on,plot(tm(rpos),ecg(rpos),'*r');
    subplot(3,1,3)
    plot(tm,ppg)
end