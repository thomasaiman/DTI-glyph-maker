mynum = randi([1e8 1e9]);
matname = [num2str(mynum) '.mat'];
sliceList = sliceList(sliceList>slice);
clear tensors_block compositematrix mysphere
cd([mainFolder '/' 'codefiles'])
save(matname)
if ispc
   command=['"' matlab_exe_path '" -r "load ' matname ' ;DTI_glyphs_v10"'];
elseif isunix
   command=[ matlab_exe_path ' -r "load ' matname ' ;DTI_glyphs_v10"'];
end
system(command)
exit

