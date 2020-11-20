% Code for analyzing matched FRET and Speckle data

close all;
clear all;


%=================Input Parameters =========================================
%Directory Base
img_direc_base = uigetdir;
cd(img_direc_base);
warning('off','images:initSize:adjustingMag');


flag=1; %1-for cropping fret image for cytoplasmic pool or ROI, make  0 if thresholded image present

subdirec='\Analysis';
Flowdirec='\Actin\QFSMPackage\flowAnalysis\Actin';
Csubdirec='\Cell_';

MaskType='MaskFAGFP'; %make name format

subdirecno=10;  % # Cells to analyze
timepoints=5;  % # Timepoints per cell

% Pre-calculated bleedthrough co-efficients
donleak=0.051038;
acccross=0.0575;


%Select Smoothing, Colormap and Scale
smoothtype = fspecial('average'); %for 3x3 image smoothening
cmap=colormap('jet');
cmap(1,3)=0.0;
fretscalemin=0.0;
fretscalemax=0.2;
speedMin=0;
speedMax=800;
GmagMin=-7;
GmagMax=7;

Gcmap=colormap('jet');
Gcmap(32,:)=0.0;
Gcmap(33,:)=0.0;

% Create colormap that is blue for negative, green for positive,
% and a chunk inthe middle that is black.
greenColorMap = [zeros(1, 132), linspace(0, 1, 124)];
blueColorMap = [linspace(1, 0, 124), zeros(1, 132)];
GBcmap = [zeros(1, 256); greenColorMap; blueColorMap ]';

gColorMap=[linspace(0,1,256)];
bColorMap=[linspace(1,0,256)];
PosGBcmap=[zeros(1,256); gColorMap; bColorMap]';


% Get the background intensity
cell_img_direc=strcat(img_direc_base,Csubdirec,num2str(1,'%02d'),subdirec);
cd(cell_img_direc);
close all;
time=1;
time=sprintf('%04d',time);
donfname = strcat('GFP',time,'.tif');
don=imread(donfname);
don=imfilter(don,smoothtype);
bkimg=imcrop(don, [0 700]);   %120 forRingTIRF
avgbk=mean(mean(bkimg));


%Gradient Corection Images
gfpgradRAW=imread(strcat(img_direc_base,'/ATTO488.tif'));
FRredgradRAW=imread(strcat(img_direc_base,'/ATTO488FR.tif'));
rfpgradRAW=imread(strcat(img_direc_base,'/ATTO565.tif'));

gfpgradRAW=double(gfpgradRAW)-avgbk;
FRredgradRAW=double(FRredgradRAW)-avgbk;
rfpgradRAW=double(rfpgradRAW)-avgbk;
gfpgradNORM=gfpgradRAW./max(max(gfpgradRAW));
FRredgradNORM=FRredgradRAW./max(max(FRredgradRAW));
rfpgradNORM=rfpgradRAW./max(max(rfpgradRAW));

gfpgrad=gfpgradNORM;
FRredgrad=FRredgradNORM;
rfpgrad=rfpgradNORM;

%avgbk=446;%465;
th=1.0;
intth=avgbk/10;
checkintth2=1;  %for dual camera no threshld image but just intensity threshold ...1 for extra int threshold else 0
intth2=avgbk/2;   %use avgbk/2; for stringent thresholding use avgbk

objective=100;  % choose objective 60/100


%================= Main Code ==============================================


if objective==60
    rowshift=0;
    colshift=0;
end

if objective==100
    rowshift=0;  %0     % CHANGE for DUAAL CAMERA RING TIRF and other microscope
    colshift=1;  %1
    
    rowshift2=0;
    colshift2=1;
end

