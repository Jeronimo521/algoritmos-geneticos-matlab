function Z = calcularInventario(Q,S,K,datos,metodo)
if nargin < 5, metodo = 'analitico'; end
Q=Q(:)'; S=S(:)'; K=K(:)';
if numel(Q)~=5 || numel(S)~=5 || numel(K)~=5 || ...
        ~isreal([Q S K]) || any(~isfinite([Q S K])) || ...
        any(Q<datos.minQ | Q>datos.maxQ) || ...
        any(S<0 | S>datos.maxS) || any(K<0 | K>datos.maxK) || ...
        abs(sum(Q/2+S)-datos.I)>datos.tolerancia
    Z=inf; return;
end
R=S+K;
assert(any(strcmp(datos.normalizacion,{'normal','literal'})), ...
    'La normalizacion debe ser normal o literal.');
factor=ones(1,5);
if strcmp(datos.normalizacion,'literal'), factor=sqrt(datos.sigma); end
switch lower(metodo)
    case 'analitico'
        z=(R-datos.mu)./datos.sigma;
        phi=exp(-0.5*z.^2)/sqrt(2*pi);
        cola=0.5*erfc(z/sqrt(2));
        faltante=datos.sigma.*phi+(datos.mu-R).*cola;
        Z=sum(datos.D./(Q.*datos.m).*factor.*max(faltante,0));
    case 'integral'
        Z=0;
        for i=1:5
            z=(R(i)-datos.mu(i))/datos.sigma(i);
            f=@(t) (datos.sigma(i)*t+datos.mu(i)-R(i)) ...
                .*exp(-t.^2/2)/sqrt(2*pi);
            faltante=integral(f,z,inf,'AbsTol',1e-9,'RelTol',1e-9);
            Z=Z+datos.D(i)/(Q(i)*datos.m(i))*factor(i)*faltante;
        end
    otherwise
        error('Metodo de inventario desconocido.');
end
end
