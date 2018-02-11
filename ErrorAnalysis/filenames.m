
function names = filenames(folder, ext)
% The function outputs the names of all files with the specified extension
% type in the specified folder (case insensitive). The output is in the
% form of structure array.
% ext can be any file extension with any number of letters
% ext can be any combination of capital or lowercase letters
% Typical usage:
%   names = filenames('C:\My Documents\MATLAB\ImagesDB','jpg');
%   X = imread(names(1).name);

A = dir(folder);
dottype = strcat('.',lower(ext));
len = length(ext);

counter = 0;
for i = 1 : size(A,1)
   nextname = A(i).name;
   if length(nextname) > len + 1
      if lower(nextname(end-len : end)) == dottype,
         counter = counter + 1;
         names(counter).name = nextname;
      end
   end
end
