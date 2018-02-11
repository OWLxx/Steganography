function [ cost ] = RD( fileName )
img = imread(fileName);
[m, n] = size(img);
R = zeros(m, n);
cost = zeros(m,n);
for i = 2:m-1
    for j = 2:n-1
        cur = img(i, j);
        R(i, j) = 1/4 *(abs(cur-img(i, j-1)) + abs(cur-img(i, j+1)) + abs(cur-img(i-1, j)) + abs(cur-img(i+1, j)));
    end
end
cost = 1 ./ (1 + R);
cost_temp = cost(2:m-1, 2:n-1);
cost_temp = sort(reshape(cost_temp, (m-2)*(n-2), 1));
subplot(2,1,1);
plot(cost_temp);
xlabel('Pixel no.');
ylabel('rho');
title(strcat(fileName));

lambda = zeros(51, 1);
alpha = zeros(51, 1);
d = zeros(51, 1);
for i = 1:51
    lambda(i) = 1.2^(-31 + i);
    l = lambda(i);
    e = exp(-l .* cost);
    alpha(i) = 1./((m-2)*(n-2)) * sum(sum(h(1./(1+e))));
    d(i) = 1./((m-2)*(n-2)) * sum(sum(cost.*(e./(1+e))));
end
subplot(2,1,2);
plot(alpha, d);
xlabel('Rate(bpp)');
ylabel('Distortion per pixel');
title('R-D');

lambda = 1.2^(-31+31);
prob = zeros(m, n);
for i = 2:m-1
    for j = 2:n-1
        miu = -1/lambda;
        prob(i, j) = 1 / (1 + exp(-cost(i,j)/miu)); 
    end
end
prob_temp = sort(reshape(prob(2:m-1, 2:n-1), (m-2)*(n-2),1 ));
threshold = prob_temp((m-2)*(n-2)-50000);    % select the largest 50000 pixel with  highest probability
newimg = zeros(m, n);
for i = 1:m
    for j = 1:n
        if prob(i, j) >= threshold
            newimg(i, j) = 255;
        end
    end
end
figure(2);
imshow(newimg);


end

