
clear
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/');
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/m_map');
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/export_fig');
addpath('/srv/imars-objects/homes/dotis/DB_files/DB_v24');

% SEUS
% ALL input is ONLY in the form of .geojson files
% Define ROI
% GOM
roi='gom';
roi_2='GOM';

sensor='MODA';
prod_class='OC';
prods={'chlor_a','Rrs_667','ABI','Kd_490'};
[dummy]=Extract_sat_1D_func_dbv24_RECENTonly(sensor,roi,roi_2,prod_class,prods);
MAT2CSV_sat_func_dbv24(sensor,roi,roi_2,prod_class,prods);

sensor='VSNPP';
prod_class='OC';
prods={'chlor_a','Rrs_671','Kd_490'};
[dummy]=Extract_sat_1D_func_dbv24_RECENTonly(sensor,roi,roi_2,prod_class,prods);
MAT2CSV_sat_func_dbv24(sensor,roi,roi_2,prod_class,prods);

prod_class='SSTN';
prods={'sstn'};
[dummy]=Extract_sat_1D_func_dbv24_RECENTonly(sensor,roi,roi_2,prod_class,prods);
MAT2CSV_sat_func_dbv24(sensor,roi,roi_2,prod_class,prods);

% SEUS
roi='seus';
roi_2='SEUS';

sensor='MODA';
prod_class='OC';
prods={'ABI'};
[dummy]=Extract_sat_1D_func_dbv24_RECENTonly(sensor,roi,roi_2,prod_class,prods);
MAT2CSV_sat_func_dbv24(sensor,roi,roi_2,prod_class,prods);

sensor='VSNPP';
prod_class='OC';
prods={'chlor_a','Rrs_671','Kd_490'};
[dummy]=Extract_sat_1D_func_dbv24_RECENTonly(sensor,roi,roi_2,prod_class,prods);
MAT2CSV_sat_func_dbv24(sensor,roi,roi_2,prod_class,prods);

prod_class='SSTN';
prods={'sstn'};
[dummy]=Extract_sat_1D_func_dbv24_RECENTonly(sensor,roi,roi_2,prod_class,prods);
MAT2CSV_sat_func_dbv24(sensor,roi,roi_2,prod_class,prods);

