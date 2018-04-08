% Supress warnings
warning('off','all')

%%% We separate our result into three parts:
%%%   1. Image blending without using the mask, and manually select the regions
%%%   2. Image blending using the mask, and automatically select the region to blend in 
%%%   3. Image blending using the mask, and manually select the region to blend in 
%%% These will be gradually introduced below:
%% 1. Image blending without using the mask, and manually select the regions

%%% Using images of the bear in the pool
% source = imread('./img/source.jpg');
% target = imread('./img/target.jpg');
% mask = imread('./img/bear.jpeg');

%%% Using images of the airplane into the mountain
target = imread('./img/bg.jpg');
source = imread('./img/fg.jpg');
mask = imread('./img/mask2.jpg');

%default region of the target image for stitching the source image
offsetX = 150;
offsetY = 50;

%select the region for cropping and stitching manually (manually_select = 1) or not(manually_select = 0)
manually_select = 1;

%use the mask or not (if using the mask, set it to 1)
mask_selected = 0;

output = imageBlending(source,target,manually_select);
imshow(output);




%% 2. Image blending using the mask, and automatically select the region to blend in

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
disp('Press any key to quit');
pause;
close(f2);


%% 3. Image blending using the mask, repeat function and manually select the region to blend in

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
figure;
imshow(output);
disp('Press a key to quit');
pause;
close all;

