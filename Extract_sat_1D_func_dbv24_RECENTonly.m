% EXTRACT_TS_FUNC_vDB_all.M
% Written by Dan Otis, September, 2018
% Updated September 2024
% New version will import ROI from json files
% Extracts data from a directory/list of .nc files
% User inputs to function:
% roi, diriectory product class, products, and locations to extract
% Currently, this version is for SEUS circular ROI (5-km radius) only
% If ROI for FGB and FK are converted to json, they can be used here
% Location(s):
%    a. Circular ROI (5-km radius) imported as .geojson files
%    b. Polygon and box ROI imported as .geojson files 
%    c. Point ROI imported as .geojson files (need to extract w/offset)
% Output to .mat, then combine w/historical data and output as .csv

% clear 
% addpath('/srv/imars-objects/homes/dotis/MATLAB_files/');
% addpath('/srv/imars-objects/homes/dotis/DB_files/DB_v24');
% addpath('/srv/imars-objects/homes/dotis/MATLAB_files/m_map');
% addpath('/srv/imars-objects/homes/dotis/MATLAB_files/export_fig');
% addpath('/srv/imars-objects/homes/dotis/MATLAB_files/jsonlab-2.0/jsonlab-2.0');

% % Test
% sensor='VSNPP';
% roi='gom';
% roi_2='GOM';
% prod_class='OC';
% prods={'chlor_a','Rrs_671','Kd_490'}; % VSNPP OC
% prods={'sstn'}; % VSNPP SSTN
% prods={'ABI'}; % MODA OC

function[dummy]=Extract_sat_1D_func_dbv24_RECENTonly(sensor,roi,roi_2,prod_class,prods)

% This function only extracts for most recent dates (1 year) to save time
% Use 1/1/2024 as cutoff point

% Set filepaths, lat/lon limits, and x/y sizes
path_main='/srv/imars-objects/homes/dotis/DB_files/DB_v24';
eval(['path_json=''/srv/imars-objects/homes/dotis/DB_files/DB_v24/loc_files/' roi_2 ''';'])

% Get ROI from json files
eval(['flnms_tmp=struct2cell(dir(''' path_json '/*.geojson''));'])
flnms_str=char(flnms_tmp(1,:));
cd(path_json)
for i=1:size(flnms_str,1)
json_file=string(flnms_str(i,:));
json_file=char(strtrim(json_file));
json_tmp=loadjson(json_file);
name_str_tmp=string(flnms_str(i,:));
name_split_tmp = strsplit(name_str_tmp,'.');
locs(i).name = char(name_split_tmp(1));
locs(i).lat = json_tmp.features{1,1}.geometry.coordinates(:,2);
locs(i).lon = json_tmp.features{1,1}.geometry.coordinates(:,1);
locs(i).type = json_tmp.features{1,1}.geometry.type;
end
cd(path_main)

% INPUT AND OUTPUT PATHS
eval(['file_path=''/srv/imars-objects/tpa_pgs/rois2/' roi '/L3_1D_' sensor '/' prod_class '/'';'])
% Put .mat files with extracted data in the "EXT_TS_MODA", then pull and write .csv to new directory
eval(['path_out=''/srv/imars-objects/tpa_pgs/rois2/' roi '/EXT_TS_' sensor '/'';'])

eval(['filenames_tmp=struct2cell(dir(''' file_path '/*' prod_class '_1D.nc''));'])
filenames_oc=filenames_tmp(1,:);
filenames_oc=filenames_oc';
filenames_str_oc=char(filenames_oc);

% TIME
% UPDATE (7/11/24) - Datestring of L3_1D input files is now yyyymmdd
yrs=str2num(filenames_str_oc(:,2:5)); 
mos=str2num(filenames_str_oc(:,6:7));
days=str2num(filenames_str_oc(:,8:9)); 
dttime = datetime(yrs,mos,days,0,0,0);
numfiles=size(filenames_str_oc,1);

%%%%%% TEST FILE TO FIND X-Y COORDS OF PTS/POLYS %%%%%%
file=filenames_str_oc(1,:);
cd(file_path)
[lat]=open_nc(file,'lat');
[lon]=open_nc(file,'lon');
cd(path_main)
 
% Define polygons in x-y coords.
for k=1:length(locs)
if strcmp(locs(k).type,'Polygon')==1    
ROI_tmp(:,:,k)=inpolygon(lon,lat,locs(k).lon,locs(k).lat);
end
% For point locations, use an offset of 2 (5x5 pixel box)
bx_offset=2; % 5x5 box
if strcmp(locs(k).type,'Point')==1    
[pt_pix,pt_line]=latlon2pixline(locs(k).lat,locs(k).lon,lat(:,1),lon(1,:));
loc_pts_tmp=false(size(lat,1),size(lon,2));
loc_pts_tmp(pt_line-bx_offset:pt_line+bx_offset,pt_pix-bx_offset:pt_pix+bx_offset)=1;
ROI_tmp(:,:,k)=loc_pts_tmp;
end
end 

% Test plots - seems ok (7/9/24)
% imagesc(ROI_tmp(:,:,1))


%%%% PRODUCT LOOP %%%%
for p=1:length(prods)  
   
%%%% FILES LOOP %%%%
% Trim here to only run recent files to save time
% Use Jan 01 of 2024
% Must have historical values saved
time_offset = 365; 
% Last year of files
for i=numfiles-time_offset:numfiles
% All files
% for i=1:numfiles    
file=filenames_str_oc(i,:);
cd(file_path)

eval(['[img_tmp]=open_nc(file,''' prods{p} ''');'])
img_tmp(img_tmp <= 0) = NaN; % Remove negative and zero vals.

% Filter using STRAYLIGHT MASK (must be created during mosaicing and included in L3 file
if strncmp('OC',prod_class,2) == 1
sl_mask=open_nc(file,'STRAYLIGHT_MASK');
img_tmp(sl_mask==1)=NaN;
end

%%%%%%%  OUTPUT  %%%%%%%
% Output to structore variable
% Loop over both polys and pts
% polys go first, then pts

%%%%%%% STATION LOOP %%%%%%%
% Location sites (polys and pts)
for s=1:size(ROI_tmp,3)
loc_mn_tmp=img_tmp(ROI_tmp(:,:,s));
% Use function to calculate mean, std and total pix and cloudy pix
loc_ts = box_calc_func_median_raw(loc_mn_tmp);

ts_tmp(s).roiname=locs(s).name;
ts_tmp(s).dttime(i)=dttime(i);
ts_tmp(s).mn(i)=loc_ts(1);
ts_tmp(s).std(i)=loc_ts(2);
ts_tmp(s).bxtot(i)=loc_ts(4);
ts_tmp(s).bxcld(i)=loc_ts(5);
end % station loop (s)
disp(i)

end % Files Loop (i)
% clear loc_ts

%%%% OUTPUT %%%%
% Save output as .mat files
% Perhaps alter this routine to output raw (unbinned) data to .mat format
cd(path_out)
eval(['save ' roi_2 'dbv24_' prods{p} '_TS_' sensor '_1D_raw_vRECENT.mat ts_tmp'])
cd(path_main)
clear ts_tmp
end % Prod Loop (p)


dummy=1;




