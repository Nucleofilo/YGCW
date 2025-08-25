clr;
funcas(0)
load D:\Papers\Paper_III\Results\EventosNEMO\Compuestos\CompsLagrangianExps\TrayecLasts
loLast = LoTr; laLast = LaTr;
load D:\Papers\Paper_III\Results\EventosNEMO\Compuestos\CompsLagrangianExps\TrayecEarly
loEarly = LoTr; laEarly = LaTr;
load D:\Papers\Paper_III\Results\EventosNEMO\Compuestos\CompsLagrangianExps\TrayecTodas
load D:\Papers\Paper_III\Results\EventosNEMO\Compuestos\CompsLagrangianExps\TrayecNorte.mat
clear losu lasu



[Ttodas, lobin_todas, labin_todas] = twodhist(LoTr, LaTr, ...
    [min(LoTr(end, :)), -80.45], [min(LaTr(end, :)), max(LaTr(:))], 220);

[Estrt, loEar_str, laEar_str] = twodhist(loEarly(end, :), laEarly(end, :), ...
    [min(LoTr(end, :)), max(LoTr(end, :))], [min(LaTr(end, :)), max(LaTr(:))], 400);

[Lastrt, loLa_str, laLa_str] = twodhist(loLast(end, :), laLast(end, :), ...
    [min(LoTr(end, :)), max(LoTr(end, :))], [min(LaTr(end, :)), max(LaTr(:))], 400);


%%

load D:\Papers\Paper_III\Results\Figures\Fur\bat48.mat
load D:\Papers\Paper_III\Results\EventosNEMO\ExtraeDefine\TS_GCW_nemo
load D:\Papers\Paper_III\Results\EventosNEMO\Compuestos\NemoComposites_section.mat
load D:\Papers\Paper_III\Results\EventosNEMO\Compuestos\CompsLagrangianExps\FinStartValues

sds = S_start(:);
tds = T_start(:);
zds = z_start(:);

sdf = S_fin(:);
tdf = T_fin(:);

lodu = lo_fin(:);
zdf = z_fin(:);

inpu = inpolygon(sdf, tdf, bx, by-0.35);

lodu(~inpu) = [];
zdf(~inpu) = [];
sdf(~inpu) = [];
tdf(~inpu) = [];

sds(~inpu) = [];
tds(~inpu) = [];
zds(~inpu) = [];

gdf = gsw_sigma0(sdf, tdf);
gds = gsw_sigma0(sds, tds);

[XZmat, lobin_, zbin] = twodhist(lodu(:), zdf(:), ...
    [min(lo_fin), max(lo_fin)], [min(z_fin), max(z_fin)], 30);

% load('cero')

BB = [0.1642, 35.7544999999991];
x1 = -86.914;
x2 = -84.897888;

xxn = [x1, x2];
yyn = polyval(BB, xxn);

addpath(genpath('/STORAGE/SSD/gdurante/PaperIII/LC_area/extern/'))
funcas(0)
load('D:\Papers\Paper_III\Data_Methods\Anclajes\Velocidad\VirtualesNEMO\NEMO_YUC4_ts.mat')

% pcolor(tinemo, -abs(Znemo_), SAnemo_);
% shading interp;
for kk = 1 : length(tinemo)
    ps = SAnemo_(:, kk);
    gs = Gnemo_(:, kk);
    [aa, bb, cc] = polyxpoly( gs, ps, [25.3, 25.3], [0, 40]  );
    SAi(kk) = bb;
end

inGCWp = find( SAi < 36.6 );  
inSUWp = find( SAi > 37 );

load D:\Papers\Paper_III\Results\EventosNEMO\Compuestos\CompsLagrangianExps\TrayecNorte

sds = STr(end, :);
tds = TTr(end, :);
lods = LoTr(end, :);
lads = LaTr(end, :);
Zds = ZTr(end, :);
% 

%%
% tamaño trayectoires
% [0.0411 0.0687 0.3416 0.6674]
pgr = 1;
close all
figure('Position',[-1.6483e+03 -56.7778 1.5458e+03 941.7778], ...
    'Color','w');

% tamano figure;
axSAi = axes('pos', [0.0877 0.8348277 0.5129 0.1520722]);
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

vlines(Ev)

text(mean([tinemo(1), tinemo(end)]), 36.426, '\textbf{NEMO salinity index}', ...
    'HorizontalAlignment','center', 'color', rgb('Black'), 'Interpreter','latex')

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);


