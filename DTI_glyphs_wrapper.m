%change this file to suit your file locations 
%and/or environment variables

 %-----------------------User Inputs------------------
 
%specify the slices you want to run as a vector
sliceList = [1];

%.mat file with 'tensors_block' in it. Make sure it's in the
%DTI_glyph_maker folder
matFilePath = 'F:\DTI_blocks\Hazel_exvivo1_block.mat';

%name that will be appended to the beginning of all files in the set
dataSetName = 'Hazel_exvivo1_DTI';

%directory where you want your output stored. A new folder will be created for each data set.
imgs_dir = 'C:\Users\Thomas\Desktop';


%matlab.exe file location. Will be used to restart matlab every 10 slices.
%MATLAB significantly slows down with long-running scripts, so we want to
%avoid that by periodically restarting.
matlab_exe_path='C:\Program Files\MATLAB\R2017a\bin\matlab.exe';

%try to use opengl-enabled hardware if you can. If it doesn't work it will
%default back to opengl software instead. Some systems may throw an error anyway,
%in which case you should get rid of this line.
opengl hardware

%----------------------------------------------------------



%leave this
mainFolder = pwd;
addpath(genpath([mainFolder '/' 'codefiles']));
imgs_dir = fullfile(imgs_dir,[dataSetName '_glyphs']);
%run the big script
DTI_glyphs_v10

