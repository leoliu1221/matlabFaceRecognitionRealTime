function [result] = cutPic(a)
 a = imresize(a,[112 92]);
 a = rgb2gray(a);
 result = a;

end