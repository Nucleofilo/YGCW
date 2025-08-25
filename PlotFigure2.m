%% Figure 2 plot from CF NetCDF
%  First you should download the F2 NetCDF file from Zenodo: 
% decompress it and drop it in the forlder repoPath.../Figure2
% 
% function used to plot Figure 2 as in the manuscript. Slight graphic
% differences will araise from the homogeneization of the coordinate system (time, lons and depths) 
% Since the original figure is done with my messy personal codes where each datasource has its own coordinates
% 
% G. Durante, 2025

clear; close all;

%% ------------------------------------------------------------------------
%  User paths / filenames
% -------------------------------------------------------------------------
repoPath = 'D:\Papers\Paper_III\Results\Figures\Repo\';
dataPath = 'Figure2\F2_Data\';
ncFile   = 'YGCW_Figure2_data.nc';
Fname    = [repoPath, dataPath, ncFile];

%% ------------------------------------------------------------------------
%  Read coordinates & time
%  - CF time is "seconds since 1970-01-01 00:00:00"
%  - CF depth is positive down; we plot negative downward
% -------------------------------------------------------------------------
time_y   = ncread(Fname,'time')/86400 + datenum('1970-01-01');
depth    = -abs(ncread(Fname,'depth'));             % plot as negative-down
lon_yuc4 = ncread(Fname,'lon_yuc4');
lat_yuc4 = ncread(Fname,'lat_yuc4');                %
sec_lon  = ncread(Fname,'section_longitude');
sec_lat  = ncread(Fname,'section_latitude');        % not used, kept for completeness
SAi      = ncread(Fname,'sal_index');

%% ------------------------------------------------------------------------
%  Read YUC4 hovmöller variables
%  NetCDF stored [time x depth]; we transpose to [depth x time] for pcolor
% -------------------------------------------------------------------------
v_yuc4    = ncread(Fname,'v_yuc4')';        % [depth x time]
u_yuc4    = ncread(Fname,'u_yuc4')';
ro_yuc4   = ncread(Fname,'ro_yuc4')';       
dTdz_yuc4 = ncread(Fname,'dTdz_yuc4')';

v_yuc4(depth>-70, :) = NaN;
u_yuc4(depth>-70, :) = NaN;
ro_yuc4(depth<-460, :) = NaN;

%% ------------------------------------------------------------------------
%  Read section variables (stored [time x depth x section] in the file)
%  We permute to [depth x section x time] to easily time-mean later.
% -------------------------------------------------------------------------
Tgrd = permute(ncread(Fname,'Tgrd') , [2 3 1]);     % [depth x section x time]
Vgrd = permute(ncread(Fname,'Vgrd') , [2 3 1]);     % [depth x section x time]

%% ------------------------------------------------------------------------
%  Colors (simple RGBs)
% -------------------------------------------------------------------------
OrangeRed = [1.0000 0.2695 0.0000];
RoyalBlue = [0.2539 0.4101 0.8789];
Gray      = [0.75    0.75   0.75  ];
Black     = [0       0      0     ];

% thresholds for SUW / YGCW shading & composites (tune as needed)
thrYGCW = 36.80;
thrSUW  = 36.85;   % used for panel A shading
thrGCW_comp = 36.60;   % composite threshold for GCW profiles
thrSUW_comp = 37.00;   % composite threshold for SUW  profiles

%% ------------------------------------------------------------------------
%  Figure canvas
% -------------------------------------------------------------------------
figure('pos',[10 10 1220 942],'color','w');

% ====================== (A) Salinity index time series ===================
axSAi = axes('pos',[0.06185 0.76923 0.60178 0.12321]); hold on;

% Shaded bands: neutral (gray), SUW-ish (light red), YGCW-ish (light blue)
[rfx,rfy] = muadro([time_y(1) time_y(end)], [36.85 36.8]);  % neutral zone
patch(rfx,rfy,Gray,'EdgeColor','none','FaceAlpha',0.2);

[rfx,rfy] = muadro([time_y(1) time_y(end)], [36.85 37.8]);  % SUW-ish high
patch(rfx,rfy,[1 0 0],'EdgeColor','none','FaceAlpha',0.1);

[rfx,rfy] = muadro([time_y(1) time_y(end)], [36.8 36.3]);   % YGCW-ish low
patch(rfx,rfy,[0 0 1],'EdgeColor','none','FaceAlpha',0.1);

% Raw and lightly interpolated lines (the gray line is just a smooth guide)
plot(time_y, SAi, 'k','LineWidth',1.2);
nut    = time_y(1):0.1:time_y(end);           % 0.1 d resolution
si_int = interp1(time_y, SAi, nut, 'linear');
si_neg = si_int; si_pos = si_int;
si_neg(si_int > thrYGCW) = NaN;               % blue where <= thrYGCW
si_pos(si_int < thrSUW ) = NaN;               % red  where >= thrSUW

