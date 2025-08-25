
clr;
addpath(genpath('D:\Papers\Paper_III\Results\Figures\Repo\Functions\'))
load D:\Papers\Paper_III\Results\Figures\Repo\Figure1\F1_Data\TSCaribeWaters

sgcw =  sa(GCWi); tgcw = ct(GCWi); 
logcw = lom(GCWi); lagcw = lam(GCWi); pgcw = p(GCWi);
ggcw = sigt(GCWi);

ssuw =  sa(SUWi); tsuw = ct(SUWi); 
losuw = lom(SUWi); lasuw = lam(SUWi); psuw = p(SUWi);
gsuw = sigt(SUWi);

Tg = [23.5];
Sg = [interp1(tpo, spo_c, Tg)];
%
%
close all;
figurax;set(gcf, "Position", [-1541 -56.3333 1.2213e+03 937.3333])

mapax = axes('pos', [0.0581331754764104, 0.364512427427043, 0.514737891827132, 0.528744313368613]);

ponisob_cigom(gca, [-200, -200], rgb('gray'), 4); hold on;
plot(lom(~FISWi & ~GCWi & ~SUWi), lam(~FISWi & ~GCWi & ~SUWi), '.', 'color', rgb('silver'), 'markersize', 10); hold on;
plot(lom(GCWi), lam(GCWi), '.','color', rgb('steelblue'), 'markersize', 10);
plot(lom(FISWi), lam(FISWi), '.','color', rgb('steelblue'), 'markersize', 10);
plot(lom(SUWi), lam(SUWi), '.', 'color', rgb('salmon'), 'markersize', 10);
pongolfo(gca, rgb('silver'), 0);
axis equal
axis([-97.4528, -80.43, 16 29.67])
set(findall(gcf,'-property','FontSize'),'FontSize', 11);

putnorth_ax_latex(gca, 11, 1, 'W')
putnorth_ax_latex(gca, 11, 2, 'N')

box on;


plot([-94.976070255, -86.825159], [19.1001, 21.8], 'k')
plot([-88.4630, -86.1], [16.05, 21.46], 'k')

%%

axts1 = axes('pos', [0.0623 0.0505 0.2448 0.2827]); box on;

hold on;
plot(sa, ct, '.','color', rgb('silver'))
plot(ssuw, tsuw, '.', 'color', rgb('salmon'))

plot(sgcw, tgcw, '.','color', rgb('steelblue'))
plot(spo_g, tpo, 'color', rgb('Navy'), 'LineWidth',2)
plot(spo_c, tpo, 'r', 'LineWidth',2)
plot(Sg, Tg, 'sk', 'markerfacecolor', 'w','MarkerSize',10)
plot([36.8, 36.8], [20.5, 24.5], 'k--', 'LineWidth',2)
[xv, yv] = muadro([36.2, 36.75], [20, 22.5]);

hold on;
pt = patch(xv, yv, rgb('lightskyblue'));
pt.EdgeColor = 'k';pt.FaceAlpha = 0.5;
pt.LineWidth = 1;

[ss, tt] = meshgrid(28:0.01:38, 0:0.01:35);
dens0 = gsw_sigma0(ss,tt);
[ch, hh] = contour(gca, ss, tt, dens0, [22:28], 'edgecolor', rgb('gray'));
clabel(ch, hh, 'color', rgb('gray'))
axis([35.5687 37.5, 16 31])
ylabel('Temperature ($^o$C)')
xlabel('Salinity (g kg$^{-1}$)')

text(36.233, 21.1719, '\textbf{GCW}', 'FontSize', 12, 'Interpreter', 'latex');
text(37.1829, 23.4244, '\textbf{SUW}', 'FontSize', 12, 'Interpreter', 'latex');

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);

%%

load D:\Papers\Paper_III\Results\Figures\Repo\Figure1\F1_Data\TSCaribe

[sa, ~] = gsw_SA_from_SP(sp(:),p(:),lom(:),lam(:));
ct = gsw_CT_from_t(sa,te(:),p(:));
sigt = gsw_sigma0(sa,ct);
axes(mapax)
plot(lom, lam, '.', 'color', rgb('Crimson'), 'markersize', 10);

axtc = axes('pos', [0.5857 0.0505 0.2448 0.2827]); box on;
plot(sa, ct, '.', 'color', rgb('Crimson')); hold on;
dt = 0.2;
po = [16:dt:29];
spo_c = nan([length(po)-1, 1]);
for ll = 1 : length(po)-1
    inbu = find(ct >= po(ll) & ct <= po(ll+1));
    spo_c(ll) = median(sa(inbu), 'omitnan');
end
tpo = po(2:end)-dt*0.5;
spo_c = smoothdata(spo_c, 'gaussian', 7);

plot(spo_c, tpo, 'color', 'k' , 'linewidth', 2.3)
% text(37.1829, 23.4244, '\textbf{SUW}', 'FontSize', 12, 'Interpreter', 'latex');
plot(37.13, 23.1197, 'sk', 'markerfacecolor', 'w','MarkerSize',10)
text(37.2152, 23.4810, '\textbf{SUW}', 'FontSize', 12, 'Interpreter', 'latex');
plot([36.8, 36.8], [20.5, 24.5], 'k--', 'LineWidth',2)
box on;
ylabel('Temperature ($^o$C)')
xlabel('Salinity (g kg$^{-1}$)')
[ss, tt] = meshgrid(28:0.01:38, 0:0.01:35);
dens0 = gsw_sigma0(ss,tt);
[ch, hh] = contour(gca, ss, tt, dens0, [22:28], 'edgecolor', rgb('gray'));
clabel(ch, hh, 'color', rgb('gray'))
axis([35.5687 37.5, 16 31])
set(gca, 'YAxisLocation', 'right')

axes(mapax);
load D:\Papers\Paper_III\Results\Figures\Repo\Figure1\F1_Data\TSYucatan
plot(lom, lam, '.', 'color', rgb('Orange'), 'markersize', 10);
[xv, yv] = muadro([-86.825159, -86.1], [21.46, 21.8]);
plot(xv, yv, 'k', 'LineWidth',1)


[sa, in_ocean] = gsw_SA_from_SP(sp(:),p(:),lom(:),lam(:));
ct = gsw_CT_from_t(sa,te(:),p(:));
sigt = gsw_sigma0(sa,ct);

load D:\Papers\Paper_III\Results\Figures\Repo\Figure1\F1_Data\TS_GCW.mat
% pt = patch( bx, by, rgb('SteelBlue'), 'EdgeColor', rgb('SteelBlue')); pt.FaceAlpha = .25;
% pt.LineWidth = 1;
axtsy = axes('pos', [0.3237 0.0505 0.2448 0.2827]); box on;
plot(sa, ct, '.', 'color', rgb('Orange')); hold on;

inba = inpolygon(sa, ct, bx, by);
sa(inba) = NaN;
dt = 0.2;
po = [16:dt:29];
spo_y = nan([length(po)-1, 1]);
for ll = 1 : length(po)-1
    inbu = find(ct >= po(ll) & ct <= po(ll+1));
    spo_y(ll) = mean(sa(inbu), 'omitnan');
end
tpo = po(2:end)-dt*0.5;
spo_y = smoothdata(spo_y, 'gaussian', 7);
plot(spo_y, tpo, 'color',[0.850, 0.325, 0.098], 'linewidth', 2.2)
text(37.1829, 23.4244, '\textbf{SUW}', 'FontSize', 12, 'Interpreter', 'latex');
plot(37.09, 23.10, 'sk', 'markerfacecolor', 'w','MarkerSize',10)

%==============================================================
box on;

plot([36.8, 36.8], [20.5, 24.5], 'k--', 'LineWidth',2)

[ss, tt] = meshgrid(28:0.01:38, 0:0.01:35);
dens0 = gsw_sigma0(ss,tt);
[ch, hh] = contour(gca, ss, tt, dens0, [22:28], 'edgecolor', rgb('gray'));
clabel(ch, hh, 'color', rgb('gray'))
axis([35.5687 37.5, 16 31])
set(gca, 'YtickLabels', {})
xlabel('Salinity (g kg$^{-1}$)')

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);

