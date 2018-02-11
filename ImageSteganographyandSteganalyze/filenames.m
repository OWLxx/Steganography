function names=filenames(directory,type)
% The function lists all filenames of the specified type in the current directory (case insensitive)
% type can be any file extension with any number of letters
% type can be any combination of capital or lowercase letters
% Typical usage:   names=filenames('C:\My Documents\MATLAB\ImagesDB','jpg');

A=dir(directory);
dottype=strcat('.',lower(type));
len=length(type);

counter=0;
for i=1:size(A,1)
   nextname=A(i).name;
   if length(nextname)>len+1
      if lower(nextname(end-len:end))==dottype,
         counter=counter+1;
         names(counter).name=nextname;
      end
   end
end