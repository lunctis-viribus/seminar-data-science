% Supress warnings
%%warning('off','all')

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


