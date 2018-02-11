
function [R,D,lambda,rho] = DrawRDbound(image, graphical_output)
%
% INPUT:  image file (image), graphical_output ('Y' or 'N') controls
% whether the program outputs any figures.
%
% OUTPUT: Rate (R) and distortion (D), sampled at values of lambda
% (lambda)for costs rho from Assignment 5
%
% Example of usage: [R,D,lambda,rho] = DrawRDbound('130.bmp','Y');
%

X = imread(image);
if graphical_output=='Y', figure, imshow(X), title('The cover image'),end

X  = double(X);
sz = size(X);
i  = 2 : sz(1) - 1;
j  = 2 : sz(2) - 1;
rho = 1/4 * (abs(X(i,j)-X(i+1,j))+abs(X(i,j)-X(i-1,j))+abs(X(i,j)-X(i,j+1))+abs(X(i,j)-X(i,j-1)));
rho = 1./(1 + rho);
lambda = (1.2).^(-30 : 50);

R = zeros(1, length(lambda));
D = zeros(1, length(lambda));

for k = 1 : length(lambda)
    p = exp(-lambda(k) * rho(:))./(1 + exp(-lambda(k) * rho(:)));
    R(k) = sum(hbin(p));
    D(k) = sum(rho(:).*p);
end

R = R/numel(rho);  % Normalize the payload to image size (obtain rate)
D = D/numel(rho);  % Normalize the distortion to image size
% if graphical_output=='Y', figure, plot(lambda, R, '-k'), title(['Payload per pixel ' image]), xlabel('Lambda'), ylabel('Rate (bpp)'), end
% if graphical_output=='Y', figure, plot(lambda, D, '-k'), title(['Distortion per pixel ' image]), xlabel('Lambda'), ylabel('Distortion per pixel'), end
if graphical_output=='Y', figure, plot(R, D, '-k'), title(['Rate--distortion bound ' image]), xlabel('Rate (bpp)'), ylabel('Distortion per pixel'), end
if graphical_output=='Y', figure, plot(sort(rho(:))), title(['Profile of costs for ' image]), end

% Np = 10000;         % Np pixels with the largest p will be displayed as a binary image
% [~,ind] = sort(-p); % Sort the probabilities from the largest to the smallest
% if graphical_output=='Y', figure, imshow(reshape(uint8(255*(p >= p(ind(Np)))),[sz(1)-2 sz(2)-2])), end

function y = hbin(x)
y = zeros(size(x));
I = abs(x-0.5)<0.4999999;
y(I) = -x(I).*log2(x(I)) - (1-x(I)).*log2(1-x(I));
