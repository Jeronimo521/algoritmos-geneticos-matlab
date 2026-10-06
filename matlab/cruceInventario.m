function [h1,h2] = cruceInventario(p1,p2,datos)
mascara=rand(1,14)<0.5;
h1=p1; h2=p2;
h1(mascara)=p2(mascara); h2(mascara)=p1(mascara);
h1=repararInventario(h1,datos); h2=repararInventario(h2,datos);
end