%%

cnkd = {['05-Aug-2018';'10-Nov-2020']};
fecs = datenum(char(cnkd(1, :)));
%
%
axtsMc = axes('pos', [0.5857 0.3643662872 0.2448 0.2827]); box on; hold on;
hold on;
plot(sa, ct, '.','color', rgb('Orange'))
%
%
load D:\Papers\Paper_III\Results\Figures\Repo\Figure1\F1_Data\YUC3MCT.mat
plot(SAmicro, CTmicro, '.', 'color', rgb('LightSeaGreen'))
load D:\Papers\Paper_III\Results\Figures\Repo\Figure1\F1_Data\YUC4MCT.mat
plot(SAmicro, CTmicro, '.', 'color', rgb('LightSeaGreen'))

% pt = patch( bx, by, rgb('OrangeRed'), 'EdgeColor', rgb('OrangeRed')); pt.FaceAlpha = .15;
% pt.LineWidth = 1;
axis([35.5687 37.5, 16 31])
[ss, tt] = meshgrid(28:0.01:38, 0:0.01:35);
dens0 = gsw_sigma0(ss,tt);
[ch, hh] = contour(gca, ss, tt, dens0, [22:28], 'edgecolor', rgb('gray'));
clabel(ch, hh, 'color', rgb('gray'))
axis([35.5687 37.5, 16 31])

