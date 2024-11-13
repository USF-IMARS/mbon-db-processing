% MEAN_7D_FUNC_vDB_ALL.M
% Written by Dan Otis, August 2024
% Function to create means from a set of daily mosaic .nc files
% These files are compatable for input into ERDDAP
% UPDATE: 7/12/24
% This version is for waters around Florida (save space)
% This version is for PACE OCI
% More products will be added as they become available


% Test
% clear
% % addpath('/srv/imars-objects/homes/dotis/MATLAB_files/');
% % addpath('/srv/imars-objects/homes/dotis/DB_files/DB_v24');
% % 
% % % Set params
% sensor='POCI';
% % roi='gom';
% % roi_2='GOM';
% roia='florida'; roi_2a='SFL'; roi_desc='Florida';
% prod_class='OC_BGC';
% % For all files, set recent=0
% % Otherwise, set number of recent files to process (starting w/newest)
% recent=0; 

% Run as a function for automated processing (VIIRS, plus MODA for ABI only)
function[dummy]=MEAN_1D_func_ED_vPOCI(roia,roi_2a,roi_desc,prod_class,sensor,recent)

% No real need for this (can uncomment later if needed)
% Set lat/lon bounds 
% % florida
% if strcmp(roia,'florida')==1
% lat_min = 24.0;
% lat_max = 31.0;
% lon_min = -85.0;
% lon_max = -78.5;
% end
% % nwgom
% if strcmp(roia,'nwgom')==1
% lat_min = 26.0;
% lat_max = 31.0;
% lon_min = -98.0;
% lon_max = -88.0;
% end

% Define product(s) to be extracted
prod_oc={'chlor_a','carbon_phyto','STRAYLIGHT_MASK'}; % Can add other prods when ready
units_oc={'mg m^-3','mg m^-3','none'};

prod_rrs={'Rrs_339','Rrs_341','Rrs_344','Rrs_346','Rrs_348','Rrs_351','Rrs_353','Rrs_356','Rrs_358','Rrs_361','Rrs_363','Rrs_366','Rrs_368','Rrs_371','Rrs_373','Rrs_375','Rrs_378','Rrs_380','Rrs_383','Rrs_385','Rrs_388','Rrs_390','Rrs_393','Rrs_395','Rrs_398',...
    'Rrs_400','Rrs_403','Rrs_405','Rrs_408','Rrs_410','Rrs_413','Rrs_415','Rrs_418','Rrs_420','Rrs_422','Rrs_425','Rrs_427','Rrs_430','Rrs_432','Rrs_435','Rrs_437','Rrs_440','Rrs_442','Rrs_445','Rrs_447','Rrs_450','Rrs_452','Rrs_455','Rrs_457','Rrs_460','Rrs_462','Rrs_465','Rrs_467','Rrs_470','Rrs_472','Rrs_475','Rrs_477','Rrs_480','Rrs_482','Rrs_485','Rrs_487','Rrs_490','Rrs_492','Rrs_495','Rrs_497',...
    'Rrs_500','Rrs_502','Rrs_505','Rrs_507','Rrs_510','Rrs_512','Rrs_515','Rrs_517','Rrs_520','Rrs_522','Rrs_525','Rrs_527','Rrs_530','Rrs_532','Rrs_535','Rrs_537','Rrs_540','Rrs_542','Rrs_545','Rrs_547','Rrs_550','Rrs_553','Rrs_555','Rrs_558','Rrs_560','Rrs_563','Rrs_565','Rrs_568','Rrs_570','Rrs_573','Rrs_575','Rrs_578','Rrs_580','Rrs_583','Rrs_586','Rrs_588','Rrs_591','Rrs_593','Rrs_596','Rrs_598',...
    'Rrs_601','Rrs_603','Rrs_605','Rrs_608','Rrs_610','Rrs_613','Rrs_615','Rrs_618','Rrs_620','Rrs_623','Rrs_625','Rrs_627','Rrs_630','Rrs_632','Rrs_635','Rrs_637','Rrs_640','Rrs_641','Rrs_642','Rrs_643','Rrs_645','Rrs_646','Rrs_647','Rrs_648','Rrs_650','Rrs_651','Rrs_652','Rrs_653','Rrs_655','Rrs_656','Rrs_657','Rrs_658','Rrs_660','Rrs_661','Rrs_662','Rrs_663','Rrs_665','Rrs_666','Rrs_667','Rrs_668','Rrs_670','Rrs_671','Rrs_672','Rrs_673','Rrs_675','Rrs_676','Rrs_677','Rrs_678','Rrs_679','Rrs_681','Rrs_682','Rrs_683','Rrs_684','Rrs_686','Rrs_687','Rrs_688','Rrs_689','Rrs_691','Rrs_693','Rrs_694','Rrs_696','Rrs_697','Rrs_698','Rrs_699'...
    'Rrs_701','Rrs_702','Rrs_703','avw','STRAYLIGHT_MASK'}; % Add spectral Rrs here (files will be big)
