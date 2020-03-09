t = Tiff('rectangle.tif','r');
imageData = read(t);

imshow(imageData);
title('Data');

[x,y] = scanpoints(imageData);