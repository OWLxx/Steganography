cover = 'covers/L1000724.jpg';
seed = 1:10000;
% beta = zeros(size(seed));
% for i = seed
%     [Y, ~] = Jsteg_simulator(cover, i, 0.2);
%     beta(i) = Jsteg_det(Y);
% end
% save('beta10000.mat', 'beta')
load('beta10000.mat');
beta_mean = mean(beta);
bias = beta_mean - 0.2;
fprintf('Bias is %f', bias);
beta = beta - 0.2;
count = hist(beta, 50);
count = count * 1.001;
x = linspace(min(beta), max(beta), 50);
figure(1);
plot(x, count, 'r+')
hold on;
f = fit(x.', count.', 'gauss1')
plot(f, x, count)
figure(1)
xlabel('betai - betahat'); ylabel('Count');
