fid=fopen('filter.names.txt');
while 1
   tline = fgetl(fid);
   if ~ischar(tline) 
	break
   end
   disp(tline);
   wfdb2mat(tline);
end
fclose(fid);
