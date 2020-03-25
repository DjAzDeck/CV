
function get_disparity_image(file1,file2,p_w,p_h)
    imagel=imread(file1);
    imager=imread(file2);
    disparity_matrix = compute_disparity(imagel,imager,p_w,p_h);
    fprintf("%d %d", size(disparity_matrix));
    disparity_image = mat2gray(disparity_matrix);
    imwrite(disparity_image,"disparity.bmp");
end

% Given two images from left and right, compute the disparity in each point
% using p_w and p_h for the width and height of the patch
function disparity=compute_disparity(imagel,imager, p_w, p_h)
    % image sizes
    i_w = size(imagel, 1);
    i_h = size(imagel, 2);
    fprintf("%d %d\n", i_w, i_h);
    fprintf("%d %d\n", p_w, p_h);
    disparity=zeros(i_w, i_h);
    
    % WE HAVE TO PARALLELIZE THIS
    % ACTUALLY VECTORIZE https://nl.mathworks.com/matlabcentral/answers/182083-changing-the-step-in-a-for-loop
    for ul=1:i_w-p_w
        for vl=1:i_h-p_h
            fprintf("%d %d\n", ul, vl);
            patch=imagel(ul:ul+p_w-1, vl:vl+p_h-1);
            point_on_right = get_similar_region(patch,imager);
            disparity(ul,vl)= ul - point_on_right(1);
        end
    end
end
    
% normalized cross correlation https://nl.mathworks.com/help/images/ref/normxcorr2.html
% patch - a 2d matrix of pixels that must be found in an image
% image - the image to search through
function coords=get_similar_region(patch, image)
    % patch sizes
    p_w = size(patch,1);
    p_h = size(patch,2);
    % image sizes
    i_w = size(image,1);
    i_h = size(image,2);
    % initialize most similar region
    coords = [1, 1];
    best_fit_score = normxcorr2(patch, image(1:p_w, 1:p_h));
    for ui=1:i_w-p_w
        for vi=1:i_h-p_h
            region=image(ui:ui+p_w-1, vi:vi+p_h-1);
            fit_score = normxcorr2(patch,region);
            if fit_score > best_fit_score
                coords = [ui, vi];
                best_fit_score = fit_score;
            end
        end
    end
end

% calculate 3d coordinates from 2 pairs of 2d coordinates from cameras with
% focal length f set distance b apart
function coords=get_coords(ul, ur, vl, vr, f, b)
    z = f .* b .* (ul - ur);
    x = ((z ./ f .* ul - b ./ 2) + (z ./ f .* ur - b ./ 2)) ./ 2;
    y = ((z ./ f .* vl - b ./ 2) + (z ./ f .* vr - b ./ 2)) ./ 2;
    coords = [x, y, z];
end