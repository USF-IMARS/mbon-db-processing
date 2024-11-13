
clear
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/');
addpath('/srv/imars-objects/homes/dotis/DB_files/DB_v24');

% Set recent
% For all files, set recent=0
% Otherwise, set number of recent files to process (starting w/newest)
 
sensor='VSNPP';
prod_class='OC';
roi='gom'; roi_2='GOM'; roi_desc='Gulf of Mexico (GOM)';
% roi='seus'; roi_2='SEUS'; roi_desc='Southeast US(SEUS)';
% Use recent=0 for all files
recent=225;

[dummy]=MEAN_7D_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);

