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
pc='OC'; % Use SSTN for VIIRS nighttime SST
roi='seus';
roi_2='SEUS';
sensor='MODA';
sub=0; % Indicates to be used with recent files from subscription directories
rec_files=0; % Number of most recent files to process; Set to zero for all recent files 

% function[dummy]=MOSAIC_1D_func_dbv24(roi,roi_2,pc,sub,rec_files,sensor)

% Output directories based on region
% if strcmp(roi_2,'FK')==1 || strcmp(roi_2,'FGB')==1
% eval(['path_L3=''/srv/imars-objects/' roi '/L3_1D_' sensor '/' pc '/'';'])
% end
%  GOM and SEUS on tpa_pgs
if strcmp(roi_2,'GOM')==1 || strcmp(roi_2,'SEUS')==1
eval(['path_L3=''/srv/pgs/rois2/' roi '/L3_1D_' sensor '/' pc '/'';'])
end

% XML files w/product and projection info
eval(['xml_file=''~/DB_files/DB_v24/xml_files/map_' sensor '_' roi '_' pc '.xml'';']) % Need to add sensor

% Input files (ALL input files are in "gom")
if sub==0 && strcmp(pc,'OC')==1
eval(['path_L2=''/srv/pgs/rois2/' roi '/L2_' sensor '_r2022/' pc '/'';']) % Updated OC files in separate directory
end
if sub==0 && strcmp(pc,'SST4')==1
eval(['path_L2=''/srv/pgs/rois2/' roi '/L2_' sensor '_r2022/' pc '/'';']) 
end
if sub==0 && strcmp(pc,'SSTN')==1
eval(['path_L2=''/srv/pgs/rois2/' roi '/L2_' sensor '_r2022/' pc '/'';']) 
end
if sub==0 && strcmp(pc,'SST')==1
eval(['path_L2=''/srv/pgs/rois2/' roi '/L2_' sensor '_r2022/' pc '/'';']) 
end

if sub==1 && strcmp(pc,'SSTN')==1
eval(['path_L2=''/srv/pgs/rois2/' roi '/L2_' sensor '_sub/' pc '/'';']) % For GOM only 
end
if sub==1 && strcmp(pc,'SST4')==1
eval(['path_L2=''/srv/pgs/rois2/' roi '/L2_' sensor '_sub/'';']) % For GOM only 
end
if sub==1 && strcmp(pc,'SST')==1
eval(['path_L2=''/srv/pgs/rois2/' roi '/L2_' sensor '_sub/'';']) % For GOM only 
end
if sub==1 && strcmp(pc,'OC')==1
eval(['path_L2=''/srv/pgs/rois2/' roi '/L2_' sensor '_sub/'';']) % For GOM only 
end

% List input files
if sub==0
eval(['flnms_tmp=struct2cell(dir(''' path_L2 '/*.nc''));']) 
end

if sub==1 && strcmp(pc,'SSTN')==1
eval(['flnms_tmp=struct2cell(dir(''' path_L2 '*.L2.*nc''));']) % Use for subscription files
end
if sub==1 && strcmp(pc,'SST4')==1
eval(['flnms_tmp=struct2cell(dir(''' path_L2 '*.L2.' pc '.*nc''));']) % Use for subscription files
end
if sub==1 && strcmp(pc,'SST')==1
eval(['flnms_tmp=struct2cell(dir(''' path_L2 '*.L2.' pc '.*nc''));']) % Use for subscription files
end
if sub==1 && strcmp(pc,'OC')==1
eval(['flnms_tmp=struct2cell(dir(''' path_L2 '*.L2.' pc '.*nc''));']) % Use for subscription files
end

% Add sensor IDs
if strcmp (sensor,'MODA')==1
sensor_prefix='A';
end

if strcmp (sensor,'VSNPP')==1
sensor_prefix='V';
end

% Extract filename
flnms_str=char(flnms_tmp(1,:));
num_files=size(flnms_str,1);

% NEW filenames: Define DOY using function from Y/M/D;
% CHANGED AS OF 8/1/2022
% UPDATE (6/12/24): Output files now have Y/M/D format (not DOY)
yrs=str2num(flnms_str(:,12:15));
mos=str2num(flnms_str(:,16:17));
days=str2num(flnms_str(:,18:19));
mltime=datenum(yrs,mos,days,0,0,0);
doy=date2doy(mltime);
yrs_tmp = num2str(yrs);
mos_tmp = num2str(mos,'%02.f');
day_tmp = num2str(days,'%02.f');
doy_tmp = num2str(doy,'%03.f');
datestamp=strcat(yrs_tmp,doy_tmp);
datestamp_ymd=strcat(yrs_tmp,mos_tmp,day_tmp);

% Find days with at least one image
% days=unique(mltime); 
% num_days=length(days); % Needed?

bins_peryr=366;
ind_1D=(1:1:366);

% Define year range here
years=(min(yrs):max(yrs));
num_years=size(years,2);

% Find indeces of images in each 1d bin for OC and SST
j=1;
for h=1:num_years
for i=1:bins_peryr
oc_tmp=find(yrs == years(h) & doy == ind_1D(i));
oc_tmp2=length(oc_tmp);
DAY_bin_ind(j,1:oc_tmp2)=oc_tmp;
j=j+1;
end % i
end % h

% Remove rows where 1st column is zero in XX_8d-bin_ind arrays
DAY_bin_ind(DAY_bin_ind(:,1)==0,:)=[];

% Loop through input files (Or, can subset using yrs, doy)
begin=1; % All files
if sub==1
if rec_files>0    
begin=size(DAY_bin_ind,1)-rec_files; % Most recent files only
end
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
date_tmp=datestamp_ymd(tmp_2,:);
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

