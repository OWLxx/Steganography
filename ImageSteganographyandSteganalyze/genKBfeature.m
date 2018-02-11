function [] = genKBfeature( folderName )
% save KB features of all images in target folder into a mat file

images = filenames(folderName,'pgm');       % Filenames of all pgm images in directory folder
N = size(images,2);                     % N is the total number of images with extension ext in folder

% Use q = 4 (quantization step), T = 2 (threshold for the co-occurrence),
% order = 4 (4D co-occurrence). In this case, f will be a 6561-dimensional
% column vector.
q = 4;
T = 2;
order = 4;
dimension = (2*T+1)^order;
Fea = zeros(dimension, N);

for i=1:1:N
    % read image
    i
    curName = images(i).name;
    coverpath = strcat(folderName, '\', curName);
    X = imread(coverpath);
    X = double(X);
    names{i} = images(i).name;
    f = KB_feature(X,q,T,order);
    Fea(:, i) = f;
end
% reduce dimension
Fea_sym = symmetrize(Fea,T,order,'spam','both');
F = Fea_sym'; 
save(strcat(folderName, 'KB_features.mat'),'F','names');

end

