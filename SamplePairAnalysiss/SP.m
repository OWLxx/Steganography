function [ beta ] = SP( image )
[M, N] = size(image);
image = double(image);
% horizontal pairs
x1 = 0;
y1 = 0;
kappa1 = 0;
% vertical pairs
x2 = 0;
y2 = 0;
kappa2 = 0;
for i = 1:M
    for j = 1:N
        if (j ~= N) 
            r1 = image(i, j);
            s1 = image(i, j+1);
            if (mod(s1, 2)==0 && r1<s1) || (mod(s1, 2)==1 && r1>s1)
                x1 = x1 + 1;
            end
            if (mod(s1, 2)==0 && r1>s1) || (mod(s1, 2)==1 && r1<s1)
                y1 = y1 + 1;
            end
            if (ceil(r1/2)==ceil(s1/2)) 
                kappa1 = kappa1 + 1; 
            end             
        end
        if i ~= M
            r2 = image(i, j);
            s2 = image(i+1, j);
            if (mod(s2, 2)==0 && r2<s2) || (mod(s2, 2)==1 && r2>s2)
                x2 = x2 + 1;
            end
            if (mod(s2, 2)==0 && r2>s2) || (mod(s2, 2)==1 && r2<s2)
                y2 = y2 + 1;
            end
            if (ceil(r1/2)==ceil(s1/2)) 
                kappa2 = kappa2 + 1; 
            end
        end
    end
end

a = 2*kappa1;
b = 2*(2*x1-M*(N-1));
c = y1-x1;
beta11 = real((-b + (b^2-4*a*c)^0.5)/(2*a));
beta12 = real((-b - (b^2-4*a*c)^0.5)/(2*a));
beta1 = min([beta11, beta12])

a = 2*kappa2;
b = 2*(2*x2-M*(N-1));
c = y2-x2;
beta121 = real((-b + (b^2-4*a*c)^0.5)/(2*a));
beta122 = real((-b - (b^2-4*a*c)^0.5)/(2*a));
beta2 = min([beta121, beta122])
beta = max([beta1, beta2])

end

