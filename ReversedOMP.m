% modelito OMP
clr;

load(['D:\Papers\Paper_III\Results\Figures\Repo\Figure1\F1_Data\TSCaribe.mat']);
[sa, in_ocean] = gsw_SA_from_SP(sp(:),p(:),lom(:),lam(:));
ct = gsw_CT_from_t(sa,te(:),p(:));
sigt = gsw_sigma0(sa,ct);
mons = datevec(fe);
mons = mons(:, 2);
Prof = unique([lom, lam, fe],'rows');
nProf = length(Prof);
lon = Prof(:, 1);
lat = Prof(:, 2);
fec = Prof(:, 3);
g = 9.81;
%%
load D:\Papers\Paper_III\Results\Figures\Repo\Figure1\F1_Data\CaribeBaseTS_rOMP
po = [0:5:550];

tpo = nan([length(po)-1, 1]);
spo = nan([length(po)-1, 1]);
vpo = nan([length(po)-1, 1]); 

for ll = 1 : length(po)-1
    inbu = find(press >= po(ll) & press <= po(ll+1));
    tpo(ll) = nanmean(temp(inbu));
    spo(ll) = nanmean(sal(inbu));
    vpo(ll) = nanmean(vort(inbu));
end
spo = smoothdata(spo, 'gaussian', 5);
vpo = smoothdata(vpo, 'gaussian', 5);
tpo = smoothdata(tpo, 'gaussian', 5);


inba = isnan(spo + tpo + vpo);
spo(inba) = [];
vpo(inba) = [];
tpo(inba) = [];


po = [22:0.03:26.8];
opon = nan([length(po)-1, 1]);
spon = nan([length(po)-1, 1]);
vpon = nan([length(po)-1, 1]); 

for ll = 1 : length(po)-1
    inbu = find(sigt >= po(ll) & sigt <= po(ll+1));

    opon(ll) = nanmean(temp(inbu));
    spon(ll) = nanmean(sal(inbu));
    gpo(ll) = mean([po(ll), po(ll+1)]);
    vpon(ll) = nanmean(vort(inbu));

end
spon = smoothdata(spon, 'gaussian', 5);
% tpon = smoothdata(tpon, 'gaussian', 5);
vpon = smoothdata(vpon, 'gaussian', 10);

inba = isnan(spon + opon + vpon);
spon(inba) = [];
opon(inba) = [];
vpon(inba) = [];


spo = interp1(opon, spon, tpo);
vpo = interp1(opon, vpon, tpo);

%%

close all;
figurax;set(gcf, "Position", ...
    [[-1723 27.6666666666667 1708.66666666667 679.333333333333]]);

axts1 = axes('Position', [0.13 0.534805890227577 0.17325129140079 0.390194109772423])

[masa, indma] = max(spo);

Tf = [16.5051, tpo(indma), 28.4429];
Sf = [interp1(tpo, spo, Tf(1)), masa, interp1(tpo, spo, Tf(end))];
Vf = [interp1(tpo, vpo, Tf(1)), vpo(indma), interp1(tpo, vpo, Tf(end))];
Gf = [gsw_sigma0(Sf,Tf)];

Tr = [];
Sr = [];
Vr = [];
Gr = [];
a = 1;
inc = 0.01;

t1 = -0.3; t2 = 0.3;
s1 = -0.05; s2 = 0.05;
v1 = -0.01; v2 = 0.01;
g1 = -0.1; g2 = 0.1;

x1 = [0:inc:1];
for x3 = 0:inc:1
    xi = [0:inc:1-x3];
    for xi = xi
        x1 = xi;
        x2 = 1 - x1 - x3;
        rt = t1 + (t2-t1) .*  rand(1);
        rs = s1 + (s2-s1) .* rand(1);
        rpv = v1 + (v2-v1) .* rand(1); 
        rg = g1 + (g2-g1) .* rand(1); 

        Tr = x1.*Tf(1) + x2.*Tf(2) + x3.*Tf(3)+rt;
        Sr = x1.*Sf(1) + x2.*Sf(2) + x3.*Sf(3)+rs;
        Vr = x1.*Vf(1) + x2.*Vf(2) + x3.*Vf(3)+rpv;
        Gr = x1.*Gf(1) + x2.*Gf(2) + x3.*Gf(3)+rg;

        if x1 + x2 + x3 == 1
        a = a + 1;
        hold on;
        plot(Sr, Tr, '.', 'color', rgb('silver'))
        end
    end
end

