function indices = seleccionTorneo(valores,grupo)
if nargin<2, grupo=4; end
n=numel(valores);
assert(mod(grupo,2)==0 && grupo>=2 && mod(n,grupo)==0);
orden=randperm(n); indices=zeros(n/2,1); k=1;
for i=1:grupo:n
    candidatos=orden(i:i+grupo-1);
    [~,ganadores]=sort(valores(candidatos));
    indices(k:k+grupo/2-1)=candidatos(ganadores(1:grupo/2));
    k=k+grupo/2;
end
end
