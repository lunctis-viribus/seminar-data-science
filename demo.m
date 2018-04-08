target = imread('./img/bg.jpg');
source = imread('./img/fg.jpg');
mask = imread('./img/mask2.jpg');

offsetX = 150;
offsetY = 50;

output = imageBlending(source,target,0, mask, offsetX,offsetY);
imshow(output);
disp('heey');
output = imageBlending(source,output,1);
imshow(output);