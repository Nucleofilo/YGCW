
function ponisob_cigom(h, cons, color, fsz)

    load BAT_FUS_GLOBAL_PIXEDIT_V4.mat;
    hold(h, 'on')
    [cc, hh] = contour(LON25, LAT25, -ZZ4b, cons,'EdgeColor', color);
    clabel(cc, hh, 'Color', rgb('Gray'), 'FontSize', fsz);
    li = [get(h, 'Xlim'), get(h, 'Ylim')];
    
end
%     
%     %%
% 
% 
% % 
% % 
% % 
% % 
% % %% 
% % 
% % ax
% % 
% % limes = [-98, -76.4, 18.0916, 31.9606];
% % 
% % load BAT_FUS_GLOBAL_PIXEDIT_V4.mat;
% % 
% % 
% % 
% % 
% % 
% % 
