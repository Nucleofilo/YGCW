function putnorth_ax_latex(h, sz, ar, dire)

switch ar
    case 3
        
        yts = get(h, 'YtickLabels');
        yts = strcat(yts, '°N');
        set(h, 'YtickLabels', yts, 'fontsize', sz);
        yts = get(h, 'Xtick');
        set(h, 'XtickLabels', abs(yts));
        yts = get(h, 'Xticklabels');
        yts = strcat(yts, '°W');
        set(h, 'XtickLabels', yts, 'fontsize', sz);
        
    case 2
        yts = get(h, 'Ytick');
        set(h, 'YtickLabels', abs(yts));
        yts = get(h, 'YtickLabels');
        yts = strcat(yts, ['$^o', dire, '$']);
        set(h, 'YtickLabels', yts, 'fontsize', sz);
        
    case 1
        yts = get(h, 'Xtick');
        set(h, 'XtickLabels', abs(yts));
        yts = get(h, 'Xticklabels');
        yts = strcat(yts, ['$^o', dire, '$']);
        set(h, 'XtickLabels', yts, 'fontsize', sz);
end

end


