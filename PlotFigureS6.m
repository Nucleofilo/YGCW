clr;
addpath(genpath('D:\Papers\Paper_III\Results\Figures\Repo\Functions\'))

arch = 'D:\Papers\Paper_III\Results\Figures\Repo\Figure3\F3_Data\NEMO_YucSection_2010_2022.nc';

SAi = ncread(arch, 'sal_index');

tinemo = ( ncread(arch, 'time')./86400) + datenum('1970-01-01');

inGCWp = find( SAi < 36.6 ); % YGCW events 
inSUWp = find( SAi > 37 ); % SUW events

load YucSecTopo

Xnemo = ncread(arch, 'section_longitude');
Znemo = -abs(ncread(arch, 'depth'));
     
% save SAindexNEMO tinemo SAi
%%

close all
figure('pos', [-1587 -56.7777777777778 1219.55555555556 941.777777777778], 'color', 'w')
%
axSAi = axes('pos', [0.0618513119533529 0.769230769230769 0.783174198250729 0.123206701274189]);
hold on
[rfx, rfy] = muadro([tinemo(1) tinemo(end)],  [36.85, 36.8] );
ptc = patch( rfx, rfy, rgb('Silver') );
ptc.EdgeColor = 'none';
ptc.FaceAlpha = 0.2;

[rfx, rfy] = muadro([tinemo(1) tinemo(end)],  [36.85, 37.8] );
ptc = patch( rfx, rfy, rgb('Red') );
ptc.EdgeColor = 'none';
ptc.FaceAlpha = 0.1;

[rfx, rfy] = muadro([tinemo(1) tinemo(end)],  [36.8, 36.3] );
ptc = patch( rfx, rfy, rgb('Blue') );
ptc.EdgeColor = 'none';
ptc.FaceAlpha = 0.1;

plot(tinemo, smoothdata(SAi, 'gaussian', 3), 'k', 'LineWidth',1.2)

%
serie = smoothdata(SAi, 'gaussian', 2);
sgcw = serie;
nut = tinemo(1):1/10:tinemo(end);
sgcw = interp1(tinemo, sgcw, nut);
indis = (sgcw<=36.8);

sgcw_n = sgcw; sgcw_p= sgcw;

sgcw_n(~indis) = NaN;

indis = (sgcw>=36.85);
sgcw_p(~indis) = NaN;

plot(nut, sgcw, 'color',rgb('gray'),'LineWidth',1.2); hold on
plot(nut, sgcw_n, 'color', rgb('RoyalBlue'),'LineWidth',1.2);
plot(nut, sgcw_p, 'color', rgb('OrangeRed'),'LineWidth',1.2);

%
ylim([36.35, 37.25])
datetick('x', 'mmm/yy')
xlim([tinemo(1), tinemo(end)])

box on
set(gca, 'TickLength', [0.001, 0.001])
grid on;

ylabel("(g kg$^{-1}$) ", 'interpreter', 'Latex')
text(734479, 37.107, '\textbf{SUW}', ...
    'HorizontalAlignment','center', 'color', rgb('gray'), 'Interpreter','latex')
text(734479, 36.4948275862069, '\textbf{YGCW}', ...
    'HorizontalAlignment','center', 'color', rgb('gray'), 'Interpreter','latex')

Ev = [734655
734719
734912
734981
735314
735381
735786
735850
736781
737574
738107
735426
738237
737885];

% vlines(Ev) % This funciton is in the jLab package from Jonathan Lilly, 
 
text(mean([tinemo(1), tinemo(end)]), 36.426, '\textbf{NEMO salinity index}', ...
    'HorizontalAlignment','center', 'color', rgb('Black'), 'Interpreter','latex')

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);
%% Velocity:

tic
v = ncread(arch, 'v');
v = permute(v,  [2, 3, 1] );

Vgcw = nanmean( v(:, :, inGCWp), 3 );
Vsuw = nanmean( v(:, :, inSUWp), 3 );
clear v
toc

%%

figure('pos', [-1587 -56.7777777777778 1219.55555555556 941.777777777778], 'color', 'w')

axYg = axes('pos', [0.0619533527696947 0.8116 0.187 0.13921651609252]); box on;
hold on;
contourf(Xnemo, Znemo, Vgcw, [45], 'EdgeColor', 'none');
hold on;
contour(Xnemo, Znemo, Vgcw, [0.6, 0.6], 'edgecolor', rgb('Red'), 'linewidth', 4);
contour(Xnemo, Znemo, Vgcw, [0.0, 0.0], 'edgecolor', rgb('black'), 'linewidth', 3);
contour(Xnemo, Znemo, Vgcw, -[0.1, 0.1], 'edgecolor', rgb('Blue'), 'linewidth', 3);
[cc, hh] = contour(Xnemo,  Znemo, Vgcw, [-0.1:0.2:1.2], 'EdgeColor', rgb('black'));
clabel(cc, hh, 'Color', rgb('black'))
shading interp

colormap(axYg, cmocean('Balance', 'pivot', 0));
clim([-0.25, 1.6])
cmocean('Balance', 'pivot', 0)
box on;
set(gca, 'Layer', 'top')
Pol = closepoli(xto, zto, 'add', 100);
pt = patch(Pol(:, 1), Pol(:, 2), [1 1 1]*0.65);
pt.EdgeColor = 'none'; pt.LineWidth = 2;
xlim([-86.5892  -85.9795]);
ylim([-500, 50])
ylabel('Depth (m)')
set(gca, 'XTickLabels', {}, 'TickLength', [0.001, 0.001])
cb = colorbar('horiz');
cb.Position = [0.0619533527696947+0.016126 0.8116-0.028787141859358 0.349854227405248 0.0188910435772994];
% putnorth_ax_latex(gca, 11, 1, 'W')
grid on;
xlabel(cb, 'Meridional velocity (m s$^{-1}$)', 'Interpreter','latex')
%
axYw = axes('pos', [0.260659620991268 0.8116 0.187 0.13921651609252]); box on;
hold on;
contourf(Xnemo, Znemo, Vsuw, [45], 'EdgeColor', 'none');
contour(Xnemo, Znemo, Vsuw, [0.6, 0.6], 'edgecolor', rgb('Red'), 'linewidth', 4);
contour(Xnemo, Znemo, Vsuw, [0.0, 0.0], 'edgecolor', rgb('black'), 'linewidth', 3);
contour(Xnemo, Znemo, Vsuw, -[0.1, 0.1], 'edgecolor', rgb('Blue'), 'linewidth', 3);
hold on;
[cc, hh] = contour(Xnemo, Znemo, Vsuw, [-0.1:0.2:1.2], 'EdgeColor', rgb('black'));
clabel(cc, hh, 'Color', rgb('black'))
shading interp
colormap(axYw, cmocean('Balance', 'pivot', 0));
clim([-0.25, 1.6])
cmocean('Balance', 'pivot', 0)
box on;
set(gca, 'Layer', 'top')
Pol = closepoli(xto, zto, 'add', 100);
pt = patch(Pol(:, 1), Pol(:, 2), [1 1 1]*0.65);
pt.EdgeColor = 'none'; pt.LineWidth = 2;
xlim([-86.5892  -85.9795]);
ylim([-500, 50])
set(gca, 'YTickLabels', {}, 'XTickLabels', {}, 'TickLength', [0.001, 0.001])
% putnorth_ax_latex(gca, 11, 1, 'W')
grid on;
% set(gca,  'TickLength', [0.001, 0.001])
set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);


