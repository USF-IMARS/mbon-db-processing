
clear
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/');
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/m_map');
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/export_fig');
addpath('/srv/imars-objects/homes/dotis/DB_files/DB_v24');

%%%%%% GOM %%%%%%
roi='gom';
roi_2='GOM';
recent=15;

% VSNPP/florida
sensor='VSNPP';
roia='florida'; roi_2a='FL'; roi_desc='Florida';
prod_class='OC';
[dummy]=MEAN_1D_func_ED_dbv24(roi,roi_2,roia,roi_2a,roi_desc,prod_class,sensor,recent);
% prod_class='SSTN';
% [dummy]=MEAN_1D_func_ED_dbv24(roi,roi_2,roia,roi_2a,roi_desc,prod_class,sensor,recent);

% VSNPP/nwgom
roia='nwgom'; roi_2a='NWGOM'; roi_desc='NW Gulf of Mexico';
prod_class='OC';
[dummy]=MEAN_1D_func_ED_dbv24(roi,roi_2,roia,roi_2a,roi_desc,prod_class,sensor,recent);
% prod_class='SSTN';
% [dummy]=MEAN_1D_func_ED_dbv24(roi,roi_2,roia,roi_2a,roi_desc,prod_class,sensor,recent);

% MODA
sensor='MODA';
roia='florida'; roi_2a='FL'; roi_desc='Florida';
prod_class='OC';
[dummy]=MEAN_1D_func_ED_dbv24(roi,roi_2,roia,roi_2a,roi_desc,prod_class,sensor,recent);

% % PACE (do not automate for now)
% sensor='POCI';
% roia='florida'; roi_2a='FL'; roi_desc='Florida';
% prod_class='OC_BGC';
% [dummy]=MEAN_1D_func_ED_dbv24(roi,roi_2,roia,roi_2a,roi_desc,prod_class,sensor,recent);



%%%%%% SEUS %%%%%%
% No MEAN_1D_ED files currently generated for SEUS (can add in the future)
