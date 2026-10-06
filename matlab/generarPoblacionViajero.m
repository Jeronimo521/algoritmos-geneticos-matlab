function poblacion = generarPoblacionViajero(n, fijarInicio)
if nargin<2, fijarInicio=false; end
poblacion=zeros(n,13);
for i=1:n
    if fijarInicio, poblacion(i,:)=[1,randperm(12)+1];
    else, poblacion(i,:)=randperm(13); end
end
end
