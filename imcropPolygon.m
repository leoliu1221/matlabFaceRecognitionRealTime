function [ result ] = imcropPolygon( Polygon, image )
%imcropPolygon: crop a polygon out of an image
%   polygon is a 6*1 matrix, while image is just the input image. Require
%   it to be rgb
% the Polygon(1:2:end)is the xs, while Polygon(2:2:end) is the ys

%cropping rectangle
%[xMin yMin abs(xMax-xMin+1) abs(yMax-yMin+1)]
polyX = Polygon(1:2:end);
polyY = Polygon(2:2:end);

xMin = min(polyX);
xMax = max(polyX);

yMin = min(polyY);
yMax = max(polyY);
result = imcrop(image, [xMin yMin abs(xMax-xMin+1) abs(yMax-yMin+1)]);
end

