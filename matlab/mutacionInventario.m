function x = mutacionInventario(x,pm,magnitud,datos)
if rand()<pm
    j=randi(14);
    rangos=[repmat(datos.maxQ-datos.minQ,1,4),datos.maxS,datos.maxK];
    x(j)=x(j)+magnitud*rangos(j)*randn();
    x=repararInventario(x,datos);
end
end
