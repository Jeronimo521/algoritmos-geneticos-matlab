function validarPoblacion(poblacion,problema,cfg,datos)
assert(all(isfinite(poblacion(:))),'La poblacion contiene NaN o Inf.');
switch lower(problema)
    case 'viajero'
        assert(size(poblacion,2)==13);
        for i=1:size(poblacion,1)
            assert(isequal(sort(poblacion(i,:)),1:13),'Ruta invalida.');
        end
        if cfg.fijarInicioUCO, assert(all(poblacion(:,1)==1)); end
    case 'ackley'
        assert(size(poblacion,2)==cfg.dimensiones);
        assert(all(poblacion(:)>=cfg.limitesAckley(1) & ...
            poblacion(:)<=cfg.limitesAckley(2)),'Ackley fuera de limites.');
    case 'inventario'
        assert(size(poblacion,2)==14);
        for i=1:size(poblacion,1)
            [Q,S,K]=decodificarInventario(poblacion(i,:),datos);
            assert(all(Q>=datos.minQ-1e-8 & Q<=datos.maxQ));
            assert(all(S>=0 & S<=datos.maxS) && all(K>=0 & K<=datos.maxK));
            assert(abs(sum(Q/2+S)-datos.I)<=datos.tolerancia);
        end
end
end
