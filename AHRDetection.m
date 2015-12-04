function rpos=AHRDetection(ecg)
    SAMPLE = 1;
    COMPLEX = 2;

    method = SAMPLE;
    
    if method == SAMPLE
        [rpos,~] = HR_detection(ecg'); 
        rpos = rpos(:,1);
    else
        rpos = pantompkins_qrs(ecg, getSampleRate());
    end
end
