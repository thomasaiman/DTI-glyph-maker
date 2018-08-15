DTI Glyph Maker.

-leave all the files/folders within DTI_glyph_maker in their current locations.
-This takes a .mat file containing the tensors_block output from the previous dti_block_space function and creates a glyph .png file for each voxel. This means millions of files. These files are automatically zipped into .tar.gz files so that your OS isn't bogged down too much. Expect each data set to be about 60 GB.
-You can run specific slices from each data set if desired.
-This program also creates a composite .png of all the glyphs in each slice. Good for checking your work.
 
To run on a desktop:
-Open DTI_glyphs_wrapper.m in MATLAB. Edit the file locations under ----User Inputs----- to be what you want. 
-Edit the variables under ----User Inputs----- to be what you want. There are comments in that file explaining what each one does.
-Run DTI_glyphs_wrapper.m
-If your computer has a 4 or more processor cores and >8GB of RAM, I recommend opening multiple MATLABs on the computer and running different parts in parallel.  E.g. open MATLAB, start running slices 1:140, then open a different MATLAB window and in that window start running slices 141:280.

To run on ACCRE:
-make sure the DTI_glyphs_folder and your block.mat files are on ACCRE
-Open glyphs.slurm with your favorite text editor
-Change the #SBATCH --output as described in the file comments
-Change the #SBATCH --mail-user as described in the file comments
-Change the #SBATCH --array as described in the file comments
-Change the variables under ---- User Inputs---- to be what you want.
-Save these changes.
-Login to ACCRE, cd to the DTI_glyph_maker folder
-sbatch glyphs.slurm



------------Other folders--------------------------------------------
Notepad++ is a text editor for Windows. It's handy for editing your .slurm files because it can save with unix newline characters. If you're on Mac, use nano within Terminal to edit. Or use whatever program you want.

Renamer is a GUI tool that can help you if you find yourself needing to rename many files or folders. Only works on Windows.

7-zip is a tool that lets you make many types of archives and compressed files. Good if a Windows user needs to work with .tar.gz files. MacOS should be able to work with .tar.gz by default.




---------------Common Errors-----------------------------------------
-If you get an error for the line
 
compositematrix(1+(row-1)*32:row*32 , 1+(col-1)*32:col*32 , :) = chunk;

then you probably have high DPI monitor and MATLAB is automatically increasing the resolution to make the image look larger on your screen. This is bad because we want to make images that are exactly 256x256 pixels. Google "DPI Aware-Behavior in MATLAB". You can adjust your screen resoution, OS scaling, or adjust line 25 set(gcf,'Units', 'pixels', 'Position', [0 0 256 256], 'Resize', 'off'); in DTI_glyphs_v10.m.




------------Notes----------------------------------------------------
-This code is intended to automatically restart MATLAB periodically if it's running on a desktop/laptop. This is because with long-running scripts, MATLAB inevitably fragments its memory space and grinds to a halt. The only way to fix that is to restart MATLAB. It will pick up where it left off on restart.

-Expect a single instance of MATLAB on a desktop to take ~48 hours to do a full data set. If you run two instances at once, you're down to 24 hours. If you have multiple computers, it can be even faster.

-Expect ACCRE to take about 12 hours to finish with everything running in parallel. This is due to the fact that the more intricate slices tend to take about 12 hours each on ACCRE. ACCRE uses the X window system for graphics, so it's very bad at this particular task. If you get failures due to low memory or timeout, you can edit the parameters in the glyphs.slurm file.

-If you want to just make a composite slice image and not spend time writing lots of small .pngs to disk, try changing the last line of DTI_glyphs_wrapper.m from 'DTI_glyphs_v10' to 'DTI_glyphs_v10_debug'

-To change the size of the glyphs in the .pngs, change scalefactor at line 33 in DTI_glyphs_v10.

-To change other glyph calculations, edit OD_generator.m



---------Changing orientation of data and slices---------------------
-There is a matrix in DTI_glyphs_v10.m called xform_RAS1. It is used to transform the diffusion tensor matrix to the RAS coordinate space, which is necessary for getting the correct glyph directions and colors. It should be good as is, unless you start trying to use differently oriented tensors and block spaces. For what it's worth, the tensors_block data at the time of this writing is coming in a 5D arrays of the following form:
(+inferior, +right, +posterior, 3, 3) i.e. a 3x3 tensor matrix for each voxel.

-Each slice is currently in the coronal plane, viewed from posterior. To change this you need to change:
1. the cameraposition coordinates at line 34 in DTI_glyphs_v10. These are RAS coordinates. 
2. the order of (row,col,slice) in lines 130+131 of DTI_glyphs_v10.
3. the approprite limits for the for loops on lines 113 + 123

E.g. given tensors_block of (+inferior, +right, +posterior, 3, 3), we want sagittal slices viewed from right.
line 34: set(gca,'cameraposition',[10 0 0])
line 130: if blockmask(col,slice,row)
line 131: DT_mat(:) = tensors_block(col,slice,row,:,:);
line 123: for col = 1:size(blockmask,3)



----------Optimization notes-----------------------------------
-This code does not use the dwmri_monkey_visualizer class. That code is inefficient for capturing images and writing to disk.

-If a voxel is empty, this code copies an existing blank_glyph.png image instead of using imwrite()

-Glyph surface calculations and rendering are only done if the voxel isn't blank

-.tar.gz files are good for this project because they don't have headers like other zip formats. We have a bunch of small files and the headers take up a lot of extra space and time.

-MATLAB has figure objects, axes objects, and surface objects, among others. The surf() function creates a new axes object every time it is called. This takes time. Furthermore, these axes objects will stack up in the figure, so that even if they're not visible, your computer still spends resources keeping track of them. It is fastest to create just one figure, one axes, one surface, and then constantly update the properties of the surface object to be what you want.

-using the parfor and parfeval just leads to even more memory problems. Just run separate MATLAB instances.

 
