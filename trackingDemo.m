function [] = trackingDemo()
threshold = 100;
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

figure(1); imshow(videoFrame); title('Detected face');

% Detect feature points in the face region.
points = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', bbox);

% Display the detected points.
figure('name','detected'), imshow(videoFrame), hold on, title('Detected features');
plot(points);

% Create a point tracker and enable the bidirectional error constraint to
% make it more robust in the presence of noise and clutter.
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

% Initialize the tracker with the initial point locations and the initial
% video frame.
points = points.Location;
initialize(pointTracker, points, videoFrame);

%set(0, 'ShowHiddenHandles', 'on') % Revert this back to off after you get the handle



videoPlayer  = vision.VideoPlayer('Position',...
    [100 100 [size(videoFrame, 2), size(videoFrame, 1)]+30]);

% Make a copy of the points to be used for computing the geometric
% transformation between the points in the previous and the current frames
oldPoints = points;


newperson=1;
for taoefaeffadef =1:900

%while ~isDone(videoFileReader)
    % get the next frame
    videoFrame = step(videoFileReader);

    % Track the points. Note that some points may be lost.
    [points, isFound] = step(pointTracker, videoFrame);
    visiblePoints = points(isFound, :);
    oldInliers = oldPoints(isFound, :);

    if size(visiblePoints, 1) >= 2 % need at least 2 points
    if(newperson==1)
    if(size(visiblePoints, 1)<threshold&newperson==1)
      disp('I saw your face. You look uglier than I think');
    else
      disp('Good looking!!!')
    end
     newperson=0;
     end
  
        % Estimate the geometric transformation between the old points
        % and the new points and eliminate outliers
        [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
            oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);

        % Apply the transformation to the bounding box
        [bboxPolygon(1:2:end), bboxPolygon(2:2:end)] ...
           = transformPointsForward(xform, bboxPolygon(1:2:end), bboxPolygon(2:2:end));

        % Insert a bounding box around the object being tracked
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon);

        % Display tracked points
        videoFrame = insertMarker(videoFrame, visiblePoints, '+', ...
            'Color', 'red');

        % Reset the points
        oldPoints = visiblePoints;
        setPoints(pointTracker, oldPoints);
    else
        release(pointTracker);
        pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
  
        % Detect feature points in the face region.
        points = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', bbox);
        points = points.Location;
        initialize(pointTracker, points, videoFrame);
        oldPoints = points;
        
        bbox= step(faceDetector, videoFrame);
        while(size(bbox,1)<1)
            videoFrame = step(videoFileReader);
            bbox= step(faceDetector, videoFrame);
            step(videoPlayer, videoFrame);
           
        end
        
        % Convert the first box to a polygon.
        % This is needed to be able to visualize the rotation of the object.
        x = bbox(1, 1); y = bbox(1, 2); w = bbox(1, 3); h = bbox(1, 4);
        bboxPolygon = [x, y, x+w, y, x+w, y+h, x, y+h];

        
        % Draw the returned bounding box around the detected face.
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon);
        newperson=1;
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