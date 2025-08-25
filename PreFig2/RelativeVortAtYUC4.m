% Relative vorticity at YUC4 (centered finite differences in x)
% Uses daily, low-pass filtered horizontal velocities (U,V) at YUC4 and YUC5
% on a common depth grid Zn, plus the Yucatan-section topography line.
%
% ζ ≈ ∂v/∂x (we neglect ∂u/∂y). 
% We estimate ∂v/∂x at YUC4 by averaging two one-sided shears:
%   (i) between the wall (no-slip, v=0) and YUC4, and
%  (ii) between YUC4 and YUC5.
% Rossby number Ro = ζ / f.
%
% Inputs (from previous step):
%   Us, Vs  : [depth x day x mooring], moorings: 1=YUC4, 2=YUC5
%   Zn      : depth vector (negative down)
%   tid     : daily datenums
%   mlon, mlat : [2x1] lon/lat for YUC4 (1) and YUC5 (2)
%   YucSecTopo.mat: xto, yto, zto (section longitude, latitude, topography depth)
%
% NOTE: spheric_dist(lat1,lat2,lon1,lon2) is assumed to return distance in METERS.
%       If your function returns km, multiply by 1000.

clear; close all; clc
addpath(genpath('D:\Papers\Paper_III\Results\Figures\Repo\Functions'))
% ---- load daily velocities and section topography
load('D:\Papers\Paper_III\Results\Figures\Repo\Figure2\F2_Data\MooringVel_YUC4_YUC5_daily.mat')
load YucSecTopo % Yucatan section (lon, lat, depth)
load D:\Papers\Paper_III\Results\Figures\Repo\Figure2\F2_Data\MooringSalinityIndex.mat tday

tid = tday;
% ---- Coriolis parameter (use YUC4 latitude)
omega = 2*pi/86400;
f = 2*omega*sind(mlat(1));

% ---- Horizontal distance between YUC4 and YUC5 (constant with depth)
dx2 = spheric_dist( mlat(1),  mlat(2),  mlon(1), mlon(2) );   % meters

% ---- Preallocate outputs
Ro     = nan(numel(Zn), numel(tid));   % Rossby number ζ/f at YUC4
zeta1  = nan(numel(Zn), numel(tid));   % shear between wall and YUC4:  (v_Y4 - 0)/dx1
zeta2  = nan(numel(Zn), numel(tid));   % shear between YUC5 and YUC4:  (v_Y5 - v_Y4)/dx2
dx1vec = nan(numel(Zn), 1);            % wall–YUC4 distance by depth (m)

% ---- Loop over depths
for k = 1:numel(Zn)

    % 1) Distance from the topographic wall to YUC4 at this depth:
    % find intersection of the horizontal line z=Zn(k) with the topo profile
    x_int = polyxpoly( xto, zto, [min(xto) mlon(1)], [Zn(k) Zn(k)] );  % returns lon(s)
    x_int = min(x_int);
    if ~isempty(x_int)
        % interpolate latitude along section near the intersection (±0.2° lon window)
        ix = (xto >= x_int-0.2) & (xto <= x_int+0.2);
        y_int = interp1(xto(ix), yto(ix), x_int);
        dx1 = spheric_dist( mlat(1), y_int, mlon(1), x_int );          % meters
    else
        dx1 = NaN;
    end
    dx1vec(k) = dx1;

    % 2) Shear between wall (no-slip: v=0) and YUC4
    v_wall = 0;                           % no-slip boundary at the wall
    v_Y4   = Vs(k,:,1);                   % meridional velocity at YUC4, this depth
    zeta1(k,:) = (v_Y4 - v_wall) ./ dx1;  % ∂v/∂x toward the wall (midpoint)

    % 3) Shear between YUC4 and YUC5
    v_Y5   = Vs(k,:,2);                   
    zeta2(k,:) = (v_Y5 - v_Y4) ./ dx2;    % ∂v/∂x toward YUC5 (midpoint)

    % 4) Centered estimate at YUC4 and convert to Rossby number
    %    (average of the two one-sided shears), Ro = ζ / f
    Ro(k,:) = 0.5*(zeta1(k,:) + zeta2(k,:)) ./ f;
end

% ---- Quick look: Rossby number section (depth–time)
figure('Position',[100 100 1200 420],'Color','w')
pcolor(tid, Zn, Ro); shading interp; colorbar
% caxis([-1 1])                                  % adjust range as you like
ylabel('Depth (m)')
title('Rossby number ( \zeta / f ) at YUC4')
xlim([tid(1) tid(end)]); ylim([min(-550,min(Zn)) 10])
datetick('x','mmm-yyyy','keeplimits'); grid on; box on; set(gca,'Layer','top')


% ---- Save results for the figure/paper

save('D:\Papers\Paper_III\Results\Figures\Repo\Figure2\F2_Data\Ro_YUC4_daily.mat', ...
     'Ro','zeta1','zeta2','dx1vec','dx2','Zn','mlon','mlat','f','-v7.3');
