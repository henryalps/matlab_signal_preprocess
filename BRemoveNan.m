function sigWithoutNaN = BRemoveNan(sigWithNaN)
    
    sigWithoutNaN=sigWithNaN;

    defaultVal = 0;
    nanPos =isnan(sigWithNaN);
    
    sigWithoutNaN(nanPos) = defaultVal;
    
end