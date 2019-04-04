%This script populates the subfolders within the cell folders (Actin,
%Analysis), splits tiff images, and generates movieData.mat files for QFSM
%BH 9/2015, v4.1 production

%--INSTRUCTIONS---------------------------------------------------------
%=>Your directory is where all your cell folders are stored.
%=>Your cell folders should be named serially (e.g. TS_Cell_1, etc)
%=>You need to :
%1) comment out lines 55-56 on MovieObject.m, 
%2) comment out lines 136-137 on Channel.m
%3) to re-classify channelPath_ from a write protected property (line 39, 
%Channel.m) to a property
%4) to re-classify nFrames_ from a write protected property (line 25,
%MovieData.m) to a property
%=>You need a (any) movieData.mat file in the same directory as this script 
%or the script will prompt you for one. Rename it movieData_QFSM.mat

%New in version 4.0:
%-added support for existing image directories
%-switch/case statements for usability (v4.1)
%-create info.txt file (v4.1)
%New in version 3.0:
%-revised mkdir structure (new Actin subfolder)
%-create movieData.mat files in preparation for QFSM analysis
%New in version 2.0:
%-multiselect tifs
%--INSTRUCTIONS-END-----------------------------------------------------

close all
clear all

%--SPLIT-TIFF-PROMPT----------------------------------------------------
%prompts to split tiff and create directories, if 'n', then proceed to
%processing movieData.mat
prompt_split_tiff = 'Would you like to split a tiff? [y/n] ';
split_tiff = input(prompt_split_tiff,'s');
switch split_tiff
    
%if split_tiff == 'y'
case 'y'   
%--SPLIT-TIFF-PROMPT-END------------------------------------------------

%--SETTING-DIRECTORY----------------------------------------------------
%creating directory, would need to do once per session
%prompt_make_dir = 'Would you like to create a new directory? [y/n] ';
%make_dir = input(prompt_make_dir,'s');
disp('Select a directory to work in');
dir_path = uigetdir;

prompt_name_dir = 'What would you like to name your directory? ';
directory_name = input(prompt_name_dir,'s');

mkdir(dir_path,directory_name); %path, name

%creating cell subfolders
prompt_cell_number = 'How many cells are you analyzing? ';
prompt_folder_naming = 'How would you like to name your folders? ';
cell_folder_num = input(prompt_cell_number);
folder_naming = input(prompt_folder_naming,'s');

