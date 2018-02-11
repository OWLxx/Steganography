
function fsym = symmetrize(f,T,order,feature_type,sym_type)
%
% Symmetrization by sign and directional symmetry for a feature array.
% The feature array f is assumed to be a dim x database_size matrix of
% features stored as columns with dim = (2T+1)^order for 'spam' type and
% dim = 2(2T+1)^order for the 'minmax' type.
%
% INPUTS:
% T = threshold
% order = co-occurrence order
% feature_type = type of feature \in {'spam','minmax'}
% sym_type = type of symmetrization \in {'sign','dir','both'}
% OUTPUT: reduced feature array fsym

[dim,N] = size(f);
B = 2*T+1; c = B^order;
ERR = 1;

if strcmp(feature_type,'spam')
    if dim == c
        %
        % Computing the reduced dimensionality
        %
        if strcmp(sym_type,'sign')  % Sign only
            red = 1 + 1/2*(B^order - 1);
        end
        if strcmp(sym_type,'dir')   % Directional only
            switch order
                case 3, red = B^3 - T*B^2;          % Dim of the marginalized set is (2T+1)^3-T*(2T+1)^2
                case 4, red = B^4 - 2*T*(T+1)*B^2;  % Dim of the marginalized set is (2T+1)^4-2T*(T+1)*(2T+1)^2
                case 5, red = B^5 - 2*T*(T+1)*B^3;
            end
        end
        if strcmp(sym_type,'both')  % Sign and direction
            switch order
                case 1, red = T + 1;
                case 2, red = (T + 1)^2;
                case 3, red = 1 + 3*T + 4*T^2 + 2*T^3;
                case 4, red = B^2 + 4*T^2*(T + 1)^2;
                case 5, red = 1/4*(B^2 + 1)*(B^3 + 1);
            end
        end
        fsym = zeros(red,N);
        %
        % Symmetrizing
        %
        for i = 1 : N
            switch order
                case 1, cube = f(1:c,i);
                case 2, cube = reshape(f(1:c,i),[B B]);
                case 3, cube = reshape(f(1:c,i),[B B B]);
                case 4, cube = reshape(f(1:c,i),[B B B B]);
                case 5, cube = reshape(f(1:c,i),[B B B B B]);
            end
            switch sym_type
                case 'sign', fsym(:,i) = symm_sign(cube,T,order);
                case 'dir',  fsym(:,i) = symm_dir(cube,T,order);
                case 'both', fsym(:,i) = symm(cube,T,order);
            end
        end
    else
        fsym = [];
        fprintf('*** ERROR: feature dimension is not (2T+1)^order. ***\n')
    end
    ERR = 0;
end

if strcmp(sym_type,'minmax')
    if dim == 2*c
        %
        % Computing the reduced dimensionality
        %
        if strcmp(sym_type,'both')
            switch order
                case 3, red = B^3 - T*B^2;          % Dim of the marginalized set is (2T+1)^3-T*(2T+1)^2
                case 4, red = B^4 - 2*T*(T+1)*B^2;  % Dim of the marginalized set is (2T+1)^4-2T*(T+1)*(2T+1)^2
            end
        end
        if strcmp(sym_type,'dir')
            switch order
                case 3, red = 2 * (B^3 - T*B^2 );          % Dim of the marginalized set is (2T+1)^3-T*(2T+1)^2
                case 4, red = 2 * (B^4 - 2*T*(T+1)*B^2 );  % Dim of the marginalized set is (2T+1)^4-2T*(T+1)*(2T+1)^2
                case 5, red = 2 * (B^5 - 2*T*(T+1)*B^3 );
            end
        end
        if strcmp(sym_type,'sign')
           red = c;
        end
        fsym = zeros(2*red, N);
        %
        % Symmetrizing
        %
        if strcmp(sym_type,'both')
            for i = 1 : N
                switch order
                    case 3, cube_min = reshape(f(1:c,i),[B B B]);    cube_max = reshape(f(c+1:2*c,i),[B B B]);    f_signsym = cube_min + cube_max(end:-1:1,end:-1:1,end:-1:1);
                    case 4, cube_min = reshape(f(1:c,i),[B B B B]);  cube_max = reshape(f(c+1:2*c,i),[B B B B]);  f_signsym = cube_min + cube_max(end:-1:1,end:-1:1,end:-1:1,end:-1:1);
                    case 5, cube_min = reshape(f(1:c,i),[B B B B B]);cube_max = reshape(f(c+1:2*c,i),[B B B B B]);f_signsym = cube_min + cube_max(end:-1:1,end:-1:1,end:-1:1,end:-1:1,end:-1:1);
                end
                fsym(:,i) = symm_dir(f_signsym,T,order);
            end
        end
        
        if strcmp(sym_type,'dir')
            for i = 1 : N
                switch order
                    case 2, cube_min = reshape(f(1:c,i),[B B]);      cube_max = reshape(f(c+1:2*c,i),[B B]); 
                    case 3, cube_min = reshape(f(1:c,i),[B B B]);    cube_max = reshape(f(c+1:2*c,i),[B B B]);  
                    case 4, cube_min = reshape(f(1:c,i),[B B B B]);  cube_max = reshape(f(c+1:2*c,i),[B B B B]);  
                    case 5, cube_min = reshape(f(1:c,i),[B B B B B]);cube_max = reshape(f(c+1:2*c,i),[B B B B B]);
                end
                auxmin = sym_dir(cube_min,T,order);
                auxmax = sym_dir(cube_max,T,order);
                fsym(:,i) = [auxmin;auxmax];
            end
        end
        
        if strcmp(sym_type,'sign')
            for i = 1 : N
                switch order
                    case 2, cube_min = reshape(f(1:c,i),[B B]);      cube_max = reshape(f(c+1:2*c,i),[B B]);      aux = cube_min + cube_max(end:-1:1,end:-1:1);
                    case 3, cube_min = reshape(f(1:c,i),[B B B]);    cube_max = reshape(f(c+1:2*c,i),[B B B]);    aux = cube_min + cube_max(end:-1:1,end:-1:1,end:-1:1);
                    case 4, cube_min = reshape(f(1:c,i),[B B B B]);  cube_max = reshape(f(c+1:2*c,i),[B B B B]);  aux = cube_min + cube_max(end:-1:1,end:-1:1,end:-1:1,end:-1:1);
                    case 5, cube_min = reshape(f(1:c,i),[B B B B B]);cube_max = reshape(f(c+1:2*c,i),[B B B B B]);aux = cube_min + cube_max(end:-1:1,end:-1:1,end:-1:1,end:-1:1,end:-1:1);
                end
                fsym(:,i) = aux(:);
            end
        end
    end
    ERR = 0;
end

if ERR == 1, fprintf('*** ERROR: Feature dimension and T, order incompatible. ***\n'), end