%% Temperature and temperature gradient

tic
T = ncread(arch, 'CT');
T = permute(T,  [2, 3, 1] );

dTdz = ncread(arch, 'dTdz');
dTdz = permute(dTdz,  [2, 3, 1] );

Tgcw = nanmean( T(:, :, inGCWp), 3 );
Tsuw = nanmean( T(:, :, inSUWp), 3 );

dTdz_gcw = nanmean( dTdz(:, :, inGCWp), 3 );
dTdz_suw = nanmean( dTdz(:, :, inSUWp), 3 );

clear T

toc

%%


axTg = axes('pos', [0.459001457725949 0.8116 0.187 0.13921651609252]); box on;
hold on;

pcolor(Xnemo, Znemo, dTdz_gcw);shading interp
hold on
[ch, hh] = contour(Xnemo, Znemo, Tgcw,  [12:2:26, 26:29], '--', 'edgecolor', rgb('black') );
clabel(ch, hh)
clim([-0.32, 0])
colormap(axTg, cmocean( 'Balance', 'pivot', 0));
box on;
set(gca, 'Layer', 'top')
Pol = closepoli(xto, zto, 'add', 100);
pt = patch(Pol(:, 1), Pol(:, 2), [1 1 1]*0.65);
pt.EdgeColor = 'none'; pt.LineWidth = 2;

