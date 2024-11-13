% MEAN_7D_FUNC_vDB_ALL.M
% Written by Dan Otis, September 2018
% Function to create means from a set of daily mosaic .nc files

% Inputs:
% directory names, roi, product classes, and products

% Test
clear
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/');
addpath('/srv/imars-objects/homes/dotis/DB_files/DB_v24');

% Need to add "sensor" field here
sensor='VSNPP';
prod_class='SSTN';
% roi='GOM'; dirs='gom'; roi_desc='Gulf of Mexico (GOM)';
roi='SEUS'; dirs='seus'; roi_desc='Southeastern US (SEUS)';

% VSNPP OC
% prod_oc={'chlor_a','Rrs_671','Kd_490'};
% units_oc={'mg m^-3','sr^-1','m^-1'};
% VSNPP SST/SSTN
prod_sstn={'sstn'};
units_sstn={'DegC'};

% MODA OC
% prod_oc={'chlor_a','Rrs_667','ABI','Kd_490'};
% units_oc={'mg m^-3','sr^-1','W m^-2 um^-1 sr^-1','m^-1'};
% MODA SST/SST4
% prod_sst={'sst'};
% units_sst={'DegC'};
% prod_sst4={'sst4'};
% units_sst4={'DegC'};


if strcmp(sensor,'MODA')==1
yr_start=2003;
yr_end=2019;
end
if strcmp(sensor,'VSNPP')==1
yr_start=2013;
yr_end=2019;
end
% function[dummy]=CLIM_7D_func_vDB_all(dirs,roi,roi_desc,prod_class,prod_oc,units_oc,prod_sst,units_sst,yr_start,yr_end)

% Set filepaths, lat/lon limits, and x/y sizes
path_main='/srv/imars-objects/homes/dotis/DB_files/DB_v24';

% Define product(s) to be extracted
if strcmp('OC',prod_class) == 1
prods=prod_oc;
units=units_oc;
end
if strcmp('SST',prod_class) == 1
prods=prod_sst;
units=units_sst;
end
if strcmp('SST4',prod_class) == 1
prods=prod_sst4;
units=units_sst4;
end
if strcmp('SSTN',prod_class) == 1
prods=prod_sstn;
units=units_sstn;
end
% INPUT AND OUTPUT PATHS
eval(['file_path=''/srv/imars-objects/tpa_pgs/rois2/' dirs '/L3_1D_' sensor '/' prod_class '/'';'])
path_out='/srv/imars-objects/homes/dotis/DB_files/DB_v24/CLIM_files/';

