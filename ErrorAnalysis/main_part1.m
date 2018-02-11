images = filenames('covers', 'jpg');
N = size(images,2); 
% beta = zeros(N,1);
% for i=1:1:N
%     % read image
%     curName = images(i).name;
%     coverpath = strcat('covers\', curName);
%     beta(i) = Jsteg_det(coverpath);
% end

% the 1000 beta value is precalculated and saved in beta.mat file
load('beta.mat');
figure(1)
hist(beta, 50);
xlabel('beta_i'); ylabel('Count');
threshold = 0;
beta0 = beta(beta>threshold);

beta0_sort = sort(beta0);
N = numel(beta0);
figure(2)
lgX = log(beta0_sort)';
lgY = log([N:-1:1]);
plot(lgX, lgY, 'bo');
xlabel('log x'); ylabel('logPr(Err>x)')
hold on;
% the line is observed linear between -3.5 and -1.5 
fitX = lgX(-5<=lgX) ;
fitX = fitX(fitX<=-3.5) ;
fitY = lgY(-5<=lgX );
fitY = fitY(1:numel(fitX));

v = polyfit(fitX, fitY, 1);
lineX = -6:0.1:-2
lineY = lineX .* v(1) + v(2) ;
plot(lineX, lineY, 'k')
v(1)