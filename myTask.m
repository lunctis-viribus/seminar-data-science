image=imread('blurryImage.png');
[h w d]=size(image);
U = double(reshape(image,w*h,d))/255;

%% Write your method here
kernel = -1 * ones(3)/9
kernel(2,2) = 8;
kernel = kernel / sum(kernel(:)); % Normalize sum to 1.
% High frequency boost filter
sharpenedImage = conv2(double(U), kernel, 'same');


sharpenedImage =uint8(reshape(sharpenedImage,h,w,d)*255);

figure
subplot(1,2,1), imshow(image)
subplot(1,2,2), imshow(sharpenedImage)
imwrite(sharpenedImage,'out.png')
