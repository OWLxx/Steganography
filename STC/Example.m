function Example(image)

[R,D,lambda,rho] = DrawRDbound(image,'N');   % Obtain data for R-D bound and costs for cover 'image'
figure, plot(R, D, 'k')                      % Draw R-D bound
title(['Rate--distortion bound ' image]), xlabel('Rate (bpp)'), ylabel('Distortion per pixel'), 
hold on

h = 8;       % Constraint height h (no. of rows of H_hat)
w = 4;       % No. of columns of H_hat
alpha = 1/w; % Relative message length that can be embedded with codes built from H_hat

H_hat = round(rand(h,w)); % H_hat is generated randomly
H_hat(1,:) = 1;           % The first and last rows of H_hat should be all ones
H_hat(end,:) = 1;

rep = 100;   % Number of message bits that will be embedded in each pixel block
             % Each block will have rep*w pixels => we can embed rep bits.
[code,alpha] = create_code_from_submatrix(H_hat, rep);  % Create the STC

% Test the code

X = double(imread(image));  % Cover image
X = X(2:end-1,2:end-1);     % rhos are available only for the inner portion of X (see DrawRDbound.m), thus we crop X
x = mod(X(:), 2);           % LSBs of image X arranged as a 1-d vector
message = round(rand(1,floor(alpha*numel(x)))); % A random binary message of relative length alpha

[y cost] = STC_Embed(message, x, rho, code);    % Embed message in x using code for costs in rho
fprintf('  Relative payload alpha = %f  embedded with average cost of %f \n', alpha, cost/numel(x))
plot(alpha, cost/numel(x),'k*') % Draw the point in the R-D bound plot to see how far you are from the bound
                                % Note that the point should be above the bound (the distortion will be slightly larger)
extracted_message = STC_Extract(code,y);  % Extract the message from stego vector y using code

m = min(numel(message), numel(extracted_message));

if sum(message(1:m) == extracted_message(1:m)) == m
    fprintf('  Message correctly extracted.\n')
else
    fprintf('  ERROR: Message not extracted correctly.\n')
end

