% Supress warnings
%%warning('off','all')

target = imread('./img/bg.jpg');
source = imread('./img/fg.jpg');
mask = imread('./img/mask2.jpg');

%default region of the target image for stitching the source image
offsetX = 150;
offsetY = 50;

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

% Manually give position image

offsetX = 300;
offsetY = 50;
output = imageBlending(source,output,manually_select, mask, offsetX,offsetY);

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
close(f2);