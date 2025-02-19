
clear
addpath('~/MATLAB_files/');
addpath('~/MATLAB_files/m_map');
addpath('~/MATLAB_files/export_fig');
addpath('~/DB_files/DB_v24');

%%%%%% GOM %%%%%%
% roi='gom';
% roi_2='GOM';
recent=75;
sensor='POCI';
prod_class='OC_BGC'; % No SST for 1D means
roia='florida'; roi_2a='SFL'; roi_desc='South Florida';
% roia='nwgom'; roi_2a='NWGOM'; roi_desc='NW Gulf of Mexico';


[dummy]=MEAN_1D_func_ED_vPOCI(roia,roi_2a,roi_desc,prod_class,sensor,recent);