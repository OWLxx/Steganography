function [ avgPe, avgAD ] = calError( coverFile, stegoFile )

Nruns = 10;              % Number of random splits of the database into halves over which we will be avergaging the testing error
Pe = zeros(1,Nruns);     % Testing error for each run

settings.cover = coverFile;    % This must be the complete path, including the feature file.mat name.
settings.stego = stegoFile; % This must be the complete path, including the feature file.mat name.
settings.ratio = 0.8

for seed = 1 : Nruns
    settings.seed_trntst = seed;    
    results = ensemble(settings);
    Pe(seed) = results.testing_error;   % Testing error for seed-th split
end

avgPe = mean(Pe)
avgAD = mean(abs(Pe - avgPe))


end

