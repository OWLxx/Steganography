% Bit-plane analysis tool, HW1-4
function LSBembeddingHelper(imagePath, L)

    A = imread(imagePath);
    r = A(:,:,1);
    g = A(:,:,2);
    b = A(:,:,3);

    if isequal(r,g,b)
        color = 0;
    else
        color = 1;
    end
    
    if ~color
        subplot(1,2,1);
        h = histogram(r);
        h.FaceColor = 'k';
        xlabel('value');
        ylabel('count');
        title('Histograme');
        subplot(1,2,2);
        [m, n] = size(r); % L=8 for LSB and L=1 for the MSB
        p1 = zeros(m,n);
        for i = 1:m
            for j = 1:n
                curPixel = dec2bin(r(i,j),8);
                p1(i, j) = str2num(num2str(curPixel(L)));  
            end
        end
        imshow(p1);
        title(['L=' num2str(L)]);
        
    else
        figure(1);
        subplot(2,2,1);
        h1 = histogram(r);
        h1.FaceColor = 'r';
        xlabel('value');
        ylabel('count');
        title('Histograme');
        subplot(2,2,2);
        h2 = histogram(g);
        h2.FaceColor = 'g';
        xlabel('value');
        ylabel('count');
        title('Histograme');
        subplot(2,2,3);
        h3 = histogram(b);
        h3.FaceColor = 'b';
        xlabel('value');
        ylabel('count');
        title('Histograme');
        
        figure(2);
        % r
         [m, n] = size(r); % L=8 for LSB and L=1 for the MSB
        p1 = zeros(m,n);   % find L bit at different channel
        pads = zeros(m,n); % add some color to the L plot 
        for i = 1:m
            for j = 1:n
                curPixel = dec2bin(r(i,j),8);
                p1(i, j) = str2num(num2str(curPixel(L)));  
            end
        end
        p1 = cat(3, p1, pads, pads);
        imshow(p1);
        title(['L=' num2str(L)]);
        
        figure(3);
        % g
        [m, n] = size(r); % L=8 for LSB and L=1 for the MSB
        p1 = zeros(m,n);
        for i = 1:m
            for j = 1:n
                curPixel = dec2bin(g(i,j),8);
                p1(i, j) = str2num(num2str(curPixel(L)));  
            end
        end
        p1 = cat(3, pads, p1, pads);
        imshow(p1)
        title(['L=' num2str(L)]);
        
        figure(4);
        % b
        [m, n] = size(r); % L=8 for LSB and L=1 for the MSB
        p1 = zeros(m,n);
        for i = 1:m
            for j = 1:n
                curPixel = dec2bin(b(i,j),8);
                p1(i, j) = str2num(num2str(curPixel(L)));  
            end
        end
        p1 = cat(3, pads, pads, p1);
        imshow(p1)
        title(['L=' num2str(L)]);
        
        
    end
        

end