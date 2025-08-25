% Regresa informacion de todos los instrumentos de un anclaje (temperatura o corrientes o ambas)
% para pintarlo en un diagrama
% indica de qué sensores quieres informacion
% 
% infrom = 'temp', 'vel', 'otemp', 'all'.  Con inform = 'otemp' quita todo lo que
% no sea sensor de temperature, porque los de corriente tmbn la miden
% G. Durante 2024
function anclaje = InfoAnclaje(anc, infrom, origen)

addpath('C:\Users\nucle\Documents\Canek_VelocidadPorAnclaje\extrn\');
% Ruta base donde estan los datos
% origen = 'I:\TesisDoc\datos\CNK_extractions\P3\A\';

% estructura de pura informacion del anclaje, digamosle metadata, no datos
% medidos
anclaje = struct();

try
    clear mooring
    load([origen,  anc])
    if exist('anchor')
        mooring = anchor;
    end
catch
end

if exist('mooring') && ~isempty(fieldnames(mooring))

    sens = {};
    for ee = 1 :length(mooring)
        name = mooring(ee).name;
        tip = find(int16(name) == 45);
        rtipo = char(name( tip(2)+1:tip(3)-1 ));
        sens(ee) = {TipoSensor(rtipo)};
    end
    
    switch infrom
        case 'temp'
            flg = logical([mooring(:).RegTemp]);
            mooring(flg) = [];
            
        case 'otemp'
            flg = logical([mooring(:).RegTemp]);
            mooring(flg) = [];
            sens(flg) = [];
            
            flg1 = contains(sens, 'TERM');
            flg2 = contains(sens, 'MCT');
            flg = logical(flg1 + flg2);
            mooring = mooring(flg);
            sens = sens(flg);
            
        case 'vel'
            flg = logical([mooring(:).RegVel]);
            mooring(flg) = [];
            sens(flg) = [];
            
            flg = contains(sens, 'TERM');
            mooring(flg) = [];
            sens(flg) = [];
            
            flg = contains(sens, 'MCT');
            mooring(flg) = [];
            sens(flg) = [];
            
    end
    sens = {};
    for ee = 1 :length(mooring)
        name = mooring(ee).name;
        tip = find(int16(name) == 45);
        rtipo = char(name( tip(2)+1:tip(3)-1 ));
        sens(ee) = {TipoSensor(rtipo)};
        
        if contains( name, 'DW' )
            ori(ee) = 2;
        else
            ori(ee) = 1;
        end
    end
    
    if ~isempty(mooring)
        name = mooring(1).name;
        tira = find(int16(name) == 45);
        tiran = str2num(name(tira(1)+2:tira(2)-1));
                
        anclaje.lola = mooring(1).lola;
        anclaje.sens = sens;
        anclaje.znom = [mooring(:).znom]';
        anclaje.ori = ori;
        anclaje.name = anc;
        anclaje.column = tiran;
    end
end

end


%%
