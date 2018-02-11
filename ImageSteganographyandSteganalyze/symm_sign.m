
function As = symm_sign(A,T,order)
%
% Sign symmetrization routine. The purpose is to reduce the feature
% dimensionality and make the features more populated.
% A is an array of features of size (2*T+1)^order, otherwise error is
% outputted.

% Symmetrization by sign pertains to the fact that, fundamentally,
% the differences between consecutive pixels in a natural image (both cover
% and stego) d1, d2, d3, ..., have the same probability of occurrence as
% -d1, -d2, -d3, ... The dimensionality reduction is from (2T+1)^order to
% 1 + 1/2*((2T+1)^order - 1).

B = 2*T+1;
m = 2;
red = 1 + 1/2*(B^order - 1);
As = zeros(red, 1);
done = zeros(size(A));

switch order
    case 3
        if numel(A) == B^3
            As(1) = A(T+1,T+1,T+1); % The only non-marginalized bin is the origin (0,0,0)
            for i = -T : T
                for j = -T : T
                    for k = -T : T
                        if (abs(i)+abs(j)+abs(k)~=0) && (done(i+T+1,j+T+1,k+T+1) == 0)
                            As(m) = A(i+T+1,j+T+1,k+T+1) + A(T+1-i,T+1-j,T+1-k);
                            done(i+T+1,j+T+1,k+T+1) = 1;
                            done(T+1-i,T+1-j,T+1-k) = 1;
                            m = m + 1;
                        end
                    end
                end
            end
        else
            fprintf('Number of elements does not match the routine.\n')
        end
        As = As(:);
    case 4
         if numel(A) == B^4
            As(1) = A(T+1,T+1,T+1,T+1);  % The only non-marginalized bin is the origin (0,0,0,0)
            for i = -T : T
                for j = -T : T
                    for k = -T : T
                        for n = -T : T
                            if (abs(i)+abs(j)+abs(k)+abs(n)~=0) && (done(i+T+1,j+T+1,k+T+1,n+T+1) == 0)
                                As(m) = A(i+T+1,j+T+1,k+T+1,n+T+1) + A(T+1-i,T+1-j,T+1-k,T+1-n);
                                done(i+T+1,j+T+1,k+T+1,n+T+1) = 1;
                                done(T+1-i,T+1-j,T+1-k,T+1-n) = 1;
                                m = m + 1;
                            end
                        end
                    end
                end
            end
        else
            fprintf('Number of elements does not match the routine.\n')
        end
        As = As(:);
    otherwise
        fprintf('*** ERROR: Order not equal to 3 or 4! ***\n')
end