xlim([-86.5892  -85.9795]);
ylim([-500, 50])
set(gca, 'YTickLabels', {}, 'XTickLabels', {}, 'TickLength', [0.001, 0.001])
grid on;
cb = colorbar('horiz');
cb.Position =  [0.459001457725949+0.016126 0.8116-0.028787141859358 0.349854227405248 0.0188910435772994];
xlabel(cb, '${\partial T}/{\partial z}$ ($^oC$ m$^{-1}$)', 'Interpreter','latex', 'FontSize', 15)

axTs = axes('pos', [0.657434402332373 0.8116 0.187 0.13921651609252]); box on;
hold on;
contourf(Xnemo, Znemo, dTdz_suw, [50], 'EdgeColor', 'none');
hold on
[ch, hh] = contour(Xnemo, Znemo, Tsuw, [12:2:26, 26:29], '--', 'edgecolor', rgb('black') );
clabel(ch, hh)
clim([-0.32, 0])
colormap(axTs, cmocean( 'Balance', 'pivot', 0));
box on;
set(gca, 'Layer', 'top', 'XTickLabels', {})
Pol = closepoli(xto, zto, 'add', 100);
pt = patch(Pol(:, 1), Pol(:, 2),  [1 1 1]*0.65);
pt.EdgeColor = 'none'; pt.LineWidth = 2;

xlim([-86.5892  -85.9795]);
ylim([-500, 50])
set(gca, 'TickLength', [0.001, 0.001], 'YAxisLocation', 'right')
ylabel('Depth (m)')
grid on;

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);

%%

Ro = ncread(arch, 'Ro');
Ro = permute(Ro,  [2, 3, 1] );

Rogcw = nanmean( Ro(:, :, inGCWp), 3 );
Rosuw = nanmean( Ro(:, :, inSUWp), 3 );

G = ncread(arch, 'G');
G = permute(G,  [2, 3, 1] );

Ggcw = nanmean( G(:, :, inGCWp), 3 );
Gsuw = nanmean( G(:, :, inSUWp), 3 );

%%

axZg = axes('pos', [0.0619533527696947 0.582586062529497 0.187 0.13921651609252]); box on;
hold on;

contourf(Xnemo, Znemo, Rogcw, [50], 'EdgeColor', 'none');
hold on
contour(Xnemo, Znemo, Ggcw, [25.35, 25.35], 'edgecolor', rgb('black'), 'LineWidth', 1);

[ch, hh] = contour(Xnemo, Znemo, Ggcw, [23, 24, 25, 26, 26.5, 27], '-','edgecolor', rgb('black'));
clabel(ch, hh)
clim([-2, 2])
colormap(axZg , cmocean( 'Balance', 'pivot', 0));
box on;
set(gca, 'Layer', 'top')
Pol = closepoli(xto, zto, 'add', 100);
pt = patch(Pol(:, 1), Pol(:, 2), [1 1 1]*0.65);
pt.EdgeColor = 'none'; pt.LineWidth = 2;

xlim([-86.5892  -85.9795]);
ylim([-500, 50])
set(gca, 'TickLength', [0.001, 0.001],  'XTickLabels', {})
ylabel('Depth (m)')
cb = colorbar('horiz');

cb.Position =  [0.0619533527696947+0.016126 0.582586062529497-0.028787141859358 0.349854227405248 0.0188910435772994];
xlabel(cb, '$R_o$', 'Interpreter','latex', 'FontSize', 15)
grid on;



axZs = axes('pos', [0.260659620991268 0.582586062529497  0.187 0.13921651609252]); box on;
hold on;
contourf(Xnemo, Znemo, Rosuw, [50], 'EdgeColor', 'none');
hold on
[ch, hh] = contour(Xnemo, Znemo, Gsuw, [23, 24, 25, 26, 26.5, 27], '-','edgecolor', rgb('black'));
clabel(ch, hh)
clim([-2, 2])
colormap(axZs, cmocean( 'Balance', 'pivot', 0));
box on;
set(gca, 'Layer', 'top')
Pol = closepoli(xto, zto, 'add', 100);
pt = patch(Pol(:, 1), Pol(:, 2), [1 1 1]*0.65);
pt.EdgeColor = 'none'; pt.LineWidth = 2;