for sub=1:subdirecno
    cell_img_direc=strcat(img_direc_base,Csubdirec,num2str(sub,'%02d'),subdirec);
    cell_base_direc=strcat(img_direc_base,Csubdirec,num2str(sub,'%02d'));
    
    flow_img_direc = strcat(img_direc_base,Csubdirec,num2str(sub,'%02d'),Flowdirec);
    %=========  Variable Initiations ==========================================
    FRETvSpeedFULL=[0,0];
    FRETvGmagFULL=[0,0];
    
    
    for p=1:timepoints
        cd(cell_img_direc);
        close all;
        clear FRETvSpeed;
        clear FRETvGmag;
        clear XDirIntU;
        clear YDirIntU;
        tic;
        
        
        %Identify Image names
        if p==1;
            i=p;
        elseif p==2;
            i=11;
        else
            i=i+10;
        end
        
        
        time=i;
        time=sprintf('%04d',time);
        donfname = strcat('GFP',time,'.tif');
        accfname = strcat('FRETRED',time,'.tif');
        rfpfname = strcat('RFP',time,'.tif');
        
        %read in images
        don=imread(donfname);
        acc=imread(accfname);
        rfp=imread(rfpfname);
        
        don=double(don);
        acc=double(acc);
        rfp=double(rfp);
        
        don=imfilter(don,smoothtype);
        acc=imfilter(acc,smoothtype);
        rfp=imfilter(rfp,smoothtype);
        
        don=don-avgbk;
        doncell=don;
        [m,n]=size(doncell);
        
        for j=1:m
            for k=1:n
                if  doncell(j,k)<0
                    doncell(j,k)=0;
                end
            end
        end
        
        doncell=doncell./gfpgrad;
        
        acc=acc-avgbk;
        acccell=acc;
        
        for j=1:m
            for k=1:n
                if acccell(j,k)<0
                    acccell(j,k)=0;
                end
            end
        end
        
        acccell=acccell./gfpgrad;
        acccell=circshift(acccell,[rowshift, colshift]);
        
        rfp=rfp-avgbk;
        rfpcell=rfp;
        
        for j=1:m
            for k=1:n
                if rfpcell(j,k)<0
                    rfpcell(j,k)=0;
                end
            end
        end
        
        rfpcell=rfpcell./rfpgrad;
        rfpcell=circshift(rfpcell,[rowshift2, colshift2]);
        
        acccellfret=acccell-donleak*doncell-acccross*rfpcell;
        
        for j=1:m
            for k=1:n
                if acccellfret(j,k)<0.0
                    acccellfret(j,k)=0.0;
                end
            end
        end
        
        fret=acccellfret./(rfpcell);
        
        
        for j=1:m
            for k=1:n
                if  fret(j,k)>=.75 || fret(j,k)==inf || isnan(fret(j,k)) || doncell(j,k)<intth || rfpcell(j,k)<intth
                    fret(j,k)=0;
                end
            end
        end
        
        fretraw=fret;
        fret=imfilter(fret,smoothtype);
        
        if checkintth2==1
            for j=1:m
                for k=1:n
                    if  doncell(j,k)<intth2 || rfpcell(j,k)<intth2
                        fret(j,k)=0.0;
                    end
                end
            end
        end
        
        
        
        %%%%%%%%%%%%%% IF FA MASK IS IN THE FOLDER; ONLY FOR REGION FRET VALUES%%%%%%%%%%%%%
        if flag==1
            figure;
            %[test,rect]=imcrop(don, [50 max(max(don))]); %select region
            rect=[0,0,1000,1000];
            fret=imcrop(fret,rect);
        else
            rect=[0,0,1000,1000];
            
            maskfilename=strcat(MaskType,time,'.tif');
            
            mask=imread(maskfilename);
            mask=double(mask);
            
            mask=mask./255;
            mask=abs(mask-1.0);
            
            fret=fret.*mask;
        end
        
        
        
        %==================CROP FLOW MAPS==================================
        cd(flow_img_direc)
        Flowfilename = ['flowMaps_' num2str(i,'%02d') '.mat'];
        Maskfilename= [MaskType num2str(i,'%04d') '.tif'];
        crpsavename = ['crpMap_' num2str(i,'%02d') '.jpg'];
        flowMap = load(Flowfilename);
        ActinSpeed=flowMap.speedMap;
        NonCropActinSpeed=ActinSpeed;
        Md=flowMap.Md;
        
        cd(cell_img_direc)
        Mask=imread(Maskfilename);
        %============== Import Flow Direction and Convert to MAP =========
        allFlow=Md;
        flowXmag=(diff(allFlow(:,[1 3]),1,2));
        flowYmag=(diff(allFlow(:,[2 4]),1,2));
        
        flowDirectionMap=zeros(1000,1000,2);
        
        for MInd=1:length(allFlow);
            flowDirectionMap(allFlow(MInd,1),allFlow(MInd,2),1)=flowXmag(MInd); %X magnitude
            flowDirectionMap(allFlow(MInd,1),allFlow(MInd,2),2)=flowYmag(MInd); %Y magnitude
        end
        
        flowXmap=flowDirectionMap(:,:,1);
        flowYmap=flowDirectionMap(:,:,2);
        
        %============== Interpolate Flow Direction Maps ==================
        [m,n]=size(ActinSpeed);
        
        [flowXlistx,flowXlisty,flowXlist]=find(flowXmap);
        [flowYlistx,flowYlisty,flowYlist]=find(flowYmap);
        
        IntFlowXMap=TriScatteredInterp(flowXlistx,flowXlisty,flowXlist);
        IntFlowYMap=TriScatteredInterp(flowYlistx,flowYlisty,flowYlist);
        
        
        %Create maps, switch x and y and invert y, image vs cart coordinates
        tx=linspace(1,m,m);
        ty=linspace(1,n,n);
        [yq,xq]=meshgrid(tx,ty);
        YDirInt=-IntFlowXMap(xq,yq);
        XDirInt=IntFlowYMap(xq,yq);
        XDirIntU=zeros(m,n);
        YDirIntU=zeros(m,n);
        
        for j=1:m
            for k=1:n
                if ActinSpeed(j,k)==0
                    YDirInt(j,k)=0;
                    XDirInt(j,k)=0;
                else
                    mag=(XDirInt(j,k)^2+YDirInt(j,k)^2)^0.5;
                    XDirIntU(j,k)=XDirInt(j,k)/mag;
                    YDirIntU(j,k)=YDirInt(j,k)/mag;
                end
            end
        end
        
        
        
        %============Calculate Flow Gradient Maps==========================
        gradientfilename = ['gradientMap_' num2str(i,'%02.0f') '.mat'];
        [Gx,Gy]=gradient(flowMap.speedMap);
        %flip y magnitude;
        Gy=-Gy;
        
        save(gradientfilename, 'Gx', 'Gy');
        XVect=[1,0];
        [Gw,Gh]=size(Gx);
        Gdir=zeros(Gw,Gh);
        GcompMag=zeros(Gw,Gh);
        Gmag=(Gx.^2+Gy.^2).^0.5;
        
        NonCropGmag=Gmag;
        
        %load flowMap and cropp[]
        [m,n]=size(ActinSpeed);
        
        
        for j=1:m
            for k=1:n
                if Mask(j,k)==255
                    ActinSpeed(j,k)=0;
                    Gmag(j,k)=0;
                    GcompMag(j,k)=0;
                    
                    
                else
                    
                    GMAT=[Gx(j,k),Gy(j,k)];
                    AVECT=[XDirIntU(j,k);YDirIntU(j,k)];
                    GcompMag(j,k)=GMAT*AVECT;
                    
                    
                end
            end
        end
        
        
        ActinSpeedList=ActinSpeed(:);
        fretScatter=fret(:);
        FRETvSpeed=[ActinSpeedList';fretScatter']';
        ipos=find(FRETvSpeed(:,2)>0);
        FRETvSpeed=FRETvSpeed(ipos,:);
        
        Gmaglist=GcompMag(:);
        FRETvGmag=[Gmaglist';fretScatter']';
        ipos=find(FRETvGmag(:,2)>0);
        FRETvGmag=FRETvGmag(ipos,:);
        
        
        %==================================================================
        
        %===================  WRITE DATA ==================================
        
        % #1 Total Cell FRET
        fig1=figure;
        imagesc(fret, [fretscalemin fretscalemax]);
        colormap(cmap);
        colorbar;
        axis equal;
        axis off;
        TCfretimg=strcat('totalcellfret',time,'.tif');
        saveas(fig1,TCfretimg);
        
        % #2 Croped Actin Speed
        fig1;
        imshow(ActinSpeed,[speedMin,speedMax]);
        colormap(cmap);
        colorbar;
        axis equal;
        axis off;
        ActinSpeedfile=strcat('ActinSpeed',time,'.tif');
        saveas(fig1,ActinSpeedfile);
        
        % No Crop Actin Speed
        
        fig2=figure;
        imshow(NonCropActinSpeed,[speedMin,speedMax]);
        colormap(cmap);
        colorbar;
        
        hold on;
        quiver(allFlow(:,2),allFlow(:,1),flowYmag, flowXmag);
        title('Actin Speed and Direction')
        NCActinSpeedfile=strcat('FullActinSpeed',time,'.tif');
        
        axis equal;
        axis off;
        saveas(fig2,NCActinSpeedfile);
        hold off;
        
        
        % #3 FRET Image tif
        fig3=figure;
        imagesc(fret, [fretscalemin fretscalemax]);
        colorbar;
        colormap(cmap);
        axis equal;
        axis off;
        fretimg=strcat('fret',time,'.tif');
        saveas(fig3,fretimg);
        
        % #4 FRET PNG file (Data Image)
        fretimg2=strcat('fret2',time,'.png');
        fret2=uint16(1000*fret);
        imwrite(fret2,fretimg2);
        
        % #5 Donor Image tif
        fig3;
        doncell=imcrop(doncell,rect);
        imagesc(doncell, [intth max(max(doncell))]);
        axis equal;
        axis off;
        colormap(cmap);
        colorbar;
        donimg=strcat('donor',time,'.tif');
        saveas(fig3,donimg);
        
        % #6 RFP Image tif
        fig3;
        rfpcell=imcrop(rfpcell,rect);
        imagesc(rfpcell, [intth max(max(rfpcell))]);
        colormap(cmap);
        colorbar;
        axis equal;
        axis off;
        rfpimg=strcat('rfpimg',time,'.tif');
        saveas(fig3,rfpimg);
        
        
        %close all;
        
        %Compile Variables
        FRETvSpeedFULL=[FRETvSpeedFULL;FRETvSpeed];
        FRETvGmagFULL=[FRETvGmagFULL;FRETvGmag];
        
        
        % #7 RAW FILES
        RawDatafile=strcat('RawData',time,'.mat');
        
        fretlin=fret(:);
        ipos=find(fretlin>0);
        fretlin=fretlin(ipos);
        doncelllin=doncell(:);
        doncelllin=doncelllin(ipos);
        rfpcelllin=rfpcell(:);
        rfpcelllin=rfpcelllin(ipos);
        
        % Normalized Linear Datasets
        fretlinNORM=(fretlin-min(fretlin))./(max(fretlin)-min(fretlin));
        doncelllinNORM=(doncelllin-min(doncelllin))./(max(doncelllin)-min(doncelllin));
        rfpcelllinNORM=(rfpcelllin-min(rfpcelllin))./(max(rfpcelllin)-min(rfpcelllin));
        
        %VALUES TO WRITE
        save(RawDatafile, 'fret', 'doncell', 'rfpcell', 'fretlin',...
            'doncelllin', 'rfpcelllin', 'fretlinNORM', 'doncelllinNORM',...
            'rfpcelllinNORM');
        
        FrameTime=toc;
        fprintf(strcat('Processing Time for Frame',time,'..........', num2str(toc), 's'),'s\n');
        fprintf('\n');
        
    end
    
    
    %============= Save Scatter Data ====================================
    
    % Save Compiled Scatter Data
    Scattername = strcat('ScatterData_',num2str(sub,'%02d'),'.mat');
    save(Scattername, 'FRETvSpeedFULL', 'FRETvGmagFULL');
    
    %===================MOVE FILES TO SUBDIRECTORIES=======================
    cd(cell_img_direc);
    
    if isdir(MaskType)==0;
        mkdir(MaskType);
        
    end
    
    movefile(Scattername,img_direc_base);
    
    
    
    for p=1:timepoints
        
        if p==1;
            i=p;
        elseif p==2;
            i=11;
        else
            i=i+10;
        end
        time=sprintf('%04d',i);
        
        
        RawDatafile=strcat('RawData',time,'.mat');
        movefile(RawDatafile,MaskType);
        gradientfilename = ['gradientMap_' num2str(i,'%02.0f') '.mat'];
        movefile(gradientfilename,MaskType);
        fretimg2=strcat('fret2',time,'.png');
        movefile(fretimg2,MaskType);
        
        
        fretimg=strcat('fret',time,'.tif');
        movefile(fretimg,MaskType);
        donimg=strcat('donor',time,'.tif');
        movefile(donimg,MaskType);
        rfpimg=strcat('rfpimg',time,'.tif');
        movefile(rfpimg,MaskType);
        TCfretimg=strcat('totalcellfret',time,'.tif');
        movefile(TCfretimg,MaskType);
        ActinSpeedfile=strcat('ActinSpeed',time,'.tif');
        movefile(ActinSpeedfile,MaskType);
        NCActinSpeedfile=strcat('FullActinSpeed',time,'.tif');
        movefile(NCActinSpeedfile,MaskType);
        
    end
    
    
    binnum=30;
    FRETmax=max(FRETvSpeedFULL(:,2));
    Speedmax=max(FRETvSpeedFULL(:,1));
    Gradmax=10;
    
    bincenter=0;
    
    for i=1:binnum
        
    end
    
    close all;
    clear FRETvSpeedFULL
    clear FRETvGmagFULL
    
end











