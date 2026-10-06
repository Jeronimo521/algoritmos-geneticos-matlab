function resumen = experimentos()
addpath(fileparts(mfilename('fullpath')));
base=configuracion(); problemas={'viajero','ackley','inventario'};
metodos={'elitismo','torneo','ruleta'};
carpeta=fullfile(fileparts(mfilename('fullpath')),'..','resultados_matlab');
if ~exist(carpeta,'dir'), mkdir(carpeta); end
resumen=struct([]); corridas=struct([]); contador=0;
for p=1:3
    cfg=base; cfg.semilla=base.semilla+p*1000;
    filas=struct([]);
    for j=1:3
        cfg.seleccion=metodos{j};
        ejecutar('seleccion',problemas{p},cfg);
        filas=[filas,resumen(end)];
    end
    [~,j]=min([filas.media]); cfg.seleccion=filas(j).seleccion;
    filas=struct([]);
    for it=base.iteracionesPrueba
        cfg.iteraciones=it; ejecutar('iteraciones',problemas{p},cfg);
        filas=[filas,resumen(end)];
    end
    calidad=[filas.media];
    if strcmp(problemas{p},'ackley'), calidad=[filas.rmse]; end
    j=find(calidad<=1.05*min(calidad)+1e-12,1);
    cfg.iteraciones=filas(j).iteraciones;
    filas=struct([]);
    for pm=base.pmPrueba
        magnitudes=base.magnitudPrueba;
        if strcmp(problemas{p},'viajero') || pm==0, magnitudes=base.magnitud; end
        for mag=magnitudes
            cfg.pm=pm; cfg.magnitud=mag;
            ejecutar('mutacion',problemas{p},cfg);
            filas=[filas,resumen(end)];
        end
    end
    [~,j]=min([filas.media]); cfg.pm=filas(j).pm; cfg.magnitud=filas(j).magnitud;
    if strcmp(problemas{p},'ackley')
        for d=base.dimensionesPrueba
            cfg.dimensiones=d; ejecutar('dimensiones',problemas{p},cfg);
        end
    end
end
T=struct2table(resumen); writetable(T,fullfile(carpeta,'resumen_completo.csv'));
R=struct2table(corridas); writetable(R,fullfile(carpeta,'corridas.csv'));
for p=1:3
    for estudio={'seleccion','iteraciones','mutacion','dimensiones'}
        filtro=strcmp(T.problema,problemas{p}) & strcmp(T.estudio,estudio{1});
        if any(filtro)
            writetable(T(filtro,:),fullfile(carpeta,[estudio{1},'_',problemas{p},'.csv']));
        end
    end
end
save(fullfile(carpeta,'experimentos.mat'),'resumen','corridas','base');
entorno.version=string(version); entorno.plataforma=string(computer);
entorno.fecha=string(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
entorno.calentamiento=base.calentamiento;
datosEntorno=datosProblemas(); entorno.normalizacionInventario=string(datosEntorno.normalizacion);
writetable(struct2table(entorno),fullfile(carpeta,'entorno.csv'));
fprintf('\nFinalizado: %d configuraciones y %d corridas.\n',numel(resumen),numel(corridas));
disp(['Resultados: ',carpeta]);

    function ejecutar(estudio,problema,config)
        contador=contador+1; valores=zeros(base.repeticiones,1);
        tiempos=valores; resultados=cell(base.repeticiones,1);
        mejor=inf; vector=[];
        if base.calentamiento
            calentamiento=config; calentamiento.semilla=config.semilla+1;
            algoritmoGenetico(problema,calentamiento);
        end
        for rep=1:base.repeticiones
            local=config; local.semilla=config.semilla+rep;
            r=algoritmoGenetico(problema,local); resultados{rep}=r;
            valores(rep)=r.mejorValor; tiempos(rep)=r.tiempo;
            if r.mejorValor<mejor, mejor=r.mejorValor; vector=r.mejorIndividuo; end
            c.id=sprintf('C%02d',contador); c.estudio=estudio; c.problema=problema;
            c.repeticion=rep; c.semilla=local.semilla; c.seleccion=config.seleccion;
            c.iteraciones=config.iteraciones; c.dimensiones=config.dimensiones;
            c.pm=config.pm; c.magnitud=config.magnitud;
            c.objetivo=r.mejorValor; c.tiempo_s=r.tiempo;
            c.individuo=mat2str(r.mejorIndividuo,17);
            corridas=[corridas,c];
        end
        s.id=sprintf('C%02d',contador); s.estudio=estudio; s.problema=problema;
        s.seleccion=config.seleccion; s.iteraciones=config.iteraciones;
        s.dimensiones=config.dimensiones; s.pm=config.pm; s.magnitud=config.magnitud;
        s.pruebas=base.repeticiones; s.tiempo_medio_s=mean(tiempos);
        s.tiempo_desviacion_s=std(tiempos);
        s.mejor=mejor; s.media=mean(valores); s.desviacion=std(valores);
        s.rmse=NaN;
        if strcmp(problema,'ackley'), s.rmse=sqrt(mean((valores-(3-exp(1))).^2)); end
        s.individuo=mat2str(vector,17);
        resumen=[resumen,s];
        save(fullfile(carpeta,[s.id,'.mat']),'resultados','s');
        fprintf('%s %s %s: media=%.8g; mejor=%.8g\n',s.id,estudio,problema,s.media,s.mejor);
    end
end
