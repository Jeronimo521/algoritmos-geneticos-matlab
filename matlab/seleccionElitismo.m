function indices = seleccionElitismo(valores)
[~,orden]=sort(valores);
indices=orden(1:numel(valores)/2);
end
