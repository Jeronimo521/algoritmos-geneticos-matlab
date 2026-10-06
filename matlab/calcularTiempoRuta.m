function tiempo = calcularTiempoRuta(ruta, T, regreso)
if nargin < 3, regreso = false; end
if ~isvector(ruta) || numel(ruta) ~= 13 || ...
        ~isequal(sort(ruta(:)'),1:13)
    tiempo = inf; return;
end
ruta = ruta(:)';
indices = sub2ind(size(T),ruta(1:end-1),ruta(2:end));
tiempo = sum(T(indices));
if regreso, tiempo = tiempo + T(ruta(end),ruta(1)); end
end
