
% This function computes a 625-dimensional column feature vector for image
% X. See hint.m for the recommended values of the parameters q, T, and
% order

function f = KB_feature(X,q,T,order)
D = residual(X,2,'KB');         % Computes the image residual using the KB filter
Dq = Quant(D,q,T);              % Quantizes the residual by quant. step q and rounds to [-T,...,T]

% Computes the (2T=1)^order dimensional co-occurrence matrices along the horisontal and vertical
% directions and arranges the co-occurrence into a column vector

f = Cooc(Dq,order,'ver',T) + Cooc(Dq,order,'hor',T);
f = f(:);