% Vertical section
AxSec = axes('Position', [0.611787656876698 0.779613025011798 0.186051649631259 0.207286874988207]);
pcolor(lobin_, zbin, XZmat./max(XZmat(:)));shading interp;
hold on

load D:\Papers\Paper_III\Results\EventosNEMO\Compuestos\NemoComposites_section Xnemo Znemo Vgcw

Vgcw(find(Znemo<-260), :) = NaN;
Tgcw(find(Znemo<-260), :) = NaN;

hold on;
contour(Xnemo, -abs(Znemo), Vgcw, [0.6, 0.6], 'edgecolor', rgb('Red'), 'linewidth', 3.2);
contour(Xnemo, -abs(Znemo), Vgcw, [0.0, 0.0], 'edgecolor', rgb('black'), 'linewidth', 2.3);
contour(Xnemo, -abs(Znemo), Vgcw, -[0.1, 0.1], 'edgecolor', rgb('Blue'), 'linewidth', 2.3);

[ch, hh] = contour(Xnemo, Znemo, Tgcw,  [14:2:26, 28], '--', 'edgecolor', rgb('gray'), 'LineWidth',1);
clabel(ch, hh)

Pol = closepoli(xtopo, topo, 'add', 100);
pt = patch(Pol(:, 1), Pol(:, 2), [1 1 1]*0.70);
pt.EdgeColor = 'none'; pt.LineWidth = 2;
box on;
axis([-86.5588  -86.1267, -350, 1])
box on;
clim([0, 1])

set(gca, 'YAxisLocation', 'right')
set(gca, 'Layer', 'top')
ylabel('Depth (m)')
% grid on;

cmap = cmocean('tempo');
cmap = [1, 1, 1; cmap];
colormap(AxSec, cmap);

cb = colorbar('horiz');
cb.Position = [0.7136 0.787648324681457 0.0794000000000001 0.0198];
set(cb, 'AxisLocation', 'in')
text(-86.3157946, -238.581274259681, '\textbf{Parcel density}','Interpreter', 'latex', 'color', rgb('gray'), 'BackgroundColor', 'w')

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);
putnorth_ax_latex(gca, 12, 1, 'W')


text(-86.5527, -161, '\textbf{Isotherms}', 'Interpreter', 'latex')
plot([-86.5404, -86.4650], [-190, -190], 'linewidth', 1, 'linestyle', '--', 'color', rgb('black'));

text(-86.5527, -225, '\textbf{Vel.} (m s$^{-1}$)', 'Interpreter', 'latex')

plot([-86.5311 , -86.4977], [-260.0699, -260.0699], 'linewidth', 2, 'linestyle', '-', 'color', rgb('Red'));
text([-86.4913], [-260.0699], '$~$0.6', 'Interpreter', 'latex');

plot([-86.5311 , -86.4977], [-294, -294], 'linewidth', 2, 'linestyle', '-', 'color', rgb('Black'));
text([-86.4913], [-294], '$~$0.0', 'Interpreter', 'latex');

plot([-86.5311 , -86.4977], [-328, -328], 'linewidth', 2, 'linestyle', '-', 'color', rgb('Blue'));
text([-86.4905], [-328], '-0.1', 'Interpreter', 'latex');

%%
% _____________________________________________________________

Tmap = axes('Position', [0.07343085 0.1832 0.3093 0.6044]);

plot(LoTr(:, 1:2:end), LaTr(:, 1:2:end), 'k'); hold on; 

pc = pcolor(lobin_todas, labin_todas, Ttodas./max(Ttodas(:)));shading interp
cmap = cmocean('deep');
cmap = [1, 1, 1; cmap];
colormap(Tmap, cmap);
clim([0, 1])
pc.FaceAlpha = 0.65;
axis equal tight
axis([-88.4, -80.45, 14, 24])
pongolfo(gca, rgb('white'), pgr, 'k');

grid on;
plot(xxn, yyn, 'color', rgb('Orange'),'LineWidth', 3)
cb = colorbar('horiz');
cb.Position = [0.1076 0.1913 0.1324 0.03];
set(cb, 'AxisLocation', 'in')
xlabel(cb, 'Trajectory density','Interpreter', 'latex')

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);

putnorth_ax_latex(gca, 12, 1, 'W')
putnorth_ax_latex(gca, 12, 2, 'N')

%%

[Smat, sbin, tbin] = twodhist(sds(:), tds(:), ...
    [34, 37.5], [8, 30], 230);

