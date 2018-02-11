function y = h(x)
y = zeros(size(x));
I = abs(x - 0.5) < 0.4999999;
y(I) = -x(I).* log2(x(I)) - (1 - x(I)).* log2(1 - x(I));

end

