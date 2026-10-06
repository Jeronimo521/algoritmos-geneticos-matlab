function prepararResultados()
raiz=fullfile(fileparts(mfilename('fullpath')),'..');
carpeta=fullfile(raiz,'resultados_matlab');
assert(isfile(fullfile(carpeta,'experimentos.mat')), ...
    'Primero ejecuta experimentos para generar los archivos MAT. Para comprobar los CSV publicados, ejecuta verificarResultadosCSV.');
archivo=load(fullfile(carpeta,'experimentos.mat'));
resumen=archivo.resumen; corridas=archivo.corridas; base=archivo.base;
assert(numel(resumen)==59 && numel(corridas)==295);
datos=datosProblemas(); registros=struct([]); elegidas=struct();
for i=1:numel(resumen)
    s=resumen(i); guardado=load(fullfile(carpeta,[s.id,'.mat']));
    resultados=guardado.resultados;
    y=zeros(5,1); t=y;
    for rep=1:5
        r=resultados{rep}; cfg=r.configuracion;
        validarPoblacion(r.poblacionFinal,s.problema,cfg,datos);
        validarPoblacion(r.mejorIndividuo,s.problema,cfg,datos);
        f=evaluarPoblacion(r.mejorIndividuo,s.problema,cfg,datos);
        assert(abs(f-r.mejorValor)<1e-9*max(1,f));
        assert(numel(r.historial)==cfg.iteraciones+1);
        assert(all(diff(r.historial)<=1e-12));
        assert(r.historial(end)==r.mejorValor && r.tiempo>0);
        y(rep)=r.mejorValor; t(rep)=r.tiempo;
        c.id=s.id; c.estudio=s.estudio; c.problema=s.problema;
        c.repeticion=rep; c.semilla=cfg.semilla; c.seleccion=cfg.seleccion;
        c.iteraciones=cfg.iteraciones; c.dimensiones=cfg.dimensiones;
        c.pm=cfg.pm; c.magnitud=cfg.magnitud;
        c.mejor=r.mejorValor; c.individuo=r.mejorIndividuo;
        c.historial=r.historial'; c.tiempo_s=r.tiempo;
        registros=[registros,c];
    end
    assert(abs(s.media-mean(y))<1e-10);
    assert(abs(s.desviacion-std(y))<1e-10);
    assert(s.mejor==min(y));
    assert(abs(s.tiempo_medio_s-mean(t))<1e-10);
    if strcmp(s.problema,'ackley')
        assert(abs(s.rmse-sqrt(mean((y-(3-exp(1))).^2)))<1e-12);
    end
    [~,j]=min(y); resumen(i).individuo=resultados{j}.mejorIndividuo;
end
problemas={'viajero','ackley','inventario'};
for p=1:3
    problema=problemas{p}; cfg=base; cfg.semilla=base.semilla+p*1000;
    filas=resumen(strcmp({resumen.problema},problema) & strcmp({resumen.estudio},'seleccion'));
    [~,j]=min([filas.media]); cfg.seleccion=filas(j).seleccion;
    filas=resumen(strcmp({resumen.problema},problema) & strcmp({resumen.estudio},'iteraciones'));
    calidad=[filas.media];
    if strcmp(problema,'ackley'), calidad=[filas.rmse]; end
    j=find(calidad<=1.05*min(calidad)+1e-12,1); cfg.iteraciones=filas(j).iteraciones;
    filas=resumen(strcmp({resumen.problema},problema) & strcmp({resumen.estudio},'mutacion'));
    [~,j]=min([filas.media]); cfg.pm=filas(j).pm; cfg.magnitud=filas(j).magnitud;
    elegidas.(problema)=cfg;
end
exportado.resumen=resumen; exportado.corridas=registros; exportado.elegidas=elegidas;
guardarJSON(fullfile(carpeta,'datos.json'),exportado);
entorno.motor='MATLAB nativo'; entorno.version=version; entorno.plataforma=computer;
entorno.configuraciones=numel(resumen); entorno.corridas=numel(registros);
entorno.normalizacionInventario=datos.normalizacion;
entorno.validacionesPorFase=true;
guardarJSON(fullfile(carpeta,'entorno.json'),entorno);

