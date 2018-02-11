function [] = genStegoImage( alpha, sourceFolder,targetFolder,  type)
% example genStegoImage(0.05, 'C:\My Documents\MATLAB\ImagesDB','jpg')

% lists all filenames of the specified type in the target directory
images = filenames(sourceFolder, type);
% number of images in that folder
N = size(images,2); 

for i=1:1:N
    % read image
    i
    curName = images(i).name;
    coverpath = strcat(sourceFolder, '\', curName);
    X = imread(coverpath);
    % calculate cost rho
    rho = calcost(X);
    % LSB embedding based on RD bound
    Y = simulate_emb(X,alpha,rho);
    Y = uint8(Y);
    % save to corresponding folder
    stegopath = strcat(targetFolder, '\', curName);
    imwrite(Y, stegopath);    
    
end


end

