function [ ] = showDatabase(db )
%showDatabase show all images in the database in a figure
%   db is the input of the database
db2=double(zeros(size(db,1),1));
figure(1);
width =round(sqrt(size(db,2)));
length = width+1;
for i = 1:size(db,2)
    subplot(width, length, i)
    imshow(reshape(db(:,i),112,92));
    db2(:) = db2(:) + double(db(:,i));
end
db2 = db2 ./ size(db,2);
figure(2);
imshow(uint8(reshape(db2(:),112,92)));
end

