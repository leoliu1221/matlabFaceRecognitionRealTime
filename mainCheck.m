cd s40
imshow('1.jpg')
cd ..
a = imcrop;
imwrite(a,'cutted.bmp','bmp');
r = imread('cutted.bmp');
w = load_database();
r = imresize(r,[112 92]);
r = rgb2gray(r);
imshow(r)
a = libCheck(w,r);
