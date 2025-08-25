% Demo: salinity index time series for YUC4 (legacy minmax_mean, 25.30±0.30)
clear; clc
load D:\Papers\Paper_III\Results\Figures\Repo\Figure2\F2_Data\YUC4MicroCAT  % expects: S T P times lon lat

% 1) Compute the daily salinity index
[SAi, tday, di] = salinity_index(S, T, P, lon, lat, times, 25.30, 0.30, 'minmax_mean');

% 2) Prepare figure
figure('Color','w'); hold on

% Shaded bands (Transitional: 36.80–36.85; SUW: >36.85; YGCW: <36.80)
t1 = tday(1);  t2 = tday(end);

[rfx, rfy] = muadro([t1 t2], [36.80 36.85]);    % Transitional (silver band)
p = patch(rfx, rfy, rgb('Silver')); p.EdgeColor = 'none'; p.FaceAlpha = 0.20;

[rfx, rfy] = muadro([t1 t2], [36.85 37.80]);    % SUW above 36.85
p = patch(rfx, rfy, rgb('Red'));    p.EdgeColor = 'none'; p.FaceAlpha = 0.10;

[rfx, rfy] = muadro([t1 t2], [36.30 36.80]);    % YGCW below 36.80
p = patch(rfx, rfy, rgb('Blue'));   p.EdgeColor = 'none'; p.FaceAlpha = 0.10;

% 3) Raw daily SI (black) + densified line with colored segments
plot(tday, SAi, 'k', 'LineWidth', 1.2);

% densify to smooth the color masks (interp in time at 0.1 day)
tt_dense = t1:0.1:t2;
SI_dense = interp1(tday, SAi, tt_dense, 'linear', 'extrap');

% build masks
SI_gcw = SI_dense; SI_gcw(SI_dense > 36.80) = NaN;      % YGCW ≤ 36.80
SI_suw = SI_dense; SI_suw(SI_dense < 36.85) = NaN;      % SUW  ≥ 36.85

% gray backbone + colored overlays
plot(tt_dense, SI_dense, 'Color', rgb('gray'), 'LineWidth', 1.2);
plot(tt_dense, SI_gcw,  'Color', rgb('RoyalBlue'), 'LineWidth', 1.2);
plot(tt_dense, SI_suw,  'Color', rgb('OrangeRed'), 'LineWidth', 1.2);

% 4) Axes, labels, annotations
ylim([36.35 37.25]); xlim([t1 t2]);
datetick('x', 'dd-mmm', 'keeplimits');  % keep simple (datenum axis)

grid on; box on
set(gca, 'TickLength', [0.001 0.001]);

ylabel('Salinity index, SAi (g kg$^{-1}$)', 'Interpreter','latex');
xlabel('Date',                          'Interpreter','latex');
title('Example of the salinity index computation', 'Interpreter','latex');

% panel annotations (centered in time)
tc = mean([t1 t2]);
text(tc, 37.04, '\textbf{SUW}',  'Color', rgb('gray'), ...
     'HorizontalAlignment','center', 'Interpreter','latex');
text(tc, 36.49, '\textbf{YGCW}', 'Color', rgb('gray'), ...
     'HorizontalAlignment','center', 'Interpreter','latex');
text(tc, 36.426, '\textbf{Salinity index}', 'Color', 'k', ...
     'HorizontalAlignment','center', 'Interpreter','latex');
