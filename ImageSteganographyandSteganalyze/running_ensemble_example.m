
% ensemble.m by default divides the feature files into two halves -- one
% will be used for training, the other for testing. The division is driven
% by a user-specified seed. The input into the ensemble are the paths to
% the cover and stego features (stego embedded with a certain fixed
% payload). You will be running the ensemble for each cover-stego pair for
% each payload separately, e.g., cover-stego(0.05bpp), cover-stego(0.1bpp), ...,
% cover-stego(0.5bpp). There will be 6 payloads: 0.05, 0.1, 0.2, ..., 0.5.

Nruns = 10;              % Number of random splits of the database into halves over which we will be avergaging the testing error
Pe = zeros(1,Nruns);     % Testing error for each run

settings.cover = 'D:\Department\Course562\Final_stego_project\cover\KB_features.mat';    % This must be the complete path, including the feature file.mat name.
settings.stego = 'D:\Department\Course562\Final_stego_project\stego020\KB_features.mat'; % This must be the complete path, including the feature file.mat name.
    
for seed = 1 : Nruns
    settings.seed_trntst = seed;    
    results = ensemble(settings);
    Pe(seed) = results.testing_error;   % Testing error for seed-th split
end

avgPe = mean(Pe);
avgAD = mean(abs(Pe - avgPe));

% The result is the average error P_e and the
% statistical spread (mean absolute deviation, MAD)