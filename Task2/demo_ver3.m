% Supress warnings
warning('off','all')

%%% Image of the airplane into the mountain
target = imread('./img/bg.jpg');
source = imread('./img/fg.jpg');
mask = imread('./img/mask2.jpg');

%%% change to other images, the squirrel into the sky
% target = imread('./img/air.jpg');
% source = imread('./img/squirrel.jpg');
% mask = imread('./img/squirrel_mask.jpg');



%default region of the target image for stitching the source image
offsetX = 250;
offsetY = 150;

%select the region for cropping and stitching manually (manually_select = 1) or not(manually_select = 0)
manually_select = 0;

%use the mask or not (if using the mask, set it to 1)
mask_selected = 1;

% Insert image automatically on given coordinates
output = imageBlending(source,target,manually_select, mask, offsetX,offsetY);
f2 = figure(2);
imshow(output);
disp('Press a key to continue');
pause;
close(f2);

manually_select = 1;
output = imageBlending(source,output,manually_select, mask);
imshow(output);
disp('Press a key to continue');
pause;
close all;