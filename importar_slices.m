function stackSLICES = importar_slices()
%importamos primera slice, la idea es imitar la funcion de importar
%secuencia de imageJ
[filename, pathname] = uigetfile('*.dcm', 'open image');
if isequal(filename, 0) || isequal(pathname, 0)   
    disp('Image input canceled.');  
   frame1 = [];    map_AP = []; 
   return
else
    [frame1,map1]=dicomread(fullfile(pathname, filename));
end
%vamos a importar el resto de slices haciendo parsing del nombre del
%archivo e intentando importar numeros más altos, asi no dependemos de
%meter el tamaño del stack manualmente ni de una etiqueta DICOM que se
%puede romper.
%el stack hay que definirlo dinamicamente si o si, aunque sea mucho más
%lento
stackTAC=[];
stackTAC(:,:,1)=frame1;
%parsing, podria utilizar regexp pero lo tengo oxidadisimo y no soy tan
%listo, así que hago esta chapuza de parsing y pista

filename=string(filename);
nombre_parsed=split(filename,'_');
num=split(nombre_parsed(2),'');
slice_number=str2double(num(2));

%hago un bucle infinito en el que busca archivos con el mismo nombre y un
%numero al final HAY QUE TENER CUIDADO POR SI EL NOMBRE TIENE MÁS DE UNA _
%EN EL NOMBRE. cuando el archivo ya no existe llama a un error por eso el
%bucle va con un try/catch. cuando sale el ME (mensaje de error) busca su
%identificador  y rompe el bucle.

while true
     try 
        slice_number=slice_number +1;
        stackTAC(:,:,slice_number)= dicomread(sprintf('%s_%d.dcm',nombre_parsed(1),slice_number));
      catch ME
         if (strcmp(ME.identifier,'images:dicomread:fileNotFound'))
             disp('bucle roto');
             disp(slice_number);             
              break      
         end        
    end
end
stackSLICES=stackTAC;
end
