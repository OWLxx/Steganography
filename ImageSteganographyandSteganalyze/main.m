% step 3- Compute stego image
% genStegoImage(0.5, 'covers', 'stego050', 'pgm' )

% step 4- KB features
% genKBfeature('stego050')

% step 5- Steganalyze
% avgPe = zeros(1,6);
% avgAD = zeros(1,6)
% [avgPe(1), avgAD(1)] = calError('coversKB_features.mat', 'stego005KB_features.mat')
% [avgPe(2), avgAD(2)] = calError('coversKB_features.mat', 'stego010KB_features.mat')
% [avgPe(3), avgAD(3)] = calError('coversKB_features.mat', 'stego020KB_features.mat')
% [avgPe(4), avgAD(4)] = calError('coversKB_features.mat', 'stego030KB_features.mat')
% [avgPe(5), avgAD(5)] = calError('coversKB_features.mat', 'stego040KB_features.mat')
% [avgPe(6), avgAD(6)] = calError('coversKB_features.mat', 'stego050KB_features.mat')
alpha = [0.05, 0.1, 0.2, 0.3, 0.4, 0.5];
avgPe = [0.4760    0.4545    0.4060    0.3390    0.2895    0.2373];
plot(alpha, avgPe)
hold on
scatter(alpha,  avgPe, 'b')
xlabel('alpha')
ylabel('P_e')
hold off