%change this file to suit your file locations 
%and/or environment variables

 %-----------------------User Options------------------
 
%specify the slices you want to run as a vector
sliceList = [1];

%.mat file with 'tensors_block' in it. Make sure it's in the
%DTI_glyph_maker folder
matFilePath = ['C:\Users\aimantj\Desktop\DTI_blocks\' 'MJ_invivo2_block.mat'];

%name that will be appended to the beginning of all files in the set
dataSetName = 'MJ_invivo2_DTI';

%directory to where you want your slice directories to be stored
imgs_dir = ['C:/Users/aimantj/Desktop' '/' dataSetName '_glyph_images'];

%try to use opengl-enabled hardware if you can. If it doesn't work it will
%default back to opengl software instead. Some systems may throw an error anyway,
%in which case you should try 'opengl software'
opengl hardware

%----------------------------------------------------------

%add path for the folder with all the data and code files
mainFolder = pwd;
addpath(genpath([mainFolder '/' 'codefiles']));

%run the big script
DTI_ellipses


