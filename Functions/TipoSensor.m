function sens = TipoSensor(tipo)
if contains(tipo, 'LR')
    sens = 'LR';
elseif contains(tipo, 'SBE56')
    sens = 'TERM';
elseif contains(tipo, 'SBE37')
    sens = 'MCT';
elseif contains(tipo, 'WH300')
    sens = 'WH300';
elseif contains(tipo, 'WH600')
    sens = 'WH600';
elseif contains(tipo, 'SIG55')
    sens = 'SIG55';
elseif contains(tipo, 'AQ')
    sens = 'AQD';
elseif contains(tipo, 'MCT')
    sens = 'MCT';
elseif contains(tipo, 'TERM')
    sens = 'TERM';
elseif contains(tipo, 'A')
    sens = 'CORR';
elseif contains(tipo, 'SCT')
    sens = 'SCT';
else
    sens = 'CORR';
end