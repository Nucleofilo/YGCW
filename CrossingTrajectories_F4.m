clr;


archi = 'D:\Papers\Paper_III\Results\EventosNEMO\Compuestos\Parcels_Backtracked_20d_YGCW.nc';

ncdisp(archi) 

timevec = (ncread(archi, 'time')./86400) + datenum('1970-01-01');

lon = double(ncread(archi, 'lon'));
lat = double(ncread(archi, 'lat'));
SA = double(ncread(archi, 'SA'));
CT = double(ncread(archi, 'CT'));

nparts = size(timevec, 2);
ntimes = size(timevec, 1);
%% This is going to be used to detect crossings of the Yucatan sections
xx = lon(1, :);
yy = lat(1, :);
inba = isnan(xx + yy);
xx(inba) = [];
yy(inba) = [];
BB = polyfit(xx, yy, 1);

x1 = -89.3983;
x2 = -83.1237;
xxn = [x1, x2];
yyn = [polyval(BB, xxn)]+0.01;

xxpol = [x1, x2, x2, x1, x1];
yypol = [polyval(BB, x1), polyval(BB, x2), 27, 27, polyval(BB, x1)]+0.01;

%%
close all
Cross = false([1, nparts]);
CrossStrtNorth = false([1, nparts]);
CrossStrtSouth = false([1, nparts]);


for kk = 1 : nparts
        [aa, bb, cc] =  polyxpoly(lon(:, kk), lat(:, kk), xxn, yyn);
        if length(bb) >= 2

            Cross(kk) = true;            
            seclat = polyval(BB, lon(end, kk));

            if (lat(end, kk) > seclat)
                CrossStrtNorth(kk) = true;
            else
                CrossStrtSouth(kk) = true;
            end
        end
end


%%
close all
plot(lon(:, CrossStrtNorth), lat(:, CrossStrtNorth))



%%
close all
figure; 
subplot(1, 2, 1)
plot(SA(end, CrossStrtNorth), CT(end, CrossStrtNorth), '.')
hold on;
plot(SA(1, CrossStrtNorth), CT(1, CrossStrtNorth), '.r')

subplot(1, 2, 2)
plot(SA(end, CrossStrtSouth), CT(end, CrossStrtSouth), '.')
hold on;
plot(SA(1, CrossStrtSouth), CT(1, CrossStrtSouth), '.r')


%%


% for kk = 1 : size(timevec, 2)

kk = 1;


plot()



% 
% end




