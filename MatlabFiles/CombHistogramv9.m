% Code for plotting histogram of FRET and Speckle Data

close all;
clear all;

%enter n per group
N1=14;
N2=12;
N3=13;
N4=8;
N5=9;

%enter number of groups
ngroups=2;

%enter group names
G1='TS';
G2='ABS2';
G3='ABS3';
G4='R6';
G5='CTS';


%=================Input Parameters =========================================
%Directory Base
img_direc_base = uigetdir;
cd(img_direc_base);
warning('off','images:initSize:adjustingMag');
H1COMBFRETFULL=0;
H2COMBFRETFULL=0;
H1COMBSpeedFULL=0;
H2COMBSpeedFULL=0;
H3COMBFRETFULL=0;
H3COMBSpeedFULL=0;
H4COMBFRETFULL=0;
H4COMBSpeedFULL=0;

H5COMBFRETFULL=0;
H5COMBSpeedFULL=0;  


for i=1:N1;
    
    H1name = ['ScatterData_' sprintf('%02d',i) '.mat'];
    H1SCAT = load(H1name);
    H1COMBFRET=[H1COMBFRETFULL; H1SCAT.FRETvSpeedFULL(:,2)];   
    H1COMBSpeed=[H1COMBSpeedFULL; H1SCAT.FRETvSpeedFULL(:,1)]; 
    MeanFRET1(i)=mean(H1SCAT.FRETvSpeedFULL(:,2));
    MeanSpeed1(i)=mean(H1SCAT.FRETvSpeedFULL(:,1));
    
    H1COMBFRETFULL=H1COMBFRET;
    H1COMBSpeedFULL=H1COMBSpeed;
    
    clear H1COMBFRET H1COMBSpeed H1SCAT
    
end

for i=1:N2;
    
    H2name = ['ScatterData2_' sprintf('%02d',i) '.mat'];
    H2SCAT = load(H2name);
    H2COMBFRET=[H2COMBFRETFULL; H2SCAT.FRETvSpeedFULL(:,2)]; 
    H2COMBSpeed=[H2COMBSpeedFULL; H2SCAT.FRETvSpeedFULL(:,1)]; 
    MeanFRET2(i)=mean(H2SCAT.FRETvSpeedFULL(:,2));
    MeanSpeed2(i)=mean(H2SCAT.FRETvSpeedFULL(:,1));
    
    H2COMBFRETFULL=H2COMBFRET;
    H2COMBSpeedFULL=H2COMBSpeed;
    
    clear H2COMBFRET H2COMBSpeed H2SCAT
    
end

if ngroups>2
    for i=1:N3;
    
    H3name = ['ScatterData3_' sprintf('%02d',i) '.mat'];
    H3SCAT = load(H3name);
    H3COMBFRET=[H3COMBFRETFULL; H3SCAT.FRETvSpeedFULL(:,2)]; 
    H3COMBSpeed=[H3COMBSpeedFULL; H3SCAT.FRETvSpeedFULL(:,1)]; 
    MeanFRET3(i)=mean(H3SCAT.FRETvSpeedFULL(:,2));
    MeanSpeed3(i)=mean(H3SCAT.FRETvSpeedFULL(:,1));
    
    H3COMBFRETFULL=H3COMBFRET;
    H3COMBSpeedFULL=H3COMBSpeed;
    
    clear H3COMBFRET H3COMBSpeed H3SCAT
    
end
end


if ngroups>3
    for i=1:N4;
    
    H4name = ['ScatterData4_' sprintf('%02d',i) '.mat'];
    H4SCAT = load(H4name);
    H4COMBFRET=[H4COMBFRETFULL; H4SCAT.FRETvSpeedFULL(:,2)]; 
    H4COMBSpeed=[H4COMBSpeedFULL; H4SCAT.FRETvSpeedFULL(:,1)]; 
    MeanFRET4(i)=mean(H4SCAT.FRETvSpeedFULL(:,2));
    MeanSpeed4(i)=mean(H4SCAT.FRETvSpeedFULL(:,1));
    
    H4COMBFRETFULL=H4COMBFRET;
    H4COMBSpeedFULL=H4COMBSpeed;
    
    clear H4COMBFRET H4COMBSpeed H4SCAT
    
