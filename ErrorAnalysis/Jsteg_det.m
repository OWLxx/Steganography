
function beta_hat = Jsteg_det(image)
% This function computes an estimated change rate of Jsteg-modified quantized
% DCT coefficients in file (or array) 'image'

if ischar(image)                                            % If image is a character string, interpret it as a filename
    im = jpeg_read(image);               

    if im.jpeg_components == 1                              % If image is grayscale               
        Lum = im.coef_arrays{im.comp_info(1).component_id}; % Luminance coefficient array
        All = Lum(:);
    end

    if im.jpeg_components == 3                              % If image is color
        Lum = im.coef_arrays{im.comp_info(1).component_id}; % Luminance coefficient array
        U = im.coef_arrays{im.comp_info(2).component_id};   % U coefficient array
        V = im.coef_arrays{im.comp_info(3).component_id};   % V coefficient array
        All = [Lum(:); U(:); V(:)];
    end
    
else
    All = image(:);                                         % If 'image' is not a character string, it is interpreted as the array of quantized DCTs
end

hmin = min(All);
hmax = max(All);
if mod(abs(hmin),2) == 1, hmin = hmin - 1;end
if mod(abs(hmax),2) == 0, hmax = hmax + 1;end

h    = hist(All,hmin:hmax);                                 % h(0) bin is h(1+abs(hmin))
z    = 1 + abs(hmin);
sum1 = sum(h(z+2:2:end)-h(z+3:2:end));
sum2 = sum(h(z-1:-2:1)-h(z-2:-2:1));
beta_hat = 1/2 * (1 - (sum1 + sum2)/h(z+1));                % Notice the factor of 1/2 to estimate beta rather than alpha

[h(z+1)]