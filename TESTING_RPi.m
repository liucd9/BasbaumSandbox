% https://www.mathworks.com/help/supportpkg/raspberrypiio/examples/getting-started-with-matlab-support-package-for-raspberry-pi-hardware.html
% https://www.mathworks.com/help/supportpkg/raspberrypiio/examples/working-with-raspberry-pi-camera-board.html

% setup workspace
clc, clear, close all 

% initialize rpi
rpi = raspi();
cam = cameraboard(rpi,'Resolution','1280x720');

% video filename 
vid_name = 'video'; 

% % Take images
% for i = 1:50
%     img = snapshot(cam);
%     image(img);
%     axis image
%     drawnow;
% end

% Record video 
video_time = 10; % seconds
record(cam, [vid_name '.h264'], video_time)

% Convert file 
pause(video_time + 3)
getFile(rpi, [vid_name '.h264'])
ffmpegDir = 'C:\ffmpeg\'; 
cmd = ['"' fullfile(ffmpegDir, 'bin', 'ffmpeg.exe') '" -r 30 -i ' [vid_name '.h264'] ' -vcodec copy myvid.mp4 &'];
[status, message] = system(cmd); 

disp('Finished')
