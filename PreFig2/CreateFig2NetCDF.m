clear all;close all;clc;

% path to the preprocessed data used to create Figure 2
DataPath = 'D:\Papers\Paper_III\Results\Figures\Repo\Figure2\F2_Data\';

load([DataPath, 'MooringSalinityIndex.mat']); % Salinity index
% Temperature and velocity sections
load([DataPath, 'MooringProccTemp.mat'], 'Tgrd', 'xgi', 'zgi');
load([DataPath, 'MooringProccVel.mat']);         
% hovmollers and Profiles
load([DataPath, 'Ro_YUC4_daily.mat'], 'Ro');
load([DataPath, 'MooringVel_YUC4_YUC5_daily.mat'], 'Us', 'Vs', 'Zn', 'mlon', 'mlat');

% compute vertical temperature gradient in the Yucatan section and at YUC4
load D:\Papers\Paper_III\Results\Figures\Repo\Figure2\F2_Data\YUC4_Temp Thm Phm Ttime
[dTdt, dTdz] = gradient(Thm, 5, 5);
dTdz_yuc4 = interp1( -abs(Phm) , dTdz, -abs( Zn(:) ));
dTdz_yuc4 = interp1( Ttime, dTdz_yuc4', tday )';

F2 = struct;

% salinity index;
F2.sal_index = SAi;

F2.lon_yuc4 = mlon(1);
F2.lat_yuc4 = mlat(1);

F2.time = tday(:); % same for all teh variables
F2.depth = -abs( Zn(:) ); % same for both, hovmollers and 2D sections maps
% depth is NEGATIVE downward

% longitude and latitude of the vertical sections
ygi = getCanekSCoor('yuc', xgi(1, :)');
F2.longitude = xgi(1, :)';
F2.latitude = ygi(:);

% Hovmollers
F2.v_yuc4 = Vs(:, :, 1);
F2.u_yuc4 = Us(:, :, 1);
F2.ro_yuc4 = Ro;
F2.dTdz_yuc4 = dTdz_yuc4;

F2.Vgrd = Vgrd;
F2.Tgrd = Tgrd;

outfile = fullfile(DataPath,'YGCW_Figure2_data.nc');
write_grl_fig2_cf(F2, outfile);



%%

%%




