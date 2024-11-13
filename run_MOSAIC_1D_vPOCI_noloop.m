
clear
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/');
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/m_map');
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/export_fig');
addpath('/srv/imars-objects/homes/dotis/DB_files/DB_v24');

sensor='POCI';

roi='gom';
roi_2='GOM';
roi_out='florida';
pc='OC_AOP';
sub=0;
rec_files=70;

% Function works for all sensors and ROI!
[dummy]=MOSAIC_1D_func_vPOCI(roi,roi_2,roi_out,pc,sub,rec_files,sensor);
