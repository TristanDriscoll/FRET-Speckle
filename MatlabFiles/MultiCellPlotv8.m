% Code for plotting correlations between speckle and FRET data
close all;
clear all;

numcells=49;
plotALL=0; % set to 1 to plot each cell separate
plot3DHIST=0; % set to 1 to plot 3D histograms

xSpMin=0;
xSpMax=1000;
yFrMin=0.06;
yFrMax=0.14;
yGrMin=0.04;  
yGrMax=0.14;
xGrMin=-20;
xGrMax=20;

Gradmax=20;
binnum=20;
doublebinnum=2*binnum; %60;

matfiledirec = uigetdir;
cd(matfiledirec);
FRETCellAve=zeros(numcells);
SpeedCellAve=zeros(numcells);

FRETmax=0.2;
Speedmax=1000;



for i=1:numcells;
    
        
    ScatDat=load(['ScatterData_' num2str(i,'%02d') '.mat']);
    FRETvSpeedFULL=ScatDat.FRETvSpeedFULL;
    FRETvGmagFULL=ScatDat.FRETvGmagFULL;
    
    FRETCellAve(i)= mean(FRETvSpeedFULL(:,2));
    SpeedCellAve(i)= mean(FRETvSpeedFULL(:,1));
    
    
%     FRETmax=max(FRETvSpeedFULL(:,2));
%     Speedmax=max(FRETvSpeedFULL(:,1));

    bincenter=0;
    
    for i=1:binnum
        
        %calculate bins and their centers
        binmax=(Speedmax/binnum)*i;
        binmin=(Speedmax/binnum)*i-(Speedmax/binnum);
        gbinmax=(2*Gradmax/binnum)*i-Gradmax;
        gbinmin=(2*Gradmax/binnum)*i-(Gradmax/binnum)-Gradmax;
        bincenter(i)=(binmax-(binmax-binmin));
        gbincenter(i)=(gbinmax-(gbinmax-gbinmin));
        
        %Find FRET values for Speed Bins
        binsAboveMin=find(FRETvSpeedFULL(:,1)>binmin);
        valuesAboveMin=FRETvSpeedFULL(binsAboveMin,:);
        binsBelowMax=find(valuesAboveMin(:,1)<binmax);
        valuesBelowMax=valuesAboveMin(binsBelowMax,:);
        FRETbinValues=valuesBelowMax(:,2);
        
        %Find FRET values for Gradient Bins
        gbinsAboveMin=find(FRETvGmagFULL(:,1)>gbinmin);
        gvaluesAboveMin=FRETvGmagFULL(gbinsAboveMin,:);
        gbinsBelowMax=find(gvaluesAboveMin(:,1)<gbinmax);
        gvaluesBelowMax=gvaluesAboveMin(gbinsBelowMax,:);
        gFRETbinValues=gvaluesBelowMax(:,2);
        
        %Calculated Mean, SD, n, and SEM for bin;
        binmean(i)=mean(FRETbinValues);
        binstd(i)=std(FRETbinValues);
        n(i)=length(FRETbinValues);
        binSEM(i)=binstd(i)/sqrt(n(i));
        
        gbinmean(i)=mean(gFRETbinValues);
        gbinstd(i)=std(gFRETbinValues);
        gn(i)=length(gFRETbinValues);
        gbinSEM(i)=gbinstd(i)/sqrt(gn(i));    
        
    end
    
    if plotALL==1;
        
        figure('units','normalized','outerposition',[0 0 1 1]);
        
        subplot(2,4,1);
        histogram(FRETvSpeedFULL(:,2));
        xlabel('FRET Index');
        title('FRET Index');
        ylabel('Pixel Count (#)');
        
        subplot(2,4,2);
        histogram(FRETvSpeedFULL(:,1));
        xlabel('Actin Flow Velocity (nm/min)');
        ylabel('Pixel Count (#)');
        title('Actin Speed');
        
        subplot(2,4,3);
        histogram(FRETvGmagFULL(:,1));
        xlabel('Actin Flow Gradient');
        title('Flow Gradient');
        ylabel('Pixel Count (#)');
        
        subplot(2,4,[5,6]);
        hold on
        axis([xSpMin xSpMax yFrMin yFrMax]);
        bar(bincenter,binmean,'FaceColor', [0 0.7 0.5], 'EdgeColor', [0 0 0],...
            'Linewidth', 1)
        errorbar(bincenter,binmean,binSEM,'.k','Linewidth',2);
        title('FRET Index vs. Actin Flow Velocity');
        ylabel('FRET Index');
        xlabel('Actin Flow Velocity (nm/min)');
        
        subplot(2,4,[7,8]);
        hold on
        axis([xGrMin xGrMax yFrMin yFrMax]);
        bar(gbincenter,gbinmean,'FaceColor', [0.7 0 0.5], 'EdgeColor', [0 0 0],...
            'Linewidth', 1)
        errorbar(gbincenter,gbinmean,gbinSEM,'.k','Linewidth',2);
        title('FRET Index vs. Actin Flow Gradient');
        ylabel('FRET Index');
        xlabel('Actin Flow Gradient');
    end
    
    
end


