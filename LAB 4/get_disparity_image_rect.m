function get_disparity_image_rect(file1,file2,p_h,p_w,max_disp)
tic
% Get disparity image between file1 and file2, use rectangular patch of
% size p_h by p_w, maximum disparity is max_disp.
imagel=imread(file1);
imager=imread(file2);
% Assume both images have same size.
% 3rd dim is color channels, we don't need to know it.
[i_h, i_w, ~] = size(imagel);
disparity_matrix = zeros(i_h, i_w);

% Parse the left image point by point.
% We discarded the points on the very edge (a border of width p_h or p_w) as it
% seems the same thing was done in the provided "ground truth" image.
for vl=1+p_h:i_h-p_h
    for ul=1+p_w:i_w-p_w
        patchL = imagel(vl-p_h:vl+p_h, ul-p_w:ul+p_w);
        % Initialize fit score with worst case value.
        
        % Sum of squared differences
        % best_fit_score = (2*p_w+1)*(2*p_h+1)*255*255;
        
        % Sum of absolute differences
        best_fit_score = (2*p_w+1)*(2*p_h+1)*255;
        
        % Normalized cross corellation
        % best_fit_score = -1;
        
        other_u = 0;
        
        % Only check max_disp pixels back and forth, it takes very long to
        % compute and we couldn't see any disparity higher than 15
        % anyway.
        start_ur = max(ul-max_disp, 1+p_w);
        end_ur = min(ul+max_disp, i_w-p_w);
        for ur=start_ur:end_ur
            patchR = imager(vl-p_h:vl+p_h, ur-p_w:ur+p_w);
            X = double(patchL) - double(patchR);
                        
            % Sum of squared differences
            % fit_score = sum(X(:).^2);
            
            % Sum of absolute differences
            fit_score = sum(abs(X), 'all');
            
            % Normalized cross corellation
            % fit_score = normxcorr2(patchL,patchR);
            
            % Maximize cross correlation, minimize differences.
            if fit_score < best_fit_score
                other_u = ur;
                best_fit_score = fit_score;
            end
        end
        if other_u == 0
            % This probably means you forgot to flip the sign.
            error('Did not find ur.');
        end
        % fprintf('ul vl: %03d %03d, ur: %03d, disparity: %02d\n', ul, vl, other_u, ul-other_u);
        disparity_matrix(vl, ul)= ul - other_u;
    end
end

% All disparities should have same sign, so remove the noise that doesn't.
if mean(disparity_matrix, 'all') > 0
    disparity_matrix = max(disparity_matrix, zeros(i_h, i_w));
else
    disparity_matrix = min(disparity_matrix, zeros(i_h, i_w));
end

fprintf('%d %d max: %d, min: %d\n', size(disparity_matrix), max(disparity_matrix(:)), min(disparity_matrix(:)));
% mat2gray also normalizes
disparity_image = mat2gray(disparity_matrix);
imwrite(disparity_image,"disparity.png");
toc
end
