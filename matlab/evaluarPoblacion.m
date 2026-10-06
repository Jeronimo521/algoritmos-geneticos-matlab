function valores = evaluarPoblacion(poblacion,problema,cfg,datos)
valores=zeros(size(poblacion,1),1);
for i=1:size(poblacion,1)
    x=poblacion(i,:);
    switch lower(problema)
        case 'viajero'
            valores(i)=calcularTiempoRuta(x,datos.T,cfg.regresoUCO);
        case 'ackley'
            valores(i)=calcularAckley(x,cfg.limitesAckley);
        case 'inventario'
            [Q,S,K]=decodificarInventario(x,datos);
            valores(i)=calcularInventario(Q,S,K,datos);
        otherwise
            error('Problema desconocido.');
    end
end
end
