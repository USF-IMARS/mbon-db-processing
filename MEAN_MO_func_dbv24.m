% MEAN_MO_FUNC_vDB_ALL.M
% Written by Dan Otis, January 2025 (modified from MEAN_7D routine)
% Function to create means from a set of daily mosaic .nc files

% Test
% clear 
% addpath('~/MATLAB_files/');
% addpath('~/DB_files/DB_v24');
% 
% sensor='MODA';
% % roi='seus'; roi_2='SEUS'; roi_desc='Southeast US (SEUS)';
% roi='gom'; roi_2='GOM'; roi_desc='Gulf of Mexico (GOM)';
% prod_class='OC';
% % For all files, set recent=0
% % Otherwise, set number of recent files to process (starting w/newest)
% recent=5; 

function[dummy]=MEAN_MO_func_dbv24(roi,roi_2,roi_desc,prod_class,sensor,recent)

% Define product(s) to be extracted
if strcmp(sensor,'MODA') == 1
prod_oc={'chlor_a','Rrs_667','ABI','Kd_490'};
units_oc={'mg m^-3','sr^-1','W m^-2 um^-1 sr^-1','m^-1'};
prod_sst={'sst'};
units_sst={'DegC'};
prod_sst4={'sst4'};
units_sst4={'DegC'};
end

if strcmp(sensor,'VSNPP') == 1
prod_oc={'chlor_a','Rrs_671','Kd_490'};
units_oc={'mg m^-3','sr^-1','m^-1'};
prod_sst={'sst'};
units_sst={'DegC'};
prod_sstn={'sstn'};
units_sstn={'DegC'};
end

if strncmp('OC',prod_class,2) == 1
prods=prod_oc;
units=units_oc;
end
if strncmp('SST',prod_class,2) == 1
prods=prod_sst;
units=units_sst;
end
if strncmp('SST4',prod_class,4) == 1
prods=prod_sst4;
units=units_sst4;
end
if strncmp('SSTN',prod_class,4) == 1
prods=prod_sstn;
units=units_sstn;
end
% Set filepaths, lat/lon limits, and x/y sizes
path_main='~/DB_files/DB_v24/';

% INPUT AND OUTPUT PATHS
eval(['file_path=''/srv/pgs/rois2/' roi '/L3_1D_' sensor '/' prod_class '/'';'])
eval(['path_out=''/srv/pgs/rois2/' roi '/MEAN_MO_' sensor '/' prod_class '/'';'])
% eval(['path_geotiff=''/srv/imars-objects/tpa_pgs/rois/' roi '/TIFF_out_' sensor '/' prod_class '/'';'])

