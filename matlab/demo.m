clear; clc;
addpath(fileparts(mfilename('fullpath')));
cfg=configuracion(); datos=datosProblemas();
problemas={'viajero','ackley','inventario'};
for p=1:3
    r=algoritmoGenetico(problemas{p},cfg);
    fprintf('\n%s: mejor = %.10g; tiempo = %.3f s\n',problemas{p},r.mejorValor,r.tiempo);
    disp(r.mejorIndividuo);
    if p==1
        disp(datos.nombres(r.mejorIndividuo));
    elseif p==3
        [Q,S,K]=decodificarInventario(r.mejorIndividuo,datos);
        disp('Filas Q, S y K (miles de COP):'); disp([Q;S;K]);
        fprintf('Presupuesto: %.8f\n',sum(Q/2+S));
    end
    figure('Name',problemas{p}); plot(0:cfg.iteraciones,r.historial,'LineWidth',1.5);
    xlabel('Generacion'); ylabel('Mejor objetivo observado'); grid on;
    title(problemas{p});
end
