
% ori es la orientacon ori = 1 es pa arriba, ori = 2 es pa abajo
function PintaSensor(sens, xp, zp, ax, ay, ori, alF)
aLR = 500; aWH3 = 100; aWH6=60; aAQD=20; sig55 = 600;
switch sens
    case 'AQD'
        cAQD(xp, zp, ax, ay)
        if alF
        plot([xp,xp],[zp,0],':r','linewidth',2)
        end
    case 'TERM'
        SBE_(xp, zp, ax, ay);
    case 'MCT'
        MicroCat(xp, zp, ax, ay);
    case 'CORR'
        czcm(xp, zp, ax, ay);
        
    case 'LR'
        if ori == 2
            cLRd(xp, zp, ax, ay);
            if alF
                plot([xp,xp],[zp,zp-aLR],':r','linewidth',2)
            end
        elseif ori == 1
            cLRu(xp, zp, ax, ay)
            if alF
                if (zp+aLR)>0
                    plot([xp,xp],[zp,0],':r','linewidth',2)
                else
                    plot([xp,xp],[zp,zp+aLR],':r','linewidth',2)
                end
            end
        end
        
    case 'WH300'
        if ori == 1
            cza300(xp, zp, ax, ay);
            if alF
                if (zp+aWH3)>0
                    plot([xp,xp],[zp,0],':r','linewidth',2)
                else
                    plot([xp,xp],[zp,zp+aWH3],':r','linewidth',2)
                end
            end
        elseif ori == 2
            WH300d(xp, zp, ax, ay);
            if alF
                plot([xp,xp],[zp,zp-aWH3],':r','linewidth',2)
            end
        end
    case 'WH600'
        if ori == 1
            cza300(xp, zp, ax, ay);
            if alF
                if (zp+aWH6)>0
                    plot([xp,xp],[zp,0],':r','linewidth',2)
                else
                    plot([xp,xp],[zp,zp+aWH6],':r','linewidth',2)
                end
            end
        elseif ori == 2
            WH300d(xp, zp, ax, ay);
            if alF
                
                plot([xp,xp],[zp,zp-aWH6],':r','linewidth',2)
            end
        end
        
    case 'SIG55'
        if ori == 1
            cSIG55u(xp, zp, ax, ay)
            if alF
                plot([xp,xp],[zp,zp+sig55],':r','linewidth',2)
            end
        elseif ori == 2
            cSIG55d(xp, zp, ax, ay)
            if alF
                plot([xp,xp],[zp,zp-sig55],':r','linewidth',2)
            end
        end
end