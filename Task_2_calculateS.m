image=imread('source.jpg');

[h w d]=size(image);

U = double(reshape(image,w*h,d))/255;
%% Construct gradient matrix
r = [];
c = [];
v = [];
z = 0;


r_s = [];
c_s = [];
v_s = [];

boundary_h = h+2;
boundary_w = w+2;

for k = 1:boundary_h
    j = 1;
    for i = 1:boundary_w-1
        r = [r,(k-1)*(boundary_w-1)+i];
        c = [c,k+(boundary_h*(i-1))];
        v = [ v,-1];
        
        r = [r,(k-1)*(boundary_w-1)+i];
        c = [c,k+(boundary_h*(i))];
        v = [v,1];
        j = j + boundary_h;
        q = k+(boundary_h*(i-1));
        % for select
        if (mod(q,boundary_h)==1 | mod(q,boundary_h)==0 | q <= boundary_h |  boundary_w*boundary_h-2*boundary_h< q)
            r_s = [r_s,(k-1)*(boundary_w-1)+i];
            c_s = [c_s,k+(boundary_h*(i-1))];
            v_s = [ v_s,-1];
        
            r_s = [r_s,(k-1)*(boundary_w-1)+i];
            c_s = [c_s,k+(boundary_h*(i))];
            v_s = [v_s,1];
        end

    end
end
z = (boundary_w-1)*boundary_h; % 71862 rows, starts at 71863
for k = 1:boundary_w
    j = 1;
    for i = 1:boundary_h-1
        r = [r,(k-1)*(boundary_h-1)+i+z];
        c = [c,j+(k-1)*(boundary_h)];
        v = [ v,1];
        
        r = [r,(k-1)*(boundary_h-1)+i+z];
        c = [c,j+1+(k-1)*(boundary_h)];
        v = [v,-1];
        
        
        q = j+(k-1)*(boundary_h);
        % for select
        if ( mod(q,boundary_h)==1 | mod(q,boundary_h)==boundary_h-1 | q <= boundary_h |  boundary_w*boundary_h-boundary_h< q)
            r_s = [r_s,(k-1)*(boundary_h-1)+i+z];
            c_s = [c_s,j+(k-1)*(boundary_h)];
            v_s = [ v_s,1];
        
            r_s = [r_s,(k-1)*(boundary_h-1)+i+z];
            c_s = [c_s,j+1+(k-1)*(boundary_h)];
            v_s = [v_s,-1];
        end
        j = j + 1;
        
    end
end
G = sparse(r,c,v,(boundary_h-1)*boundary_w+(boundary_w-1)*boundary_h,boundary_h*boundary_w);
S = sparse(r_s,c_s,v_s,(boundary_h-1)*boundary_w+(boundary_w-1)*boundary_h,boundary_h*boundary_w);


%% Solve linear system
size=size(G);
N=size(2);
g=G*U;
cs = 3;
cu = .5;
p=sparse(N,N,pi);
Id=eye(N,'like',p);
A = G'*G+cu*Id;
B = cs*G'*g+cu*U;
Uinv = A\B;
%% Show images
sharpenedImage =uint8(reshape(Uinv,h,w,d)*255); 
figure
imshowpair(image,sharpenedImage,'montage')
imwrite(sharpenedImage,'out.png')
