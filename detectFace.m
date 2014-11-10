function [  ] = face_tracker(  )
%Create a cascadeObjectDetector, by default it detects the face
faceDetector = vision.CascadeObjectDetector();

%Get the input device using image acquisition toolbox,resolution = 640x480 to improve performance
vidDevice = imaq.VideoDevice('winvideo', 1, 'MJPG_640x480','ROI',[1 1 640 480]);

%Get a video frame and run the detector.
videoFrame = step(vidDevice);

%Get a bounding box around the face
bbox            = step(faceDetector, videoFrame);

%Check if something was detected, otherwise exit
if numel(bbox) == 0
    error('Nothing was detected, try again');
end   

%Show coordinates of tracked face
textColor = [255, 0, 0];
textLocation = [1 1];
text =  ['x: ',num2str(bbox(1)),' y: ',num2str(bbox(2)),' Width: ',num2str(bbox(3)), ' Height: ',num2str(bbox(4))];
textInserter = vision.TextInserter(text,'Color', textColor, 'FontSize', 12, 'Location', textLocation);
videoOut = step(textInserter, videoFrame);

% Draw the returned bounding box around the detected face.
videoOut = insertObjectAnnotation(videoOut,'rectangle',bbox,'Face');
figure, imshow(videoOut), title('Detected face');

% Get the skin tone information by extracting the Hue from the video frame
% converted to the HSV color space.
[hueChannel,~,~] = rgb2hsv(videoFrame);

% Display the Hue Channel data and draw the bounding box around the face.
figure, imshow(hueChannel), title('Hue channel data');
rectangle('Position',bbox(1,:),'LineWidth',2,'EdgeColor',[1 1 0])
% Detect the nose within the face region. The nose provides a more accurate
% measure of the skin tone because it does not contain any background
% pixels.
noseDetector = vision.CascadeObjectDetector('Nose');
faceImage    = imcrop(videoFrame,bbox(1,:));
noseBBox     = step(noseDetector,faceImage);

% The nose bounding box is defined relative to the cropped face image.
% Adjust the nose bounding box so that it is relative to the original video
% frame.
noseBBox(1,1:2) = noseBBox(1,1:2) + bbox(1,1:2);

% Create a tracker object.
tracker = vision.HistogramBasedTracker;

% Initialize the tracker histogram using the Hue channel pixels from the
% nose.
initializeObject(tracker, hueChannel, noseBBox(1,:));

% Create a video player object for displaying video frames.
ROI = get(vidDevice,'ROI');
videoSize = [ROI(3) ROI(4)];

videoPlayer  = vision.VideoPlayer('Position',[300 300 videoSize(1:2)+30]);


% Track the face over successive video frames until the video is finished.
%You could set here a finite number of frames to capture
while 1
    % Extract the next video frame
    videoFrame = step(vidDevice);

    % RGB -> HSV
    [hueChannel,~,~] = rgb2hsv(videoFrame);

    % Track using the Hue channel data
    bbox = step(tracker, hueChannel);

    % Insert a bounding box around the object being tracked
    videoOut = insertObjectAnnotation(videoFrame,'rectangle',bbox,'Face');
   
    %Insert text coordinates
    text =  ['x: ',num2str(bbox(1)),' y: ',num2str(bbox(2)),' Width: ',num2str(bbox(3)), ' Height: ',num2str(bbox(4))];
    textInserter = vision.TextInserter(text,'Color', textColor, 'FontSize', 12, 'Location', textLocation);
    videoOut = step(textInserter,videoOut);
   
    % Display the annotated video frame using the video player object
    step(videoPlayer, videoOut);
end

% Release resources
release(vidDevice);
release(videoPlayer);

end