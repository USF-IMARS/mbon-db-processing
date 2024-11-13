
clear
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/');
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/m_map');
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/export_fig');
addpath('/srv/imars-objects/homes/dotis/DB_files/DB_v24');



%%%%%% GOM %%%%%%
roi='gom';
roi_2='GOM';
sub=1;
rec_files=5;

% MODA
sensor='MODA';
prods={'OC'};% Only running recent MODA for dashboard ABI
for i=1:length(prods) 
[dummy]=MOSAIC_1D_func_dbv24(roi,roi_2,prods{i},sub,rec_files,sensor);
end

% VSNPP
sensor='VSNPP';
prods={'OC','SSTN'};
for i=1:length(prods)
[dummy]=MOSAIC_1D_func_dbv24(roi,roi_2,prods{i},sub,rec_files,sensor);
end

%%%%%% SEUS %%%%%%
roi='seus';
roi_2='SEUS';
sub=1;
rec_files=5;

% MODA
sensor='MODA';
prods={'OC'};% Only running recent MODA for dashboard ABI
for i=1:length(prods) 
[dummy]=MOSAIC_1D_func_dbv24(roi,roi_2,prods{i},sub,rec_files,sensor);
end

% VSNPP
sensor='VSNPP';
prods={'OC','SSTN'};
for i=1:length(prods)
[dummy]=MOSAIC_1D_func_dbv24(roi,roi_2,prods{i},sub,rec_files,sensor);
end