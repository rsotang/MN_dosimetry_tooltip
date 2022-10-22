% % Cálculo de dosis %%
% Vamos a usar la herramienta de ROIs, y el creador de kernel para hacer
% una herramienta de cálculo de dosis, esta primera versíon funciona con
% dos imágenes planares y el método de la imagen conjugada. 
% 
% SE REQUIERE DEL SCRIPT DEL CREACIÓN DE KERNELS DE VALOR S Y EL ARCHVIO
% BASE DE DATOS S_VOXEL PARA ESTE.

clear, clc, close all;
 %   Lectura de imagenes           
%msgbox("Selecciona imagen AP");
[filename, pathname] = uigetfile('*.dcm', 'open image');%


if isequal(filename, 0) || isequal(pathname, 0)   
    disp('Image input canceled.');  
   im_AP = [];    map_AP = []; 
else
    [im_AP,map_AP]=dicomread(fullfile(pathname, filename));
end

%msgbox("Selecciona imagen PA");
[filename, pathname] = uigetfile('*.dcm', 'open image');%


if isequal(filename, 0) || isequal(pathname, 0)   
    disp('Image input canceled.');  
   im_PA = [];    map_PA = []; 
else
    [im_PA,map_PA]=dicomread(fullfile(pathname, filename));
end

%%------------Dibujo de ROI AP ----------%% 
%Lo ideal sería poder dibujar varias ROIS, para poder dibujar los dos
%riñones simultaneamente, o portar el codigo al script de transaxiales para
%poder dibujar las lesiones. Estoy intentando aprender como funciona
%CROIEditor y modeandolo para que funcione con imagenes DICOM, pero llevará
%bastante trabajo.

%en vez de dibujar dos veces los riñones y conjugarlos, vamos a conjugar
%las imagenes y dibujar cada riñon por separado para ahorrar tiempo.
limite_bucle= size(im_AP);
conj=[limite_bucle(1,1),limite_bucle(1,2)]; %predefino el tamaño en vez de hacerlo de forma dinamica para optimizar el programa
for i=1:limite_bucle(1,1)
    for j=1:limite_bucle(1,2)
      conj(i,j) = sqrt(double(im_AP(i,j))* double(im_PA(i,j)));
    end
end
imshow(conj,[])                            

conj_izq=double(conj);
h_im = imshow(conj_izq,[]),title('Dibuja ROI izquierda');
ROI_izq = drawfreehand;

BW = createMask(ROI_izq,h_im);
ROI_izq=conj_izq.*BW;
% figure,imshow(ROI_AP,[]);
im_DIF=conj_izq-ROI_izq;
conj_izq=conj_izq-ROI_izq;
% figure,imshow(im_DIF,[]);
ROI_izq=uint8(ROI_izq);im_DIF=uint8(im_DIF);
dicomwrite(ROI_izq,'ROI_izq.dcm');
dicomwrite(im_DIF,'diff_AP.dcm');
close;

conj_der=double(conj);
h_im = imshow(conj_der,[]),title('Dibuja ROI derecha ');
ROI_der = drawfreehand;

BW = createMask(ROI_der,h_im);
ROI_der=conj_der.*BW;
% figure,imshow(ROI_AP,[]);
im_DIF=conj_der-ROI_der;
conj_der=conj_der-ROI_der;
% figure,imshow(im_DIF,[]);
ROI_der=uint8(ROI_der);im_DIF=uint8(im_DIF);
dicomwrite(ROI_der,'ROI_der.dcm');
dicomwrite(im_DIF,'diff_PA.dcm');

close;


%%-----------------CÁLCULOS--------------%%
%En el caso de las planares habría que aplicar el método de la imagen
%conjugada. En este caso hemos hecho la raiz cuadradad del producto de cada
%valor de pixel. Además hay que dividir las cuentas de cada imagen despues
%de la convolución por el tiempo de imagen, para tener una tasa de dosis
%que integrar en el reajuste