[ss, tt] = meshgrid(36.23:0.005:37.33, 19:0.01:26);
dens0 = gsw_sigma0(ss,tt);
[ch, hh] = contour(gca, ss, tt, dens0, [25, 25.6], 'edgecolor', 'none');
xxl = [ch(1, 2:end)]; yyl = [ch(2, 2:end)]; 
indse = find(xxl < 36.23);

xxl = [xxl(1:indse-1), fliplr(xxl(indse+1:end)), xxl(1)];
yyl = [yyl(1:indse-1), fliplr(yyl(indse+1:end)), yyl(1)];

% [ss, tt] = meshgrid(36.23:0.005:37.33, 19:0.01:26);
% [ch, hh] = contour(gca, ss, tt, dens0, [25.35, 25.35], 'edgecolor', 'k', 'LineWidth',1);

plot(xxl, yyl, 'k', 'LineWidth',1.3)
plot([36.8, 36.8], [20.5, 24.5], 'k--', 'LineWidth',2)

set(gca, 'XtickLabels', {}, 'YAxisLocation', 'right')
ylabel('Temperature ($^o$C)')
box on;

text(36.36879453125, 21.1719, '\textbf{YGCW}', 'FontSize', 12, 'Interpreter', 'latex', 'Rotation', 16);
text(36.879328125, 22.39572864, '\textbf{SUW}', 'FontSize', 12, 'Interpreter', 'latex', 'Rotation', 16);

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);


%%
load polyGCW_seccion.mat
load YucSecTopo

axse = axes('pos', [0.5857 0.686666856367954 0.2448 0.207003125626]); box on; hold on;
hold on;
ylabel('Depth (m)')
set(gca, 'YAxisLocation', 'right')

origen = 'D:\Papers\Paper_III\Results\Figures\Repo\Figure2\F2_Data\RawVel\'; % carpeta de origen de los datos
anc_yuc4 = InfoAnclaje('CNK48_YUC4', 'vel', origen);
anc_yuc5 = InfoAnclaje('CNK48_YUC5', 'vel', origen);

hold on;
pt = patch(xxi, yyi, rgb('OrangeRed'), 'EdgeColor', rgb('Orange')); 
pt.FaceAlpha = .30;
pt.LineWidth = 0.1;

Pol = closepoli(xto, zto, 'add', 100); xli = get(gca, 'xlim');
pt = patch(Pol(:, 1), Pol(:, 2), rgb('silver'));
pt.EdgeColor = 'none'; pt.LineWidth = 2;
%
% plot microcats
%
set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);

putnorth_ax_latex(gca, 11, 1, 'W')

%