hold on;
plot(sal, temp, '.', 'color', rgb('Crimson')); 

[ss, tt] = meshgrid(min(sa):0.01:38, 0:0.01:35);
dens0 = gsw_sigma0(ss,tt);
[ch, hh] = contour(gca, ss, tt, dens0, [22:28], 'edgecolor', rgb('gray'));
clabel(ch, hh, 'color', rgb('gray'))

%
hold on;
plot(spo, tpo, 'k', 'LineWidth', 3)
plot(Sf, Tf, 'sk', 'markerfacecolor', 'w','MarkerSize',10)


axis([35.2 37.7, 15 31])
ylabel('Temperature ($^o$C)')
xlabel('Salinity (g kg$^{-1}$)')
box on;

plot([36.8, 36.8], [20, 24.5], 'k:', 'LineWidth',3)
[xv, yv] = muadro([36.2, 36.75], [20, 22.5]);

hold on;
pt = patch(xv, yv, rgb('lightskyblue'));
pt.EdgeColor = 'k';pt.FaceAlpha = 0.5;
pt.LineWidth = 1;
title('\textbf{Caribbean data + rOMP}', 'Interpreter','latex')
text(36.233, 21.1719, '\textbf{GCW}', 'FontSize', 12, 'Interpreter', 'latex');
text(36.690413, 29.0275, '\textbf{CSW}', 'FontSize', 12, 'Interpreter', 'latex');
text(37.3134, 23.3625, '\textbf{SUW}', 'FontSize', 12, 'Interpreter', 'latex');
text(36.35955, 15.3625, '\textbf{18$^o$ water}', 'FontSize', 12, 'Interpreter', 'latex');


ax0(1) = plot(NaN, NaN, '.', 'color', rgb('crimson'), 'Markersize', 15); hold on;
ax0(2) = plot(NaN, NaN, '.', 'color', rgb('silver'), 'Markersize', 15);
ax0(3) = plot(NaN, NaN, 'sk', 'markerfacecolor', 'w','MarkerSize',10);

ll = legend(ax0, {'Caribbean samples', 'rOMP', 'end-members'}, 'location', 'best');
ll.Position = [0.13 0.361944161712313 0.107231268136705 0.0921491664104067];

set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
set(findall(gcf,'-property','FontSize'),'FontSize', 12);




%%

