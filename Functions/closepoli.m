% close poligons;
% cierra polígonos en los puntos dados por los vectores x, y;
% regresa los vectores del polígono cerrado por lados rectos;
% Entrada: 
%   x , y: Vectores que contienen al polígono a cerrar
%   cierre: Estilo de cierre, 'min' = minimo de y, 
%   'max' = maximo de y, 
%   'add' = añade un segmento (util para perfiles batimetricos)
%   con la opcion 'add' se debe incluir el segmento a añadir 
%   en las unidades de y    
%   'none' el primer elemento de y
%
function P = closepoli(x, y, cierre, varargin)
    % Ren - Col;
    sx = size(x);
    sy = size(y);
    
    if(max(sx) ~= max(sy))
       disp('Error. Matrix dimensions most be the same'); 
       return;
    end
    
    
    if(sx(1) < sx(2))
        
       x = x';
        
    end
    
    if(sy(1) < sy(2))
        
       y = y';
        
    end
    
    switch cierre
        case 'min'
            cie = min(y);
        case 'max'
            cie = max(y);
        case 'add'
            cie = min(y) - double( varargin{end} ); 
        case 'none'
            cie = y(1);
        case 'cero'
            cie = 0;
            
    end
    
    y(end+1) = cie;
    
    
    x(end+1) = x(end);
    
    y(end+1) = y(end);
    x(end+1) = x(1);
    y(end+1) = y(1);
    x(end+1) = x(1);
    
    P = [x, y];


end