xlim([-86.5892  -85.9795]);
ylim([-500, 50])

set(gca, 'TickLength', [0.001, 0.001], 'YAxisLocation', 'right', 'XTickLabels', {} ,'YTickLabels', {})
grid on;

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);


%%

dvdz = ncread(arch, 'dvdz');
dvdz = permute(dvdz,  [2, 3, 1] );

Dvgcw = nanmean( dvdz(:, :, inGCWp), 3 );
Dvsuw = nanmean( dvdz(:, :, inSUWp), 3 );

%%

axVGg = axes('pos', [0.459001457725949 0.582586062529497 0.187 0.13921651609252]); box on;
hold on;
pcolor(Xnemo, Znemo, Dvgcw); shading interp
hold on

[ch, hh] = contour(Xnemo, Znemo, Ggcw, [23, 24, 25, 26, 26.5, 27], '-','edgecolor', rgb('black'));
clabel(ch, hh)
clim([0.0003 0.03])
colormap(axVGg , cmocean( 'amp'));
box on;
set(gca, 'Layer', 'top')
Pol = closepoli(xto, zto, 'add', 100);
pt = patch(Pol(:, 1), Pol(:, 2), [1 1 1]*0.65);
pt.EdgeColor = 'none'; pt.LineWidth = 2;

xlim([-86.5892  -85.9795]);
ylim([-500, 50])
set(gca, 'TickLength', [0.001, 0.001],  'XTickLabels', {}, 'YTickLabels', {})
% 
cb = colorbar('horiz');

% 0.459001457725949
cb.Position =  [0.459001457725949+0.016126 0.582586062529497-0.028787141859358 0.349854227405248 0.0188910435772994];
xlabel(cb, '$\displaystyle |\partial\vec{u}/{\partial z}|$ (s$^{-1}$)', 'Interpreter','latex', 'FontSize', 15)
grid on;



axVGs = axes('pos', [0.657434402332373 0.582586062529497  0.187 0.13921651609252]); box on;
hold on;
contourf(Xnemo, Znemo, Dvsuw, [50], 'EdgeColor', 'none');
hold on
[ch, hh] = contour(Xnemo, Znemo, Gsuw, [23, 24, 25, 26, 26.5, 27], '-','edgecolor', rgb('black'));
clabel(ch, hh)
clim([0.0003 0.03])
colormap(axVGs, cmocean( 'amp'));
box on;
set(gca, 'Layer', 'top')
Pol = closepoli(xto, zto, 'add', 100);
pt = patch(Pol(:, 1), Pol(:, 2), [1 1 1]*0.65);
pt.EdgeColor = 'none'; pt.LineWidth = 2;

xlim([-86.5892  -85.9795]);
ylim([-500, 50])

set(gca, 'TickLength', [0.001, 0.001], 'YAxisLocation', 'right', 'XTickLabels', {})
grid on;
ylabel('Depth (m)')
set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);


%% Salinity composites

S = ncread(arch, 'SA');
S = permute(S,  [2, 3, 1] );

Sgcw = nanmean( S(:, :, inGCWp), 3 );
Ssuw = nanmean( S(:, :, inSUWp), 3 );

%%

axSg = axes('pos', [0.0619533527696947 0.353586597451631 0.187 0.13921651609252]); box on;
pcolor(Xnemo, Znemo, Sgcw); shading interp
hold on;
contour(Xnemo, Znemo, Sgcw, [36.82, 36.82], 'EdgeColor', rgb('black'), 'LineWidth',1.2);
[cc, hh] = contour(Xnemo, Znemo, Sgcw, [35.5:0.25:36.5], 'EdgeColor', rgb('gray'));
clabel(cc, hh, 'Color', rgb('gray'))
colormap(axSg, cmocean('ice'));
box on;
set(gca, 'Layer', 'top')
Pol = closepoli(xto, zto, 'add', 100);
pt = patch(Pol(:, 1), Pol(:, 2), [1 1 1]*0.65);
pt.EdgeColor = 'none'; pt.LineWidth = 2;
xlim([-86.5892  -85.9795]);
ylim([-500, 50])
ylabel('Depth (m)')
set(gca, 'TickLength', [0.001, 0.001])
putnorth_ax_latex(gca, 11, 1, 'W')
grid on;
set(gca, 'TickLength', [0.001, 0.001])
clim([35.13, 37])


