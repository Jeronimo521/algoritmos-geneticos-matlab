function indices = seleccionRuleta(valores)
valores=valores(:);
assert(all(isfinite(valores) & valores>0), ...
    'La ruleta requiere objetivos finitos y positivos.');
pesos=1./valores; acumulada=cumsum(pesos/sum(pesos));
acumulada(end)=1;
indices=zeros(numel(valores)/2,1);
for i=1:numel(indices)
    indices(i)=find(acumulada>=rand(),1,'first');
end
end
