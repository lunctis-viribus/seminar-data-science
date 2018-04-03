image=imread('blurryImage.png');
[h w d]=size(image);
U = double(reshape(image,w*h,d))/255;
%% Write your method here
kernel = -1 * ones(3)/9
kernel(2,2) = 8;
kernel = kernel / sum(kernel(:)); % Normalize sum to 1.


%% I matrix
%%
r = [];
c = [];
v = [];
z = 0;
for k = 1:h
    j = 1;
    for i = 1:w-1
        r = [r,(k-1)*(w-1)+i];
%         c = [c,j+(k-1)*(h-1)];
        c = [c,k+(h*(i-1))];
        v = [ v,-1];
        
        r = [r,(k-1)*(w-1)+i];
%         c = [c,j+h+(k-1)*(h-1)];
        c = [c,k+(h*(i))];
        v = [v,1];
        j = j + h;

    end
end
z = (w-1)*h; % 71862 rows, starts at 71863
for k = 1:w
    j = 1;
    for i = 1:h-1
        r = [r,(k-1)*(h-1)+i+z];
        c = [c,j+(k-1)*(h)];
        v = [ v,1];
        
        r = [r,(k-1)*(h-1)+i+z];
        c = [c,j+1+(k-1)*(h)];
        v = [v,-1];
        j = j + 1;
        
    end
end

M1 = sparse(r,c,v,(h-1)*w+(w-1)*h,h*w);
%%
    
        


% High frequency boost filter
sharpenedImage = conv2(double(U), kernel, 'same');


sharpenedImage =uint8(reshape(sharpenedImage,h,w,d)*255);

figure
subplot(1,2,1), imshow(image)
subplot(1,2,2), imshow(sharpenedImage)
imwrite(sharpenedImage,'out.png')
