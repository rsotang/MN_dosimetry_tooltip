

% El script coge los archivos txt de valores S de voxel de la universidad
% de Bolonia y los convierte en un Kernel 3d para hacer convoluciones de
% dosis en los stacks transaxiales del SPECT de un paciente

% En este caso hemos cogido el archivo de Lu 177, es importante cambiar la
% primera linea del archivo ya que es información redundante que puede ir
% en el nombre del archivo y así se puede leer mas facilmente la
% información


t =table2array(readtable("S_voxel_Lu_177_4.42_mm.txt")); 
% El objeto table es distinto que array, pero la conversión a array es
% inmediata y no conlleva ninguna perdida de información de ningún
% tipo,simplemente me parece más eficiente leer el archivo de esta forma,
% en vez de hacer un bucle de lectura

% convertimos la tabla de coordenadas en un array con esos valores en sus
% coordenadas
S_kernel_octante = zeros(6,6,6);
counter = 1; 
for i =1:6
    for j = 1:6
        for k = 1:6
            S_kernel_octante(i,j,k)= t(counter,4);
            counter = counter+1;
        end
    end
end

% Ahora convertimos el kernel en forma de octante, en una matriz simetrica
% entorno a su centro

S_kernel_completo = zeros(11,11,11);

% notación octante x/vertical, y/horizontal, z/profundidad
% la notación es tan rara por como se definen los arrays de arriba a abajo
% y de delante a atrás (siendo lo normal en un sistema de coordenadas lo
% contrario)

% octante 1,1,1
for i=6:11
    for j=6:11
        for k=6:11
            S_kernel_completo(i,j,k)= S_kernel_octante (i-5,j-5,k-5);
        end
    end
end

% El flipped gira 180 grados entorno al centro del array con respecto a una
% de las dimensiones de este, siendo por defecto en torno a k
% octante 0,1,1
flipped110= flip(S_kernel_octante);
for i=1:6
    for j=6:11
        for k=6:11
           
            S_kernel_completo(i,j,k)=  flipped110(i,j-5,k-5);
        end
    end
end

% octante 1,0,1
flipped101= flip(S_kernel_octante,2);
for i=6:11
    for j=1:6
        for k=6:11            
            S_kernel_completo(i,j,k)= flipped101(i-5,j,k-5);
        end
    end
end

% octante 0,0,1
flipped001= flip(flip(S_kernel_octante ,2));
for i=1:6
    for j=1:6
        for k=6:11
            S_kernel_completo(i,j,k)= flipped001(i,j,k-5);
        end
    end
end

% octante 1,1,0
flipped110 = flip(S_kernel_octante ,3);
for i=6:11
    for j=6:11
        for k=1:6
            S_kernel_completo(i,j,k)=flipped110(i-5,j-5,k) ;
        end
    end
end

% octante 0,1,0
flipped000=flip(flip(S_kernel_octante ,3));
for i=1:6
    for j=6:11
        for k=1:6
            S_kernel_completo(i,j,k)= flipped000(i,j-5,k);
        end
    end
end

% octante 1,0,0
flipped100 = flip(flip(S_kernel_octante,3),2);
for i=6:11
    for j=1:6
        for k=1:6
            S_kernel_completo(i,j,k)= flipped100(i-5,j,k);
        end
    end
end

% octante 0,0,0
flipped000 = flip(flip(flip(S_kernel_octante,3),2));
for i=1:6
    for j=1:6
        for k=1:6
            S_kernel_completo(i,j,k)= flipped000(i,j,k);
        end
    end
end

% display(S_kernel_completo);