TSax = axes('pos', [0.402440928741269 0.506017 0.1787539 0.281823937215683]);
box on;
hold on;
cmap = cmocean('amp');
cmap = [1, 1, 1; cmap];
colormap(TSax, cmap);
clim([0, 1])
plot(sds(:), tds(:), '.', 'color', rgb('Crimson')); hold on;
% pc = pcolor(sbin, tbin, Smat./max(Smat(:)));shading interp
plot(sdf(:), tdf(:), '.', 'color', rgb('royalblue')); hold on;
% pc.FaceAlpha = 0.65;
set(gca, 'YAxisLocation', 'right');
box on; 

[ss, tt] = meshgrid(34:0.01:38, 0:0.01:35);
dens0 = gsw_sigma0(ss,tt);

[ch, hh] = contour(gca, ss, tt, dens0, [22:28],...
    'edgecolor', rgb('gray'));
clabel(ch, hh, 'color', rgb('gray'))

[ch, hh] = contour(gca, ss, tt, dens0, [25.35, 25.35],...
    'edgecolor', rgb('black'));

clabel(ch, hh, 'color', rgb('black'))

[xxv, yyv] = muadro( [34.2, 35.16], [10, 19.86] );
set(gca, 'layer', 'top')

% cb = colorbar; 
% cb.Position = [0.413395749288107 0.516635205 0.0155864243749178 0.114204813591315];
% set(cb, 'AxisLocation', 'in')
% xlabel(cb, 'Parcel density','Interpreter', 'latex')

axis([34.2 37.25, 10 29.53])
ylabel('Temperature ($^o$C)')
xlabel('Salinity (g kg$^{-1}$)')
% clim([0, 1])

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);


%%

Gax = axes('pos', [0.628594010251377 0.506017 0.170179727906499 0.234898532304966]);
box on; hold on;
plot( gsw_sigma0(sds(:), tds(:)), Zds(:), '.', 'Color', rgb('crimson'))
plot( gsw_sigma0(sdf(:), tdf(:)), zdf(:), '.', 'Color', rgb('royalblue'))

set(gca, 'YAxisLocation', 'right')
ylabel('Depth (m)','Interpreter', 'latex')
xlabel('$\sigma_\theta$ (kg m$^{-3}$)','Interpreter', 'latex')

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);

grid on;

ax0(2) = plot(NaN, NaN, '.', 'color', rgb('Crimson'), 'MarkerSize', 16); hold on;
ax0(1) = plot(NaN, NaN, '.', 'color', rgb('RoyalBlue'), 'MarkerSize', 16);
ll = legend(ax0, {'YGCW detection', '20 days before'});
ll.Position = [0.629991422214168 0.508364800142095 0.109833369109739 0.0455521470592403];
% ll.Orientation = "horizontal";
%%

Tma1 = axes('Position', [0.406052754378233 0.183208495004521 0.129959693531037 0.261965997096645]);

[Estrt, loEar_str, laEar_str] = twodhist(loEarly(end, :), laEarly(end, :), ...
    [min(LoTr(end, :)), max(LoTr(end, :))], [min(LaTr(end, :)), max(LaTr(:))], 200);

plot(loEarly(:, 1:1:end), laEarly(:, 1:1:end),  'color', rgb('silver')); hold on; 

% Uno = nan(size(loEarly));
% Vno = Uno; Wno = Uno;
% for kk = 1 : size(loEarly, 2)
%     [u, v, w] = trajectory_velocity(loEarly(:, kk), laEarly(:, kk), Zno(:, kk), tino(:, kk), []);
%     Uno(:, kk) = u(:); Vno(:, kk) = v(:); Wno(:, kk) = w(:);
% end

% [loCno, laCno, Ugridno, Vgridno, Wgridno, CountNo] = ...
%     binned_mean_velocity_2d(loEarly(:), laEarly(:), Uno(:), Vno(:), Wno(:), [0.03, 0.03], 1);

% quiver( loCno, laCno, Ugridno, Vgridno, 3,'k')

% pc = pcolor(loEar_str, laEar_str, Estrt./max(Estrt(:)));shading interp
% cmap = cmocean('deep');
% cmap = [1, 1, 1; cmap];
% colormap(Tma1, cmap);
% clim([0, 0.5])
% pc.FaceAlpha = 0.65;
axis equal tight
axis([-89.061, -81.7571, 15, 23.97])
pongolfo(gca, rgb('white'), pgr, 'k');

grid on;
plot(xxn, yyn, 'color', rgb('Orange'),'LineWidth', 1)

% set(gca, 'YTickLabels', {}, 'XTickLabels', {})
set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);

