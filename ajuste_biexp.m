%prueba de ajuste biexponencial con la herramienta fittype
%vamos a intentar convertirlo en una función utilizable en otros scripts

function[ajuste,estadistica,coeficientes] = ajuste_biexp(t,D)

biexponential_fit = fittype('A*(exp(-lambda*t))+B*(exp(-lambda2*t))',...
  'independent','t','dependent', 'D' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 0 0 0]; %estos parametros todavia no se muy bien como funcionan pero supongo que habría que 
opts.StartPoint = [0.2 0.2 0.2 0.2]; %chinchonearlos para que funcionases como el solver
opts.Upper = [1,1,1,1];

[ajuste, estadistica] = fit( t, D, biexponential_fit, opts ); 
coeficientes = coeffvalues(ajuste);

end