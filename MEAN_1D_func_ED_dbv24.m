% MEAN_7D_FUNC_vDB_ALL.M
% Written by Dan Otis, July 2024
% Function to create means from a set of daily mosaic .nc files
% These files are compatable for input into ERDDAP
% UPDATE: 7/12/24
% This version is for waters around Florida (save space)
% The files in L3_1D_VSNPP are compatible for w/ERDDAP (can we fix?)
% These files are to support NOAA AOML SFP program cruises
% This processing should be automated and files copied to dune
% Automated MEAN_1D processing: VSNPP OC, SSTN and MODA ABI only
% Can add for other regions if needed (nwgom?)

% Test
% clear
% addpath('/srv/imars-objects/homes/dotis/MATLAB_files/');
% addpath('/srv/imars-objects/homes/dotis/DB_files/DB_v24');
% 
% % Set params
% sensor='MODA';
% roi='gom';
% roi_2='GOM';
% roia='florida'; roi_2a='FL'; roi_desc='Florida';
% % roia='nwgom'; roi_2a='NWGOM'; roi_desc='NW Gulf of Mexico';
% 
% prod_class='OC';
% % For all files, set recent=0
% % Otherwise, set number of recent files to process (starting w/newest)
% recent=0; 



% Run as a function for automated processing (VIIRS, plus MODA for ABI only)
function[dummy]=MEAN_1D_func_ED_dbv24(roi,roi_2,roia,roi_2a,roi_desc,prod_class,sensor,recent)

% Set lat/lon bounds 
% florida
if strcmp(roia,'florida')==1
lat_min = 24.0;
lat_max = 31.0;
lon_min = -85.0;
lon_max = -78.5;
end
% nwgom
if strcmp(roia,'nwgom')==1
lat_min = 26.0;
lat_max = 31.0;
lon_min = -98.0;
lon_max = -88.0;
end

% Define product(s) to be extracted
if strcmp(sensor,'MODA') == 1
prod_oc={'chlor_a','Rrs_667','ABI','Kd_490','STRAYLIGHT_MASK'};
units_oc={'mg m^-3','sr^-1','W m^-2 um^-1 sr^-1','sr^-1','none'};
prod_sst4={'sst4'};
units_sst4={'DegC'};
end

if strcmp(sensor,'VSNPP') == 1
prod_oc={'chlor_a','Rrs_671','Kd_490','STRAYLIGHT_MASK'};
units_oc={'mg m^-3','sr^-1','m^-1','none'};
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
if strncmp('SSTN',prod_class,4) == 1
prods=prod_sstn;
units=units_sstn;
end
if strncmp('SST4',prod_class,4) == 1
prods=prod_sst4;
units=units_sst4;
end

% Set filepaths, lat/lon limits, and x/y sizes
path_main='/srv/imars-objects/homes/dotis/DB_files/DB_v24/';

% INPUT AND OUTPUT PATHS
eval(['file_path=''/srv/imars-objects/tpa_pgs/rois2/' roi '/L3_1D_' sensor '/' prod_class '/'';'])
eval(['path_out=''/srv/imars-objects/tpa_pgs/rois2/' roia '/MEAN_1D_' sensor '/' prod_class '/'';'])
% eval(['path_geotiff=''/srv/imars-objects/tpa_pgs/rois/' roi '/TIFF_out_' sensor '/' prod_class '/'';'])

