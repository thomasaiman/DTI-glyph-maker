
 %-----------------------No User Options------------------
 %you should modify the .slurm file to change names and paths
 %try not to edit this one
 
 %----------------------------------------------------------

%specify the slices you want to run as a vector
inputArg1 = getenv('SLURM_ARRAY_TASK_ID');
sliceList = str2num(inputArg1)
WORK_DIR = getenv('WORK_DIR');
STOR_DIR = getenv('STOR_DIR');

%.mat file with 'tensors_block' in it. Make sure it's in the
%DTI_glyph_maker folder
matFilePath = getenv('MATFILEPATH')

%name that will be appended to the beginning of all files in the set
dataSetName = getenv('DATASETNAME')

%directory to where you want your (temporary) slice directories to be created
imgs_dir = [WORK_DIR '/' dataSetName '_glyphs']
mkdir(imgs_dir)

%move compressed slice from WORK_DIR to your normal non-tmp folder
final_dir = [STOR_DIR '/' dataSetName '_glyphs']
mkdir(final_dir)

%try to use opengl-enabled hardware if you can. If it doesn't work it will
%default back to opengl software instead. Some systems may throw an error anyway,
%in which case you should try 'opengl software'
opengl software

%putting this in because if you happen to set WRAPPERFOLDER incorrectly and then add that to the path, %it screws up and slows down MATLAB next time you run it
restoredefaultpath
savepath

%add path for the folder with all the data and code files
mainFolder = getenv('WRAPPERFOLDER')
addpath(genpath([mainFolder '/' 'codefiles/']));

%run the big script
DTI_glyphs_v10

%move compressed slice and composite from WORK_DIR to your normal non-tmp folder
slice = sliceList
gzName = [sliceFolderName '.tar.gz']
gzPath = [imgs_dir '/' gzName]
movefile(gzPath, final_dir)
compositeName = [dataSetName sprintf('Slice%03d.png',slice)]
compositePath = [imgs_dir '/' compositeName]
movefile(compositePath,final_dir)