% 0.0619533527696947 0.353586597451631

axSs = axes('pos', [0.260659620991268 0.353586597451631 0.187 0.13921651609252]); box on;
pcolor(Xnemo, Znemo, Ssuw); shading interp
hold on;
contour(Xnemo, Znemo, Ssuw, [36.82, 36.82], 'EdgeColor', rgb('black'), 'LineWidth',1.2);
[cc, hh] = contour(Xnemo, Znemo, Ssuw, [35.5:0.25:36.5], 'EdgeColor', rgb('gray'));
clabel(cc, hh, 'Color', rgb('gray'))
colormap(axSs, cmocean('ice'));
box on;
set(gca, 'Layer', 'top')
Pol = closepoli(xto, zto, 'add', 100);
pt = patch(Pol(:, 1), Pol(:, 2), [1 1 1]*0.65);
pt.EdgeColor = 'none'; pt.LineWidth = 2;
xlim([-86.5892  -85.9795]);
ylim([-500, 50])
set(gca, 'TickLength', [0.001, 0.001])

putnorth_ax_latex(gca, 11, 1, 'W')
grid on;
clim([35.13, 37])
set(gca, 'YTickLabels', {}, 'TickLength', [0.001, 0.001])

cb = colorbar('horiz');
cb.Position =  [0.0619533527696947+0.016126 0.3014 0.349854227405248 0.0188910435772994];
xlabel(cb, 'Salinity (g kg$^{-1}$)', 'Interpreter','latex')
putnorth_ax_latex(gca, 11, 1, 'W')

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);

%%


W = ncread(arch, 'w');
W = permute(W,  [2, 3, 1] );

Wgcw = nanmean( W(:, :, inGCWp), 3 );
Wsuw = nanmean( W(:, :, inSUWp), 3 );


%%

axWg = axes('pos', [0.459001457725949 0.353586597451631 0.187 0.13921651609252]); box on;
cla
pcolor(Xnemo, Znemo, Wgcw*86400); shading interp
hold on;
[ch, hh] = contour(Xnemo, Znemo, Ggcw, [23, 24, 25, 26, 26.5, 27], '-','edgecolor', rgb('black'));
clabel(ch, hh)
hold on;

% h = quiver(Xnemo(1:4:end), Znemo(1:5:end), Ugcw(1:5:end, 1:4:end)./20, ...
    % Wgcw(1:5:end, 1:4:end)*60, 0,'color', rgb('gray'));
% h.Head.LineStyle = 'solid'; h.Head.LineWidth = 1.5;   

box on;
set(gca, 'Layer', 'top', 'YTickLabels', {})
Pol = closepoli(xto, zto, 'add', 100);
pt = patch(Pol(:, 1), Pol(:, 2), [1 1 1]*0.65);
pt.EdgeColor = 'none'; pt.LineWidth = 2;
xlim([-86.5892  -85.9795]);
ylim([-500, 50])

set(gca, 'TickLength', [0.001, 0.001])
putnorth_ax_latex(gca, 11, 1, 'W')
grid on;
set(gca, 'TickLength', [0.001, 0.001])
clim([-40, 20])
colormap(axWg, cmocean('curl', 'pivot', 0));

axWs = axes('pos', [0.657434402332373 0.353586597451631 0.187 0.13921651609252]); box on;
pcolor(Xnemo, Znemo, Wsuw*86400); shading interp
hold on;

% h = quiver(Xnemo(1:4:end), Znemo(1:5:end), Usuw(1:5:end, 1:4:end)./20, ...
    % Wgcw(1:5:end, 1:4:end)*60, 0,'color', rgb('gray'));
% h.Head.LineStyle = 'solid'; h.Head.LineWidth = 1.5;   

[ch, hh] = contour(Xnemo, Znemo, Gsuw, [23, 24, 25, 26, 26.5, 27], '-','edgecolor', rgb('black'));
clabel(ch, hh)

box on;
set(gca, 'Layer', 'top')
Pol = closepoli(xto, zto, 'add', 100);
pt = patch(Pol(:, 1), Pol(:, 2), [1 1 1]*0.65);
pt.EdgeColor = 'none'; pt.LineWidth = 2;
xlim([-86.5892  -85.9795]);
ylim([-500, 50])
set(gca, 'TickLength', [0.001, 0.001], 'YAxisLocation', 'right')

