function poblacion = generarPoblacionInventario(n,datos)
poblacion=zeros(n,14);
for i=1:n
    S=rand(1,5).*datos.maxS;
    K=rand(1,5).*datos.maxK;
    disponible=2*(datos.I-sum(S));
    pesos=-log(max(rand(1,5),realmin));
    Q=datos.minQ+(disponible-5*datos.minQ)*pesos/sum(pesos);
    poblacion(i,:)=[Q(1:4),S,K];
end
end
