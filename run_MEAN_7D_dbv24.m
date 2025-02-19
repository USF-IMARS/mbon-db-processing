 
clear
addpath('~/MATLAB_files/');
addpath('~/DB_files/DB_v24');

% Set recent
% For all files, set recent=0
% Otherwise, set number of recent files to process (starting w/newest)
recent=5; 

%%%%% GOM %%%%%
roi='gom';
roi_2='GOM';
roi_desc='Gulf of Mexico (GOM)';
sensor='MODA';
% Set product class and run
prod_class='OC';
[dummy]=MEAN_7D_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);
% prod_class='SST4';
% [dummy]=MEAN_7D_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);
% prod_class='SST';
% [dummy]=MEAN_7D_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);


% Run for other sensors if needed
sensor='VSNPP';
prod_class='OC';
[dummy]=MEAN_7D_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);
prod_class='SSTN';
[dummy]=MEAN_7D_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);
% prod_class='SST';
% [dummy]=MEAN_7D_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);


%%%%%% SEUS %%%%%%
roi='seus';
roi_2='SEUS';
roi_desc='Southeastern US (SEUS)';

% Set sensor
sensor='MODA';
% Finally, set product class and run
prod_class='OC';
[dummy]=MEAN_7D_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);

% VSNPP
sensor='VSNPP';
prod_class='OC';
[dummy]=MEAN_7D_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);
prod_class='SSTN';
[dummy]=MEAN_7D_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);
% prod_class='SST';
% [dummy]=MEAN_7D_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);


