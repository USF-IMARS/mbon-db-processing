% MEAN_7D_FUNC_vDB_ALL.M
% Written by Dan Otis, September 2018
% Function to create means from a set of daily mosaic .nc files

clear
addpath('~/MATLAB_files/');
addpath('~/MATLAB_files/m_map');
addpath('~/MATLAB_files/export_fig');
addpath('~/DB_files/DB_v24');

% INPUT AND OUTPUT PATHS
file_path='/srv/pgs/rois2/glob/VGPM_9KM_MO_HDF';
path_out='/srv/pgs/rois2/glob/VGPM_9KM_MO_NC';
path_main='~/DB_files/DB_v24/';

% Define input files for each product type
% oc (chl,rrs)
eval(['flnms_tmp=struct2cell(dir(''' file_path '/*.hdf''));'])
flnms_tmp=flnms_tmp(1,:);
flnms_str=char(flnms_tmp');

% Find number(s) of files
num_files=size(flnms_str,1);

% UPDATE: July 2024
% Datestamp from L3_1D files is yyyymmdd
yrs_img=str2num(flnms_str(:,6:9)); 
doy_img=str2num(flnms_str(:,10:12));
mltime_img=doy2date(doy_img,yrs_img); 
month_img=datestr(mltime_img,'mm');
day_img=datestr(mltime_img,'dd');
yrs_img_str=string(yrs_img);
% datestr_out=strcat(yrs_img_str,month_img,day_img);

%%%%%%%%%%%%%%%%%%%  BEGIN FULL LOOP  %%%%%%%%%%%%%%%%%%
% Run loop to open all files in each bin 
for i=1:num_files % All files   
cd(file_path)
file = flnms_str(i,:); 

% hdfinfo(file)
data = hdfread(file,'npp');
start_time = hdfread(file,'Start Time String'); 
start_time_str = char(start_time); start_time_str=start_time_str';
start_time_str_out = start_time_str([7:10,1:2,4:5]);
end_time = hdfread(file,'Stop Time String');
end_time_str = char(end_time); end_time_str=end_time_str';
end_time_str_out = end_time_str([7:10,1:2,4:5]);
units = hdfread(file,'Units');
units_str = char(units); units_str=units_str';
limits = cell2mat(hdfread(file,'Limit'));
ysz = double(cell2mat(hdfread(file,'fakeDim0')));
xsz = double(cell2mat(hdfread(file,'fakeDim1')));
lat_lims=[limits(1),limits(3)]; 
lon_lims=[limits(2),limits(4)];
% Create grid
[lat,lon,lat_out,lon_out]=def_grid(xsz,ysz,lat_lims,lon_lims);

% Transpose for output (not needed for geotiff)
data=data';
% Change bad vals to NaN
data(data<=0) = NaN;

% Clean up
% clear prod prod_out prod_stack_tmp anom anom_out clim_out



%%%%%%%%%%%%%    OUTPUT    %%%%%%%%%%%%%%
% Output as a .nc file
cd(path_out)
eval(['out_file = ''MODA_' start_time_str_out '_' end_time_str_out '_MO_npp_VGPM_global_9km.nc'''])
ncid_out = netcdf.create(out_file,'NETCDF4');
% Define Constant for Global Attibutes
NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
% Define dimensions
dimid_y = netcdf.defDim(ncid_out,'img_y',ysz);
dimid_x = netcdf.defDim(ncid_out,'img_x',xsz);
% Add other params to output NC file
% Global attributes
netcdf.putAtt(ncid_out,NC_GLOBAL,'Region','Global')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Time interval','Monthly Composite')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Sensor','MODIS-Aqua')
netcdf.putAtt(ncid_out,NC_GLOBAL,'NASA satellite file reprocessing version','r2022.0.1')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Original Image Source','Ocean Productivity Lab at Oregon State University')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Image Source URL','orca.science.oregonstate.edu')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Image Source FAQ','orca.science.oregonstate.edu/faq01.php')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Image Source contact','westbert@oregonstate.edu')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Original Image Format','HDF')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Projection','Equidistant Cylindrical')
eval(['netcdf.putAtt(ncid_out,NC_GLOBAL,''Image size'',''' num2str(ysz) ' pixels(N-S) x ' num2str(xsz) ' pixels(E-W)'');']) 
eval(['netcdf.putAtt(ncid_out,NC_GLOBAL,''LatLon Limits'',''' num2str(lat_lims(1)) 'N to ' num2str(lat_lims(2)) 'N ' num2str(lon_lims(1)) 'W to ' num2str(lon_lims(2)) 'W'');']) 
netcdf.putAtt(ncid_out,NC_GLOBAL,'ERDDAP Contact','Dan Otis - dotis@usf.edu')
netcdf.putAtt(ncid_out,NC_GLOBAL,'CreationDate',datestr(now,'mm/dd/yyyy HH:MM:SS'))
netcdf.putAtt(ncid_out,NC_GLOBAL,'Composite start date',start_time_str)
netcdf.putAtt(ncid_out,NC_GLOBAL,'Composite end date',end_time_str)

% Define variables
prod_mean_varid = netcdf.defVar(ncid_out,'npp','NC_DOUBLE',[dimid_x dimid_y]);

% Add vars and atts
netcdf.putAtt(ncid_out,prod_mean_varid,'Product','npp (VGPM)')
netcdf.putAtt(ncid_out,prod_mean_varid,'Units',units_str)


% Write variables into file 
netcdf.putVar(ncid_out,prod_mean_varid,data)


%%%%%%%%%%%%%   GEOTIFF OUTPUT   %%%%%%%%%%%%%%
% % ABI output only for MODA OC
% if strncmp('ABI',prods{p},2) == 1
% % GIS output for ftp links on FWC dashboard
% % Output one GeoTIFF for each product with three bands (median, climatology,anomaly)
% cd(path_geotiff)
% R = georasterref('RasterSize',[ysz,xsz],'LatitudeLimits',[min(lat_out) max(lat_out)],'LongitudeLimits',[min(lon_out) max(lon_out)]);
% eval(['geotiff_name = ''MODA_' start_date_gt '_' end_date_gt '_7D_' roi_2 '_' prods{p} '.tif'''])
% eval(['geotiffwrite(geotiff_name,out_gt_' prods{p} ',R)'])
% % eval(['geotiffwrite(geotiff_name,clim_out_gt_' prods{p} ',R)'])
% % eval(['geotiffwrite(geotiff_name,anom_out_gt_' prods{p} ',R)'])
% cd(path_out)
% end



% Lat/lon as matrices
% lon_varid = netcdf.defVar(ncid_out,'longitude','NC_DOUBLE',[dimid_x dimid_y]);
% lat_varid = netcdf.defVar(ncid_out,'latitude','NC_DOUBLE',[dimid_x dimid_y]);

% Lat/lon as vectors
lon_varid = netcdf.defVar(ncid_out,'longitude','NC_FLOAT',[dimid_x]);
lat_varid = netcdf.defVar(ncid_out,'latitude','NC_FLOAT',[dimid_y]);

% Add lat/lon and close output file
netcdf.putVar(ncid_out,lon_varid,lon) 
netcdf.putVar(ncid_out,lat_varid,lat)

% Close output file
netcdf.close(ncid_out)
cd(path_main)

% Clean up
clear data

end % i (main - all files)

dummy=1;









