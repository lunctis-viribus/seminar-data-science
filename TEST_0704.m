
image_s = imread('source.jpg');

% image_s = imread('./img/fg.jpg');

f1 = figure(2);
imshow(image_s);
disp("select the source region");
rect = getrect;
rect = round(rect);
region_source = image_s(rect(2):rect(2)+rect(4)-1,rect(1):rect(1)+rect(3)-1,:);
close(f1);
f1 = figure(1);
imshow(region_source);
disp("type anything to close the figure");
pause;
close(f1);


image_t = imread('target.jpg');
% image_t = imread('./img/bg.jpg');
f2 = figure(2);
imshow(image_t);
disp("select the target region");
rect = getrect;
rect = round(rect);
region_target = image_t(rect(2):rect(2)+rect(4)-1,rect(1):rect(1)+rect(3)-1,:);
close(f2);
f1 = figure(1);
imshow(region_target);
disp("type anything to close the figure");
pause;
close(f1);

[h_t w_t d_t]  = size(region_target);
[h_s w_s d_s]  = size(region_source);
if(h_t<w_t)
    rate = floor(10*(h_t)/h_s)/10;
    region_source = imresize(region_source,rate*0.9);
else
    rate = floor(10*(w_t)/w_s)/10;
    region_source = imresize(region_source,rate*0.9);
end




% [h w d]=size(region_source);
% image_empty = zeros(h_t,w_t,d_t);
% 
% image_empty(floor(h_t/2)-floor(h/2):floor(h_t/2)-floor(h/2)+h-1, floor(w_t/2)-floor(w/2):floor(w_t/2)-floor(w/2)+w-1,:) = ones(h,w,d);
% 
% image_m = image_empty;
% target = region_target;
% target(floor(h_t/2)-floor(h/2):floor(h_t/2)-floor(h/2)+h-1, floor(w_t/2)-floor(w/2):floor(w_t/2)-floor(w/2)+w-1,:) = region_source;

[h w d]=size(region_source);
image_empty = zeros(h+2,w+2,d);
image_empty(2:h+1,2:w+1,:) = ones(h,w,d);
image_m = image_empty;
target = region_target;
disp("?");
target(2:h+1,2:w+1,:) = region_source;
target_1 = target(1:h+2,1:w+2,:);
f4 = figure(4);
imshow(target_1);
pause;
close(f4);
disp("??");
boundary_h = h+2;
boundary_w = w+2;
U = double(reshape(target_1,boundary_h*boundary_w,d_t))/255;


% Construct gradient matrix
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
        if image_m(i,k) ~= 0 | (image_m(i+1,k) ~= 0)
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
r_ss = [r_ss , z , z+1, z+2, z+3];
c_ss = [c_ss , 1 , boundary_h, boundary_h*(boundary_w-1)+1, boundary_h*boundary_w];
v_ss = [v_ss , 1 , 1 ,1 , 1];

G = sparse(r,c,v,(boundary_h-1)*boundary_w+(boundary_w-1)*boundary_h,boundary_h*boundary_w);

S = sparse(r_s,c_s,v_s,(boundary_h-1)*boundary_w+(boundary_w-1)*boundary_h,boundary_h*boundary_w);

SS = sparse(r_ss,c_ss,v_ss,(boundary_h-1)*boundary_w+(boundary_w-1)*boundary_h,boundary_h*boundary_w);

GD = G-S;
%

g = GD*U;

Ub = SS*U;

a  = 10000;
A = G'*G + a*(SS'*SS);

% B = G'*g+a*S'*Ub;
B = G'*g+a*SS'*Ub;
U_after = A\B; % here, too small

U_blending =uint8(reshape(U_after,boundary_h,boundary_w,d)*255); 
imshow(U_blending);


[h,w,d] = size(U_blending);
figure(3);
image_t(rect(2):rect(2)+h-1,rect(1):rect(1)+w-1,:) = U_blending;

imshow(image_t);