% axts2 = axes('Position', [0.318341453826057 0.534805890227577 0.17325129140079 0.390194109772423]);
% box on;
% load D:\Papers\Paper_III\Data_Methods\Full_per_Region\TSYucatan
% plot(sa, ct, '.', 'color', rgb('Orange')); hold on;
% cnkd = {['05-Aug-2018';'10-Nov-2020']};
% fecs = datenum(char(cnkd(1, :)));
% %
% %
% load D:\Papers\Paper_III\Data_Methods\Anclajes\MicroCATS\YUC3MCT.mat
% plot(SAmicro, CTmicro, '.', 'color', rgb('LightSeaGreen'))
% load D:\Papers\Paper_III\Data_Methods\Anclajes\MicroCATS\YUC4MCT.mat
% plot(SAmicro, CTmicro, '.', 'color', rgb('LightSeaGreen'))
% 
% 
% [ss, tt] = meshgrid(min(sa):0.01:38, 0:0.01:35);
% dens0 = gsw_sigma0(ss,tt);
% [ch, hh] = contour(gca, ss, tt, dens0, [22:28], 'edgecolor', rgb('gray'));
% clabel(ch, hh, 'color', rgb('gray'))
% 
% %
% hold on;
% plot(spo, tpo, 'k', 'LineWidth', 3)
% plot(Sf, Tf, 'sk', 'markerfacecolor', 'w','MarkerSize',10)
% % title('Caribean CT-AS samples')
% 
% axis([35.2 37.7, 15 31])
% % ylabel('Temperature ($^o$C)')
% set(gca, 'YTickLabels', {})
% xlabel('Salinity (g kg$^{-1}$)')
% box on;
% title('\textbf{Yucatan section data}', 'Interpreter','latex')
% plot([36.8, 36.8], [20, 24.5], 'k:', 'LineWidth',3)
% [xv, yv] = muadro([36.2, 36.75], [20, 22.5]);
% 
% hold on;
% pt = patch(xv, yv, rgb('lightskyblue'));
% pt.EdgeColor = 'k';pt.FaceAlpha = 0.5;
% pt.LineWidth = 1;
% 
% text(36.233, 21.1719, '\textbf{GCW}', 'FontSize', 12, 'Interpreter', 'latex');
% text(36.690413, 29.0275, '\textbf{CSW}', 'FontSize', 12, 'Interpreter', 'latex');
% text(37.3134, 23.3625, '\textbf{SUW}', 'FontSize', 12, 'Interpreter', 'latex');
% text(36.35955, 15.3625, '\textbf{18$^o$ water}', 'FontSize', 12, 'Interpreter', 'latex');
% 
% ax0(1) = plot(NaN, NaN, '.', 'color', rgb('Orange'), 'Markersize', 15); hold on;
% ax0(2) = plot(NaN, NaN, '.', 'color', rgb('LightSeaGreen'), 'Markersize', 15);
% % ax0(3) = plot(NaN, NaN, 'sk', 'markerfacecolor', 'w','MarkerSize',10);
% 
% ll = legend(ax0, {'CTD data', 'MicroCATs data (YUC3 and YUC4)'}, 'location', 'best');
% ll.Position = [0.31479087113678 0.361944161712313 0.107231268136705 0.0921491664104067];
% 
% 
% %%
% 
% axts3 = axes('Position', [0.506682907652114 0.534805890227577 0.17325129140079 0.390194109772423]);
% 
% load D:\Papers\Paper_III\Data_Methods\Anclajes\Velocidad\VirtualesNEMO\NEMO_YUC5
% plot(SAnemo_(:), CTnemo_(:), '.', 'color',rgb('royalblue'))
% hold on;
% load D:\Papers\Paper_III\Data_Methods\Anclajes\Velocidad\VirtualesNEMO\NEMO_YUC7_ts_n
% plot(SAnemo_(:), CTnemo_(:), '.', 'color',rgb('royalblue'))
% hold on;
% load D:\Papers\Paper_III\Data_Methods\Anclajes\Velocidad\VirtualesNEMO\NEMO_YUC10_ts_n
% plot(SAnemo_(:), CTnemo_(:), '.', 'color',rgb('royalblue'))
% hold on;
% load D:\Papers\Paper_III\Data_Methods\Anclajes\Velocidad\VirtualesNEMO\NEMO_YUC4
% plot(SAnemo_(:), CTnemo_(:), '.', 'color',rgb('orangered'))
% load D:\Papers\Paper_III\Data_Methods\Anclajes\Velocidad\VirtualesNEMO\NEMO_YUC3
% plot(SAnemo_(:), CTnemo_(:), '.', 'color',rgb('orangered'))
% plot([36.8, 36.8], [20, 24.5], 'k:', 'LineWidth',3)
% 
% [ss, tt] = meshgrid(min(sa):0.01:38, 0:0.01:35);
% dens0 = gsw_sigma0(ss,tt);
% [ch, hh] = contour(gca, ss, tt, dens0, [22:28], 'edgecolor', rgb('gray'));
% clabel(ch, hh, 'color', rgb('gray'))
% 
% load D:\Papers\Paper_III\Results\EventosNEMO\ExtraeDefine\TS_GCW_nemo
% Pol = polyshape( bx, by );
% Pol = polybuffer(Pol, -0.02);
% plot(Pol, 'linewidth', 2)
% 
% set(gca, 'YTickLabels', {})
% ax0(1) = plot(NaN, NaN, '.', 'color', rgb('orangered'), 'Markersize', 15);
% ax0(2) = plot(NaN, NaN, '.', 'color', rgb('royalblue'), 'Markersize', 15);
% ll = legend(ax0, {'YUC3-YUC4', 'YUC5-YUC10'}, 'location', 'best');
% ll.Position = [0.506682907652114 0.361944161712313 0.107231268136705 0.0921491664104067];
% axis([35.2 37.7, 15 31])
% 
% title('\textbf{NEMO-G108 Virtual moorings}', 'Interpreter','latex')
% 
% set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter', 'latex');
% set(findall(gcf,'-property','Interpreter'),'Interpreter', 'latex');
% set(findall(gcf,'-property','FontSize'),'FontSize', 12);
% %%
% 
% text(axts1, 35.2171, 15.755, '\textbf{(A)}', 'FontSize',15,'Interpreter', 'latex')
% text(axts2, 35.2171, 15.755, '\textbf{(B)}', 'FontSize',15,'Interpreter', 'latex')
% text(axts3, 35.2171, 15.755, '\textbf{(C)}', 'FontSize',15,'Interpreter', 'latex')

%%