bins = (-abs(anc_yuc4.znom):16:-60);
plot(anc_yuc4.lola(1)*ones(size(bins)), bins, '.k', 'linewidth', 2)
bins = (-abs(anc_yuc5.znom(1)):16:-60);
plot(anc_yuc5.lola(1)*ones(size(bins)), bins, '.k', 'linewidth', 2)
plot(anc_yuc5.lola(1)*[1, 1], [-abs(anc_yuc5.znom(end)), -800], 'k', 'linewidth', 1)

PintaSensor('WH300', anc_yuc4.lola(1), -abs(anc_yuc4.znom), 0.035, 65, 1, 0);
PintaSensor('WH300', anc_yuc5.lola(1), -abs(anc_yuc5.znom(1)), 0.035, 65, 1, 0);

rut = 'D:\Papers\Paper_III\Results\Figures\Repo\Figure1\F1_Data\L2_SBE37_YUCATANCHANNEL-YUC4SIO_START-2018-07-27.nc';
% ncdisp(rut);
D = ncread1(rut, 'DEPTH');
znoms = -nanmean(D, 1);
plot(anc_yuc4.lola(1), znoms(1), 's', 'MarkerEdgeColor', rgb('gray'), 'MarkerFaceColor', rgb('LightSeaGreen'), 'MarkerSize', 9)


rut = 'D:\Papers\Paper_III\Results\Figures\Repo\Figure1\F1_Data\L2_SBE37_YUCATANCHANNEL-YUC3SIO_START-2018-07-27.nc';
D = ncread1(rut, 'DEPTH');
znoms = -nanmean(D, 1);
lon_yuc3 = ncread1(rut, 'LONGITUDE');
lat_yuc3 = ncread1(rut, 'LATITUDE');
plot(lon_yuc3*[1, 1], [double(znoms(1)), -129], 'k', 'linewidth', 1);
hold on;
plot(lon_yuc3, znoms(1), 's', 'MarkerEdgeColor', rgb('gray'), 'MarkerFaceColor', rgb('LightSeaGreen'), 'MarkerSize', 9)
%
box on;
xlim([-86.5588  -86.1267]);
ylim([-570, 50])
set(gca, 'Layer', 'top')

% custom legend:
% ==============================================================
% background
[clx, cly] = muadro([-86.5508, -86.3977], [-320, -556.5]);  
patch(clx, cly, 'w', 'edgecolor', 'k');
% 

plot(-86.5302, -372.0824, 's', 'MarkerEdgeColor', rgb('gray'), 'MarkerFaceColor', rgb('LightSeaGreen'), 'MarkerSize', 7.5);
text(-86.5037870535714, -374.92, 'MicroCAT', 'FontSize', 10, 'Interpreter', 'latex');
PintaSensor('WH300', -86.5302, -467.1396, 0.03, 55, 1, 0);
text(-86.5037870535714, -451.1789, 'LR ADCP', 'FontSize', 10, 'Interpreter', 'latex');
xle = [-86.5450:0.005:-86.518612];
plot(xle, -525.1716*ones(size(xle)), '.k', 'linewidth', 1)
text(-86.5037870535714, -525.1716, 'ADCP bins', 'FontSize', 10, 'Interpreter', 'latex');
grid on;

%  yuc3
%%

mapix = axes('pos', [0.135371179039301 0.366461799007046 0.192685994968489 0.117716129527984]); box on;

ponisob_cigom(gca, [-200, -200], rgb('gray'), 4); hold on;
pongolfo(gca, rgb('silver'), 0);
load D:\Papers\Paper_III\Data_Methods\Full_per_Region\TSYucatan
plot(lom, lam, '.', 'color', rgb('Orange'), 'markersize', 10);

plot([-86.57157, -86.57157, -86.4522, -86.4522], ...
    [21.63479, 21.62245, 21.62245, 21.55802], 'k', 'linewidth', 1)
plot([-86.3563, -86.3563], ...
    [21.68963, 21.57310], 'k', 'linewidth', 1)
plot([-86.17673, -86.17673, -86.2329], ...
    [21.72116, 21.61423, 21.61423], 'k', 'linewidth', 1)