run("S_kernel.m");

ROI_izq=dicomread('ROI_izq.dcm');
ROI_der=dicomread('ROI_der.dcm');

kernel= S_kernel_completo(:,:,6); %suponemos imagen plana, solo cogemos el slice central del voxel.
sens_planar = 0.039; %CAMBIAR POR INPUT DE SENSIBILIDAD
dosis_izq = conv2(kernel,ROI_izq.*sens_planar); %NO HABRÍA QUE TENER EN CUENTA EL ESPESOR DEL PACIENTE??????????
dosis_der = conv2(kernel,ROI_der.*sens_planar); %???????????????????????????????????????????????????????????????

%podría intentar castear la imagen a uint8 para escribirla como dicom, pero
%realmente no necesito un archivo de dosis en imagen para visualizar, solo
%necesito hacer el conteo de valores en cada pixel como si fuese una matriz
%de información.

limite_bucle= size(dosis_izq);
value_dosis_izq = 0;
for i=1:limite_bucle(1,1)
    for j=1:limite_bucle(1,2)
        value_dosis_izq = value_dosis_izq + dosis_izq(i,j);
    end
end
value_dosis_izq=value_dosis_izq/1800; %el tiempo de adquisición, tengo que adquirir la info de forma automatica de la etiqueta DICOM
limite_bucle= size(dosis_der);
value_dosis_der = 0;
for i=1:limite_bucle(1,1)
    for j=1:limite_bucle(1,2)
        value_dosis_der = value_dosis_der + dosis_der(i,j);
    end
end
value_dosis_der=value_dosis_der/1800;

% Dosis_total = sqrt(value_dosis_izq * value_dosis_der);
%msgbox(sprintf('Dosis en riñon izquierdo: %d \n Dosis en riñón derecho: %d',value_dosis_izq,value_dosis_der));

%-----------------Añadimos el resto de imágenes --------------------%

%Ahora repetimos el mismo proceso para las otras dos imagenes para poder
%hacer el fitting

%HAY QUE OPTIMIZAR ESTO EN UNA FUNCIÓN PARA QUE NO SEA TAN FARRAGOSO A
%NIVEL DE CODIGO



%----------------------IMAGEN 2-------------------------------------%
% msgbox("Selecciona segunda secuencia de imagenes");
[filename, pathname] = uigetfile('*.dcm', 'open image');%



if isequal(filename, 0) || isequal(pathname, 0)   
    disp('Image input canceled.');  
   im_AP2 = [];    map_AP2 = []; 
else
    [im_AP2,map_AP2]=dicomread(fullfile(pathname, filename));
end

[filename, pathname] = uigetfile('*.dcm', 'open image');%


if isequal(filename, 0) || isequal(pathname, 0)   
    disp('Image input canceled.');  
   im_PA2 = [];    map_PA2 = []; 
else
    [im_PA2,map_PA2]=dicomread(fullfile(pathname, filename));
end

%%%%%%%%%%%%%%%%%%%AJUSTE PARA PRUEBAS%%%%%%%%%%%%%%%BORRAR DESPUÉS
im_AP2 = im_AP2.*0.45;
im_PA2 = im_PA2.*0.45;
%%%%%%%%%%%%%%%%%%%AJUSTE PARA PRUEBAS%%%%%%%%%%%%%%%BORRAR DESPUÉS
limite_bucle= size(im_AP2);
conj=[limite_bucle(1,1),limite_bucle(1,2)]; 
for i=1:limite_bucle(1,1)
    for j=1:limite_bucle(1,2)
      conj(i,j) = sqrt(double(im_AP2(i,j))* double(im_PA2(i,j)));
    end
end
imshow(conj,[])                            

conj_izq=double(conj);
h_im = imshow(conj_izq,[]),title('Dibuja ROI izquierda');
ROI_izq2 = drawfreehand;

