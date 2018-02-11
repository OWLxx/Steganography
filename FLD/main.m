x = randn(10, 1000);
y = randn(10, 1000);
a = [0, 0.25, 0.5, 0.75, 1, 1.5];
pe = zeros(1,6);
k = 1;
for i = a
    [v, pe(k)] = FLD(x, i + randn(10, 1000));
    figure(1);
    k = k+1;
    legend('0', '0.25', '0.5', '0.75', '1', '1.5')
end
hold off;
figure(2)
plot(a, pe)
xlabel('a'); ylabel('P_E')