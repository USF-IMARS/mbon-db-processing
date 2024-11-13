
clear
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/');
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/m_map');
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/export_fig');
addpath('/srv/imars-objects/homes/dotis/DB_files/DB_v24');

%%%%%% GOM %%%%%%
roi='gom';
roi_2='GOM';
recent=1550;
sensor='VSNPP';
prod_class='OC'; % No SST for 1D means
% roia='florida'; roi_2a='FL'; roi_desc='Florida';
roia='nwgom'; roi_2a='NWGOM'; roi_desc='NW Gulf of Mexico';

[dummy]=MEAN_1D_func_ED_dbv24(roi,roi_2,roia,roi_2a,roi_desc,prod_class,sensor,recent);