putnorth_ax_latex(gca, 11, 1, 'W')
grid on;
clim([-40, 20])
colormap(axWs, cmocean('curl', 'pivot', 0));

cb = colorbar('horiz');
cb.Position =  [0.459001457725949+0.016126 0.3014 0.349854227405248 0.0188910435772994];
xlabel(cb, 'Vertical velocity (m day$^{-1}$)', 'Interpreter','latex')
putnorth_ax_latex(gca, 11, 1, 'W')
ylabel('Depth (m)')

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);


%%

text(axYg, -86.58499, -331.47, '\textbf{TGCW}', 'FontSize', 12,'Interpreter', 'latex')
text(axYw, -86.58499, -331.47, '\textbf{SUW}', 'FontSize', 12,'Interpreter', 'latex')
text(axYg, -86.58499, -452.9235, '\textbf{(A)}', 'FontSize', 13.5,'Interpreter', 'latex')
text(axYw, -86.58499, -452.9235, '\textbf{(B)}', 'FontSize', 13.5,'Interpreter', 'latex')


text(axTg, -86.58499, -331.47, '\textbf{TGCW}', 'FontSize', 12,'Interpreter', 'latex')
text(axTs, -86.58499, -331.47, '\textbf{SUW}', 'FontSize', 12,'Interpreter', 'latex')
text(axTg, -86.58499, -452.9235, '\textbf{(C)}', 'FontSize', 13.5,'Interpreter', 'latex')
text(axTs, -86.58499, -452.9235, '\textbf{(D)}', 'FontSize', 13.5,'Interpreter', 'latex')


text(axZg, -86.58499, -331.47, '\textbf{TGCW}', 'FontSize', 12,'Interpreter', 'latex')
text(axZs, -86.58499, -331.47, '\textbf{SUW}', 'FontSize', 12,'Interpreter', 'latex')
text(axZg, -86.58499, -452.9235, '\textbf{(E)}', 'FontSize', 13.5,'Interpreter', 'latex')
text(axZs, -86.58499, -452.9235, '\textbf{(F)}', 'FontSize', 13.5,'Interpreter', 'latex')

text(axVGg, -86.58499, -331.47, '\textbf{TGCW}', 'FontSize', 12,'Interpreter', 'latex')
text(axVGs, -86.58499, -331.47, '\textbf{SUW}', 'FontSize', 12,'Interpreter', 'latex')
text(axVGg, -86.58499, -452.9235, '\textbf{(G)}', 'FontSize', 13.5,'Interpreter', 'latex')
text(axVGs, -86.58499, -452.9235, '\textbf{(H)}', 'FontSize', 13.5,'Interpreter', 'latex')


text(axSg, -86.58499, -331.47, '\textbf{TGCW}', 'FontSize', 12,'Interpreter', 'latex')
text(axSs, -86.58499, -331.47, '\textbf{SUW}', 'FontSize', 12,'Interpreter', 'latex')
text(axSg, -86.58499, -452.9235, '\textbf{(I)}', 'FontSize', 13.5,'Interpreter', 'latex')
text(axSs, -86.58499, -452.9235, '\textbf{(J)}', 'FontSize', 13.5,'Interpreter', 'latex')

text(axWg, -86.58499, -331.47, '\textbf{TGCW}', 'FontSize', 12,'Interpreter', 'latex')
text(axWs, -86.58499, -331.47, '\textbf{SUW}', 'FontSize', 12,'Interpreter', 'latex')
text(axWg, -86.58499, -452.9235, '\textbf{(K)}', 'FontSize', 13.5,'Interpreter', 'latex')
text(axWs, -86.58499, -452.9235, '\textbf{(L)}', 'FontSize', 13.5,'Interpreter', 'latex')



% text(axZi, 738227.843288916, -114.102, '\textbf{(C)}', 'FontSize',13.5,'Interpreter', 'latex')
% text(axVi, 738375.012786357, -347.630225806452, '\textbf{(B)}', 'FontSize', 13.5,'Interpreter', 'latex')
% text(axSAi, 738375.012786357, 36.455523, '\textbf{(A)}', 'FontSize', 13.5,'Interpreter', 'latex')

