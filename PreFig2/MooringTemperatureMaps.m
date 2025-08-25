% Temperature reconstruction along the Yucatan section
% (natural neighbor in x–z, then light Gaussian smoothing)
%
% INPUT (RawMooringsTemp.mat)
%   Iflag      : instrument flag (0=MUR, 1=MicroCAT, 2=ADCP)
%   Tmat       : temperature  [ntime x ninstr]
%   Pmat       : pressure/depth (m, positive down recommended) [ntime x ninstr]
%   Xmat       : longitude     [ntime x ninstr]  (constant in time per instrument)
%   xy         : target longitudes (vector) covering the YGCW area
%   temp_time  : datenum time vector (length ntime)
%
% OUTPUT (in workspace)
%   Tgrd       : gridded temperature (depth x xgrid x time)
%   Ttime      : copy of temp_time
%
% Notes:
% - Depth grid Pi is in meters, positive downward. For plotting we use -Pi.
% - Interpolation: griddata(...,'natural') ~ natural neighbor (good for scattered).
% - Smoothing: small Gaussian (4 grid steps) in depth (dim 1) and x (dim 2).
% - Overlays: YGCW polygon (xxi, yyi) and filled topography from YucSecTopo.

clear; close all; clc

% --- load raw concatenated time series
load('D:\Papers\Paper_III\Results\Figures\Repo\Figure2\F2_Data\RawTemp\RawMooringsTemp.mat', ...
     'Iflag','Tmat','Pmat','Xmat','xy','temp_time');

% ---- choose a regular depth grid (m, positive down)
Pi = (0:8:600)';              % 5-m spacing; adjust if you need deeper
 
% ---- build target (x,z) grid for each time slice
[xgi, zgi] = meshgrid(xy(:), Pi(:));   % size: [numel(Pi) x numel(xy)]

% ---- preallocate gridded cube: depth x xgrid x time
Tgrd  = nan(numel(Pi), numel(xy), numel(temp_time));

% bad extrapolation data
Ibad = zgi > 500 & xgi < -86.2623;
 
% ---- loop over time, interpolate scattered obs to regular (x,z)
for ll = 1 : length(temp_time)

    xx = Xmat(ll, :); yy = Pmat(ll, :); tt = Tmat(ll, :);
    inba = isnan(xx + yy + tt);
    xx(inba) = []; yy(inba) = []; tt(inba) = [];
    
    dum = griddata(xx(:), yy(:), tt(:), xgi, zgi, 'natural');
    % light smoothing in depth (dim 1) and x (dim 2), being aware that the
    % resolution is not that high
    dum = smoothdata(dum, 1, 'gaussian', 4);
    dum = smoothdata(dum, 2, 'gaussian', 4);
    
    

    if ~isempty(dum)
        dum(Ibad) = NaN;
        Tgrd(:, :, ll) = dum;
    end
end

Ttime = temp_time;

% ---- load overlays: YGCW polygon & section topography
addpath(genpath('D:\Papers\Paper_III\Results\Figures\Repo\Functions\'))  % for rgb, closepoli, etc.
load polyGCW_seccion.mat   % provides: xxi, yyi (polygon in x–z)
load YucSecTopo            % provides: xto, yto, zto (section lon/lat/depth)

% ---- make the figure: STD shading + mean contours + sensors + topo
Tstd = nanstd(Tgrd, [], 3);
Tavg = nanmean(Tgrd, 3);

% interpolate to SAi times so at the end all variables in Figure 2 have the
% same associated time vector, even though will have nans at the ends

load D:\Papers\Paper_III\Results\Figures\Repo\Figure2\F2_Data\MooringSalinityIndex.mat tday
Tdum = [];
for jj = 1 : numel(xy) 
    for ii = 1 : numel(Pi) 
        Tdum(ii, jj, :) = interp1( Ttime ,squeeze(Tgrd(ii, jj, :)), tday);
    end
end
Tgrd = Tdum;
%%
figure('Color','w','Position',[50 80 1000 600]); hold on

% STD shading
pcolor(xy, -Pi, Tstd); shading interp
cb = colorbar; ylabel(cb,'Standard deviation ($^\circ$C)','Interpreter','latex')

% Mean temperature contours (choose even 2 °C spacing)
c_levels = 10:2:28;
[CS, CH] = contour(xy, -Pi, Tavg, c_levels, '--k','LineWidth',1.2);
clabel(CS, CH, 'Color','k')

% colormap and range (use your S3 range; tweak if desired)
try
    cmocean('dense');
catch
    colormap(parula); % fallback if cmocean is not installed
end
caxis([0.6 2.5])

% YGCW historical detection polygon (shaded)
pt = patch(xxi, yyi, [1, 0.26953, 0], 'EdgeColor','k', 'LineWidth',0.8);
pt.FaceAlpha = 0.30;

% Fill topography (close polygon with a bottom line)
Pol = closepoli(xto, zto, 'add', 100);
patch(Pol(:,1), Pol(:,2), rgb('silver'), 'EdgeColor','none');

% Instrument markers (use time means for positions)
xins = nanmean(Xmat, 1);
zins = -nanmean(Pmat, 1);     % negative for plot (depth down)

h(1) = plot(xins(Iflag==0), zins(Iflag==0), '*', 'Color','r');                        % MUR SST (at surface)
h(2) = plot(xins(Iflag==1), zins(Iflag==1), 's', 'MarkerEdgeColor','k', ...
            'MarkerFaceColor', [0.125, 0.6953125, 0.6640625], 'MarkerSize',9);                     % MicroCATs
h(3) = plot(xins(Iflag==2), zins(Iflag==2), 'o', 'MarkerEdgeColor','k', ...
            'MarkerFaceColor','r');                                                   % ADCP thermistors

leg = legend(h, {'MUR-SST','CICESE--SIO MicroCATs','Canek ADCPs'}, 'Interpreter','latex');
leg.Location = 'southwest';

% Axes/labels
ylabel('Depth (m)');
set(gca,'YAxisLocation','right');
xlim([-86.8023  -85.9]);
ylim([-950, 50])
grid on; box on; set(gca,'Layer','top')

title('Average and standard deviation from temperature reconstructions Canek-48 (Jul-2018 to Nov-2020)', ...
      'Interpreter','none')

% LaTeX text/labels
set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter','latex');
set(findall(gcf,'-property','FontSize'),'FontSize',12);

save D:\Papers\Paper_III\Results\Figures\Repo\Figure2\F2_Data\MooringProccTemp xgi zgi Tgrd Pi Xmat Pmat Tmat