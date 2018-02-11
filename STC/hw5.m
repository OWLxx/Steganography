% hw5 Xin Wen
h = 5;                      % change h to 8 and 10 for different output
Nruns = 10;
image = '130.bmp';
[R,D,lambda,rho] = DrawRDbound(image,'N');
overallCost = zeros(1, 9);  % cost over different w, with same h

for w=2:10
    costs_per_pixel = zeros(Nruns, 1);
    Hmatrices = zeros(h, w, Nruns);
    for k=1:Nruns
        H_hat = round(rand(h,w)); 
        H_hat(1,:) = 1;           
        H_hat(end,:) = 1;
        rep = 100;
        [code,alpha] = create_code_from_submatrix(H_hat, rep);
        
        X = double(imread(image));  % Cover image
        X = X(2:end-1,2:end-1);     
        x = mod(X(:), 2);           
        message = round(rand(1,floor(alpha*numel(x))));
        [y cost] = STC_Embed(message, x, rho, code);    % Embed message in x using code for costs in rho
        costs_per_pixel(k) = cost/numel(x);     % save costs per pixel
        m = min(numel(message), numel(extracted_message));
    end
    
    [mincost, minindex] = min(costs_per_pixel);
    bestHmatrix = Hmatrices(:, :, minindex);     % You could retrive the best Hmatrix
    overallCost(w-1) = mincost
end
if h==10
    w = 2:1:10;
    alpha = 1./w;
    plot(alpha, overallCost);
    xlabel('alpha')
    ylabel('distortion per pixel')
    title('rate distortion for h=10')
end