end
end

if ngroups>4
    for i=1:N5;
    
    H5name = ['ScatterData5_' sprintf('%02d',i) '.mat'];
    H5SCAT = load(H5name);
    H5COMBFRET=[H5COMBFRETFULL; H5SCAT.FRETvSpeedFULL(:,2)]; 
    H5COMBSpeed=[H5COMBSpeedFULL; H5SCAT.FRETvSpeedFULL(:,1)]; 
    MeanFRET5(i)=mean(H5SCAT.FRETvSpeedFULL(:,2));
    MeanSpeed5(i)=mean(H5SCAT.FRETvSpeedFULL(:,1));
    
    H5COMBFRETFULL=H5COMBFRET;
    H5COMBSpeedFULL=H5COMBSpeed;
    
    clear H5COMBFRET H5COMBSpeed H5SCAT
    
end
end







v=linspace(0,0.2);       
FRETfig=figure;
hold on;
h1=histogram(H1COMBFRETFULL(:,1),v);
h1.FaceColor = [0 0 0];

h2=histogram(H2COMBFRETFULL(:,1),v);
h2.FaceColor = [0 0 0.5];

h1.Normalization=('probability');
h2.Normalization=('probability');
legend(G1,G2);

if ngroups>2;
    h3=histogram(H3COMBFRETFULL(:,1),v);
    h3.Normalization=('probability');
    legend(G1,G2,G3);
    h3.FaceColor = [0.5 0 0.5];
end

if ngroups>3;
    h4=histogram(H4COMBFRETFULL(:,1),v);
    h4.Normalization=('probability');
    legend(G1,G2,G3,G4);
    h4.FaceColor = [1 1 1];

end

if ngroups>4;
    h5=histogram(H5COMBFRETFULL(:,1),v);
    h5.Normalization=('probability');
    legend(G1,G2,G3,G4,G5);
end




for i=1:ngroups
    group=sprintf('%01d',i);
    FRETvalues=genvarname(strcat('H',group,'COMBFRET'));
    FRETmean(i)=mean(FRETvalues);
    FRETstd(i)=std(FRETvalues);
    FRETn(i)=length(FRETvalues);
    FRETSEM(i)=FRETstd(i)/sqrt(FRETn(i));
    
end


% figure;
% bar(bincenter,binmean,'FaceColor', [0 0.7 0.5], 'EdgeColor', [0 0 0],...
%     'Linewidth', 1);
% errorbar(bincenter,binmean,binSEM,'.k','Linewidth',2);
% title('FRET Index vs. Actin Flow Velocity');
% ylabel('FRET Index');
% xlabel('Actin Flow Velocity (nm/min)')
% 
% 
% 

speedfig=figure;

v=linspace(10,2000);   
hold on;
h1=histogram(H1COMBSpeedFULL,v);

SpeedMean1=mean(H1COMBSpeedFULL);
SpeedMean2=mean(H2COMBSpeedFULL);

h2=histogram(H2COMBSpeedFULL,v);

h1.Normalization=('probability');
h2.Normalization=('probability');

 h1.FaceColor = [0 0 0];
 h2.FaceColor = [0 0 0.5];

h3=histogram(H3COMBSpeedFULL,v);
h3.Normalization=('probability');
 h3.FaceColor = [0.5 0 0.5];
h4=histogram(H4COMBSpeedFULL,v);
h4.Normalization=('probability');
 %h4=histogram(H4COMBSpeed,v);
 %h4.Normalization=('probability');
 h4.FaceColor = [1 1 1];

legend(G1,G2,G3,G4);