% Define input files for each product type
% oc (chl,rrs)
eval(['flnms_tmp=struct2cell(dir(''' file_path '/*.nc''));'])
flnms_tmp=flnms_tmp(1,:);
flnms_str=char(flnms_tmp');
len_flnms=length(flnms_str(1,:));

% Find number(s) of files
num_files=size(flnms_str,1);

% Daily index (no means, just flip write new NC files)
ind_1D=(1:1:366);
bins_peryr=366;

% Define weekly (7-day index) for use w/weekly MAC
start_ind=(1:7:365)';
end_ind=(7:7:365+6)';
ind_7D=cat(2,start_ind,end_ind);
ind_7D(53,:)=[];
ind_7D(52,2)=366;

% UPDATE: July 2024
% Datestamp from L3_1D files is yyyymmdd
yrs_img=str2num(flnms_str(:,2:5)); 
mos_img=str2num(flnms_str(:,6:7));
days_img=str2num(flnms_str(:,8:9)); 
dttime = datetime(yrs_img,mos_img,days_img,0,0,0);
numfiles=size(flnms_str,1);
[doy_img,~]=date2doy(datenum(dttime)); 

% Can use a Y/M/D datestamp for output if needed
% mltime=doy2date(doy_img,yrs_img);
% years_img_char=datestr(mltime,'yyyy');
% months_img=datestr(mltime,'mm');
% days_img=datestr(mltime,'dd');
% datestamp_ymd=cat(2,years_img_char,months_img,days_img);

% Comment the following line if subsetting years above
years=(min(yrs_img):max(yrs_img));
num_years=size(years,2);

% Find indeces of images in each bin
j=1;
for h=1:num_years
for i=1:bins_peryr
oc_tmp=find(yrs_img == years(h) & doy_img == ind_1D(i));
% oc_tmp2=length(oc_tmp);
if isempty(oc_tmp)==1; oc_tmp=0;
end
bin_ind_1D(j)=oc_tmp;
j=j+1;
end % i 
end % h

bin_ind_1D=bin_ind_1D';
% Remove rows where 1st column is zero in bin_ind array
bin_ind_1D(bin_ind_1D(:,1)==0,:)=[];

% All files (passed into function)
if recent == 0
    begin=1;
end
% For only recent files
if recent > 0
    begin=size(bin_ind_1D,1)-recent;
end

%%%%%%%%%%%%%%%%%%%  BEGIN FULL LOOP  %%%%%%%%%%%%%%%%%%
% Run loop to open all files in each bin 
for i=begin:size(bin_ind_1D,1) % All files   
% for i=size(bin_ind_7D,1)-5:size(bin_ind_7D,1) % Recent files only   
% for i=1:5 % reduced loop for testing
tmpdays=(bin_ind_1D(i,:)>0);
tmp1=bin_ind_1D(i,:);
if sum(tmp1)>=0; tmp2=tmp1(tmp1>0); end
tmp3=flnms_str(tmp2,:);
doy_tmp=doy_img(tmp2);
% image_yr=str2num(tmp3(4,2:5)); 
image_doy=doy_tmp(1); 

%%%% PRODUCT LOOP #1 %%%%
for p=1:length(prods)  

% Load climatology (not for SLmask)
if strcmp(prods{p},'chlor_a')==1 || strcmp(prods{p},'Rrs_671')==1 || strcmp(prods{p},'Rrs_667')==1 || strcmp(prods{p},'ABI')==1 || strcmp(prods{p},'Kd_490')==1 || strcmp(prods{p},'sst')==1 || strcmp(prods{p},'sstn')==1
if strcmp(sensor,'MODA')==1 % (2003-2019) 
eval(['load ''/srv/imars-objects/homes/dotis/DB_files/DB_v24/CLIM_files/A2003_2019_7D_CLIM_' roi_2 '_' prods{p} '_SLm.mat'';'])
end
if strcmp(sensor,'VSNPP')==1 % (2013-2019)
eval(['load ''/srv/imars-objects/homes/dotis/DB_files/DB_v24/CLIM_files/V2013_2019_7D_CLIM_' roi_2 '_' prods{p} '_SLm.mat'';'])
end
end
% Loop through images in bin
cd(file_path)
for h=1:size(tmp3,1) % Loop on OC files only
tmp4=tmp3(h,:);
[prod]=open_nc(tmp4,prods{p});
doy_tmp=doy_img(tmp2);
image_doy=doy_tmp(1); 

% Get lat/lon info from file
[lat_tmp]=open_nc(tmp4,'lat');
[lon_tmp]=open_nc(tmp4,'lon');

% Define lat_out and lon_out as vectors
lat_vec=lat_tmp(:,1);
lon_vec=lon_tmp(1,:);

% These images are too big (188MB each)
% Subset for SFL cruises and FRESCA project
% 24 to 28N and -78.5 to -85E
lat_good_ind=find(lat_vec >= lat_min & lat_vec <= lat_max);
lon_good_ind=find(lon_vec >= lon_min & lon_vec <= lon_max);

% Subset images and lat/lon arrays
lat_out_sub = lat_vec(lat_good_ind);
lon_out_sub = lon_vec(lon_good_ind);

%%%%%% Flip lat to test ERDDAP %%%%%%
% lat_out = flipud(lat_out); % 
lat_lims_sub=[min(lat_out_sub),max(lat_out_sub)]; 
lon_lims_sub=[min(lon_out_sub) max(lon_out_sub)];
% Need to flip?
ysz_sub=length(lat_out_sub);
xsz_sub=length(lon_out_sub);

% Filter using STRAYLIGHT MASK (must be created during mosaicing and included in L3 file
% For 1D images, use SL_MASK
% Do we really want to do this? Can run either way.
% We are using an SLm for the climatologies
% Run only for OC and IOP if using
% Could also export SLm as a separate product
% if strcmp(prod_class,'OC') == 1 || strcmp(prod_class,'IOP') ==1
% sl_mask=open_nc(tmp4,'STRAYLIGHT_MASK');
% prod(sl_mask==1)=NaN;
% end

% Create stack of images in 7d bin
prod_stack_tmp(:,:,h)=prod;
end % h
cd(path_main)

% Convert zeros to NaN (areas with no data)
if strcmp(prods{p},'STRAYLIGHT_MASK')==0
prod_stack_tmp(prod_stack_tmp <= 0 | prod_stack_tmp > 100)=NaN;
end

% Find times of start and end images in bin for filename
start_time = tmp3(1,2:9);
end_time = tmp3(end,2:9);
start_date = datetime(start_time,'InputFormat','yyyyMMdd');
end_date = datetime(end_time,'InputFormat','yyyyMMdd');

% start_date=datestr(doy2date(str2num(start_time(5:7)),str2num(start_time(1:4))),'mm/dd/yyyy');
% end_date=datestr(doy2date(str2num(end_time(5:7)),str2num(end_time(1:4))),'mm/dd/yyyy');
% start_date_gt=datestr(doy2date(str2num(start_time(5:7)),str2num(start_time(1:4))),'yyyymmdd');
% end_date_gt=datestr(doy2date(str2num(end_time(5:7)),str2num(end_time(1:4))),'yyyymmdd');

prod_out=prod_stack_tmp;

%%%%%%%%%%%%%    CALCULATE ANOMALIES    %%%%%%%%%%%%%%
% Use weekly anom
if strcmp(prods{p},'STRAYLIGHT_MASK')==1
clim_out=zeros(size(prod_out));
anom_out=zeros(size(prod_out));
else    
mac_ind=find(image_doy >= ind_7D(:,1) & image_doy <= ind_7D(:,2));
eval(['clim_out=' prods{p} '_clim_stack(:,:,mac_ind);'])
eval(['anom_out=prod_out-' prods{p} '_clim_stack(:,:,mac_ind);'])
end

%%%%%%%%%%%%%    DEFINE NAMED VARIABLES FOR OUTPUT    %%%%%%%%%%%%%%
% Define prods for gt output
% eval(['out_gt_' prods{p} '=cat(3,flipud(prod_out),flipud(clim_out),flipud(anom_out));'])
% eval(['anom_out_gt_' prods{p} '=flipud(anom_out);'])
% eval(['clim_out_gt_' prods{p} '=flipud(clim_out);'])

% Flup U/D for ERDDAP!?!
% prod_out = flipud(prod_out);
% anom_out = flipud(anom_out);
% clim_out = flipud(clim_out);

% Subset prods
prod_out_sub=prod_out(lat_good_ind,lon_good_ind);
anom_out_sub=anom_out(lat_good_ind,lon_good_ind);
clim_out_sub=clim_out(lat_good_ind,lon_good_ind); % Don't write clim to file (could in future...)

% Transpose for output (not needed for geotiff)
prod_out_sub=prod_out_sub';
anom_out_sub=anom_out_sub';
clim_out_sub=clim_out_sub';

eval(['prod_out_' prods{p} '=prod_out_sub;'])
eval(['anom_out_' prods{p} '=anom_out_sub;'])
eval(['clim_out_' prods{p} '=clim_out_sub;'])

% Clean up
clear prod prod_out prod_out_sub prod_stack_tmp anom anom_out anom_out_sub clim_out
end % p (prod)

%%%%%%%%%%%%%    OUTPUT    %%%%%%%%%%%%%%
% Output as a .nc file
cd(path_out)
eval(['out_file = ''' sensor '_' start_time '_1D_' roi_2a '_' prod_class '_ED.nc'''])
ncid_out = netcdf.create(out_file,'NETCDF4');
% Define Constant for Global Attibutes
NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
% Define dimensions
dimid_y = netcdf.defDim(ncid_out,'img_y',ysz_sub);
dimid_x = netcdf.defDim(ncid_out,'img_x',xsz_sub);
% Add other params to output NC file
% Global attributes
netcdf.putAtt(ncid_out,NC_GLOBAL,'Region',roi_desc)
netcdf.putAtt(ncid_out,NC_GLOBAL,'Time interval','1-Day Composite')
if strcmp(sensor,'MODA')==1
netcdf.putAtt(ncid_out,NC_GLOBAL,'Sensor','MODIS-Aqua')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Level2 file version','r2022.0.1')
end
if strcmp(sensor,'VSNPP')==1
netcdf.putAtt(ncid_out,NC_GLOBAL,'Sensor','VIIRS-SNPP')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Level2 file version','r2022.0')
end
netcdf.putAtt(ncid_out,NC_GLOBAL,'Original Image Source','NASA Ocean Biology Processing Group')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Original Image Format','Level-2(NetCDF)')

netcdf.putAtt(ncid_out,NC_GLOBAL,'Ocean color masks based on L2_flags','LAND,CLDICE,HIGLINT')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Projection','Equidistant Cylindrical')
eval(['netcdf.putAtt(ncid_out,NC_GLOBAL,''Image size'',''' num2str(ysz_sub) ' pixels(N-S) x ' num2str(xsz_sub) ' pixels(E-W)'');']) 
eval(['netcdf.putAtt(ncid_out,NC_GLOBAL,''LatLon Limits'',''' num2str(lat_lims_sub(1)) 'N to ' num2str(lat_lims_sub(2)) 'N ' num2str(lon_lims_sub(1)) 'W to ' num2str(lon_lims_sub(2)) 'W'');']) 
netcdf.putAtt(ncid_out,NC_GLOBAL,'Processing and binning','USF IMaRS')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Contact','Dan Otis - dotis@usf.edu')
netcdf.putAtt(ncid_out,NC_GLOBAL,'CreationDate',datestr(now,'mm/dd/yyyy HH:MM:SS'))
netcdf.putAtt(ncid_out,NC_GLOBAL,'Composite date',string(start_date))
% netcdf.putAtt(ncid_out,NC_GLOBAL,'Composite end date',end_date)

%%%% PRODUCT LOOP #2 %%%%
for p=1:length(prods) 
% Define variables
if strcmp(prods{p},'STRAYLIGHT_MASK')==1
eval(['prod_mean_varid = netcdf.defVar(ncid_out,''' prods{p} ''',''NC_DOUBLE'',[dimid_x dimid_y]);'])
end
if strcmp(prods{p},'STRAYLIGHT_MASK')==0
eval(['prod_mean_varid = netcdf.defVar(ncid_out,''' prods{p} ''',''NC_DOUBLE'',[dimid_x dimid_y]);'])
eval(['prod_clim_varid = netcdf.defVar(ncid_out,''' prods{p} '_clim'',''NC_DOUBLE'',[dimid_x dimid_y]);'])
eval(['prod_anom_varid = netcdf.defVar(ncid_out,''' prods{p} '_anom'',''NC_DOUBLE'',[dimid_x dimid_y]);'])
netcdf.putAtt(ncid_out,prod_mean_varid,'Product',prods{p})
netcdf.putAtt(ncid_out,prod_mean_varid,'Units',units{p})
end

eval(['netcdf.putAtt(ncid_out,prod_anom_varid,''Product'',''' prods{p} '_anomaly'')'])
netcdf.putAtt(ncid_out,prod_anom_varid,'Units',units{p})
eval(['netcdf.putAtt(ncid_out,prod_clim_varid,''Product'',''' prods{p} '_climatology'')'])
netcdf.putAtt(ncid_out,prod_clim_varid,'Units',units{p})
if strcmp(sensor,'MODA')==1
netcdf.putAtt(ncid_out,prod_clim_varid,'Climatology period','2003-2019')
end
if strcmp(sensor,'VSNPP')==1
netcdf.putAtt(ncid_out,prod_clim_varid,'Climatology period','2013-2019')
end

% Write variables into file 
if strcmp(prods{p},'STRAYLIGHT_MASK')==1
eval(['netcdf.putVar(ncid_out,prod_mean_varid,prod_out_' prods{p} ')'])
end
if strcmp(prods{p},'STRAYLIGHT_MASK')==0
eval(['netcdf.putVar(ncid_out,prod_mean_varid,prod_out_' prods{p} ')'])
eval(['netcdf.putVar(ncid_out,prod_clim_varid,clim_out_' prods{p} ')'])
eval(['netcdf.putVar(ncid_out,prod_anom_varid,anom_out_' prods{p} ')'])
end
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
netcdf.putVar(ncid_out,lon_varid,lon_out_sub) 
netcdf.putVar(ncid_out,lat_varid,lat_out_sub)

% Close output file
netcdf.close(ncid_out)
cd(path_main)
end % i (main - 7D bin)

% Clean up
clear bin_ind_7D

dummy=1;