BW = createMask(ROI_izq2,h_im);
ROI_izq2=conj_izq.*BW;
% figure,imshow(ROI_AP,[]);
im_DIF=conj_izq-ROI_izq2;
conj_izq=conj_izq-ROI_izq2;
% figure,imshow(im_DIF,[]);
ROI_izq2=uint8(ROI_izq2);im_DIF=uint8(im_DIF);
dicomwrite(ROI_izq2,'ROI_izq2.dcm');
dicomwrite(im_DIF,'diff_AP2.dcm');
close;

conj_der=double(conj);
h_im = imshow(conj_der,[]),title('Dibuja ROI derecha ');
ROI_der2 = drawfreehand;

BW = createMask(ROI_der2,h_im);
ROI_der2=conj_der.*BW;
% figure,imshow(ROI_AP,[]);
im_DIF=conj_der-ROI_der2;
conj_der=conj_der-ROI_der2;
% figure,imshow(im_DIF,[]);
ROI_der2=uint8(ROI_der2);im_DIF=uint8(im_DIF);
dicomwrite(ROI_der2,'ROI_der2.dcm');
dicomwrite(im_DIF,'diff_PA.dcm');

close;

ROI_izq2=dicomread('ROI_izq2.dcm');
ROI_der2=dicomread('ROI_der2.dcm');

kernel= S_kernel_completo(:,:,6);
sens_planar = 0.039; 
dosis_izq2 = conv2(kernel,ROI_izq2.*sens_planar); 
dosis_der2 = conv2(kernel,ROI_der2.*sens_planar); 


limite_bucle= size(dosis_izq2);
value_dosis_izq2 = 0;
for i=1:limite_bucle(1,1)
    for j=1:limite_bucle(1,2)
        value_dosis_izq2 = value_dosis_izq2 + dosis_izq2(i,j);
    end
end
value_dosis_izq2=value_dosis_izq2/1800; 
limite_bucle= size(dosis_der2);
value_dosis_der2 = 0;
for i=1:limite_bucle(1,1)
    for j=1:limite_bucle(1,2)
        value_dosis_der2 = value_dosis_der2 + dosis_der2(i,j);
    end
end
value_dosis_der2=value_dosis_der2/1800; 



%----------------------IMAGEN 3-------------------------------------%
% msgbox("Selecciona tercera secuencia de imagenes");
[filename, pathname] = uigetfile('*.dcm', 'open image');%



if isequal(filename, 0) || isequal(pathname, 0)   
    disp('Image input canceled.');  
   im_AP3 = [];    map_AP3 = []; 
else
    [im_AP3,map_AP3]=dicomread(fullfile(pathname, filename));
end

[filename, pathname] = uigetfile('*.dcm', 'open image');%


if isequal(filename, 0) || isequal(pathname, 0)   
    disp('Image input canceled.');  
   im_PA3 = [];    map_PA3 = []; 
else
    [im_PA3,map_PA3]=dicomread(fullfile(pathname, filename));
end

%%%%%%%%%%%%%%%%%%%AJUSTE PARA PRUEBAS%%%%%%%%%%%%%%%BORRAR DESPUÉS
im_AP3 = im_AP3.*0.115;
im_PA3 = im_PA3.*0.115;
%%%%%%%%%%%%%%%%%%%AJUSTE PARA PRUEBAS%%%%%%%%%%%%%%%BORRAR DESPUÉS

limite_bucle= size(im_AP3);
conj=[limite_bucle(1,1),limite_bucle(1,2)]; 
for i=1:limite_bucle(1,1)
    for j=1:limite_bucle(1,2)
      conj(i,j) = sqrt(double(im_AP3(i,j))* double(im_PA3(i,j)));
    end
end
imshow(conj,[])                            

conj_izq=double(conj);
h_im = imshow(conj_izq,[]),title('Dibuja ROI izquierda');
ROI_izq3 = drawfreehand;