for i=1:numcells
    
    if i==1;
        ScatDat=load(['ScatterData_' num2str(i,'%02d') '.mat']);
        FRETvSpeedFULL=ScatDat.FRETvSpeedFULL;
        FRETvGmagFULL=ScatDat.FRETvGmagFULL;
        
        
    else
        ScatDat=load(['ScatterData_' num2str(i,'%02d') '.mat']);
        FRETvSpeedFULL=[FRETvSpeedFULL; ScatDat.FRETvSpeedFULL];
        FRETvGmagFULL=[FRETvGmagFULL; ScatDat.FRETvGmagFULL];

    end
    
end





bincenter=0;

 
for i=1:binnum
    
    %calculate bins and their centers
    binmax=(Speedmax/binnum)*i;
    binmin=(Speedmax/binnum)*i-(Speedmax/binnum);
    gbinmax=(2*Gradmax/binnum)*i-Gradmax;
    gbinmin=(2*Gradmax/binnum)*i-(Gradmax/binnum)-Gradmax;
    bincenter(i)=(binmax-(binmax-binmin));
    gbincenter(i)=(gbinmax-(gbinmax-gbinmin));
    
    %Find FRET values for Speed Bins
    binsAboveMin=find(FRETvSpeedFULL(:,1)>binmin);
    valuesAboveMin=FRETvSpeedFULL(binsAboveMin,:);
    binsBelowMax=find(valuesAboveMin(:,1)<binmax);
    valuesBelowMax=valuesAboveMin(binsBelowMax,:);
    FRETbinValues=valuesBelowMax(:,2);
    
    %Find FRET values for Gradient Bins
    gbinsAboveMin=find(FRETvGmagFULL(:,1)>gbinmin);
    gvaluesAboveMin=FRETvGmagFULL(gbinsAboveMin,:);
    gbinsBelowMax=find(gvaluesAboveMin(:,1)<gbinmax);
    gvaluesBelowMax=gvaluesAboveMin(gbinsBelowMax,:);
    gFRETbinValues=gvaluesBelowMax(:,2);
    
    %Calculated Mean, SD, n, and SEM for bin;
    binmean(i)=mean(FRETbinValues);
    binstd(i)=std(FRETbinValues);
    n(i)=length(FRETbinValues);
    binSEM(i)=binstd(i)/sqrt(n(i));
    
    gbinmean(i)=mean(gFRETbinValues);
    gbinstd(i)=std(gFRETbinValues);
    gn(i)=length(gFRETbinValues);
    gbinSEM(i)=gbinstd(i)/sqrt(gn(i));
    
end

if plot3DHIST==1;
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(1,2,1)
    hist3(FRETvSpeedFULL,[200,200],'FaceAlpha',.65)
    xlabel('Actin Flow Velocity (nm/min)');
    ylabel('FRET Index');
    zlabel('Counts');
    set(gcf,'renderer','opengl');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
    subplot(1,2,2);
    hist3(FRETvGmagFULL,[200,200],'FaceAlpha',.65,'FaceColor','interp','CDataMode','auto');
    xlabel('Max Flow Gradient');
    ylabel('FRET Index');
    zlabel('Counts')
end




figure('units','normalized','outerposition',[0 0 1 1]);

subplot(2,4,1);
histogram(FRETvSpeedFULL(:,2));
xlabel('FRET Index');
title('FRET Index');
ylabel('Pixel Count (#)');

subplot(2,4,2);
histogram(FRETvSpeedFULL(:,1));
%axis([0,1200,0,20000])
xlabel('Actin Flow Velocity (nm/min)');
ylabel('Pixel Count (#)');
title('Actin Speed');


subplot(2,4,3);
histogram(FRETvGmagFULL(:,1));
axis([xGrMin,xGrMax,0,20000])
xlabel('Actin Flow Gradient');
title('Flow Gradient');
ylabel('Pixel Count (#)');


subplot(2,4,[5,6]);
hold on
axis([xSpMin xSpMax yFrMin yFrMax]);
bar(bincenter,binmean,'FaceColor', [0 0.7 0.5], 'EdgeColor', [0 0 0],...
    'Linewidth', 1)
errorbar(bincenter,binmean,binSEM,'.k','Linewidth',2);
title('FRET Index vs. Actin Flow Velocity');
ylabel('FRET Index');
xlabel('Actin Flow Velocity (nm/min)');


subplot(2,4,[7,8]);
hold on
axis([xGrMin xGrMax yGrMin yGrMax]);
bar(gbincenter,gbinmean,'FaceColor', [0.7 0 0.5], 'EdgeColor', [0 0 0],...
    'Linewidth', 1)
errorbar(gbincenter,gbinmean,gbinSEM,'.k','Linewidth',2);
title('FRET Index vs. Actin Flow Gradient');
ylabel('FRET Index');
xlabel('Actin Flow Gradient');


AveFRET=mean(FRETvSpeedFULL(:,2));
AveFLOW=mean(FRETvSpeedFULL(:,1));
AveGRAD=mean(FRETvGmagFULL(:,1));



columnname={'Parameter', 'Value', 'Units'};
columnformat={'char', 'numeric', 'char'};


datSTUFF={ 'Mean FRET', AveFRET, '  ';...
    'Mean Flow', AveFLOW', 'nm/min';...
    'Mean Gradient', AveGRAD,'min^-1'};

t=uitable('Units','normalized','Position',[0.75 0.7 0.18 0.12], 'Data', datSTUFF);
set(t,'ColumnName',columnname, 'ColumnFormat', columnformat, 'RowName', []);





