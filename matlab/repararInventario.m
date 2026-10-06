function x = repararInventario(x,datos)
x=x(:)';
x(5:9)=min(max(x(5:9),0),datos.maxS);
x(10:14)=min(max(x(10:14),0),datos.maxK);
q=min(max(x(1:4),datos.minQ),datos.maxQ);
disponible=2*(datos.I-sum(x(5:9)));
if sum(q)>disponible-10*datos.minQ
    exceso=q-datos.minQ;
    q=datos.minQ+exceso/sum(exceso)*(disponible-14*datos.minQ);
end
x(1:4)=q;
end
