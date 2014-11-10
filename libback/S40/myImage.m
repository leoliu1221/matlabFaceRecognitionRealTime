for i=1:10
   a = imread([num2str(i),'.jpg']);
   a = imresize(a,[112 92]);
   a = rgb2gray(a);
   imwrite(a,[num2str(i),'.bmp'],'bmp');
    
    
    
end