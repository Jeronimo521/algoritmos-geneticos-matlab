function x = mutacionViajero(x,pm,fijarInicio)
if nargin<3, fijarInicio=false; end
if rand()<pm
    disponibles=1:numel(x);
    if fijarInicio, disponibles=2:numel(x); end
    posiciones=disponibles(randperm(numel(disponibles),2));
    x(posiciones)=x(fliplr(posiciones));
end
end