plot(nut, si_int, 'Color',Gray,     'LineWidth',1.2);
plot(nut, si_neg, 'Color',RoyalBlue,'LineWidth',1.2);
plot(nut, si_pos, 'Color',OrangeRed,'LineWidth',1.2);

ylim([36.35 37.25]); 
datetick('x','mmm/yy'); grid on; box on;
set(gca,'XTickLabels',{},'TickLength',[0.001 0.001]);
ylabel('(g kg$^{-1}$)','Interpreter','latex');

text(mean(xlim), 36.426, '\textbf{Salinity index}', ...
    'HorizontalAlignment','center','Color',Black,'Interpreter','latex');

text(time_y(1)+50, 37.05, '\textbf{SUW}',  'Color',Gray, 'Interpreter','latex');
text(time_y(1)+50, 36.50, '\textbf{YGCW}', 'Color',Gray, 'Interpreter','latex');
xlim([time_y(1) time_y(end)]);
%% ================= (B) Meridional velocity hovmöller (YUC4) ==============
axVi = axes('pos',[0.06185 0.63355 0.60178 0.12321]); box on; hold on;
pcolor(time_y, depth, v_yuc4); shading interp;
ylim([-472.5 -72.5]);
datetick('x','mmm/yy'); grid on;
set(gca,'XTickLabels',{},'TickLength',[0.001 0.001]);
ylabel('Depth (m)','Interpreter','latex');

% Colormap & colorbar
set(axVi,'CLim',[-0.3 2.0]);
if exist('cmocean','file')==2, colormap(axVi, cmocean('balance','pivot',0));
else,                          colormap(axVi, parula); end
cb = colorbar('horiz'); cb.Position = [0.56961 0.63957 0.08746 0.01675];
set(cb,'AxisLocation','in','Ticks',[-0.2 1.8]);
xlabel(cb,'m s$^{-1}$','Interpreter','latex');

text(mean(xlim), -430, '\textbf{Meridional velocity}', ...
    'HorizontalAlignment','center','Color',Black,'Interpreter','latex');
xlim([time_y(1) time_y(end)]);
%% ========== (C) Relative vorticity (or Rossby number) hovmöller =========
axZi = axes('pos',[0.06185 0.49705 0.60178 0.12321]); box on; hold on;
pcolor(time_y, depth, ro_yuc4); shading interp;
xlim([time_y(1) time_y(end)]); ylim([-472.5 -72.5]);
datetick('x','mmm/yy'); grid on;
set(gca,'TickLength',[0.001 0.001]);
ylabel('Depth (m)','Interpreter','latex');

% Colormap & colorbar
set(axZi,'CLim',[-1.5 1.5]);
if exist('cmocean','file')==2, colormap(axZi, cmocean('delta','pivot',0));
else,                          colormap(axZi, parula); end
cb = colorbar('horiz'); cb.Position = [0.56961 0.50259 0.08746 0.01675];
set(cb,'AxisLocation','in','Ticks',[-1 1]);
xlabel(cb,'R$_o$','Interpreter','latex');   % label assumes ro_yuc4 is already Ro
xlim([time_y(1) time_y(end)]);
%% =================== (D–G) YUC4 vertical mean profiles ===================
% Event indices for composites
inGCWp = find(SAi <  thrGCW_comp);
inSUWp = find(SAi >  thrSUW_comp);

% (D) v profile
axVp = axes('pos',[0.67638 0.71496 0.07799 0.17756]); box on; hold on;
plot(nanmean(v_yuc4,2),            depth,'LineWidth',1.5,'Color',Gray);
plot(nanmean(v_yuc4(:,inGCWp),2),  depth,'LineWidth',1.5,'Color',RoyalBlue);
plot(nanmean(v_yuc4(:,inSUWp),2),  depth,'LineWidth',1.5,'Color',OrangeRed);
grid on; ylim([-472.5 -50]); set(gca,'YTickLabels',{},'TickLength',[0.001 0.001]);
text(0.62, -441.1,'(m s$^{-1}$)','Color',Black,'Interpreter','latex');

% (E) u profile
axUp = axes('pos',[0.76585 0.71496 0.07799 0.17756]); box on; hold on;
plot(nanmean(u_yuc4,2),            depth,'LineWidth',1.5,'Color',Gray);
plot(nanmean(u_yuc4(:,inGCWp),2),  depth,'LineWidth',1.5,'Color',RoyalBlue);
plot(nanmean(u_yuc4(:,inSUWp),2),  depth,'LineWidth',1.5,'Color',OrangeRed);
grid on; ylim([-472.5 -50]); set(gca,'TickLength',[0.001 0.001]);
ylabel('Depth (m)'); set(gca,'YAxisLocation','right');
text(0.134, -441.1,'(m s$^{-1}$)','Color',Black,'Interpreter','latex');

