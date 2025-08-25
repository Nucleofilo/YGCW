% Vertical interpolation (common Zn), 48-h low-pass (Gaussian), daily sampling
% for YUC4 and YUC5 during CNK-48. Plain arrays, no cells.
clear; clc
% ----- user paths -----
data_dir = 'D:\Papers\Paper_III\Results\Figures\Repo\Figure2\F2_Data\RawVel\';              % where CNK*_YUC*.mat live
out_dir  = 'D:\Papers\Paper_III\Results\Figures\Repo\Figure2\F2_Data\';            % output folder
if ~exist(out_dir,'dir'), mkdir(out_dir); end

% ----- configuration -----
CNK     = 48;                                  % deployment number
anchors = {'YUC4','YUC5'};                     % moorings
Zn      = (0:-8:-600)';                      % common depth grid (m; negative down)
gap_max = 250;                                  % mask targets farther than this (m)
method  = 'makima';                             % vertical interpolation ('pchip' also fine)
win_h   = 48;                                   % Gaussian low-pass window (hours)
min_pts = 180;                                  % minimal # of good samples per depth series

% ----- process YUC4 -----
load(fullfile(data_dir, sprintf('CNK%d_%s.mat', CNK, anchors{1})), 'anchor')
[U4, V4, W4, t4] = interp_mooring_profiles(anchor, Zn, gap_max, method);
lon4 = anchor(1).lola(1); lat4 = anchor(1).lola(2);

% ----- process YUC5 -----
load(fullfile(data_dir, sprintf('CNK%d_%s.mat', CNK, anchors{2})), 'anchor')
[U5, V5, W5, t5] = interp_mooring_profiles(anchor, Zn, gap_max, method);
lon5 = anchor(1).lola(1); lat5 = anchor(1).lola(2);

% ----- build common daily time axis from the overlap -----
tmin = max(min(t4), min(t5));
tmax = min(max(t4), max(t5));
tid  = ceil(tmin):1:floor(tmax);                 % daily datenums

% ----- helper to make 48-h Gaussian length in *samples* -----
if numel(t4) > 1, dt4_h = median(diff(sort(t4))) * 24; else, dt4_h = 1; end
if numel(t5) > 1, dt5_h = median(diff(sort(t5))) * 24; else, dt5_h = 1; end
w4 = max(3, round(win_h / max(dt4_h, eps)));
w5 = max(3, round(win_h / max(dt5_h, eps)));

% ----- low-pass and daily resample (depth by depth) -----
Us = nan(numel(Zn), numel(tid), 2);   % (:,:,1)=YUC4, (:,:,2)=YUC5
Vs = nan(numel(Zn), numel(tid), 2);

for iz = 1:numel(Zn)
    % YUC4
    vraw = V4(iz, :); uraw = U4(iz, :);
    goodv = isfinite(vraw); goodu = isfinite(uraw);

    if nnz(goodv) >= min_pts
        vfil = smoothdata(vraw, 'gaussian', w4); vfil(~goodv) = NaN;
        Vs(iz,:,1) = interp1(t4, vfil, tid, 'linear');
    end
    if nnz(goodu) >= min_pts
        ufil = smoothdata(uraw, 'gaussian', w4); ufil(~goodu) = NaN;
        Us(iz,:,1) = interp1(t4, ufil, tid, 'linear');
    end

    % YUC5
    vraw = V5(iz, :); uraw = U5(iz, :);
    goodv = isfinite(vraw); goodu = isfinite(uraw);

    if nnz(goodv) >= min_pts
        vfil = smoothdata(vraw, 'gaussian', w5); vfil(~goodv) = NaN;
        Vs(iz,:,2) = interp1(t5, vfil, tid, 'linear');
    end
    if nnz(goodu) >= min_pts
        ufil = smoothdata(uraw, 'gaussian', w5); ufil(~goodu) = NaN;
        Us(iz,:,2) = interp1(t5, ufil, tid, 'linear');
    end
end

% ----- Interpolate time to SAi time for consistency -----
load D:\Papers\Paper_III\Results\Figures\Repo\Figure2\F2_Data\MooringSalinityIndex.mat tday
Udum = []; Vdum = [];
for jj = 1 : size(Us, 1) 
    for ii = 1 : 2
        Udum(jj, :, ii) = interp1( tid ,squeeze(Us(jj, :, ii)), tday);
        Vdum(jj, :, ii) = interp1( tid ,squeeze(Vs(jj, :, ii)), tday);
    end
end
Us = Udum;
Vs = Vdum;

% ----- quick-look: speed for each mooring -----
figure('Position',[100 100 1370 420],'Color','w');

subplot(2,1,1)
spd4 = sqrt(Us(:,:,1).^2 + Vs(:,:,1).^2);
pcolor(tday, Zn, spd4); shading interp; colorbar
caxis([0 1.6]); title('YUC4 speed');
ylim([min(-550,min(Zn)) 10]); xlim([tid(1) tid(end)]);
datetick('x','mmm-yyyy','keeplimits'); grid on; box on; set(gca,'Layer','top')

subplot(2,1,2)
spd5 = sqrt(Us(:,:,2).^2 + Vs(:,:,2).^2);
pcolor(tday, Zn, spd5); shading interp; colorbar
caxis([0 1.6]); title('YUC5 speed');
ylim([min(-550,min(Zn)) 10]); xlim([tid(1) tid(end)]);
datetick('x','mmm-yyyy','keeplimits'); grid on; box on; set(gca,'Layer','top')

% ----- save compact file for vorticity step -----

mlon = [lon4; lon5];  mlat = [lat4; lat5];
outfile = fullfile(out_dir, 'MooringVel_YUC4_YUC5_daily.mat');
save(outfile, 'Us','Vs','Zn','mlon','mlat','CNK','anchors','gap_max','method','tday','-v7.3');
fprintf('Saved: %s\n', outfile);

%%




