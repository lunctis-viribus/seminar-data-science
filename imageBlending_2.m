function [image_t] = imageBlending(source,target2, manual, mask, offsetX, offsetY,mask_selected)
% image_s = imread('source.jpg');
%%% REMOVE
% target2 = imread('./img/bg.jpg');
% source = imread('./img/fg.jpg');
% mask = imread('./img/mask2.jpg');
% 
% manual = 1;
% 
% offsetX = 180;
% offsetY = 100;
%%%




if manual
    %%REMOVE
    image_s = source;
    image_t = target2;
    % Choose source region
    if ~mask_selected
        f1 = figure(1);
        imshow(image_s);
        disp('select the source region');
        rect = getrect;
        rect = round(rect);
        region_source = image_s(rect(2):rect(2)+rect(4)-1,rect(1):rect(1)+rect(3)-1,:);
        close(f1);
        f1 = figure(1);
        imshow(region_source);
        disp('type anything to close the figure');
        pause;
        close(f1);
        % Choose target region
        f2 = figure(2);
        imshow(image_t);
        disp('select the target region');
        rect = getrect;
        rect = round(rect);
        region_target = image_t(rect(2):rect(2)+rect(4)-1,rect(1):rect(1)+rect(3)-1,:);
        close(f2);
        f1 = figure(1);
        imshow(region_target);
        disp('type anything to close the figure');
        pause;
        close(f1);
        
        % Resize source image
        [h_t w_t d_t]  = size(region_target);
        [h_s w_s d_s]  = size(region_source);
        if(h_t<w_t)
            rate = floor(10*(h_t)/h_s)/10;
            region_source = imresize(region_source,rate*0.9);
        else
            rate = floor(10*(w_t)/w_s)/10;
            region_source = imresize(region_source,rate*0.9);
        end

        [h w d]=size(region_source);

        target = region_target;
        target(2:h+1,2:w+1,:) = region_source;
        target_1 = target(1:h+2,1:w+2,:);
        f4 = figure(4);
        imshow(target_1);
        pause;
        close(f4);

        boundary_h = h+2;
        boundary_w = w+2;
        U = double(reshape(target_1,boundary_h*boundary_w,d_t))/255;

        %Create mask
        image_empty = zeros(h+2,w+2,d);
        image_empty(2:h+1,2:w+1,:) = ones(h,w,d);
        image_m = image_empty;
    else
        
        [h w d]=size(source);
        %region_source = image_s(rect(2):rect(2)+rect(4)-1,rect(1):rect(1)+rect(3)-1,:);
        mask = round(mask(:,:, 1)/255);
        [x_cord, y_cord] = find(mask);
        h = peak2peak(x_cord) + 1;
        w = peak2peak(y_cord) + 1;

        %Change mask
        image_empty = zeros(h+2,w+2,d);
        image_empty(2:h+1,2:w+1) = mask(min(x_cord):max(x_cord),min(y_cord):max(y_cord));
        image_m = image_empty;

        % Recalibrate coordinates
        x_cord_zero = x_cord - min(x_cord) + 1;
        y_cord_zero = y_cord - min(y_cord) + 1;

        image_empty = zeros(h+2,w+2,3);
        for dimen = 1:d
            image_empty(2:h+1, 2:w+1,:) = source(min(x_cord):max(x_cord),min(y_cord):max(y_cord), :);
        end
        image_s = image_empty; 
        
        f2 = figure(2);
        imshow(image_t);
        disp('select the target place to stitch');
        rect = getrect;
        rect = round(rect);
        target = image_t(rect(2)-1:rect(2)+h,rect(1)-1:rect(1)+w,:);
        close(f2);
        for channel = 1:3
            for j = 1:(size(x_cord,1))
                target(x_cord_zero(j)+1, y_cord_zero(j)+1, channel) = image_s(x_cord_zero(j)+1,y_cord_zero(j)+1, channel);    
            end
        end
    image_t = 2;
    boundary_h = h+2;
    boundary_w = w+2;
    U = double(reshape(target,boundary_h*boundary_w,d))/255;
    end    
    
    
else
    [h w d]=size(source);
    %region_source = image_s(rect(2):rect(2)+rect(4)-1,rect(1):rect(1)+rect(3)-1,:);
    mask = round(mask(:,:, 1)/255);
    [x_cord, y_cord] = find(mask);
    h = peak2peak(x_cord) + 1;
    w = peak2peak(y_cord) + 1;
    
    %Change mask
    image_empty = zeros(h+2,w+2,d);
    image_empty(2:h+1,2:w+1) = mask(min(x_cord):max(x_cord),min(y_cord):max(y_cord));
    image_m = image_empty;
    
    % Recalibrate coordinates
    x_cord_zero = x_cord - min(x_cord) + 1;
    y_cord_zero = y_cord - min(y_cord) + 1;
    
    
    %
    
    image_empty = zeros(h+2,w+2,3);
    for dimen = 1:d
        image_empty(2:h+1, 2:w+1,:) = source(min(x_cord):max(x_cord),min(y_cord):max(y_cord), :);
    end
    image_s = image_empty; 
    
    target = target2(offsetX-1:(offsetX+h), offsetY-1:(offsetY+w), :);
    for channel = 1:3
        for j = 1:(size(x_cord,1))
            target(x_cord_zero(j)+1, y_cord_zero(j)+1, channel) = image_s(x_cord_zero(j)+1,y_cord_zero(j)+1, channel);    
        end
    end
    
    image_t = 2;
    boundary_h = h+2;
    boundary_w = w+2;
    U = double(reshape(target,boundary_h*boundary_w,d))/255;
end




% [h w d]=size(region_source);
% image_empty = zeros(h_t,w_t,d_t);
% 
% image_empty(floor(h_t/2)-floor(h/2):floor(h_t/2)-floor(h/2)+h-1, floor(w_t/2)-floor(w/2):floor(w_t/2)-floor(w/2)+w-1,:) = ones(h,w,d);
% 
% image_m = image_empty;
% target = region_target;
% target(floor(h_t/2)-floor(h/2):floor(h_t/2)-floor(h/2)+h-1, floor(w_t/2)-floor(w/2):floor(w_t/2)-floor(w/2)+w-1,:) = region_source;


%%


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

%%
if manual & (~mask_selected)
    image_t(rect(2):rect(2)+h-1,rect(1):rect(1)+w-1,:) = U_blending;
    imshow(image_t);
else
    image_t = target2;
    if (~manual)
        for channel = 1:d
            for j = 1:(size(x_cord,1))
                image_t(offsetX+x_cord_zero(j)+1 , offsetY+y_cord_zero(j)+1 , channel) = U_blending(x_cord_zero(j)+1, y_cord_zero(j)+1, channel); 
            end
        end
    else
        for channel = 1:d
            for j = 1:(size(x_cord,1))
                image_t(rect(2)+x_cord_zero(j)+1 , rect(1)+y_cord_zero(j)+1 , channel) = U_blending(x_cord_zero(j)+1, y_cord_zero(j)+1, channel); 
            end
        end
    end
    %imshow(target3);
end


end