% (F) Ro profile
axZp = axes('pos',[0.67638 0.49705 0.07799 0.18653]); box on; hold on;
plot(nanmean(ro_yuc4,2),           depth,'LineWidth',1.5,'Color',Gray);
plot(nanmean(ro_yuc4(:,inGCWp),2), depth,'LineWidth',1.5,'Color',RoyalBlue);
plot(nanmean(ro_yuc4(:,inSUWp),2), depth,'LineWidth',1.5,'Color',OrangeRed);
grid on; ylim([-472.5 -50]); set(gca,'YTickLabels',{},'TickLength',[0.001 0.001]);
text(0.715, -444.1,'R$_o$','Color',Black,'Interpreter','latex'); xlim([-0.4 1.3]);

% (G) dT/dz profile
axTg = axes('pos',[0.76585 0.49705 0.07799 0.18653]); box on; hold on;
plot(nanmean(dTdz_yuc4,2),            depth,'LineWidth',1.5,'Color',Gray);
plot(nanmean(dTdz_yuc4(:,inGCWp),2),  depth,'LineWidth',1.5,'Color',RoyalBlue);
plot(nanmean(dTdz_yuc4(:,inSUWp),2),  depth,'LineWidth',1.5,'Color',OrangeRed);
grid on; ylim([-472.5 -50]); set(gca,'TickLength',[0.001 0.001]);
ylabel('Depth (m)'); set(gca,'YAxisLocation','right');
text(-0.071, -448.17,'$^\circ$C m$^{-1}$','Color',Black,'Interpreter','latex');
text(-0.074, -373.20,'$\frac{\partial T}{\partial z}$','Color',Black,'Interpreter','latex','FontSize',16);

%% ================== (H–K) Section composites (GCW vs SUW) =================
% External support files for bathymetry polygon
load D:\Papers\Paper_III\Results\Figures\Repo\Functions\polyGCW_seccion.mat   % provides polygon helpers?
load D:\Papers\Paper_III\Results\Figures\Repo\Functions\YucSecTopo            % provides xto, zto (bathymetry)

% (H) velocity section — GCW composite
axYg = axes('pos',[0.06195 0.32704 0.18700 0.13922]); box on; hold on;
Uy = nanmean(Vgrd(:,:,inGCWp),3);                           % [depth x section]
pcolor(sec_lon, depth, Uy); shading interp;
contour(sec_lon, depth, Uy, [ 0.6  0.6],'EdgeColor',[1 0 0],'LineWidth',4);
contour(sec_lon, depth, Uy, [ 0.0  0.0],'EdgeColor', Black,'LineWidth',3);
contour(sec_lon, depth, Uy, [-0.1 -0.1],'EdgeColor',[0 0 1],'LineWidth',3);
[cc,hh] = contour(sec_lon, depth, Uy, -0.1:0.2:1.2,'EdgeColor',Black); clabel(cc,hh,'Color',Black);
if exist('cmocean','file')==2, colormap(axYg, cmocean('balance','pivot',0)); else, colormap(axYg, parula); end
set(axYg,'CLim',[-0.25 1.6]); set(axYg,'Layer','top'); grid on;
% bathymetry polygon overlay
Pol = closepoli(xto, zto, 'add', 100);
patch(Pol(:,1), Pol(:,2), 0.65*[1 1 1], 'EdgeColor','none','LineWidth',2);
axis([-86.5892 -85.9795 -500 50]);
ylabel('Depth (m)');
cb = colorbar('horiz'); cb.Position = [0.07808 0.28221 0.34985 0.01889];
xlabel(cb,'Meridional velocity (m s$^{-1}$)','Interpreter','latex');
putnorth_ax_latex(axYg, 11, 1, 'W');

% (I) velocity section — SUW composite
axYw = axes('pos',[0.26066 0.32704 0.18700 0.13922]); box on; hold on;
Uy = nanmean(Vgrd(:,:,inSUWp),3);
pcolor(sec_lon, depth, Uy); shading interp;
contour(sec_lon, depth, Uy, [ 0.6  0.6],'EdgeColor',[1 0 0],'LineWidth',4);
contour(sec_lon, depth, Uy, [ 0.0  0.0],'EdgeColor', Black,'LineWidth',3);
contour(sec_lon, depth, Uy, [-0.1 -0.1],'EdgeColor',[0 0 1],'LineWidth',3);
[cc,hh] = contour(sec_lon, depth, Uy, -0.1:0.2:1.2,'EdgeColor',Black); clabel(cc,hh,'Color',Black);
if exist('cmocean','file')==2, colormap(axYw, cmocean('balance','pivot',0)); else, colormap(axYw, parula); end
set(axYw,'CLim',[-0.25 1.6]); set(axYw,'Layer','top'); grid on;
Pol = closepoli(xto, zto, 'add', 100);
patch(Pol(:,1), Pol(:,2), 0.65*[1 1 1], 'EdgeColor','none','LineWidth',2);
axis([-86.5892 -85.9795 -500 50]);

