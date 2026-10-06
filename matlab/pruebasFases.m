function pruebasFases()
addpath(fileparts(mfilename('fullpath')));
cfg=configuracion(); datos=datosProblemas(); rng(123,'twister');
assert(calcularTiempoRuta(1:13,datos.T,false)==641);
assert(calcularTiempoRuta(1:13,datos.T,true)==730);
assert(isinf(calcularTiempoRuta(ones(1,13),datos.T,false)));
assert(abs(calcularAckley(zeros(1,3))-(3-exp(1)))<1e-12);
assert(isinf(calcularAckley([11 0 0])));
cfgRuta=cfg; cfgRuta.regresoUCO=true;
rechazada=false;
try
    algoritmoGenetico('viajero',cfgRuta);
catch err
    rechazada=contains(err.message,'fijarInicioUCO');
end
assert(rechazada,'El regreso a UCO requiere fijar la ciudad inicial.');
cfgRuta.fijarInicioUCO=true; cfgRuta.iteraciones=2;
rRuta=algoritmoGenetico('viajero',cfgRuta);
assert(rRuta.mejorIndividuo(1)==1);
assert(rRuta.mejorValor==calcularTiempoRuta(rRuta.mejorIndividuo,datos.T,true));
p=generarPoblacionInventario(20,datos);
for i=1:20
    [Q,S,K]=decodificarInventario(p(i,:),datos);
    a=calcularInventario(Q,S,K,datos,'analitico');
    b=calcularInventario(Q,S,K,datos,'integral');
    assert(abs(a-b)<1e-7*max(1,abs(a)),'Integral no equivalente.');
end
datosLiteral=datos; datosLiteral.normalizacion='literal';
[Q,S,K]=decodificarInventario(p(1,:),datos);
a=calcularInventario(Q,S,K,datosLiteral,'analitico');
b=calcularInventario(Q,S,K,datosLiteral,'integral');
assert(abs(a-b)<1e-7*max(1,abs(a)));
valores=(1:100)';
assert(isequal(seleccionElitismo(valores),(1:50)'));
assert(numel(unique(seleccionTorneo(valores,4)))==50);
assert(numel(seleccionRuleta(valores))==50);
problemas={'viajero','ackley','inventario'};
for p=1:3
    switch problemas{p}
        case 'viajero', poblacion=generarPoblacionViajero(100);
        case 'ackley', poblacion=generarPoblacionAckley(100,3,[-10 10]);
        case 'inventario', poblacion=generarPoblacionInventario(100,datos);
    end
    validarPoblacion(poblacion,problemas{p},cfg,datos);
    for i=1:2:99
        a=poblacion(i,:); b=poblacion(i+1,:);
        switch problemas{p}
            case 'viajero'
                [h1,h2]=cruceViajero(a,b);
                assert(isequal(mutacionViajero(a,0),a));
                m1=mutacionViajero(h1,1); m2=mutacionViajero(h2,1);
                assert(sum(m1~=h1)==2);
            case 'ackley'
                [h1,h2]=cruceAckley(a,b);
                assert(isequal(mutacionAckley(a,0,.05,[-10 10]),a));
                m1=mutacionAckley(h1,1,.5,[-10 10]);
                m2=mutacionAckley(h2,1,.5,[-10 10]);
            case 'inventario'
                [h1,h2]=cruceInventario(a,b,datos);
                assert(isequal(mutacionInventario(a,0,.05,datos),a));
                m1=mutacionInventario(h1,1,.5,datos);
                m2=mutacionInventario(h2,1,.5,datos);
        end
        validarPoblacion([h1;h2],problemas{p},cfg,datos);
        validarPoblacion([m1;m2],problemas{p},cfg,datos);
    end
    for metodo={'elitismo','torneo','ruleta'}
        cfg.seleccion=metodo{1}; cfg.iteraciones=10;
        r=algoritmoGenetico(problemas{p},cfg);
        assert(size(r.poblacionFinal,1)==cfg.poblacion);
        assert(all(diff(r.historial)<=1e-12));
        v=evaluarPoblacion(r.mejorIndividuo,problemas{p},cfg,datos);
        assert(abs(v-r.mejorValor)<1e-10*max(1,v));
    end
end
x=[16000 16000 16000 16000 datos.maxS datos.maxK];
x=repararInventario(x,datos);
validarPoblacion(x,'inventario',cfg,datos);
disp('Todas las pruebas de fases finalizaron correctamente.');
end
