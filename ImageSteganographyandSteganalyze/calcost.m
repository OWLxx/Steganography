function [ cost ] = calcost(img)
% this function compute and return the cost of a image
% pixels on the boundary have 2 or 3 neighbor averaging cost
img = double(img);
[m, n] = size(img);
R = ones(m, n);

i  = 2 : m - 1;
j  = 2 : n - 1;
R(i, j) = 1/4 * (abs(img(i,j)-img(i+1,j))+abs(img(i,j)-img(i-1,j))+abs(img(i,j)-img(i,j+1))+abs(img(i,j)-img(i,j-1)));


% cornors and edges
R(1, 1) = 1/2 *(abs(img(1,1)-img(1, 2)) + abs(img(1,1)-img(2, 1)));
R(1, n) = 1/2 *(abs(img(1,n)-img(2, n)) + abs(img(1,n)-img(1, n-1)));
R(m, 1) = 1/2 *(abs(img(m,1)-img(m-1, 1)) + abs(img(m,1)-img(m, 2)));
R(m, n) = 1/2 *(abs(img(m,n)-img(m-1, n)) + abs(img(m,n)-img(m-1, n-1)));
for i = 2:m-1
    cur = img(i, 1);
    R(i, 1) = 1/3 * (abs(cur-img(i, 2)) + abs(cur-img(i-1, 1)) + abs(cur-img(i+1, 1)));
    cur = img(i, n);
    R(i, n) = 1/3 * (abs(cur-img(i, n-1)) + abs(cur-img(i-1, n)) + abs(cur-img(i+1, n)));
end
for i = 2:n-1
    cur = img(1, i);
    R(1, i) = 1/3 * (abs(cur-img(2, i)) + abs(cur-img(1, i-1)) + abs(cur-img(1, i+1)));
    cur = img(m, i);
    R(m, i) = 1/3 * (abs(cur-img(m-1, i)) + abs(cur-img(m, i-1)) + abs(cur-img(m, i+1)));
end
cost = 1 ./ (1 + R);

end

