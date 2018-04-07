image=imread('source.jpg');

[h w d]=size(image);

U = double(reshape(image,w*h,d))/255;

%%
% image_t = imread('./img/bg.jpg');
% image_s = imread('./img/fg.jpg');
% image_m = imread('./img/mask2.jpg');
image_t = imread('target.jpg');
image_s = imread('source.jpg');
% image_m = imread('bear.jpeg');
image_s = imresize(image_s,0.6);
[h w d]=size(image_s);
image_empty = zeros(h+2,w+2);
image_empty(2:h+1, 2:w+1) = ones(h,w);
image_m = image_empty;

image_empty = zeros(h+2,w+2,3);
image_empty(2:h+1, 2:w+1,:) = image_s;
image_s = image_empty; 

x_off = 230;
x2_off = x_off + (h-1);
y_off = 10;
y2_off = y_off + (w-1);
[x_cord, y_cord] = find(image_m);
%maskedRgbImage = bsxfun(@times, image_s, cast(image_m, 'like', image_s));
%imshow(maskedRgbImage)
%image_t(x_off:x2_off, y_off:y2_off, :) = image_s;

target = image_t(x_off-1:x2_off+1, y_off-1:y2_off+1, :);

for channel = 1:3
    for j = 1:(size(x_cord,1))
        target(x_cord(j), y_cord(j), channel) = image_s(x_cord(j),y_cord(j), channel);    
    end
end

%imshow(image_t)

%[h w d]=size(target);

boundary_h = h+2;
boundary_w = w+2;
U = double(reshape(target,boundary_w*boundary_h,d))/255;
%% Construct gradient matrix
r = [];
c = [];
v = [];
z = 0;


r_s = [];
c_s = [];
v_s = [];

r_ss = [];
c_ss = [];
v_ss = [];


z = 1;
for k = 1:boundary_h
    for i = 1:boundary_w-1
        %if image_m(k,i) ~= 0 | (image_m(k,i+1) ~= 0)
        if image_m(k,i) ~= 0 | (image_m(k,i+1) ~= 0)
            r = [r,z];
            c = [c,k+(boundary_h*(i-1))];
            v = [ v,-1];

            r = [r,z];
            c = [c,k+(boundary_h*(i))];
            v = [v,1];
            j = j + boundary_h;
            q = k+(boundary_h*(i-1));
            % for select
            %if (mod(q,boundary_h)==1 | mod(q,boundary_h)==0 | q <= boundary_h |  boundary_w*boundary_h-2*boundary_h< q)
            if image_m(k,i+1) ~= image_m(k,i)
                r_s = [r_s,z];
                c_s = [c_s,k+(boundary_h*(i-1))];
                v_s = [ v_s,-1];

                r_s = [r_s,z];
                c_s = [c_s,k+(boundary_h*(i))];
                v_s = [v_s,1];

                r_ss = [r_ss,z];
                if image_m(k,i) ~= 0
%                     c_ss = [c_ss,k+(boundary_h*(i+1))];
                    c_ss = [c_ss,k+(boundary_h*(i))];
                else
%                     c_ss = [c_ss,k+(boundary_h*(i))];
                    c_ss = [c_ss,k+(boundary_h*(i-1))];
                end
                v_ss = [v_ss,1];            
            end
            z= z+1;
        end
    end
end

z = (boundary_w-1)*boundary_h; % 71862 rows, starts at 71863
for k = 1:boundary_w
    for i = 1:boundary_h-1
        if image_m(i,k) ~= 0 | (i > 1 & image_m(i+1,k) ~= 0)
            r = [r,z];
            c = [c,i+(k-1)*(boundary_h)];
            v = [ v,1];

            r = [r,z];
            c = [c,i+1+(k-1)*(boundary_h)];
            v = [v,-1];


            q = i+(k-1)*(boundary_h);
            % for select
            %if ( mod(q,boundary_h)==1 | mod(q,boundary_h)==boundary_h-1 | q <= boundary_h |  boundary_w*boundary_h-boundary_h< q)
            if image_m(i+1, k) ~= image_m(i,k)
                r_s = [r_s,z];
                c_s = [c_s,i+(k-1)*(boundary_h)];
                v_s = [ v_s,1];

                r_s = [r_s,z];
                c_s = [c_s,i+1+(k-1)*(boundary_h)];
                v_s = [v_s,-1];

                r_ss = [r_ss,z];
                if image_m(i,k) ~= 0
                    c_ss = [c_ss,i+1+(k-1)*(boundary_h)];
                else
                    c_ss = [c_ss,i+(k-1)*(boundary_h)];
                end
                v_ss = [v_ss,1];            
            end
            z = z+1;
        end
    end
end
G = sparse(r,c,v,(boundary_h-1)*boundary_w+(boundary_w-1)*boundary_h,boundary_h*boundary_w);

S = sparse(r_s,c_s,v_s,(boundary_h-1)*boundary_w+(boundary_w-1)*boundary_h,boundary_h*boundary_w);

SS = sparse(r_ss,c_ss,v_ss,(boundary_h-1)*boundary_w+(boundary_w-1)*boundary_h,boundary_h*boundary_w);

GD = G-S;
%%

g = GD*U;

Ub = SS*U;

a  = 0.9;
A = G'*G + a*(SS'*SS);

% B = G'*g+a*S'*Ub;
B = G'*g+a*SS'*Ub;
U_after = A\B; % here, too small

% U_after = double(U_after>0).*U_after;

U_blending =uint8(reshape(U_after,boundary_h,boundary_w,d)*255); 
%image_t(x_off:x2_off, y_off:y2_off, :) = U_blending;
%U_blending = U_blending(2:h+1,2:w+1);

figure(3);
for channel = 1:3
    for j = 1:(size(x_cord,1))
        image_t(x_off+x_cord(j), y_off+y_cord(j), channel) = target(x_cord(j),y_cord(j), channel);    
    end
end
imshow(image_t);

for channel = 1:3
    for j = 1:(size(x_cord,1))
        image_t(x_off+x_cord(j), y_off+y_cord(j), channel) = U_blending(x_cord(j),y_cord(j), channel);    
    end
end

figure(1);
imshow(image_t);
