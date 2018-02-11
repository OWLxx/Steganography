
function message = Jsteg_read(stego,key)
% This function extracts the message embedded in a JPEG file using
% Jsteg_embed.m.
% stego is the stego file name or the stego jpeg structure.
% key is the stego key.
% msg is the extracted bitstream (header in the bitstream must be used to
% inform the recipient of the message length)

if ischar(stego), im=jpeg_read(stego);end               % If cover is a character string, interpret it as a filename

Lum = im.coef_arrays{im.comp_info(1).component_id};     % Luminance coefficient array
All = Lum(:);

if im.jpeg_components==3                                % If stego is a color image
    U = im.coef_arrays{im.comp_info(2).component_id};   % U coefficient array
    V = im.coef_arrays{im.comp_info(3).component_id};   % V coefficient array
    All = [Lum(:);U(:);V(:)];
end

N01 = find(All~=0 & All~=1);                            % Indices of all non-zero non-one coeffs
rand('state',key);                                      % Initialize the PRNG using the stego key
Order = randperm(length(N01));                          % Pseudo-random order in which the non-zero and non-one coeffs are visited

message = mod(All(N01(Order)),2);                       % Extracted message (from all non-zero non-one coeffs)