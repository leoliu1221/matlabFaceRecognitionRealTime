function [] = faceDetectDemo(  )
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

% Draw the returned bounding box around the detected face.
for i=1:size(bbox,1)
videoFrame = insertShape(videoFrame, 'Rectangle', bbox(i,:));
end
figure(1); imshow(videoFrame); title('Detected face');



videoPlayer  = vision.VideoPlayer('Position',...
    [100 100 [size(videoFrame, 2), size(videoFrame, 1)]+30]);

% Make a copy of the points to be used for computing the geometric
% transformation between the points in the previous and the current frames


for taoefaeffadef =1:900
%taoefaeffadef
%while ~isDone(videoFileReader)
    % get the next frame
    videoFrame = step(videoFileReader);
        bbox= step(faceDetector, videoFrame);
        %size(bbox,1)
       while(size(bbox,1)<1)
         videoFrame= step(videoFileReader);
         bbox= step(faceDetector, videoFrame);
         step(videoPlayer, videoFrame);
        end

% Draw the returned bounding box around the detected face.
    for i=1:size(bbox,1)
        videoFrame = insertShape(videoFrame, 'Rectangle', bbox(i,:));
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

