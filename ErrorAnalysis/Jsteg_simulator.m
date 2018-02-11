
function [Y,beta_hat] = Jsteg_simulator(cover,key,beta)
%
% This routine simulates the impact of embedding using Jsteg.
% It flips the LSBs of a beta fraction of all DCT coefficients in the 
% JPEG file 'cover' that are not equal to 0 or 1.
% The output is the array of quantized DCT coefficients Y (not a JPEG file).
% This is for research purposes to test quantitative steganalyzers.

% INPUT:  1) JPEG image 'cover' (could be directly the array of quantized DCTs)
%         2) Secret key 'key' (a positive integer)
%         3) Change rate beta (0 < beta < 1)
%
% OUTPUT: Y a column vector of quantized DCT coefficients obtained by
% flipping a beta portion of non 0 non 1 coefficients in DCTs of 'cover'.
% Y contains both luminance, and chrominance values if 'cover' is a color image.
%

if ischar(cover)
    cover = jpeg_read(cover);                                       % If cover is a character string, interpret it as a filename

    if cover.jpeg_components == 1                                   % If the cover is a grayscale image ...
        Lum = cover.coef_arrays{cover.comp_info(1).component_id};   % Luminance coefficient array
        All = Lum(:);
    end

    if cover.jpeg_components == 3                                   % If the cover is a color image ...
        Lum = cover.coef_arrays{cover.comp_info(1).component_id};   % Luminance coefficient array
        U = cover.coef_arrays{cover.comp_info(2).component_id};     % U chrominance coefficient array
        V = cover.coef_arrays{cover.comp_info(3).component_id};     % V chrominance coefficient array
        All = [Lum(:); U(:); V(:)];
    end
else
    All = cover(:);
end
        
N01 = find(All~=0 & All~=1);                                    % Indices of all non-zero and non-one coeffs
Capacity = length(N01);                                         % Embedding capacity = maximal embeddable message lentgh

rand('state',key);                                              % Initialize the PRNG with a secret key
Order = randperm(length(N01));                                  % Random order through all non-zero and non-one coeffs

Nchng = floor(beta*Capacity);                                   % Number of coeffs that will be changed

Y = All;                                                        % Y is a column vector storing the stego DCT coeffs
Y(N01(Order(1:Nchng))) = Y(N01(Order(1:Nchng)))+(-1).^(mod(Y(N01(Order(1:Nchng))),2));    % The actual LSB embedding

% Control output from Wang's detector

hmin = min(Y(:));
hmax = max(Y(:));
if mod(abs(hmin),2) == 1, hmin = hmin - 1;end
if mod(abs(hmax),2) == 0, hmax = hmax + 1;end

h    = hist(Y(:),hmin:hmax);                                  % h(0) bin is h(1+abs(hmin))
z    = 1+abs(hmin);
sum1 = sum(h(z+2:2:end)-h(z+3:2:end));
sum2 = sum(h(z-1:-2:1)-h(z-2:-2:1));
beta_hat = 1/2 * (1 - (sum1 + sum2)/h(z+1));
% [beta beta_hat]
