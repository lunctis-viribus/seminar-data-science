%Source - Source image, which get blended in the target image
%Target - Target image
%Manual - 0 = put source image on given offset. 1 = choose by clicking
%where the image is blended
%Mask - Mask image, which part of the source should be included in the
%results. (Can be omitted when manuel = 0.)
%offsetX - Height offset of source image on target image. 
%(Only for manual = 0)
%offsetY - Width offset of source image on target image. 
%(Only for manual = 0)
function [target] = imageBlending(source,target, manual, mask, offsetX, offsetY)
%Manually choose the position where the source image gets pasted in the
%target image or automatically, where the user has to give the offset.
if manual
    % If nargin > 3, then there is a mask provided. Giving an offset won't
    % do anything. Smaller than 3 does not work.
    if nargin == 3
        mask_selected = 0;
        f1 = figure(1);
        imshow(source);
        disp('select the source region');
        rect = getrect;
        rect = round(rect);
        region_source = source(rect(2):rect(2)+rect(4)-1,rect(1):rect(1)+rect(3)-1,:);
        close(f1);
        f1 = figure(1);
        imshow(region_source);
        disp('type anything to close the figure');
        pause;
        close(f1);
        % Choose target region
        f2 = figure(2);
        imshow(target);
        disp('select the target region');
        rect = getrect;
        rect = round(rect);
        region_target = target(rect(2):rect(2)+rect(4)-1,rect(1):rect(1)+rect(3)-1,:);
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

        region_target(2:h+1,2:w+1,:) = region_source;
        target_1 = region_target(1:h+2,1:w+2,:);
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
        mask_selected = 1;
        [h w d]=size(source);
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
        accepted = 0;
        while ~accepted
            f2 = figure(2);
            imshow(target);
            disp('Select the top left corner where the source image will be "pasted"');
            [rectX,rectY] = ginput(1);
            rect = round([rectX,rectY]);            
            if ~(rect(2) < 1 | rect(2) + h > size(target, 1) | rect(1) < 1 | rect(1) + w > size(target, 2))
                region_target = target(rect(2)-1:rect(2)+h,rect(1)-1:rect(1)+w,:);
                accepted = 1;
            else
                disp('Source image will be outside of the target image, choose a different position')
            end
            close(f2);
        end
        for channel = 1:3
            for j = 1:(size(x_cord,1))
                region_target(x_cord_zero(j)+1, y_cord_zero(j)+1, channel) = image_s(x_cord_zero(j)+1,y_cord_zero(j)+1, channel);    
            end
        end
    boundary_h = h+2;
    boundary_w = w+2;
    U = double(reshape(region_target,boundary_h*boundary_w,d))/255;
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
    
    region_target = target(offsetX-1:(offsetX+h), offsetY-1:(offsetY+w), :);
    for channel = 1:3
        for j = 1:(size(x_cord,1))
            region_target(x_cord_zero(j)+1, y_cord_zero(j)+1, channel) = image_s(x_cord_zero(j)+1,y_cord_zero(j)+1, channel);    
        end
    end
    boundary_h = h+2;
    boundary_w = w+2;
    U = double(reshape(region_target,boundary_h*boundary_w,d))/255;
end

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
        if image_m(k,i) ~= 0 | (image_m(k,i+1) ~= 0)
            r = [r,z];
            c = [c,k+(boundary_h*(i-1))];
            v = [ v,-1];

            r = [r,z];
            c = [c,k+(boundary_h*(i))];
            v = [v,1];
            q = k+(boundary_h*(i-1));
            % for select
            if image_m(k,i+1) ~= image_m(k,i)
                r_s = [r_s,z];
                c_s = [c_s,k+(boundary_h*(i-1))];
                v_s = [ v_s,-1];

                r_s = [r_s,z];
                c_s = [c_s,k+(boundary_h*(i))];
                v_s = [v_s,1];

                r_ss = [r_ss,z];
                if image_m(k,i) ~= 0
                    c_ss = [c_ss,k+(boundary_h*(i))];
                else
                    c_ss = [c_ss,k+(boundary_h*(i-1))];
                end
                v_ss = [v_ss,1];            
            end
            z= z+1;
        end
    end
end

z = (boundary_w-1)*boundary_h; 
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

B = G'*g+a*SS'*Ub;
U_after = A\B; 

U_blending =uint8(reshape(U_after,boundary_h,boundary_w,d)*255); 

[h,w,d] = size(U_blending);

%%
if manual & (~mask_selected)
    target(rect(2):rect(2)+h-1,rect(1):rect(1)+w-1,:) = U_blending;
else
    if (~manual)
        for channel = 1:d
            for j = 1:(size(x_cord,1))
                target(offsetX+x_cord_zero(j)+1 , offsetY+y_cord_zero(j)+1 , channel) = U_blending(x_cord_zero(j)+1, y_cord_zero(j)+1, channel); 
            end
        end
    else
        for channel = 1:d
            for j = 1:(size(x_cord,1))
                target(rect(2)+x_cord_zero(j)+1 , rect(1)+y_cord_zero(j)+1 , channel) = U_blending(x_cord_zero(j)+1, y_cord_zero(j)+1, channel); 
            end
        end
    end
end


end