% Define input files for each product type
% oc (chl,rrs)
eval(['flnms_tmp=struct2cell(dir(''' file_path '/*.nc''));'])
flnms_tmp=flnms_tmp(1,:);
flnms_str=char(flnms_tmp');
len_flnms=length(flnms_str(1,:));

% Find number(s) of files
num_files=size(flnms_str,1);

% Extract month string from filename 
% No need for an index based on doy
bins_peryr=12;

% UPDATE: July 2024
% Datestamp from L3_1D files is yyyymmdd
yrs_img=str2num(flnms_str(:,2:5)); 
mos_img=str2num(flnms_str(:,6:7));
days_img=str2num(flnms_str(:,8:9)); 
dttime = datetime(yrs_img,mos_img,days_img,0,0,0);
[doy_img,~]=date2doy(datenum(dttime)); 
years=(min(yrs_img):max(yrs_img));
num_years=size(years,2);
  
% Find indeces of images in each bin
j=1;
for h=1:num_years
for i=1:bins_peryr
oc_tmp=find(yrs_img == years(h) & mos_img == i);
oc_tmp2=length(oc_tmp);
bin_ind_MO(j,1:oc_tmp2)=oc_tmp;
j=j+1;
end % i
end % h

% Remove rows where 1st column is zero in bin_ind array
bin_ind_MO(bin_ind_MO(:,1)==0,:)=[];

% All files (passed into function)
if recent == 0
    begin=1;
end
% For only recent files
if recent > 0
    begin=size(bin_ind_MO,1)-recent;
end

%%%%%%%%%%%%%%%%%%%  BEGIN FULL LOOP  %%%%%%%%%%%%%%%%%%
% Run loop to open all files in each bin 
for i=begin:size(bin_ind_MO,1) % All files   
% for i=size(bin_ind_7D,1)-5:size(bin_ind_7D,1) % Recent files only   
% for i=1:5 % reduced loop for testing
tmpdays=(bin_ind_MO(i,:)>0);
tmp1=bin_ind_MO(i,:);
if sum(tmp1)>=0; tmp2=tmp1(tmp1>0); end
tmp3=flnms_str(tmp2,:);
doy_tmp=doy_img(tmp2);
mos_tmp=mos_img(tmp2(1));
% image_yr=str2num(tmp3(4,2:5)); 
image_doy=doy_tmp(1)+3; 

%%%% PRODUCT LOOP #1 %%%%
for p=1:length(prods)  

% Load climatology
if strcmp(sensor,'MODA')==1
eval(['load ''~/DB_files/DB_v24/CLIM_files/A2003_2019_MO_CLIM_' roi_2 '_' prods{p} '_SLm.mat'';'])
end
if strcmp(sensor,'VSNPP')==1
eval(['load ''~/DB_files/DB_v24/CLIM_files/V2013_2019_MO_CLIM_' roi_2 '_' prods{p} '_SLm.mat'';'])
end
% Loop through images in bin
cd(file_path)
for h=1:size(tmp3,1) % Loop on OC files only
tmp4=tmp3(h,:);
[prod]=open_nc(tmp4,prods{p});
% Get lat/lon info from file
[lat_tmp]=open_nc(tmp4,'lat');
[lon_tmp]=open_nc(tmp4,'lon');


% Define lat_out and lon_out as vectors
lat_out=lat_tmp(:,1);
lon_out=lon_tmp(1,:);


%%%%%% Flip lat to test ERDDAP %%%%%%
% lat_out = flipud(lat_out); % 


lat_lims=[min(lat_out),max(lat_out)]; 
lon_lims=[min(lon_out) max(lon_out)];
% Need to flip?
ysz=length(lat_out);
xsz=length(lon_out);

% Is this needed for 7D means? - Lots of lost pixels
% Filter using STRAYLIGHT MASK (must be created during mosaicing and included in L3 file
% Use for nFLH (ABI) only
if strcmp('ABI',prods{p}) == 1
sl_mask=open_nc(tmp4,'STRAYLIGHT_MASK');
prod(sl_mask==1)=NaN;
end

% Create stack of images in 7d bin
prod_stack_tmp(:,:,h)=prod;
end % h
cd(path_main)

% Convert zeros to NaN (areas with no data)
prod_stack_tmp(prod_stack_tmp <= 0 | prod_stack_tmp > 100)=NaN;

% Find times of start and end images in bin for filename
start_time = tmp3(1,2:9);
end_time = tmp3(end,2:9);
start_date = datetime(start_time,'InputFormat','yyyyMMdd');
end_date = datetime(end_time,'InputFormat','yyyyMMdd');

% start_date=datestr(doy2date(str2num(start_time(5:7)),str2num(start_time(1:4))),'mm/dd/yyyy');
% end_date=datestr(doy2date(str2num(end_time(5:7)),str2num(end_time(1:4))),'mm/dd/yyyy');
% start_date_gt=datestr(doy2date(str2num(start_time(5:7)),str2num(start_time(1:4))),'yyyymmdd');
% end_date_gt=datestr(doy2date(str2num(end_time(5:7)),str2num(end_time(1:4))),'yyyymmdd');



%%%%%%%%%%%%%    CALCULATE MEANS    %%%%%%%%%%%%%%
% Prior to output, mean all images in 8-day stack
% Use "_out" as a suffix 
% Use log-transformed mean for all chl products
if strncmp('chlor_a',prods{p},2) == 1
prod_out = 10.^(nanmedian(log10(prod_stack_tmp),3));
end
% For non-chl products use normal arithmetic mean
if strncmp('chlor_a',prods{p},2) == 0
prod_out = nanmedian(prod_stack_tmp,3);
end

%%%%%%%%%%%%%    CALCULATE ANOMALIES    %%%%%%%%%%%%%%
mac_ind=mos_tmp;
eval(['clim_out=' prods{p} '_clim_stack(:,:,mac_ind);'])
eval(['anom_out=prod_out-' prods{p} '_clim_stack(:,:,mac_ind);'])

%%%%%%%%%%%%%    DEFINE NAMED VARIABLES FOR OUTPUT    %%%%%%%%%%%%%%
% Define prods for gt output
eval(['out_gt_' prods{p} '=cat(3,flipud(prod_out),flipud(clim_out),flipud(anom_out));'])
% eval(['anom_out_gt_' prods{p} '=flipud(anom_out);'])
% eval(['clim_out_gt_' prods{p} '=flipud(clim_out);'])

% Flup U/D for ERDDAP!?!
% prod_out = flipud(prod_out);
% anom_out = flipud(anom_out);
% clim_out = flipud(clim_out);

% Transpose for output (not needed for geotiff)
prod_out=prod_out';
anom_out=anom_out';
clim_out=clim_out';

eval(['prod_out_' prods{p} '=prod_out;'])
eval(['anom_out_' prods{p} '=anom_out;'])
eval(['clim_out_' prods{p} '=clim_out;'])

% Clean up
clear prod prod_out prod_stack_tmp anom anom_out clim_out

end % p (prod)

%%%%%%%%%%%%%    OUTPUT    %%%%%%%%%%%%%%
% Output as a .nc file
cd(path_out)
eval(['out_file = ''' sensor '_' start_time '_' end_time '_MO_' roi_2 '_' prod_class '.nc'''])
ncid_out = netcdf.create(out_file,'NETCDF4');
% Define Constant for Global Attibutes
NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
% Define dimensions
dimid_y = netcdf.defDim(ncid_out,'img_y',ysz);
dimid_x = netcdf.defDim(ncid_out,'img_x',xsz);
% Add other params to output NC file
% Global attributes
netcdf.putAtt(ncid_out,NC_GLOBAL,'Region',roi_desc)
netcdf.putAtt(ncid_out,NC_GLOBAL,'Time interval','Monthly Composite (median)')
if strcmp(sensor,'MODA')==1
netcdf.putAtt(ncid_out,NC_GLOBAL,'Sensor','MODIS-Aqua')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Level2 file version','r2022.0.1')
end
if strcmp(sensor,'VSNPP')==1
netcdf.putAtt(ncid_out,NC_GLOBAL,'Sensor','VIIRS-SNPP')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Level2 file version','r2022.0.1')
end
netcdf.putAtt(ncid_out,NC_GLOBAL,'Original Image Source','NASA Ocean Biology Processing Group')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Original Image Format','Level2(NetCDF)')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Ocean color masks based on L2_flags','LAND,CLDICE,HIGLINT')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Projection','Equidistant Cylindrical')
eval(['netcdf.putAtt(ncid_out,NC_GLOBAL,''Image size'',''' num2str(ysz) ' pixels(N-S) x ' num2str(xsz) ' pixels(E-W)'');']) 
eval(['netcdf.putAtt(ncid_out,NC_GLOBAL,''LatLon Limits'',''' num2str(lat_lims(1)) 'N to ' num2str(lat_lims(2)) 'N ' num2str(lon_lims(1)) 'W to ' num2str(lon_lims(2)) 'W'');']) 
netcdf.putAtt(ncid_out,NC_GLOBAL,'Processing and binning','USF IMaRS')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Contact','Dan Otis - dotis@usf.edu')
netcdf.putAtt(ncid_out,NC_GLOBAL,'CreationDate',datestr(now,'mm/dd/yyyy HH:MM:SS'))
netcdf.putAtt(ncid_out,NC_GLOBAL,'Composite start date',string(start_date))
netcdf.putAtt(ncid_out,NC_GLOBAL,'Composite end date',string(end_date))

%%%% PRODUCT LOOP #2 %%%%
for p=1:length(prods) 
% Define variables
eval(['prod_mean_varid = netcdf.defVar(ncid_out,''' prods{p} '_median'',''NC_DOUBLE'',[dimid_x dimid_y]);'])
eval(['prod_anom_varid = netcdf.defVar(ncid_out,''' prods{p} '_anom'',''NC_DOUBLE'',[dimid_x dimid_y]);'])
eval(['prod_clim_varid = netcdf.defVar(ncid_out,''' prods{p} '_clim'',''NC_DOUBLE'',[dimid_x dimid_y]);'])
netcdf.putAtt(ncid_out,prod_mean_varid,'Product',prods{p})
netcdf.putAtt(ncid_out,prod_mean_varid,'Units',units{p})

eval(['netcdf.putAtt(ncid_out,prod_anom_varid,''Product'',''' prods{p} '_anomaly'')'])
netcdf.putAtt(ncid_out,prod_anom_varid,'Units',units{p})
if strcmp(sensor,'VSNPP')==1
eval(['netcdf.putAtt(ncid_out,prod_clim_varid,''Product'',''' prods{p} '_climatology'')'])
netcdf.putAtt(ncid_out,prod_clim_varid,'Units',units{p})
netcdf.putAtt(ncid_out,prod_clim_varid,'Climatology period','2013-2019')
end
if strcmp(sensor,'MODA')==1
eval(['netcdf.putAtt(ncid_out,prod_clim_varid,''Product'',''' prods{p} '_climatology'')'])
netcdf.putAtt(ncid_out,prod_clim_varid,'Units',units{p})
netcdf.putAtt(ncid_out,prod_clim_varid,'Climatology period','2003-2019')
end

% Write variables into file 
eval(['netcdf.putVar(ncid_out,prod_mean_varid,prod_out_' prods{p} ')'])
eval(['netcdf.putVar(ncid_out,prod_anom_varid,anom_out_' prods{p} ')'])
eval(['netcdf.putVar(ncid_out,prod_clim_varid,clim_out_' prods{p} ')'])

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

% Clean up
eval(['clear prod_out_' prods{p} ''])
eval(['clear anom_out_' prods{p} ''])
eval(['clear clim_out_' prods{p} ''])
end

% Lat/lon as matrices
% lon_varid = netcdf.defVar(ncid_out,'longitude','NC_DOUBLE',[dimid_x dimid_y]);
% lat_varid = netcdf.defVar(ncid_out,'latitude','NC_DOUBLE',[dimid_x dimid_y]);

% Lat/lon as vectors
lon_varid = netcdf.defVar(ncid_out,'longitude','NC_FLOAT',[dimid_x]);
lat_varid = netcdf.defVar(ncid_out,'latitude','NC_FLOAT',[dimid_y]);

% Add lat/lon and close output file
netcdf.putVar(ncid_out,lon_varid,lon_out) 
netcdf.putVar(ncid_out,lat_varid,lat_out)

% Close output file
netcdf.close(ncid_out)
cd(path_main)



end % i (main - MO bin)

% Clean up
clear bin_ind_MO

dummy=1;