BW = createMask(ROI_izq3,h_im);
ROI_izq3=conj_izq.*BW;
% figure,imshow(ROI_AP,[]);
im_DIF=conj_izq-ROI_izq3;
conj_izq=conj_izq-ROI_izq3;
% figure,imshow(im_DIF,[]);
ROI_izq3=uint8(ROI_izq3);im_DIF=uint8(im_DIF);
dicomwrite(ROI_izq3,'ROI_izq3.dcm');
dicomwrite(im_DIF,'diff_AP3.dcm');
close;

conj_der=double(conj);
h_im = imshow(conj_der,[]),title('Dibuja ROI derecha ');
ROI_der3 = drawfreehand;

BW = createMask(ROI_der3,h_im);
ROI_der3=conj_der.*BW;
% figure,imshow(ROI_AP,[]);
im_DIF=conj_der-ROI_der3;
conj_der=conj_der-ROI_der3;
% figure,imshow(im_DIF,[]);
ROI_der3=uint8(ROI_der3);im_DIF=uint8(im_DIF);
dicomwrite(ROI_der3,'ROI_der3.dcm');
dicomwrite(im_DIF,'diff_PA.dcm');

close;

ROI_izq3=dicomread('ROI_izq3.dcm');
ROI_der3=dicomread('ROI_der3.dcm');

kernel= S_kernel_completo(:,:,6);
sens_planar = 0.039; 
dosis_izq3 = conv2(kernel,ROI_izq3.*sens_planar); 
dosis_der3 = conv2(kernel,ROI_der3.*sens_planar); 


limite_bucle= size(dosis_izq);
value_dosis_izq3 = 0;
for i=1:limite_bucle(1,1)
    for j=1:limite_bucle(1,2)
        value_dosis_izq3 = value_dosis_izq3 + dosis_izq3(i,j);
    end
end
value_dosis_izq3=value_dosis_izq3/1800; 
limite_bucle= size(dosis_der3);
value_dosis_der3 = 0;
for i=1:limite_bucle(1,1)
    for j=1:limite_bucle(1,2)
        value_dosis_der3 = value_dosis_der3 + dosis_der3(i,j);
    end
end
value_dosis_der3=value_dosis_der3/1800; 

% breakpoint1:
% dosis_total = value_dosis_der3+value_dosis_der2+value_dosis_der + value_dosis_izq3 +value_dosis_izq+value_dosis_izq2;
% msgbox(sprintf('dosis total = %d', dosis_total));



%----------------AJUSTE BIEXP Y CÁLCULO FINAL------------%
%Hay que añadir la parte para extrapolar el valor inicial de la actividad
%en el riñon, ya no solo por que el ajuste esté bien hecho, si no por que
%el modelo de fit no funciona con menos de 4 datos.

t= [0;86400;345600;604800]; %datos al tuntún, EN SEGUNDOS PARA QUE SALGA BIEN EL CALCULO, 
D_kidney_izq=[1;value_dosis_izq;value_dosis_izq2;value_dosis_izq3];             %sustituir tiempo por extracción de fecha de
D_kidney_der=[1;value_dosis_der;value_dosis_der2;value_dosis_der3];             %etiqueta DICOM 
%no es espanglish, es que no puedo poner la ñ

biexponential_fit = fittype('A*(exp(-lambda*t))+B*(exp(-lambda2*t))',...
  'independent','t','dependent', 'D' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 0 0 0]; %estos parametros todavia no se muy bien como funcionan pero supongo que habría que 
opts.StartPoint = [0.1 0.1 0.1 0.1]; %chinchonearlos para que funcionases como el solver

% [ajuste_kidney_der, info_estadistica_der] = fit( t, D_kidney_der, biexponential_fit, opts ); 
[ajuste_kidney_izq, info_estadistica_izq] = fit( t, D_kidney_izq, biexponential_fit, opts ); 

plot(ajuste_kidney_izq,t,D_kidney_izq);
% plot(ajuste_kidney_der,t,D_kidney_der);