% Define input files for each product type
% oc (chl,rrs)
eval(['flnms_tmp=struct2cell(dir(''' file_path '/*.nc''));'])
flnms_tmp=flnms_tmp(1,:);
flnms_str=char(flnms_tmp');
len_flnms=length(flnms_str(1,:));

% Find number(s) of files
num_files=size(flnms_str,1);

% Define weekly (7-day index)
start_ind=(1:7:365)';
end_ind=(7:7:365+6)';
ind_7D=cat(2,start_ind,end_ind);
ind_7D(53,:)=[];
ind_7D(52,2)=366;
bins_peryr=52;

% Or, use an 8D interval (MTK and MBON S-scapes)
% start_8d=(1:8:365)';
% end_8d=(8:8:365+7)';
% ind_8d=cat(2,start_8d,end_8d);
% ind_8d(46,2)=366;
% bins_peryr=46;

%%%% PRODUCT LOOP %%%%
for p=1:length(prods) 
    
% Define year range here (will need to extend for 2019 and beyond)
num_years=yr_end-yr_start+1;

% UPDATE: July 2024
% Datestamp from L3_1D files is yyyymmdd
yrs_img=str2num(flnms_str(:,2:5)); 
mos_img=str2num(flnms_str(:,6:7));
days_img=str2num(flnms_str(:,8:9)); 
dttime = datetime(yrs_img,mos_img,days_img,0,0,0);
numfiles=size(flnms_str,1);
[doy_img,~]=date2doy(datenum(dttime)); 

% Create sat year and doy fields to use with 8d index
% img_yrs=str2num(flnms_str(:,2:5)); % mapped
% img_doy=str2num(flnms_str(:,6:8)); % mapped

% Trim doy and filenames to desired time interval 
mac_tmp=(yrs_img >= yr_start & yrs_img <=yr_end);
img_doy_trim=doy_img(mac_tmp);
flnms_trim=flnms_str(mac_tmp,:);

% Loop on 7-day intervals using info from filenames
num_bins=num_years*bins_peryr;
mac_bin_ind=zeros(bins_peryr,120); 

% Find indeces of images in each 7d bin 
% Omit loop on years here for MAC
j=1;
for i=1:bins_peryr
img_tmp=find(img_doy_trim >= ind_7D(i,1) & img_doy_trim <= ind_7D(i,2));  
img_tmp2=length(img_tmp);
mac_bin_ind(j,1:img_tmp2)=img_tmp;
outnm_startday(j,:) = sprintf('%03d',ind_7D(i,1));
outnm_endday(j,:) = sprintf('%03d',ind_7D(i,2));
j=j+1;
end % j  

% Remove rows where 1st column is zero in bin_ind array
mac_bin_ind(mac_bin_ind(:,1)==0,:)=[];

% Bin tests
% bin1_test=flnms_trim(mac_bin_ind(1,:),:);


%%%%%%%%%%%%%%%%%%%  BEGIN FULL LOOP  %%%%%%%%%%%%%%%%%%
% Run loop to open all files in each bin 
for i=1:size(mac_bin_ind,1) % Loop on all 52 7D bins 
tmp1=mac_bin_ind(i,:);
if sum(tmp1)>=0; tmp2=tmp1(tmp1>0); end
tmp3=flnms_trim(tmp2,:);

% Loop through images in bin
cd(file_path)
for h=1:size(tmp3,1) % Loop on files in each 7D bin
tmp4=tmp3(h,:);
[prod]=open_nc(tmp4,prods{p});
% Get lat/lon info from file
[lat_out]=open_nc(tmp4,'lat');
[lon_out]=open_nc(tmp4,'lon');
lat_lims=[min(lat_out(:)),max(lat_out(:))]; 
lon_lims=[min(lon_out(:)) max(lon_out(:))];
ysz=size(lat_out,1);
xsz=size(lon_out,2);

% Filter using STRAYLIGHT MASK (must be created during mosaicing and included in L3 file
if strcmp('OC',prod_class) == 1 || strcmp('IOP',prod_class) == 1
[sl_mask]=open_nc(tmp4,'STRAYLIGHT_MASK');
prod(sl_mask==1)=NaN;
end

% Create stack of images in 7d bin
prod_stack_tmp(:,:,h)=prod;
end % h
cd(path_main)

% Convert zeros to NaN (areas with no data)
prod_stack_tmp(prod_stack_tmp <= 0 | prod_stack_tmp > 100)=NaN;

%%%%%%%%%%%%%    CALCULATE MEANS    %%%%%%%%%%%%%%
% Prior to output, mean all images in 8-day stack
% Use "_out" as a suffix 
% Use log-transformed mean for all chl products
if strcmp('chlor_a',prods{p}) == 1 || strcmp('nflh',prods{p}) == 1
prod_out = 10.^(median(log10(prod_stack_tmp),3,'omitnan'));
end
% For non-chl products use normal arithmetic mean
if strcmp('chlor_a',prods{p}) == 0 || strcmp('nflh',prods{p}) == 0
prod_out = median(prod_stack_tmp,3,'omitnan');
end

% Stack means
eval(['' prods{p} '_clim_stack(:,:,i)=prod_out;'])
disp(i)
end % i (files)
clear prod prod_out prod_stack_tmp tmp1 tmp2 tmp3 tmp4
%%%%%%%%%%%%%    OUTPUT    %%%%%%%%%%%%%%
cd(path_out)
% Ouput .mat file with all bands
if strcmp(sensor,'MODA')==1
prefix='A';
end
if strcmp(sensor,'VSNPP')==1
prefix='V';
end
eval(['save ' prefix '' num2str(yr_start) '_' num2str(yr_end) '_7D_CLIM_' roi '_' prods{p} '_SLm.mat ' prods{p} '_clim_stack'])

% Output as a single .nc file with bands for each 7D climatology bin
eval(['out_file = ''' prefix '' num2str(yr_start) '_' num2str(yr_end) '_7D_CLIM_' roi '_' prods{p} '_SLm.nc'''])
ncid_out = netcdf.create(out_file,'NETCDF4');
% Define Constant for Global Attibutes
NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
% Define dimensions
dimid_y = netcdf.defDim(ncid_out,'img_y',ysz);
dimid_x = netcdf.defDim(ncid_out,'img_x',xsz);
% Add other params to output NC file
% Global attributes
netcdf.putAtt(ncid_out,NC_GLOBAL,'Region',roi_desc)
netcdf.putAtt(ncid_out,NC_GLOBAL,'Product',prods{p})
netcdf.putAtt(ncid_out,NC_GLOBAL,'Units',units{p})
netcdf.putAtt(ncid_out,NC_GLOBAL,'Time interval','7-Day Climatology')
if strcmp(sensor,'MODA')==1
netcdf.putAtt(ncid_out,NC_GLOBAL,'Sensor','MODIS-Aqua')
end
if strcmp(sensor,'VSNPP')==1
netcdf.putAtt(ncid_out,NC_GLOBAL,'Sensor','VIIRS-SNPP')
end
netcdf.putAtt(ncid_out,NC_GLOBAL,'Original Image Source','NASA Ocean Biology Processing Group')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Original Image Format','Level-2(NetCDF)')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Processing version','r2022')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Ocean color masks based on L2_flags','LAND,CLDICE,HIGLINT')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Projection','Equidistant Cylindrical')
eval(['netcdf.putAtt(ncid_out,NC_GLOBAL,''Image size'',''' num2str(ysz) ' pixels(N-S) x ' num2str(xsz) ' pixels(E-W)'');']) 
eval(['netcdf.putAtt(ncid_out,NC_GLOBAL,''Lat-Lon Limits'',''' num2str(lat_lims(1)) 'N to ' num2str(lat_lims(2)) 'N ' num2str(lon_lims(1)) 'W to ' num2str(lon_lims(2)) 'W'');']) 
netcdf.putAtt(ncid_out,NC_GLOBAL,'Processing and binning','USF IMaRS')
netcdf.putAtt(ncid_out,NC_GLOBAL,'Contact','Dan Otis - dotis@usf.edu')
netcdf.putAtt(ncid_out,NC_GLOBAL,'CreationDate',datestr(now,'mm/dd/yyyy HH:MM:SS'))
eval(['netcdf.putAtt(ncid_out,NC_GLOBAL,''Climatology start date'',''' num2str(yr_start) ''')'])
eval(['netcdf.putAtt(ncid_out,NC_GLOBAL,''Climatology end date'',''' num2str(yr_end) ''')'])

% Write variables into file (use loop to create NetCDF bands for each week)
for l=1:bins_peryr
% Define variables
eval(['prod_clim_varid' num2str(l) ' = netcdf.defVar(ncid_out,''' prods{p} '_climatology_week' num2str(l) ''',''NC_DOUBLE'',[dimid_x dimid_y]);'])
eval(['tmp_out=' prods{p} '_clim_stack(:,:,l)'';']) 
eval(['netcdf.putVar(ncid_out,prod_clim_varid' num2str(l) ',tmp_out)'])
end % l (bins_peryr)

% Add lat/lon outside of loop
lon_varid = netcdf.defVar(ncid_out,'longitude','NC_DOUBLE',[dimid_x dimid_y]);
lat_varid = netcdf.defVar(ncid_out,'latitude','NC_DOUBLE',[dimid_x dimid_y]);
netcdf.putVar(ncid_out,lon_varid,lon_out') 
netcdf.putVar(ncid_out,lat_varid,lat_out')

% Close output file
netcdf.close(ncid_out)
cd(path_main)

% Clean up
clear prod_stack_tmp mac_bin_ind sl_mask

end % p (prod)

dummy=1;