plot(anc_yuc4.lola(1), anc_yuc4.lola(2), 'sk', 'MarkerFaceColor', rgb('LightSeaGreen'), 'markersize', 9)
plot(anc_yuc5.lola(1), anc_yuc5.lola(2), 'sk', 'MarkerFaceColor', rgb('LightSeaGreen'), 'markersize', 9)
plot(lon_yuc3, lat_yuc3, 'sk', 'MarkerFaceColor', rgb('LightSeaGreen'), 'markersize', 9)

axis equal tight
axis([-86.825159, -86.1, 21.46, 21.8])
set(gca, 'YTickLabels', {}, 'XTickLabels', {}, 'LineWidth', 0.9)


axes(mapax);
axz(1) = plot(NaN, NaN, '.','color', rgb('steelblue'), 'markersize', 20);
axz(2) = plot(NaN, NaN, '.', 'color', rgb('silver'), 'markersize', 20);
axz(3) = plot(NaN, NaN, '.', 'color', rgb('salmon'), 'markersize', 20);
axz(4) = plot(NaN, NaN, '.', 'color', rgb('Orange'), 'markersize', 20);
axz(5) = plot(NaN, NaN, '.', 'color', rgb('FireBrick'), 'markersize', 20);
axz(6) = plot(NaN, NaN, 's', 'MarkerEdgeColor', rgb('gray'), 'MarkerFaceColor', rgb('LightSeaGreen'), 'MarkerSize', 7.5);


ll = legend(axz, {'GoM GCW', 'Transitional', 'GoM SUW', 'Yucatan section','Caribbean', 'Canek moorings'});
ll. Position = [0.43329198082543 0.762766717955193 0.134297883146194 0.1298364148201];
ll.FontSize = 11.5;
axes(mapix)

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');


text(-86.57157, 21.65947, 'YUC3', 'FontSize', 11, ...
    'Interpreter', 'latex', 'HorizontalAlignment','center');


text(-86.35495, 21.721163, 'YUC4', 'FontSize', 11, ...
    'Interpreter', 'latex', 'HorizontalAlignment','center');


text(-86.18220, 21.74892, 'YUC5', 'FontSize', 11, ...
    'Interpreter', 'latex', 'HorizontalAlignment','center');

% AA = ginput(3)

text(axse, -86.4517, 17, 'YUC3', 'FontSize', 11, 'Interpreter', 'latex', 'HorizontalAlignment','center');
text(axse, -86.35528, 17, 'YUC4', 'FontSize', 11, 'Interpreter', 'latex', 'HorizontalAlignment','center');
text(axse, -86.23247, 17, 'YUC5', 'FontSize', 11, 'Interpreter', 'latex', 'HorizontalAlignment','center');


text(axse, -86.1812755297619, -527.792434, '\textbf{(B)}', 'FontSize',15,'Interpreter', 'latex')
text(axtsMc, 35.5831, 16.7802, '\textbf{(C)}', 'FontSize',15,'Interpreter', 'latex')
text(axtsy, 35.5831, 16.7802, '\textbf{(E)}', 'FontSize',15,'Interpreter', 'latex')
text(axtc, 35.5831, 16.7802, '\textbf{(F)}', 'FontSize',15,'Interpreter', 'latex')
text(axts1, 35.5831, 16.7802, '\textbf{(D)}', 'FontSize',15,'Interpreter', 'latex')
text(mapax, -97.3610, 29.3236, '\textbf{(A-I)}', 'FontSize',15,'Interpreter', 'latex')
text(mapix, -86.8146, 21.5025, '\textbf{(A-II)}', 'FontSize',15,'Interpreter', 'latex')


text(mapax, -81.747573, 22.74289, ...
    {['\textbf{Cuba}']}, 'FontSize', 13, 'Interpreter', 'latex');

text(mapix , -86.804923, 21.763638, ...
    {['\textbf{Yucatan} \textbf{section}']}, 'FontSize', 13, 'Interpreter', 'latex');

text(mapax, -88.81272, 20.66936, ...
    {['\textbf{Yucatan}']; ['\textbf{Peninsula}']}, 'HorizontalAlignment', 'center', ...
    'FontSize', 13, 'Interpreter', 'latex');