% (J) ∂T/∂z section — GCW composite
axTsg = axes('pos',[0.45900 0.32704 0.18700 0.13922]); box on; hold on;
Tgcw = nanmean(Tgrd(:,:,inGCWp),3);
dx = 1; dz = 8;                                      % grid spacing along x / z
[~, dTdz] = gradient(Tgcw, dx, dz);
pcolor(sec_lon, depth, dTdz); shading interp;
[ch,hh] = contour(sec_lon, depth, Tgcw, [12:2:26 28], '--','EdgeColor',Black); clabel(ch,hh);
set(axTsg,'CLim',[-0.32 0]); if exist('cmocean','file')==2, colormap(axTsg, cmocean('balance','pivot',0)); else, colormap(axTsg, parula); end
set(axTsg,'Layer','top'); grid on;
Pol = closepoli(xto, zto, 'add', 100);
patch(Pol(:,1), Pol(:,2), 0.65*[1 1 1], 'EdgeColor','none','LineWidth',2);
xlim([-86.5892 -85.9795]); ylim([-500 50]);
set(gca,'YTickLabels',{},'TickLength',[0.001 0.001]);
putnorth_ax_latex(gca, 11, 1, 'W');
cb2 = colorbar('horiz'); cb2.Position = [0.47513 0.28221 0.34985 0.01889];
xlabel(cb2,'${\partial T}/{\partial z}$ ($^\circ$C m$^{-1}$)','Interpreter','latex','FontSize',15);

% (K) ∂T/∂z section — SUW composite
axTsw = axes('pos',[0.65743 0.32704 0.18700 0.13922]); box on; hold on;
Tsuw = nanmean(Tgrd(:,:,inSUWp),3);
dx = 1; dz = 8;
[~, dTdz] = gradient(smoothdata(Tsuw,'gaussian',3), dx, dz);
pcolor(sec_lon, depth, dTdz); shading interp;
[ch,hh] = contour(sec_lon, depth, Tsuw, [12:2:26 28], '--','EdgeColor',Black); clabel(ch,hh);
set(axTsw,'CLim',[-0.32 0]); if exist('cmocean','file')==2, colormap(axTsw, cmocean('balance','pivot',0)); else, colormap(axTsw, parula); end
set(axTsw,'Layer','top'); grid on;
Pol = closepoli(xto, zto, 'add', 100);
patch(Pol(:,1), Pol(:,2), 0.65*[1 1 1], 'EdgeColor','none','LineWidth',2);
xlim([-86.5892 -85.9795]); ylim([-500 50]);
set(gca,'TickLength',[0.001 0.001],'YAxisLocation','right');
ylabel('Depth (m)'); putnorth_ax_latex(gca, 11, 1, 'W');

%% ------------------------------------------------------------------------
%  Final typography tweaks and panel labels
% -------------------------------------------------------------------------
set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter','latex');
set(findall(gcf,'-property','FontSize'),'FontSize',12);

% Letter labels
text(axTsw,-86.585,-452.9,'\textbf{(K)}','FontSize',13.5);
text(axTsw,-86.585,-331.5,'\textbf{SUW}' ,'FontSize',12);
text(axTsg,-86.585,-452.9,'\textbf{(J)}','FontSize',13.5);
text(axTsg,-86.585,-331.5,'\textbf{TGCW}','FontSize',12);
text(axYw ,-86.585,-452.9,'\textbf{(I)}','FontSize',13.5);
text(axYw ,-86.585,-331.5,'\textbf{SUW}' ,'FontSize',12);
text(axYg ,-86.585,-452.9,'\textbf{(H)}','FontSize',13.5);
text(axYg ,-86.585,-331.5,'\textbf{TGCW}','FontSize',12);

text(axTg,-0.0339,-78.09,'\textbf{(G)}','FontSize',12);
text(axZp,-0.4271,-78.09,'\textbf{(F)}','FontSize',12);
text(axUp,-0.0315,-78.09,'\textbf{(E)}','FontSize',12);
text(axVp,-0.1042,-78.09,'\textbf{(D)}','FontSize',12);

text(axZi, mean(time_y)+400, -114.10,'\textbf{(C)}','FontSize',13.5);
text(axVi, mean(time_y)+400, -114.10,'\textbf{(B)}','FontSize',13.5);
text(axSAi, mean(time_y)+300, 37.158,'\textbf{(A)}','FontSize',13.5);


set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter','latex');