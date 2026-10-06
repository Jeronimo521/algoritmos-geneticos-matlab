function [h1,h2] = cruceViajero(p1,p2)
n=numel(p1); cortes=sort(randperm(n,2));
h1=ox(p1,p2,cortes(1),cortes(2));
h2=ox(p2,p1,cortes(1),cortes(2));
end
function hijo = ox(p1,p2,a,b)
n=numel(p1); hijo=zeros(1,n); hijo(a:b)=p1(a:b);
orden=[b+1:n,1:b]; posiciones=orden(hijo(orden)==0);
genes=p2(orden); genes=genes(~ismember(genes,p1(a:b)));
hijo(posiciones)=genes;
end
