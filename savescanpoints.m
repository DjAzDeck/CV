function savescanpoints(filename,x,y)

fid = fopen(filename,'wt');
dim = size(x);
nlines = dim(1);
fprintf(fid,'FILE OF DATA FOR PAR_LINE:\n');
fprintf(fid,'Number of Lines, Columns\n');
fprintf(fid,'%d %d\n',nlines,3);
fprintf(fid,'DATA\n');
for i= 1:nlines
  fprintf(fid,'%f %f %f %f\n',x(i,1), y(i,1),x(i,2), y(i,2));
end
fclose(fid);  
