function par_line(file1, file2)
    data = readfile(file1);
    data1 = readfile(file2);

    n = 3;

    f = 1.0;         %Temporary value

    m = size(data,1);
    if m<n; fprintf('M < 3 / error\n'); return; end

    % Szeliski page 291
    vp1 = get_vanishing_point(data(1,1), data(1,2), data(1,3), data(1,4), data(2,1), data(2,2), data(2,3), data(2,4));

    vp2 = get_vanishing_point(data1(1,1), data1(1,2), data1(1,3), data1(1,4), data1(2,1), data1(2,2), data1(2,3), data1(2,4));

    fprintf('Vanishing points (%f %f) and (%f %f)\n', vp1, vp2);
    f = get_focal_distance(vp1(1), vp1(2), vp2(1), vp2(2), 240, 320);
    
    fprintf('Focal distance %f\n', f)
    
    a = zeros(m,n);
    % fill first column with h1 to hN
    a(:,1) = data(:,4) - data(:,2);
    % fill second column with -g1 to -gN
    a(:,2) = -(data(:,3) - data(:,1));
    % fill third column with d1g1-c1h1 to dNgN-cNhN
    a(:,3) = data(:,2) .* -a(:,2)  - data(:,1) .* a(:,1);

    % use SVD to compute vector (x1, x2, x3)
    [U,S,V] = svd(a);  % call matlab SVD routine
    v_min = V(:,n); % s and v are already sorted from largest to smallest
    if all(v_min < 0); v_min = -v_min; end % ?

    wvec = [v_min(1)/f v_min(2)/f v_min(3)];
    wvec = wvec / norm(wvec,2);
    fprintf('Least squares solution vector %d     : (%f %f %f)\n',i,wvec );

function data=readfile(file)
    f = fopen(file,'r');
    for i=1:4; fgets(f); end
    all = fscanf(f,'%f %f %f %f '); m = length(all)/4;
    data= reshape(all,4,m)';
    fclose(f);

% given 2 parallel lines, each containing 2 points, calculate their
% intersection
function point=get_vanishing_point(x1, y1, x2, y2, x3, y3, x4, y4)
    % https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection#Given_two_points_on_each_line
    x = (x1 .* y2 - y1 .* x2) .* (x3 - x4) - (x1 - x2) .* (x3 .* y4 - y3 .* x4);
    y = (x1 .* y2 - y1 .* x2) .* (y3 - y4) - (y1 - y2) .* (x3 .* y4 - y3 .* x4);
    denom = (x1 - x2) .* (y3 - y4) - (y1 - y2) .* (x3 - x4);
    point = [x/denom,y/denom];
    
function f=get_focal_distance(xi, yi, xj, yj, cx, cy)
    f = sqrt(-(xi-cx).*(xj-cy)-(yi-cy).*(yj-cy));