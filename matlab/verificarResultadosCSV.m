function verificarResultadosCSV()
raiz=fullfile(fileparts(mfilename('fullpath')),'..','resultados_matlab');
T=readtable(fullfile(raiz,'resumen_completo.csv'),'TextType','string', ...
    'Delimiter',',','ReadVariableNames',true,'VariableNamingRule','preserve');
R=readtable(fullfile(raiz,'corridas.csv'),'TextType','string', ...
    'Delimiter',',','ReadVariableNames',true,'VariableNamingRule','preserve');
datos=datosProblemas(); base=configuracion();
assert(height(T)==59 && height(R)==295);
assert(numel(unique(T.id))==height(T));
assert(all(ismember(R.id,T.id)));
for i=1:height(T)
    filas=R(R.id==T.id(i),:);
    assert(height(filas)==T.pruebas(i) && T.pruebas(i)>=5);
    assert(isequal(sort(filas.repeticion)',1:T.pruebas(i)));
    assert(all(filas.seleccion==T.seleccion(i)));
    for nombre={'iteraciones','dimensiones','pm','magnitud'}
        campo=nombre{1}; assert(all(filas.(campo)==T.(campo)(i)));
    end
    y=filas.objetivo; tiempos=filas.tiempo_s;
    comprobar(T.mejor(i),min(y)); comprobar(T.media(i),mean(y));
    comprobar(T.desviacion(i),std(y)); comprobar(T.tiempo_medio_s(i),mean(tiempos));
    if ismember('tiempo_desviacion_s',T.Properties.VariableNames)
        comprobar(T.tiempo_desviacion_s(i),std(tiempos));
    end
    assert(all(isfinite(y) & y>0) && all(isfinite(tiempos) & tiempos>0));
    cfg=base; cfg.dimensiones=T.dimensiones(i);
    for rep=1:height(filas)
        x=leerVector(filas.individuo(rep));
        validarPoblacion(x,T.problema(i),cfg,datos);
        comprobar(evaluarPoblacion(x,T.problema(i),cfg,datos),y(rep));
    end
    x=leerVector(T.individuo(i));
    validarPoblacion(x,T.problema(i),cfg,datos);
    comprobar(evaluarPoblacion(x,T.problema(i),cfg,datos),T.mejor(i));
    [~,j]=min(y); assert(isequal(x,leerVector(filas.individuo(j))));
    if T.problema(i)=="ackley"
        comprobar(T.rmse(i),sqrt(mean((y-(3-exp(1))).^2)));
    end
end
disp('59 configuraciones y 295 corridas CSV verificadas.');
end

function x=leerVector(texto)
texto=strtrim(char(texto));
assert(~isempty(regexp(texto,'^\[[0-9eE+\-.\s]+\]$','once')),'Vector CSV invalido.');
x=sscanf(texto(2:end-1),'%f')';
assert(~isempty(x) && all(isfinite(x)));
end

function comprobar(a,b)
assert(abs(a-b)<=1e-9*max(1,abs(b)),'Los resultados CSV no coinciden.');
end
