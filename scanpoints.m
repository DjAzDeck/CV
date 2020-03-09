function [x,y] = scanpoints(I)
%scanpoints  Manually scan points in a 2-D image
%   [x,y] = scanpoints()
%  26/09/2008
% I is the image scanned
% heavily adapted from
%   Chenyang Xu and Jerry L. Prince, 4/1/95, 6/17/97
%   Copyright (c) 1995-97 by Chenyang Xu and Jerry L. Prince
%   Image Analysis and Communications Lab, Johns Hopkins University

figure; imshow(I);

d = size(I);
ysize = d(1);
hold on

x = [];
y = [];
n =0;

% Loop, picking up the points
disp('Left mouse button picks points.')
disp('Right mouse button picks last point.')

but = 1;
while but == 1
      [s, t, but] = ginput(1);
      if but == 1
	n = n + 1;
	x(n,1) = s;
	y(n,1) = ysize - t;
        [s, t, but] = ginput(1);
	x(n,2) = s;
	y(n,2) = ysize - t;
	plot(x(n,:), ysize - y(n,:), 'r-');
      end
end   

hold off

