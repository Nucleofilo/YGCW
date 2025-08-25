% Grafica parche de la costa en la region del Golfo de Mexico
% h es el current axes puede ser h = gca, o simplemente usar gca (debe haber una figura abierta)
% Color puede ser tripleta rgb o las claves de matlab como 'w'
%
% re es la resolucion del poligono de costa
% re = 0 es la resolucion intermedia de GSHHS
% re = 1 es la resolucion completa de GSHHS
% re = 2 es la resolucion que se usara en los equipos de cigom ACM que nos proporciono J. Sheinbaum 
% Giovanni Durante 2018

% Modificado en Julio de 2020 para introducir nueva batimetría re = 2. GD



function pongolfo(h, Color, re, linecol)


    if re == 0
        load GDM_coast_Interm.mat
        in = find(isnan(gy + gx) == 1);
        for i = 1 : length(in)-1
            xt = gx(in(i)+1:in(i+1)-1);
            yt = gy(in(i)+1:in(i+1)-1);
            hold(h, 'on');
            patch(xt, yt, Color, 'Edgecolor', linecol)
        end
    
    elseif re == 1
        load GDM_coast_full
        for j = 1 : length(G)
            gx = [NaN; G(j).Pol(:, 1); NaN];
            gy = [NaN; G(j).Pol(:, 2); NaN];
            in = find(isnan(gy + gx) == 1);
            for i = 1 : length(in)-1
                xt = gx(in(i)+1:in(i+1)-1);
                yt = gy(in(i)+1:in(i+1)-1);
                hold(h, 'on');
                patch(xt, yt, Color, 'Edgecolor', linecol)
            end
        end
        
    elseif re == 2
        load GDM_coast_CIGom.mat
        for j = 1 : length(G)
            gx = [NaN; G(j).Pol(:, 1); NaN];
            gy = [NaN; G(j).Pol(:, 2); NaN];
            in = find(isnan(gy + gx) == 1);
            for i = 1 : length(in)-1
                xt = gx(in(i)+1:in(i+1)-1);
                yt = gy(in(i)+1:in(i+1)-1);
                hold(h, 'on');
                patch(xt, yt, Color, 'Edgecolor', linecol)
            end
        end     
    end
    
end