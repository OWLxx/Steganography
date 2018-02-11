function [V,PE] = FLD(X, Y)
%X ... a matrix of cover features as columns
%Y ... a matrix stego features as columns
%v ... generalized eigenvector
%PE ... total minimal detection error under equal priors
[d, N] = size(X);
ux = mean(X, 2);
uy = mean(Y, 2);
size(repmat(ux, 1, N))
MX = X - ux;
MY = Y - uy;
SW = MX * MX' + MY*MY';
V = inv(SW) * (ux-uy);
Px = V' * X;
Py = V' * Y;
if mean(Px) > mean(Py)
    Px = -Px;
    Py = -Py;
end
P = [Px Py];
I = [zeros(N,1); ones(N,1)];
[~,order] = sort(P);
PFA = zeros(1,2*N+1);
PD = zeros(1,2*N+1);
PFA(1) = 1;
PD(1) = 1;
for i = 1:2*N
    if (I(order(i))==0)
        PFA(i+1) = PFA(i) - 1/N;
        PD(i+1) = PD(i);
    else
        PFA(i+1) = PFA(i);
        PD(i+1) = PD(i) - 1/N;
    end        
end
plot(PFA,PD);
axis([0, 1, 0, 1]);
xlabel('P_F_A');ylabel('P_D');
PE = min((PFA+1-PD)./2)
hold on;

end
