function config = BReadConfig()
    try
        config = load('config.mat');
        config = config.config;
    catch e
         config.timelength=60; % 每组数据的时间长度
         save('config.mat','config');
    end
    config.samplerate=getSampleRate();
end