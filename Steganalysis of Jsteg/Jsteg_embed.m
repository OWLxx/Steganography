
function stego = Jsteg_embed(cover,stego_file,message,key)
%
% This routine embeds binary messages in non-zero, non-one DCT coefficients
%   of a JPEG file. The bits are pseudo-randomly scattered using a stego key.
% The input cover is either a JPEG file name or a jpeg structure (see Sallee's
%   Matlab JPEG toolbox)
% The output stego is a jpeg structure for the stego JPEG image
% The routine also automatically displays the stego JPEG image
% The embedding mechanism is LSB embedding in non-zero and non-one DCT
%   coeffs, which is a J-steg with key-dependent pseudo-random embedding.

if ischar(cover), cover=jpeg_read(cover);end                    % If cover is a character string, interpret it as a filename

Lum = cover.coef_arrays{cover.comp_info(1).component_id};       % Luminance coefficient array
N_Lum = numel(Lum);                                             % Number of all luminance coefficients
All = Lum(:);

if cover.jpeg_components==3                                     % If the cover is a color image ...
    U = cover.coef_arrays{cover.comp_info(2).component_id};     % U chrominance coefficient array
    V = cover.coef_arrays{cover.comp_info(3).component_id};     % V chrominance coefficient array
    N_U = numel(U);                                             % Number of all U chrominance coefficients
    All = [Lum(:);U(:);V(:)];
end

N01 = find(All~=0 & All~=1);                                    % Indices of all non-zero and non-one coeffs
Capacity = length(N01);                                         % Capacity = maximal embeddable message lentgh
rand('state',key);                                              % Initialize the PRNG
Order = randperm(length(N01));                                  % Random order through all non-zero and non-one coeffs

L = min(length(message),Capacity);                              % If message is longer than capacity, cut it short

Replace=find(mod(All(N01(Order(1:L))),2)~=message(1:L)');       % Indices of all coeffs whose LSB must be modified
All_stego=All;                                                  % All_stego is a column vector storing the stego DCT coeffs
All_stego(N01(Order(Replace)))=All_stego(N01(Order(Replace)))+(-1).^(mod(All_stego(N01(Order(Replace))),2));    % The actual LSB embedding

stego=cover;                                                    % The stego object structure
Aux = All_stego(1:N_Lum);                                       % All stego coeffs
Aux = reshape(Aux,size(Lum));
stego.coef_arrays{stego.comp_info(1).component_id}=Aux;         % Luminance of the stego object

if cover.jpeg_components==3                                     % If the cover is a color image ...
    Aux = All_stego(N_Lum+1:N_Lum+N_U);                         % Aux contains all U chrominance stego coeffs
    Aux = reshape(Aux,size(U));
    stego.coef_arrays{stego.comp_info(2).component_id}=Aux;     % U chrominance of the stego object
    
    Aux=All_stego(N_Lum+N_U+1:end);                             % Aux contains all V chrominance stego coeffs
    Aux = reshape(Aux,size(V));
    stego.coef_arrays{stego.comp_info(3).component_id}=Aux;     % V chrominance of the stego object
end

jpeg_write(stego,stego_file);                                   % stego_file
% imshow(stego_file);

if L < length(message)
fprintf('\n  **Warning** Message had to be truncated to fit inside your cover image\n\n')
end
fprintf('  Total number of embedded bits   = %d\n', L)
fprintf('  Embedded relative payload alpha = %f\n', L/Capacity)
