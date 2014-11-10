function [n] = training( n )
%training Summary:train the nth dataset. return n if sucessful 
%   this is the training step before image recognition. 

% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();


% Read a video frame and run the face detector.
%videoFileReader = vision.VideoFileReader('tilted_face.avi');
%videoFileReader = vision.VideoFileReader('test.wmv');
%videoFileReader = imaq.VideoDevice('macvideo', 1, 'YCbCr422_1280x720','ROI',[1 1 1280 720]);
videoFileReader = imaq.VideoDevice('winvideo', 1, 'MJPG_640x480','ROI',[1 1 640 480]);
videoFrame      = step(videoFileReader);
bbox            = step(faceDetector, videoFrame);
while(size(bbox,1)<1)
   videoFrame= step(videoFileReader);
    bbox= step(faceDetector, videoFrame);
end

% Convert the first box to a polygon.
% This is needed to be able to visualize the rotation of the object.
x = bbox(1, 1); y = bbox(1, 2); w = bbox(1, 3); h = bbox(1, 4);
bboxPolygon = [x, y, x+w, y, x+w, y+h, x, y+h];

% Draw the returned bounding box around the detected face.
videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon);

figure; imshow(videoFrame); title('Detected face');

% Detect feature points in the face region.
points = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', bbox);

% Display the detected points.
figure, imshow(videoFrame), hold on, title('Detected features');
plot(points);

% Create a point tracker and enable the bidirectional error constraint to
% make it more robust in the presence of noise and clutter.
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

% Initialize the tracker with the initial point locations and the initial
% video frame.
points = points.Location;
initialize(pointTracker, points, videoFrame);

videoPlayer  = vision.VideoPlayer('Position',...
    [100 100 [size(videoFrame, 2), size(videoFrame, 1)]+30]);

% Make a copy of the points to be used for computing the geometric
% transformation between the points in the previous and the current frames
oldPoints = points;

m=1; %m is the number of picture
%getting the first face recgnition
matchPic = imcropPolygon(bboxPolygon,videoFrame);
matchPic = cutPic(matchPic);
mkdir(strcat('S',num2str(n)));
 cd(strcat('S',num2str(n)));
imwrite(matchPic,strcat(num2str(m),'.bmp'),'bmp');
cd ..
tic;pause(1);toc;
for m = 2:10
tic;pause(1.5);toc;
    % get the next frame
    videoFrame = step(videoFileReader);

    % Track the points. Note that some points may be lost.
    [points, isFound] = step(pointTracker, videoFrame);
    visiblePoints = points(isFound, :);
    oldInliers = oldPoints(isFound, :);

    if size(visiblePoints, 1) >= 2 % need at least 2 points

        % Estimate the geometric transformation between the old points
        % and the new points and eliminate outliers
        [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
            oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);

        % Apply the transformation to the bounding box
    [bboxPolygon(1:2:end), bboxPolygon(2:2:end)] ...
     = transformPointsForward(xform, bboxPolygon(1:2:end), bboxPolygon(2:2:end));
    matchPic = imcropPolygon(bboxPolygon,videoFrame);
    matchPic = cutPic(matchPic);
     cd(strcat('s',num2str(n)));
    imwrite(matchPic,strcat(num2str(m),'.bmp'),'bmp');
    cd ..
        % Insert a bounding box around the object being tracked
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon);

        % Display tracked points
        videoFrame = insertMarker(videoFrame, visiblePoints, '+', ...
            'Color', 'red');

        % Reset the points
        oldPoints = visiblePoints;
        setPoints(pointTracker, oldPoints);
  
        
        % Convert the first box to a polygon.
        % This is needed to be able to visualize the rotation of the object.
        x = bbox(1, 1); y = bbox(1, 2); w = bbox(1, 3); h = bbox(1, 4);
        bboxPolygon = [x, y, x+w, y, x+w, y+h, x, y+h];

        % Draw the returned bounding box around the detected face.
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon);
        
    end

    % Display the annotated video frame using the video player object
    step(videoPlayer, videoFrame);
    
    % Detect feature points in the face region.
    %points = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', bbox);
end

% Clean up
release(videoFileReader);
release(videoPlayer);
release(pointTracker);

end

