 
clear
addpath('~/MATLAB_files/');
addpath('~/DB_files/DB_v24');

% Set recent
% For all files, set recent=0
% Otherwise, set number of recent files to process (starting w/newest)
recent=0; 

%%%%% GOM %%%%%
roi='gom';
roi_2='GOM';
roi_desc='Gulf of Mexico (GOM)';
sensor='MODA';
% Set product class and run
prod_class='OC';
[dummy]=MEAN_MO_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);

% Run for other sensors if needed
sensor='VSNPP';
prod_class='OC';
[dummy]=MEAN_MO_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);
prod_class='SSTN';
[dummy]=MEAN_MO_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);

% %%%%%% SEUS %%%%%%
% % Don't need monthly means for SEUS (can add later)
% roi='seus';
% roi_2='SEUS';
% roi_desc='Southeastern US (SEUS)';
% 
% % Set sensor
% sensor='MODA';
% % Finally, set product class and run
% prod_class='OC';
% [dummy]=MEAN_MO_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);
% 
% % VSNPP
% sensor='VSNPP';
% prod_class='OC';
% [dummy]=MEAN_MO_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);
% prod_class='SSTN';
% [dummy]=MEAN_MO_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent);


