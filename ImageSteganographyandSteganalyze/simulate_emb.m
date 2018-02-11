
function Y = simulate_emb(X,alpha,rho)
%
% Simulates binary embedding (binary costs) using LSB Matching
% X ....... cover image with n pixels from {0,1,...,255}
% alpha ... relative payload in bits per pixel
% rho ..... vector costs of length n
% Y ....... stego image "embedded" with payload alpha
% embedding probability ?i = exp(???i)/(1 + exp(???i))

% First find lambda using binary search
L = 10^(-6);                % [L,R] = initial range within which lambda will be searched for
R = 10^6;
lambda_accuracy = 10^(-6);  % Accuracy with which lambda will be determined
n = numel(X);               % Number of pixels

pL = prob(L,rho); fL = 1/n*sum(h(pL)) - alpha;
pR = prob(R,rho); fR = 1/n*sum(h(pR)) - alpha;

while fL*fR > 0             % If range for lambda does not cover alpha, enlarge the search interval
    if fL > 0, R = 2*R;
    else       L = L/2; end
    pL = prob(L,rho); fL = 1/n*sum(h(pL)) - alpha;
    pR = prob(R,rho); fR = 1/n*sum(h(pR)) - alpha;
end

while abs(L-R) > lambda_accuracy
    lambda = (L+R)/2;
    plambda = prob(lambda,rho); fM = 1/n*sum(h(plambda)) - alpha;
    if fL*fM < 0, R = lambda; fR = fM;
    else          L = lambda; fL = fM; end
end

% Simulating the actual embedding
r = rand(size(X));
X = double(X);
Y = X;
Modified = (r<plambda);
Y(Modified) = X(Modified) + 2*(round(r(Modified))) - 1; % Modifying X by +-1
Y(Y>255) = 254;   % Taking care of boundary cases
Y(Y<0)   = 1;

function y = h(x)
% Binary entropy function expressed in bits
z = x(abs(x-0.5)<0.4999999); % To prevent underflow
y = -z .* log2(z) - (1-z) .* log2(1-z);

function y = prob(lambda,rho)
% Embedding change probability = e^-lambda*rho / (1 + e^-lambda*rho)
e = exp(-lambda*rho);  % Precalculate for speed
y = e ./ (1 + e);