units_rrs={'sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','nm','none'}; 

if strcmp('OC_BGC',prod_class) == 1
prods=prod_oc;
units=units_oc;
end
if strcmp('OC_AOP',prod_class) == 1
prods=prod_rrs;
units=units_rrs;
end

% Set filepaths, lat/lon limits, and x/y sizes
path_main='/srv/imars-objects/homes/dotis/DB_files/DB_v24/';

% INPUT AND OUTPUT PATHS
eval(['file_path=''/srv/imars-objects/tpa_pgs/rois2/' roia '/L3_1D_' sensor '/' prod_class '/'';'])
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
% No CLIM for PACE (yet)
for p=1:length(prods)  
% % Load climatology (not for SLmask)
% eval(['load ''/srv/imars-objects/homes/dotis/DB_files/DB_v24/CLIM_files/A2003_2019_7D_CLIM_' roi_2 '_' prods{p} '_SLm.mat'';'])
% end

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

% PACE data is downloaded for "florida" AOI only
% No need to subset
% lat_good_ind=find(lat_vec >= lat_min & lat_vec <= lat_max);
% lon_good_ind=find(lon_vec >= lon_min & lon_vec <= lon_max);

% Subset images and lat/lon arrays
% lat_out_sub = lat_vec(lat_good_ind);
% lon_out_sub = lon_vec(lon_good_ind);

%%%%%% Flip lat to test ERDDAP %%%%%%
% lat_out = flipud(lat_out); 
lat_lims=[min(lat_vec),max(lat_vec)]; 
lon_lims=[min(lon_vec) max(lon_vec)];
% % Need to flip?
ysz=size(lat_tmp,1);
xsz=size(lon_tmp,2);

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
% Do not apply for SL MASK or avw
% Can get negative Rrs, particularly in the red
% Can leave this filter out
if strcmp(prods{p},'STRAYLIGHT_MASK')==0 && strcmp(prods{p},'avw')==0 
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
% % Use weekly anom
% if strcmp(prods{p},'STRAYLIGHT_MASK')==1
% clim_out=zeros(size(prod_out));
% anom_out=zeros(size(prod_out));
% else    
% mac_ind=find(image_doy >= ind_7D(:,1) & image_doy <= ind_7D(:,2));
% eval(['clim_out=' prods{p} '_clim_stack(:,:,mac_ind);'])
% eval(['anom_out=prod_out-' prods{p} '_clim_stack(:,:,mac_ind);'])
% end

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
% prod_out_sub=prod_out(lat_good_ind,lon_good_ind);
% anom_out_sub=anom_out(lat_good_ind,lon_good_ind);
% clim_out_sub=clim_out(lat_good_ind,lon_good_ind); % Don't write clim to file (could in future...)

% Transpose for output (not needed for geotiff)
prod_out=prod_out';
% anom_out_sub=anom_out_sub';
% clim_out_sub=clim_out_sub';

eval(['prod_out_' prods{p} '=prod_out;'])
% eval(['anom_out_' prods{p} '=anom_out;'])
% eval(['clim_out_' prods{p} '=clim_out;'])

% Clean up
clear prod prod_out prod_out prod_stack_tmp
% clear prod prod_out prod_out_sub prod_stack_tmp anom anom_out anom_out_sub clim_out
end % p (prod)

%%%%%%%%%%%%%    OUTPUT    %%%%%%%%%%%%%%
% Output as a .nc file
cd(path_out)
eval(['out_file = ''' sensor '_' start_time '_1D_' roi_2a '_' prod_class '_ED.nc'''])
ncid_out = netcdf.create(out_file,'NETCDF4');
% Define Constant for Global Attibutes
NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
% Define dimensions
dimid_y = netcdf.defDim(ncid_out,'latitude',ysz);
dimid_x = netcdf.defDim(ncid_out,'longitude',xsz);
% Add other params to output NC file
% Global attributes
netcdf.putAtt(ncid_out,NC_GLOBAL,'Region',roi_desc)
netcdf.putAtt(ncid_out,NC_GLOBAL,'Time interval','1-Day Composite')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Sensor','PACE-OCI')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Level2 processing version','2.0')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Original Image Source','NASA Ocean Biology Processing Group')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Original Image Format','Level-2(NetCDF)')