putnorth_ax_latex(gca, 12, 1, 'W')
putnorth_ax_latex(gca, 12, 2, 'N')
set(gca, 'YTickLabelRotation', 30)
%%
% [0.433870093703006 ]
Tma2 = axes('Position', [0.545047220186188 0.183208495004521 0.129959693531037 0.261965997096645]);

% [Lastrt, loLa_str, laLa_str] = twodhist(loLast(end, :), laLast(end, :), ...
%     [min(LoTr(end, :)), max(LoTr(end, :))], [min(LaTr(end, :)), max(LaTr(:))], 200);

plot(loLast(:, 1:1:end), laLast(:, 1:1:end), 'color', rgb('silver')); hold on; 
% pc = pcolor( loLa_str, laLa_str, Lastrt./max(Lastrt(:)));shading interp
% cmap = cmocean('deep');
% cmap = [1, 1, 1; cmap];
% colormap(Tma2, cmap);
% clim([0, 0.5])
% pc.FaceAlpha = 0.65;
axis equal tight
axis([-89.061, -81.7571, 15, 23.97])
pongolfo(gca, rgb('white'), pgr, 'k');

grid on;
plot(xxn, yyn, 'color', rgb('Orange'),'LineWidth', 1)

set(gca, 'YTickLabels', {})
set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);

putnorth_ax_latex(gca, 12, 1, 'W')

%%
% [0.545694134405363 0.183208495004521 0.129959693531037 0.261965997096645]
Tma3 = axes( 'Position', [0.67924695924999 0.183208495004521 0.124128501068192 0.261965997096645] );

% [LaNo, loLaNo, laLaNo] = twodhist(lono(1, :), lano(1, :), ...
%     [-88.06, -85.30], [20.79, 24.7149], 200);

plot(lono(:, 1:1:end), lano(:, 1:1:end), 'color', rgb('silver')); hold on; 

Uno = nan(size(lono));
Vno = Uno; Wno = Uno;
for kk = 1 : size(lono, 2)
    [u, v, w] = trajectory_velocity(lono(:, kk), lano(:, kk), Zno(:, kk), tino(:, kk), []);
    Uno(:, kk) = u(:); Vno(:, kk) = v(:); Wno(:, kk) = w(:);
end

[loCno, laCno, Ugridno, Vgridno, Wgridno, CountNo] = ...
    binned_mean_velocity_2d(lono(:), lano(:), Uno(:), Vno(:), Wno(:), [0.12, 0.12], 1);

quiver( loCno, laCno, Ugridno, Vgridno, 3,'k')


% pc = pcolor( loLaNo, laLaNo, LaNo./max(LaNo(:)));shading interp
% cmap = cmocean('deep');
% cmap = [1, 1, 1; cmap];
% colormap(Tma3, cmap);
% clim([0, 0.5])
% pc.FaceAlpha = 0.65;

axis equal tight
axis([-87.8306926777336 -85.5086648779566, 20.8015, 24.0115])
pongolfo(gca, rgb('white'), 0, 'k');

grid on;
plot(xxn, yyn, 'color', rgb('Orange'),'LineWidth', 1)

set(gca, 'YTickLabels', {})
set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);

putnorth_ax_latex(gca, 12, 1, 'W')
putnorth_ax_latex(gca, 12, 2, 'N')
% set(gca, 'YTickLabels', {}, 'XTickLabels', {})
set(gca, 'YAxisLocation', 'right')

set(gca, 'YTickLabelRotation', -30)
%%

text(axSAi , 738308, 36.43, '\textbf{(A)}', 'FontSize', 15,'Interpreter', 'latex')

text(AxSec, -86.18439466, -26.60716, '\textbf{(B)}', 'FontSize', 15,'Interpreter', 'latex')

text(Tmap, -81.0866, 23.65377, '\textbf{(C)}', 'FontSize', 15,'Interpreter', 'latex')

text(TSax, 36.820, 28.393, '\textbf{(D)}', 'FontSize', 15,'Interpreter', 'latex')

text(Gax, 27.06957, -30.56942, '\textbf{(E)}', 'FontSize', 15,'Interpreter', 'latex')

text(Tma1, -83.183, 15.6050, '\textbf{(F)}', 'FontSize', 15,'Interpreter', 'latex')

text(Tma2, -83.183, 15.6050, '\textbf{(G)}', 'FontSize', 15,'Interpreter', 'latex')

text(Tma3, -86.06522, 21.02804, '\textbf{(H)}', 'FontSize', 15,'Interpreter', 'latex')

%%
