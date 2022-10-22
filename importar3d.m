
%%%%%%%%%%%%%%%%%%%%%%
S_voxel = S_voxel.*10000000;
S_voxel=cast(S_voxel,"uint16");
%%%%%%%%%%%%%%%%%%%%%%


imagen_stack = zeros(128,128,256,"uint16");
% metadata = zeros(256);

for i=1:256
    file_name=sprintf("TRANSAXIALES_%d.DCM",i); 
    imagen_stack(:,:,i)= dicomread(file_name);  
end

%%%%%%%%%%%%%%%%%%%
imagen_stack = imagen_stack.*10000000
%%%%%%%%%%%%%%%%%%%
% montage(imagen_stack);
% imagen_dosis_init = zeros (130,130,258);

imagen_dosis_init = convn(S_voxel,imagen_stack.*0.098);
imagen_dosis_cast = cast(imagen_dosis_init,"uint16");
imagen_dosis=imagen_dosis_cast.*0.0000001;

for j=1:258
    file_name_write=sprintf("DOSIS_TRANSAXIAL_%d.DCM",j);
    dicomwrite(imagen_dosis_cast(:,:,j),file_name_write);
end

