
clear
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/');
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/m_map');
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/export_fig');
addpath('/srv/imars-objects/homes/dotis/DB_files/DB_v24');

sensor='VSNPP';

roi='seus';
roi_2='SEUS';

pc='OC';
sub=1;
rec_files=0;

% Function works for all sensors and ROI!
dummy = MOSAIC_1D_func_dbv24(roi,roi_2,pc,sub,rec_files,sensor);
