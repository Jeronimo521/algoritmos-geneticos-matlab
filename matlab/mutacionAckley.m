function x = mutacionAckley(x,pm,magnitud,limites)
if rand()<pm
    j=randi(numel(x));
    x(j)=x(j)+magnitud*(limites(2)-limites(1))*randn();
    x(j)=min(max(x(j),limites(1)),limites(2));
end
end