graficas=fullfile(carpeta,'graficas');
if ~exist(graficas,'dir'), mkdir(graficas); end
colores=[.09 .38 .49;.76 .48 .13;.40 .34 .60];
metodos={'elitismo','torneo','ruleta'};
for p=1:3
    problema=problemas{p};
    fig=figure('Visible','off','Color','w','Position',[100 100 1060 340]);
    ax=axes(fig,'Color','w','XColor','k','YColor','k');
    hold(ax,'on'); lineas=gobjects(1,3);
    for m=1:3
        s=resumen(strcmp({resumen.problema},problema) & ...
            strcmp({resumen.estudio},'seleccion') & strcmp({resumen.seleccion},metodos{m}));
        guardado=load(fullfile(carpeta,[s.id,'.mat']));
        h=zeros(5,101);
        for rep=1:5, h(rep,:)=guardado.resultados{rep}.historial'; end
        if strcmp(problema,'ackley'), h=max(h-(3-exp(1)),1e-14); end
        g=0:100;
        fill(ax,[g,fliplr(g)],[min(h,[],1),fliplr(max(h,[],1))],colores(m,:), ...
            'FaceAlpha',.10,'EdgeColor','none','HandleVisibility','off');
        lineas(m)=plot(ax,g,mean(h,1),'Color',colores(m,:),'LineWidth',1.5);
    end
    xlabel(ax,'Generacion');
    if strcmp(problema,'ackley')
        ylabel(ax,'Error frente a 3 - e'); set(ax,'YScale','log');
    elseif strcmp(problema,'viajero'), ylabel(ax,'Tiempo de ruta (min)');
    else, ylabel(ax,'Pedidos no atendidos Z'); end
    lg=legend(ax,lineas,metodos,'Location','northeast','Orientation','horizontal');
    lg.Color='w'; lg.TextColor='k'; lg.EdgeColor=[.7 .7 .7];
    ax.XLabel.Color='k'; ax.YLabel.Color='k'; ax.GridColor=[.6 .6 .6];
    grid(ax,'on'); ax.FontSize=11;
    exportgraphics(fig,fullfile(graficas,['convergencia_',problema,'.png']), ...
        'Resolution',240,'BackgroundColor','white');
    savefig(fig,fullfile(graficas,['convergencia_',problema,'.fig'])); close(fig);
end
filas=resumen(strcmp({resumen.estudio},'dimensiones'));
fig=figure('Visible','off','Color','w','Position',[100 100 1060 360]);
ax=axes(fig,'Color','w','XColor','k','YColor','k');
loglog(ax,[filas.dimensiones],[filas.rmse],'o-','LineWidth',1.5);
ax.Color='w'; ax.XColor='k'; ax.YColor='k';
xticks(ax,[2 3 10 20 50 100]); xticklabels(ax,{'2','3','10','20','50','100'});
xlabel(ax,'Dimensiones de Ackley'); ylabel(ax,'RMSE frente a 3 - e');
grid(ax,'on'); ax.FontSize=11;
ax.XLabel.Color='k'; ax.YLabel.Color='k'; ax.GridColor=[.6 .6 .6];
exportgraphics(fig,fullfile(graficas,'dimensiones_ackley.png'), ...
    'Resolution',240,'BackgroundColor','white');
savefig(fig,fullfile(graficas,'dimensiones_ackley.fig')); close(fig);
carpetaVerificacion=fullfile(raiz,'verificacion');
if ~exist(carpetaVerificacion,'dir'), mkdir(carpetaVerificacion); end
f=fopen(fullfile(carpetaVerificacion,'auditoria_matlab.txt'),'w','n','UTF-8');
assert(f~=-1,'No se pudo abrir el archivo de auditoria.');
fprintf(f,'MATLAB %s\n',version);
fprintf(f,'59 configuraciones y 295 corridas verificadas.\n');
fprintf(f,'Objetivos, restricciones, vectores, medias, desviaciones, RMSE e historiales correctos.\n');
fprintf(f,'Cuatro graficas generadas directamente en MATLAB, con fuentes FIG editables.\n');
fclose(f);
disp('295 corridas verificadas; JSON y cuatro graficas MATLAB generados.');
end

function guardarJSON(path,datos)
f=fopen(path,'w','n','UTF-8');
assert(f~=-1,'No se pudo abrir el archivo de salida.');
limpieza=onCleanup(@() fclose(f));
fprintf(f,'%s',jsonencode(datos,'PrettyPrint',true));
end
