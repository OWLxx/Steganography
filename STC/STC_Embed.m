  function [y cost] = STC_Embed(message, x, rho, code)
% This function embeds a binary message 'message' in a binary cover 
% object 'x' (represented as a binary vector, e.g., LSBs of pixels)
% using a syndrome-trellis 'code' to minimize the embedding cost captured 
% using the costs 'rho'.
%
% message = binary vector of message bits
% x    = binary cover vector or matrix (e.g., cover LSBs)
% rho  = embedding costs (must have the same number of elements as x)
% code = STC code obtained using the command: 
%
%   code = create_code_from_submatrix(H_hat, rep);
%
% where rep is the number of repetitions of the submatrix H_hat in H.
% This code can embed rep = sum(code.shift) message bits in code.n pixels.
% See help for create_code_from_submatrix about the details of the code. 

if numel(x) ~= numel(rho)
    fprintf(' *** ERROR: costs rho and cover x must have the same number of elements. ***\n')
end

x = x(:);
rho = rho(:);
Npix = numel(x);                    % Number of pixels
rep = sum(code.shift);              % Number of bits per pixel block
Nblocks = floor(Npix/code.n);       % Number of pixel blocks
c = zeros(1, Nblocks);              % Embedding costs in each block

% The algorithm embeds 'rep' message bits in blocks of code.n pixels.
% Any leftover pixels will not be used for embedding.
% Messages longer than Nblocks*rep bits will be truncated, shorter padded
% with zeros.

y = x;                                  % Declaring the stego vector y
max_message_length = Nblocks*rep;       % Maximal embeddable message length
if numel(message) < max_message_length  % If message shorter than maximal, pad with zeros
    message(numel(message)+1:max_message_length) = zeros(1, max_message_length - numel(message));
end
if numel(message) > max_message_length  % If message longer than maximal, issue warning
    % fprintf(' *** Warning: Message of %d bits is too long, truncated to %d bits ***\n', numel(message), max_message_length)
end

for i = 1 : Nblocks                     % Embed a chunk of message in a chunk of cover (block)
    m_index_segment = ((i-1)*rep +1 : i*rep);
    y_index_segment = ((i-1)*code.n +1 : i*code.n);
    [y(y_index_segment) c(i)] = dual_viterbi(code, x(y_index_segment), rho(y_index_segment), message(m_index_segment));
end

cost = sum(c);

