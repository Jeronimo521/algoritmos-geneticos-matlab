function [Q,S,K] = decodificarInventario(x, datos)
assert(numel(x)==14,'Se requieren 14 variables independientes.');
x = x(:)';
S = x(5:9); K = x(10:14);
Q = [x(1:4), 2*(datos.I-sum(S))-sum(x(1:4))];
end
