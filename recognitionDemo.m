function [  ] = recognitionDemo( n )
%recognitionDemo demo for real-time recognition
%   Detailed explanation goes here
a = imread('1.bmp');
db = load_database(4);
result = libCheck(db,a);
if(result==31) 
    disp('YAY!!!! it worked')
else
    disp('noooooo it did not work')
end

end

