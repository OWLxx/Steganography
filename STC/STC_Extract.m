function message = STC_Extract(code,y)

Npix = numel(y);                    % No. of pixels in stego object
Nblock = floor(Npix/code.n);        % No. of pixel blocks
rep = sum(code.shift);              % No. of bits extracted from each block
message = zeros(1, Nblock*rep);     % Message to be extracted

for i = 1 : Nblock                  % Extract a message chunk from each block
    m_index_segment = ((i-1)*rep +1 : i*rep);
    y_index_segment = ((i-1)*code.n +1 : i*code.n);
    message(m_index_segment) = calc_syndrome(code,y(y_index_segment));
end