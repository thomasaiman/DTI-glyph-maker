
%-----------------------------------------------------------
close all

%add path for the folder with all the data and code files
cd(mainFolder)
addpath(genpath([mainFolder '/' 'codefiles']));
[~,x,~] = fileparts(mainFolder);
if ~isequal(x, 'DTI_glyph_maker')
    error('Make sure all your files are in DTI_glyph_maker')
end


%% graphics figure/axis/surf object properties
    set(0,'DefaultFigureWindowStyle','normal')    
    figure
    s = surf(peaks(10));
    set(gcf,'color','black')
    set(gcf,'Units', 'pixels', 'Position', [0 0 256 256], 'Resize', 'off');
    set(gca,'color','black');
    set(gca,'position',[0 0 1 1],'units','normalized');
    axis([-0.5 0.5 -0.5 0.5 -0.5 0.5])
    axis off
    set(gca,'cameraposition',[0 -10 0])
    set(gca,'cameratarget',[0 0 0])
    set(gca,'cameraviewanglemode','auto')
    light_h = light('Position', [1, -1, 1], 'Style', 'infinite');
    set(s,'facelighting','gouraud')
    set(s,'linestyle','none')
    
    %scaling factor changes how big the glyph is in frame
    scalefactor=1/2.5;
%% preprocessing variable defs
load(matFilePath,'tensors_block');
[~,w] = lastwarn;
if isequal(w,'MATLAB:load:variableNotFound')
    fprintf('Problem loading tensors_block \n')
    return
end

%make sure our files end up where we want
if ~isdir(imgs_dir)
      mkdir(imgs_dir);
end

%clean up the .mat file from last restart
if exist('matname','var')
    delete(matname)
    cd(mainFolder)
end
    
    counter = 0;
    mysphere = struct();
    mysphere.n = 100;
    [mysphere.X,mysphere.Y,mysphere.Z] = sphere(mysphere.n);
    x = mysphere.X(:);
    y = mysphere.Y(:);
    z = mysphere.Z(:);
    mysphere.colors_list = [x,y,z];
    mysphere.preOD = [x.^2, 2*x.*y, 2*x.*z, y.^2, 2*y.*z, z.^2];
    DT_mat = zeros(3,3);
    DT = zeros(6,1);
    
    %used to transform block tensors to RAS coordinates
    xform_RAS1 = [0 -1 0; 0 0 1; 1 0 0];
    xform_RAS2 = [0 0 1; -1 0 0; 0 1 0];
    
    %this is an array that tells us if there is any inforation in each voxel
    blockmask = any(any(tensors_block,5), 4);

    %make a blank glyph for copying. This is faster than writing a new .png
    %for each empty voxel.
    blglyphName = ['blank_glyph' '.png'];
    blglyphPath = [imgs_dir '/' blglyphName];
    if exist(blglyphPath)~=2
    imwrite(zeros([256 256 3]),blglyphPath,'png','Transparency',[0 0 0]);
    end
%%    
    
for slice = sliceList
    
    %blank composite image. We will edit in glyph data as each glyph is
    %generated.
    compositematrix = zeros([16384 16384 3],'uint8');
    
    %make a slice folder, if needed
    sliceFolderName = [dataSetName '_' sprintf('slice%03d', slice)];
    sliceFolderPath = [imgs_dir '/' sliceFolderName]
    if ~isdir(sliceFolderPath)
        mkdir(sliceFolderPath);
    end
    
    for row = 1:size(blockmask,1)
        %print our progress to console
        fprintf('data set = %s slice = %d row = %d \n', dataSetName, slice, row);
        %make a row folder, if needed
        rowFolderName = [dataSetName '_' sprintf('slice%03d_row%03d%s', slice, row)];
        rowFolderPath = [sliceFolderPath '/' rowFolderName];
        if ~isdir(rowFolderPath)
            mkdir(rowFolderPath);
        end
        
        for col = 1:size(blockmask,2)
            %determine our full image name and path
            imgName = [sprintf('slice%03d_row%03d_col%03d_%s', slice, row, col, dataSetName) '.png'];
            imagePath = [rowFolderPath '/' imgName];
           
           %we only proceed with making the glyph if there is information
           %in the voxel. otherwise just copy the blank glyph file.
           if blockmask(row,col,slice)
             DT_mat(:) = tensors_block(row,col,slice,:,:);
             DT_mat(:) = xform_RAS1 * DT_mat * xform_RAS2;
 
             [Xdata, Ydata, Zdata, cdata] = OD_generator(DT_mat,mysphere,scalefactor);
             set(s,'xdata',Xdata,'ydata',Ydata,'zdata',Zdata, 'facecolor', cdata)
 
             %getframe has a drawnow command inside it, so we don't need to waste time
             %drawing it elsewhere
             img = getframe(gcf);
%             imwrite(img.cdata,imagePath,'png','Transparency',[0 0 0]);
         
 
             %put our scaled-down glyph in the composite
             chunk = img.cdata(1:4:end,1:4:end,:);
             compositematrix(1+(row-1)*64:row*64 , 1+(col-1)*64:col*64 , :) = chunk;
           else
%            copyfile(blglyphPath ,imagePath)
           end
        end   
    end

 %%     archive and compress files to .tar.gz
       
%     %save our compositematrix to .png
     fprintf('Saving composite to .png... \n')
     compositeName = [dataSetName sprintf('Slice%03d.png',slice)];
     compositePath = [imgs_dir '/' compositeName];
     imwrite(compositematrix,compositePath)
    
    %check if we have the proper number of files in the slice folder
    %rdir is a function from matlab file exchange
    nFiles = rdir(fullfile(sliceFolderPath,'/**/'));
    nFiles = size(nFiles,1);
    if nFiles == size(blockmask,1)*size(blockmask,2)
        %take our thousands of files and put them in a .tar archive
        fprintf('Consolidating files to a single .tar archive... \n')
        tarName = [sliceFolderName '.tar'];
        tarPath = [imgs_dir '/' tarName];
        cd(imgs_dir)
        if ispc
            zipperPath = [mainFolder '\codefiles\7-Zip\App\7-Zip64\7z.exe'];
            command =['"' zipperPath '" a "' tarName '" "' sliceFolderName '"'];
        elseif isunix
            command =['tar --create --file=' tarName ' ' sliceFolderName '/']
        end
        system(command);
        cd(mainFolder)
        
        %gzip that bad boy (only if the .tar worked)
        try
            gzip(tarPath)
        catch
            fprintf('Tar should have worked, but didn''t \n')
            continue
        end
        %clean up files (only if gzip worked)
        fprintf('gzip done. deleting .tar ... \n')
        delete(tarPath)
        fprintf('deleting extra .png files ... \n')
        rmdir(sliceFolderPath,'s');
        fprintf('Slice %03d done. \n',slice)
    else
        fprintf('Slice %03d didn''t have the right number of files. Didn''t archive. \n', slice) 
    end
    
    
    if counter>5
       glyph_restarter
    end
end

 
