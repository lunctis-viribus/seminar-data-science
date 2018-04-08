image=imread('blurryImage.png');
[h w d]=size(image);
U = double(reshape(image,w*h,d))/255;

% Construct gradient matrix
r = [];
c = [];
v = [];
z = 1;

% to save the time, we have the pre-run one or run the code of for loop
% G = load('G_matrix.mat'); % pre-run one
% G = G.G; % pre-run one

for k = 1:h
    j = 1;
    for i = 1:w-1
        r = [r,z];
        c = [c,k+(h*(i-1))];
        v = [ v,-1];
        
        r = [r,z];
        c = [c,k+(h*(i))];
        v = [v,1];
        j = j + h;
        z = z+1;
    end
end
% z = (w-1)*h;
for k = 1:w
    j = 1;
    for i = 1:h-1
        r = [r,z];
        c = [c,j+(k-1)*(h)];
        v = [ v,1];
        
        r = [r,z];
        c = [c,j+1+(k-1)*(h)];
        v = [v,-1];
        j = j + 1;
        z = z+1;
    end
end
G = sparse(r,c,v,(h-1)*w+(w-1)*h,h*w);

% Solve linear system
G_size=size(G);
N=G_size(2);
g=G*U;
cs = 3;
cu = .5;
p=sparse(N,N,pi);
Id=eye(N,'like',p);
A = G'*G+cu*Id;
B = cs*G'*g+cu*U;
Uinv = A\B;
% Show images
sharpenedImage =uint8(reshape(Uinv,h,w,d)*255); 
figure;
imshowpair(image,sharpenedImage,'montage')
imwrite(sharpenedImage,'out.png')