netcdf.putAtt(ncid_out,NC_GLOBAL,'Ocean color masks based on L2_flags','LAND,CLDICE,HIGLINT')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Projection','Equidistant Cylindrical')
eval(['netcdf.putAtt(ncid_out,NC_GLOBAL,''Image size'',''' num2str(ysz) ' pixels(N-S) x ' num2str(xsz) ' pixels(E-W)'');']) 
eval(['netcdf.putAtt(ncid_out,NC_GLOBAL,''LatLon Limits'',''' num2str(lat_lims(1)) 'N to ' num2str(lat_lims(2)) 'N ' num2str(lon_lims(1)) 'W to ' num2str(lon_lims(2)) 'W'');']) 
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
netcdf.putAtt(ncid_out,prod_mean_varid,'Product',prods{p})
netcdf.putAtt(ncid_out,prod_mean_varid,'Units',units{p})
end
if strcmp(prods{p},'STRAYLIGHT_MASK')==0
eval(['prod_mean_varid = netcdf.defVar(ncid_out,''' prods{p} ''',''NC_DOUBLE'',[dimid_x dimid_y]);'])
% eval(['prod_clim_varid = netcdf.defVar(ncid_out,''' prods{p} '_clim'',''NC_DOUBLE'',[dimid_x dimid_y]);'])
% eval(['prod_anom_varid = netcdf.defVar(ncid_out,''' prods{p} '_anom'',''NC_DOUBLE'',[dimid_x dimid_y]);'])
netcdf.putAtt(ncid_out,prod_mean_varid,'Product',prods{p})
netcdf.putAtt(ncid_out,prod_mean_varid,'Units',units{p}) 
end

% eval(['netcdf.putAtt(ncid_out,prod_anom_varid,''Product'',''' prods{p} '_anomaly'')'])
% netcdf.putAtt(ncid_out,prod_anom_varid,'Units',units{p})
% eval(['netcdf.putAtt(ncid_out,prod_clim_varid,''Product'',''' prods{p} '_climatology'')'])
% netcdf.putAtt(ncid_out,prod_clim_varid,'Units',units{p})
% if strcmp(sensor,'MODA')==1
% netcdf.putAtt(ncid_out,prod_clim_varid,'Climatology period','2003-2019')
% end
% if strcmp(sensor,'VSNPP')==1
% netcdf.putAtt(ncid_out,prod_clim_varid,'Climatology period','2013-2019')
% end

% Write variables into file 
if strcmp(prods{p},'STRAYLIGHT_MASK')==1
eval(['netcdf.putVar(ncid_out,prod_mean_varid,prod_out_' prods{p} ')'])
end
if strcmp(prods{p},'STRAYLIGHT_MASK')==0
eval(['netcdf.putVar(ncid_out,prod_mean_varid,prod_out_' prods{p} ')'])
% eval(['netcdf.putVar(ncid_out,prod_clim_varid,clim_out_' prods{p} ')'])
% eval(['netcdf.putVar(ncid_out,prod_anom_varid,anom_out_' prods{p} ')'])
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
% eval(['clear anom_out_' prods{p} ''])
% eval(['clear clim_out_' prods{p} ''])
end % p prods

% Lat/lon as matrices
% lon_varid = netcdf.defVar(ncid_out,'longitude','NC_DOUBLE',[dimid_x dimid_y]);
% lat_varid = netcdf.defVar(ncid_out,'latitude','NC_DOUBLE',[dimid_x dimid_y]);

% Lat/lon as vectors
lon_varid = netcdf.defVar(ncid_out,'longitude','NC_DOUBLE',dimid_x);
lat_varid = netcdf.defVar(ncid_out,'latitude','NC_DOUBLE',dimid_y);

% Add lat/lon and close output file
netcdf.putVar(ncid_out,lon_varid,lon_vec) 
netcdf.putVar(ncid_out,lat_varid,lat_vec)

% Close output file
netcdf.close(ncid_out)
cd(path_main)
end % i (main - 1D bin)

% Clean up
clear bin_ind_1D

dummy=1;