for i=1:cell_folder_num
    i_var = num2str(i);
    cell_folder_name = strcat(folder_naming,'_',i_var);
    sub1folder_path = strcat(dir_path,'\',directory_name);
    mkdir(sub1folder_path,cell_folder_name);
    sub2folder_path = strcat(dir_path,'\',directory_name,'\',cell_folder_name);
    sub3folder_path = strcat(dir_path,'\',directory_name,'\',cell_folder_name,'\','Actin');
    mkdir(sub3folder_path,'Actin');
    mkdir(sub2folder_path,'Analysis');
    disp(cell_folder_name);
end

disp('Directories created...');
dir_path_cell = strcat(dir_path,'\',directory_name);
cell_folder_class = folder_naming;
%--SETTING-DIRECTORY-END------------------------------------------------


%--SETTING-CHANNELS-----------------------------------------------------
prompt_num_channel = 'How many channels would you like to analyze? ';
channel_num = input(prompt_num_channel);

channel_array = {channel_num,1,1}; %3 rows, 1 column, 1 z

for n=1:channel_num
    n_str = num2str(n);
    prompt_name_channel = ['Name of channel ',n_str,'? ']; %strcat removes white spaces
    channel_array{n} = input(prompt_name_channel,'s');
end

clearvars n
%--SETTING-CHANNELS-END-------------------------------------------------


%--SELECTING-TIFF-FILES-------------------------------------------------
%need to split tiff stack
disp('Select tiff file(s) to split');

%[FileName,PathName,FilterIndex] = uigetfile({'*.tif'});
[FileName,PathName,FilterIndex] = uigetfile({'*.tif'},'MultiSelect','on');

%identifying number of tifs selected...
switch class(FileName)
    case 'char'  %if FileName is character array --> only 1 tif selected
        num_files = 1;
        info = imfinfo(FileName);
        num_images{1} = numel(info);
        tif_multiple = 0;
        %saving information text file
        info_path = strcat(dir_path_cell,'\',cell_folder_class,'_1','\info.txt');
        fid_info = fopen(info_path,'w+'); %creates new writable file      
        fprintf(fid_info,'%s\r\n','Original file name:',FileName,' ','Channels:');%fileID,format,data1,data2,... (w/newline)
            for n=1:channel_num
                fprintf(fid_info,'%s\r\n',channel_array{n});%fileID,format,data1,data2,... (w/newline)
            end
        fclose(fid_info);
    case 'cell' %if FileName is cell array --> 2+ tif selected
        num_files = numel(FileName);
        info = {num_files};
        num_images = {num_files};
        tif_multiple = 1;
        %tabulating files selected
        for f=1:num_files
            f_var = num2str(f);
            info{f} = imfinfo(FileName{f});
            num_images{f} = numel(info{f});
            %disp(info{f});
            %saving information text file
            info_path = strcat(dir_path_cell,'\',cell_folder_class,'_',f_var,'\info.txt');
            fid_info = fopen(info_path,'w+'); %creates new writable file
            fprintf(fid_info,'%s\r\n','Original file name: ',FileName{f},' ','Channels:');%fileID,format,data1,data2,... (w/newline)
            for n=1:channel_num
                fprintf(fid_info,'%s\r\n',channel_array{n});%fileID,format,data1,data2,... (w/newline)
            end
            fclose(fid_info);
        end
end

%if number of files selected not equal to number of cells inputted
if cell_folder_num ~= num_files
    error('The number of files selected != number cells analyzing');
end
%--SELECTING-TIFF-FILES-END---------------------------------------------


%--SPLITTING-AND-SAVING-TIFF-STACKS-------------------------------------
for t=1:num_files
%----------------

%getting folder path for cell being analyzed
t_var = num2str(t);
cell_folder_path  = strcat(dir_path_cell,'\',cell_folder_class,'_',t_var);

%splitting and saving all the images
for j=1:(num_images{t}/channel_num)
    
    z = 1; %counter to reiterate every frame (block)
    
    for k=(((j-1)*channel_num)+1):(((j-1)*channel_num)+(channel_num))
        %seeing if image stack is part of a set (if more than 1 tif
        %selected)
        switch tif_multiple
            case 1
            A = imread(FileName{t}, k, 'Info', info{t});
            case 0
            A = imread(FileName, k, 'Info', info);
        end
        
        k_var = num2str(k);
        disp(k);
        
        switch channel_array{z}
            case 'Actin'
                imshow(A);
                %setting 1000x1000 image to save (without borders)
                set(gca,'position',[0 0 1 1],'units','normalized');
                set(gcf,'PaperUnits','inches','PaperPosition',[0 0 10 10]);            
                index_actin = ((k-z)/channel_num)+1;
                %adding zeros to name of string
                if index_actin<10
                    prepend_zeros = '000';
                else
                    if index_actin>=10
                        if index_actin<100
                            prepend_zeros = '00';
                        end
                        if index_actin>=100
                            prepend_zeros = '0';
                        end
                    end
                end
                index_actin = num2str(index_actin);
                cell_folder_path_actin = strcat(cell_folder_path,'\','Actin','\','Actin','\','Actin',prepend_zeros,index_actin,'.tif');
                imwrite(A,cell_folder_path_actin,'tif');
                disp('Actin splitting...');    
            case 'GFP'
                imshow(A);            
                %setting 1000x1000 image to save (without borders)
                set(gca,'position',[0 0 1 1],'units','normalized');
                set(gcf,'PaperUnits','inches','PaperPosition',[0 0 10 10]);
                index_gfp = ((k-z)/channel_num)+1;
                %adding zeros to name of string
                if index_gfp<10
                    prepend_zeros = '000';
                else
                    if index_gfp>=10
                        if index_gfp<100
                            prepend_zeros = '00';
                        end
                        if index_gfp>=100
                            prepend_zeros = '0';
                        end
                    end
                end
                index_gfp = num2str(index_gfp);
                cell_folder_path_GFP = strcat(cell_folder_path,'\','Analysis','\','GFP',prepend_zeros,index_gfp,'.tif');
                imwrite(A,cell_folder_path_GFP,'tif');
                disp('GFP splitting...');
            case 'RFP'
                imshow(A);
                %setting 1000x1000 image to save (without borders)
                set(gca,'position',[0 0 1 1],'units','normalized');
                set(gcf,'PaperUnits','inches','PaperPosition',[0 0 10 10]);
                index_rfp = ((k-z)/channel_num)+1;
                %adding zeros to name of string
                if index_rfp<10
                    prepend_zeros = '000';
                else
                    if index_rfp>=10
                        if index_rfp<100
                            prepend_zeros = '00';
                        end
                        if index_rfp>=100
                            prepend_zeros = '0';
                        end
                    end
                end
                index_rfp = num2str(index_rfp);
                cell_folder_path_RFP = strcat(cell_folder_path,'\','Analysis','\','RFP',prepend_zeros,index_rfp,'.tif');          
                imwrite(A,cell_folder_path_RFP,'tif');
                disp('RFP splitting...');    
            case 'FRETRED'
                imshow(A);
                %setting 1000x1000 image to save (without borders)
                set(gca,'position',[0 0 1 1],'units','normalized');
                set(gcf,'PaperUnits','inches','PaperPosition',[0 0 10 10]);
                index_fretred = ((k-z)/channel_num)+1;
                %adding zeros to name of string
                if index_fretred<10
                    prepend_zeros = '000';
                else
                    if index_fretred>=10
                        if index_fretred<100
                            prepend_zeros = '00';
                        end
                        if index_fretred>=100
                            prepend_zeros = '0';
                        end
                    end
                end
                index_fretred = num2str(index_fretred);
                cell_folder_path_FRETRED = strcat(cell_folder_path,'\','Analysis','\','FRETRED',prepend_zeros,index_fretred,'.tif');
                imwrite(A,cell_folder_path_FRETRED,'tif');
                disp('FRETRED splitting...');
        end
        
    %disp(z);
    z = z+1;
    end
    
    disp('end frame');
    
end

clearvars cell_folder_path;
%----------------
end
%--SPLITTING-AND-SAVING-TIFF-STACKS-END---------------------------------

%--SPLIT-TIFF-PROMPT----------------------------------------------------
%if split_tiff == 'n', prompt for existing directory to work in...needs to 
%recognize number of folders, what each of them is named
case 'n'       
    %prompt directory
    disp('Select image root directory');
    dir_path_cell = uigetdir;
    prompt_cell_folder_class = 'How did you name your folders (case sensitive, exclude suffix numbers)? ';
    cell_folder_class = input(prompt_cell_folder_class,'s');        
    dir_files = dir(dir_path_cell);
    num_files = numel(dir_files)-2; %-2 removes . and .. entries
    disp(num_files);

    %prompt number of channels analyzed
    prompt_num_channel = 'How many channels would you like to analyze? ';
    channel_num = input(prompt_num_channel);

    num_images = {num_files,1,1};

    for t=1:num_files
        t_var = num2str(t);
        actin_speckle_path = strcat(dir_path_cell,'\',cell_folder_class,'_',t_var,'\Actin');
        disp('Actin folder path:');
        disp(actin_speckle_path);
        num_images_path = strcat(actin_speckle_path,'\Actin');
        disp(num_images_path);
        images_dir_files = dir(num_images_path);
        num_images_actin = numel(images_dir_files)-2;
        num_images_actin_str = num2str(num_images_actin);
        num_images{t} = num_images_actin*channel_num;
        num_frames_str = strcat(num_images_actin_str,' frames');
        disp(num_frames_str);
    end    
end
%--SPLIT-TIFF-PROMPT-END------------------------------------------------




%--GENERATE-movieData.mat-----------------------------------------------
%Prompt to create movieData.mat
%loading existing movieData.mat as template to modify for QFSM analysis

%Checks if movieData.mat file exists in mkdir_speckle directory. If yes, 
%then proceed automatically. If not, prompt to get file.
if exist('movieData_QFSM.mat','file') == 2 %exist 2 -> test for file existance
    movieData_path = 'movieData_QFSM.mat';
else
    disp('Please load a movieData.mat file to continue');
    [movieDataName,moviePathName,movieFilterIndex] = uigetfile('*.mat');
    movieData_path = strcat(moviePathName,movieDataName);
end

%prompt to manually change settings, if 'n', proceed with hardwired
%settings
prompt_change_settings = 'Do you wish to manually change imaging settings? [y/n] ';
change_settings = input(prompt_change_settings,'s');

if change_settings == 'y'
    prompt_pixelSize_ = 'Pixel Size? ';
    prompt_timeInterval_ = 'Time Interval? ';
    prompt_numAperture_ = 'Numerical Aperature? ';
    prompt_camBitdepth_ = 'Camera Bit Depth? ';
    prompt_excitationWavelength_ = 'Excitation Wavelength? ';
    prompt_emissionWavelength_ = 'Emission Wavelength? ';
    prompt_exposureTime_ = 'Exposure Time? ';

    ans_pixelSize_ = input(prompt_pixelSize_);
    ans_timeInterval_ = input(prompt_timeInterval_);
    ans_numAperture_ = input(prompt_numAperture_);
    ans_camBitdepth_ = input(prompt_camBitdepth_);
    ans_excitationWavelength_ = input(prompt_excitationWavelength_);
    ans_emissionWavelength_ = input(prompt_emissionWavelength_);
    ans_exposureTime_ = input(prompt_exposureTime_);                
end

%loads template movieData file
load(movieData_path);

for m=1:num_files
    m_var = num2str(m);
    nFrames = num_images{m}/channel_num;
    MD.nFrames_ = nFrames;
    
    actin_speckle_path = {num_files,1,1};
    actin_speckle_path{m} = strcat(dir_path_cell,'\',cell_folder_class,'_',m_var,'\Actin');
    
    disp(actin_speckle_path{m});

    %settings to modify if necessary, MD = structural array from QFSM
    %software
    switch change_settings
        case 'y'
            MD.movieDataPath_ = actin_speckle_path{m};
            MD.outputDirectory_ = actin_speckle_path{m};

            MD.pixelSize_ = ans_pixelSize_;
            MD.timeInterval_ = ans_timeInterval_;
            MD.numAperture_ = ans_numAperture_;
            MD.camBitdepth_ = ans_camBitdepth_;

            MD.channels_.excitationWavelength_ = ans_excitationWavelength_;
            MD.channels_.emissionWavelength_ = ans_emissionWavelength_;
            MD.channels_.exposureTime_ = ans_exposureTime_;
            MD.channels_.channelPath_ = strcat(actin_speckle_path{m},'\\Actin');
        case 'n'
            MD.movieDataPath_ = actin_speckle_path{m};
            MD.outputDirectory_ = actin_speckle_path{m};

            MD.pixelSize_ = 71.8;
            MD.timeInterval_ = 10;
            MD.numAperture_ = 1.4;
            MD.camBitdepth_ = 16;

            MD.channels_.excitationWavelength_ = 640;
            MD.channels_.emissionWavelength_ = 705;
            MD.channels_.exposureTime_ = 1;
            MD.channels_.channelPath_ = strcat(actin_speckle_path{m},'\\Actin');
    end

    %modded results
    disp(movieData_path);
    disp(MD);
    disp(MD.channels_);

    %need to save to each individual directory serially
    save_path = strcat(actin_speckle_path{m},'\','movieData.mat');
    save(save_path,'MD');
    
end
%--GENERATE-movieData.mat-END-------------------------------------------
disp('End script...goodbye');