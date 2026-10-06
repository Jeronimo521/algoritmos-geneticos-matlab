function valor = calcularAckley(x, limites)
if nargin < 2, limites = [-10 10]; end
if isempty(x) || ~isvector(x) || ~isreal(x) || ...
        any(~isfinite(x)) || any(x < limites(1) | x > limites(2))
    valor = inf; return;
end
valor = -20*exp(-0.2*sqrt(mean(x.^2))) ...
    - exp(mean(cos(2*pi*x))) + 20 + 3;
end
