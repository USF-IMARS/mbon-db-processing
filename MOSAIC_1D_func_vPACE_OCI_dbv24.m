% mosaic_1D_func_vDB.M
% Written by Dan Otis, September 2018
% Revised January 2023
% Function which uses GPT mosaic operator to create daily means of MODA data
% vDB is to create 1D dashboard files 
% Current version is GOMdb_v2023
% GOM version for use with VIIRS-SNPP and MODIS-Aqua data
% Two product streams: OC, SST, SSTN/4
% User also selects ROI (FK, FGB, WFS)
% 1 day time step (daily mosaic)
% Change xml file(s) to determine output products and projection details

% TEST
clear
pc='OC_AOP'; % PACE files are OC_BGC (chlor_a and others) or OC_AOP (rrs and nflh)
roi='florida';
sensor='PACE_OCI';
version='V3_0';
sensor_prefix='P';
rec_files=0; % Number of most recent files to process; Set to zero for all recent files 

% No longer using subscription services for PACE_OCI
% Need to deal with NRT vs non-NRT files in this function
% For recent files, just use NRT
% Then, once per month, update older files to non-NRT

% Run as a function for automated processing
% function[dummy]=MOSAIC_1D_func_vPOCI(roi,roi_2,roi_out,pc,sub,rec_files,sensor)

% Output path
eval(['path_L3=''/srv/pgs/rois2/' roi '/L3_1D_' sensor '/' pc '/'';'])

% XML files w/product and projection info
eval(['xml_file=''~/DB_files/DB_v24/xml_files/map_' sensor '_' roi '_' pc '.xml'';']) 

% Input files (ALL input files are in "gom")
eval(['path_L2=''/srv/pgs/rois2/' roi '/L2_' sensor '_' version '/' pc '/'';']) 

% Need to break out input files into two bins: NRT and non-NRT
% List non-NRT input files
eval(['flnms_tmp=struct2cell(dir(''' path_L2 '/' sensor '.*.' pc '.' version '.nc''));']) 
% NRT files
eval(['flnms_tmp_nrt=struct2cell(dir(''' path_L2 '/' sensor '.*.' pc '.' version '.NRT.nc''));']) 


% Extract filename
flnms_str=char(flnms_tmp(1,:));
flnms_str_nrt=char(flnms_tmp_nrt(1,:));
num_files=size(flnms_str,1);
num_files_nrt=size(flnms_str_nrt,1);




% NEW filenames: Define DOY using function from Y/M/D;
% CHANGED AS OF 8/1/2022
% UPDATE (6/12/24): Output files now have Y/M/D format (not DOY)
% UPDATE (6/26/24): Deprecate use of datenum 
datestr_in=flnms_str(:,[10:17,19:24]);
dateformat='yyyyMMddHHmmss';
dttime=datetime(datestr_in,'InputFormat',dateformat);
years=year(dttime);
months=month(dttime);
days=day(dttime);
doy=day(dttime,'dayofyear');
yrs_tmp = num2str(years,'%02.f');
day_tmp = num2str(days,'%02.f');
month_tmp = num2str(months,'%02.f');
datestamp=strcat(yrs_tmp,month_tmp,day_tmp);

bins_peryr=366;
ind_1D=(1:1:366);

% Define year range here
years_lp=(min(years):max(years));
num_years=size(years_lp,2);

% Find indeces of images in each 1d bin for OC and SST
j=1;
for h=1:num_years
for i=1:bins_peryr
oc_tmp=find(years == years_lp(h) & doy == ind_1D(i));
oc_tmp2=length(oc_tmp);
DAY_bin_ind(j,1:oc_tmp2)=oc_tmp;
j=j+1;
end % i
end % h

% Remove rows where 1st column is zero in XX_8d-bin_ind arrays
DAY_bin_ind(DAY_bin_ind(:,1)==0,:)=[];

% Loop through input files (Or, can subset using yrs, doy)
begin=1; % All files
if rec_files>0    
begin=size(DAY_bin_ind,1)-rec_files; % Most recent files only
end

if begin <= 0; begin=1; end

% % Manual override
% begin=size(DAY_bin_ind,1)-130; % Recent files
% begin=1800; % Manual start

%%%% MAIN LOOP %%%%
for i=begin:size(DAY_bin_ind,1)

tmpdays=(DAY_bin_ind(i,:)>0);

% Define files to open
tmp_1=DAY_bin_ind(i,tmpdays);
if sum(tmp_1)>=0; tmp_2=tmp_1(tmp_1>0); end
tmp_3=flnms_str(tmp_2,:);
tmp_4=flnms_tmp(1,tmp_1);
% Concatenate input filenames into single string(!)
for k=1:size(tmp_3,1)
tmp_6=cat(2,path_L2,tmp_4(k));
tmp_7=strjoin(tmp_6);
tmp_8=tmp_7(~isspace(tmp_7));
tmp_9{k}=tmp_8;
files_out=strjoin(tmp_9);
% Create filename for output (Keep doy convention for now)
date_tmp=datestamp(tmp_2,:);
time_start=date_tmp(1,:);
time_end=date_tmp(end,:);
end

outfile=strcat(sensor_prefix,time_start,'_',roi_2,'_',pc,'_1D.nc');
% Call to mangillo gpt
eval(['command_map=''/opt/esa-snap/bin/gpt ' xml_file ' -t ' path_L3 '' sensor_prefix '' time_start '_' roi_2 '_' pc '_1D.nc -f NetCDF4-CF ' files_out ''';'])

% Call to seashell gpt
% eval(['command_map=''/opt/snap_6_0/bin/gpt ' xml_file ' -t ' path_L3 '' sensor_prefix '' time_start '_' roi_2 '_' pc '_1D.nc -f NetCDF4-CF ' files_out ''';'])

eval(['command_cd=''chmod 777 ' path_L3 '*'';'])

% Print path and 1st filename to double-check
disp(path_L2)
disp(tmp_4{1})
disp(outfile)

% Clean up
clear tmp_1 tmp_2 tmp_3 tmp_4 tmp_5 tmp_6 tmp_7 tmp_8 tmp_9 tmpdays files_out file_start time_start file_end time_end
system(command_map);
system(command_cd);

end % (files loop)
dummy=1;

