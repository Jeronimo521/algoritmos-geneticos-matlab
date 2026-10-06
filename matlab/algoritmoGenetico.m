function resultado = algoritmoGenetico(problema,cfg)
if strcmpi(problema,'viajero') && cfg.regresoUCO && ~cfg.fijarInicioUCO
    error('Para regresar a la UCO, activa tambien fijarInicioUCO.');
end
assert(cfg.poblacion>=4 && mod(cfg.poblacion,4)==0);
assert(cfg.iteraciones>=1 && cfg.pm>=0 && cfg.pm<=1 && cfg.magnitud>=0);
rng(cfg.semilla,'twister'); datos=datosProblemas(); reloj=tic;
switch lower(problema)
    case 'viajero'
        poblacion=generarPoblacionViajero(cfg.poblacion,cfg.fijarInicioUCO);
    case 'ackley'
        poblacion=generarPoblacionAckley(cfg.poblacion,cfg.dimensiones,cfg.limitesAckley);
    case 'inventario'
        poblacion=generarPoblacionInventario(cfg.poblacion,datos);
    otherwise
        error('Problema desconocido.');
end
if cfg.validarFases, validarPoblacion(poblacion,problema,cfg,datos); end
valores=evaluarPoblacion(poblacion,problema,cfg,datos);
[mejor,j]=min(valores); individuo=poblacion(j,:);
historial=zeros(cfg.iteraciones+1,1); historial(1)=mejor;
for iter=1:cfg.iteraciones
    switch lower(cfg.seleccion)
        case 'elitismo', indices=seleccionElitismo(valores);
        case 'torneo', indices=seleccionTorneo(valores,cfg.grupoTorneo);
        case 'ruleta', indices=seleccionRuleta(valores);
        otherwise, error('Metodo de seleccion desconocido.');
    end
    padres=poblacion(indices,:); padres=padres(randperm(size(padres,1)),:);
    hijos=zeros(size(padres));
    for i=1:2:size(padres,1)
        switch lower(problema)
            case 'viajero'
                [h1,h2]=cruceViajero(padres(i,:),padres(i+1,:));
                if cfg.fijarInicioUCO
                    h1=[1,h1(h1~=1)]; h2=[1,h2(h2~=1)];
                end
            case 'ackley'
                [h1,h2]=cruceAckley(padres(i,:),padres(i+1,:));
            case 'inventario'
                [h1,h2]=cruceInventario(padres(i,:),padres(i+1,:),datos);
        end
        hijos(i,:)=h1; hijos(i+1,:)=h2;
    end
    if cfg.validarFases, validarPoblacion(hijos,problema,cfg,datos); end
    for i=1:size(hijos,1)
        switch lower(problema)
            case 'viajero'
                hijos(i,:)=mutacionViajero(hijos(i,:),cfg.pm,cfg.fijarInicioUCO);
            case 'ackley'
                hijos(i,:)=mutacionAckley(hijos(i,:),cfg.pm,cfg.magnitud,cfg.limitesAckley);
            case 'inventario'
                hijos(i,:)=mutacionInventario(hijos(i,:),cfg.pm,cfg.magnitud,datos);
        end
    end
    if cfg.validarFases, validarPoblacion(hijos,problema,cfg,datos); end
    poblacion=[padres;hijos];
    if cfg.validarFases, validarPoblacion(poblacion,problema,cfg,datos); end
    valores=evaluarPoblacion(poblacion,problema,cfg,datos);
    assert(all(isfinite(valores) & valores>0));
    [actual,j]=min(valores);
    if actual<mejor, mejor=actual; individuo=poblacion(j,:); end
    historial(iter+1)=mejor;
end
resultado.tiempo=toc(reloj);
resultado.mejorValor=mejor;
resultado.mejorIndividuo=individuo;
resultado.historial=historial;
resultado.poblacionFinal=poblacion;
resultado.valoresFinales=valores;
resultado.configuracion=cfg;
end
