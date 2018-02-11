
% This code fraction contains important instructions for you to implement 
% your own routine that extracts the symmetrized KB feature from each image
% of a given extension from in a given directory

% First, use function filenames.m to obtain a structure of all files with
% extension ext in folder:

images = filenames('covers','pgm');       % Filenames of all pgm images in directory folder
N = size(images,2);                     % N is the total number of images with extension ext in folder

% now for each image i do:

% The name of the ith image is images(i).name, save it as an item in a cell array:

names{i} = images(i).name;

% You will need this cell array for the ensemble classifier

% Read the ith image using imread, cast to double, name it X
% To extract its feature, run: 

f = KB_feature(X,q,T,order);

% Use q = 4 (quantization step), T = 2 (threshold for the co-occurrence),
% order = 4 (4D co-occurrence). In this case, f will be a 625-dimensional
% column vector.

% end of loop for i

% Compute f for each image in folder and arrange their features f as columns
% in a 2D array 'Fea', which should have 625 rows and N columns
% Good advice: DECLARE Fea in the beginning before you start filling it up 
% otherwise the code will run sloooow, Fea = zeros(625,N); Do the same with
% the cell array names = cell(N,1);

% Now you need to symmetrize Fea, which will compact each feature from 625
% elements to only 169. Use the following routine:

Fea_sym = symmetrize(Fea,T,order,'spam','both');

% To save the features in a mat file ready to be analyzed with the ensemble
% classifier, execute:

F = Fea_sym';   % Because the ensemble classifier requires the features to be rows rather than columns
% The following command saves all your features and the cell array of image 
% names in a folder specified by path as a mat file 'KB_features.mat'
% Feel free to give this file a different name if you wish

save([path '\' 'KB_features.mat'],'F','names')
