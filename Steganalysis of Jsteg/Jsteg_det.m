function alpha = Jsteg_det(image)
% Idea: use the difference between 1 and others to estimate the 
if nargin < 1      % test the default 10 images
    alpha = zeros(2,10);
    for ii =1:9
        cur = '01.jpg';
        cur(2) = string(ii);
        alpha(1,ii) = ii;
        alpha(2,ii) = helper(cur);
    end
    cur = '10.jpg';
    alpha(1,10) = 10;
    alpha(2,10) = helper(cur);
    alpha = alpha'
    
else
    alpha = helper(image);          % test input image
end
    function alpha2 = helper(image)
        cover = jpeg_read(image);
        Lum = cover.coef_arrays{cover.comp_info(1).component_id};
        histogram(Lum(:));
        xlim([-6,8]);
        counter = zeros(1,2048);    % counter(1025) is the number of pixel at zero
        lumsize = numel(Lum);

        % stego = Jsteg_embed(cover,stego_file,message,key) % test payload image
        % Jsteg_embed(cover, 'tii100.jpg', randi([0 1], 1, round(lumsize*0.65)), 1);

        lumbackup = reshape(Lum, lumsize,1); 

        for i=1:lumsize           % finish the counter
            counter(lumbackup(i)+1025) = counter(lumbackup(i)+1025) + 1; 
        end

        ha_1 = counter(1026);     % ha[1]
        ha_others = 0;            % Initialize the counter for the rest 
        for i=1:2:1024            % sum negative 
            ha_others = counter(i+1)-counter(i) + ha_others;
        end
        for i=1027:2:2048         % sum positive
            ha_others = counter(i)-counter(i+1) + ha_others;
        end

        alpha2 = 1 - ha_others/ha_1;% result
    end
end
