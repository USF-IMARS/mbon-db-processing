% mosaic_1D_func_MODA250_vGEETIF.M
% Written by Dan Otis, July 2023
% Script to use GPT mosaic operator to create daily means of MODA 250m data



clear 

% addpath('/srv/imars-objects/homes/dotis/MATLAB_files/')
% addpath('/srv/imars-objects/homes/dotis/DB_files/DB_v24')
% Filepaths for seashell
addpath('~/MATLAB_files/')
addpath('~/DB_files/DB_v24')


roi='USVI';
% path_L2='/srv/imars-objects/tpa_pgs/rois2/tampa_bay/L2_MODA_r2022/OC/';
path_L2='/srv/pgs/rois2/usvi/L2_A250_NOSLM/';

% path_L3='/srv/imars-objects/tpa_pgs/rois2/tampa_bay/L3_1D_MODA_RRS/OC/';
path_L3='/srv/pgs/rois2/usvi/L3_A250_NOSLM/';

% xml_file='/home1/dotis/DB_files/DB_v24/xml_files/map_TB_gom_OC_RRS.xml';
xml_file='/srv/pgs/rois2/usvi/map_USVI_A250.xml';


eval(['flnms_tmp=struct2cell(dir(''' path_L2 '/*.L2''));']) 

% Extract filename
flnms_str=char(flnms_tmp(1,:));
num_files=size(flnms_str,1);


% NEW filenames: Define DOY using datetime;
% CHANGED AS OF 6/25/2024
% datestr_in=flnms_str(:,[12:19,21:26]);
datestr_in=flnms_str(:,2:14);
% dateformat='yyyyMMddHHmmss'; 
dateformat='uuuuDDDHHmmss'; 
dttime=datetime(datestr_in,'InputFormat',dateformat);
years=year(dttime);
months=month(dttime);
days=day(dttime);
doy=day(dttime,'dayofyear');
yrs_tmp = num2str(years,'%02.f');
day_tmp = num2str(days,'%02.f');
month_tmp = num2str(months,'%02.f');
datestamp=strcat(yrs_tmp,month_tmp,day_tmp);

% Find days with at least one image
% days=unique(mltime_tmp); % Needed?

bins_peryr=366;
ind_1D=(1:1:366);

% Define year range here
years_lp=(min(years):max(years));
num_years=size(years_lp,2);

% Find indeces of images in each 8d bin for OC and SST
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
date_out=datestamp(tmp_2(1),:);
end

outfile=strcat('A',date_out,'_',roi,'_1KM_1D.nc');
% Seashell
% eval(['command_map=''/opt/snap_6_0/bin/gpt ' xml_file ' -t ' path_L3 'A' date_out '_' roi '_1KM_1D.nc -f NetCDF-CF ' files_out ''';'])
% Manglillo
eval(['command_map=''/opt/esa-snap/bin/gpt ' xml_file ' -t ' path_L3 'A' date_out '_' roi '_1KM_1D.tif -f GeoTIFF ' files_out ''';'])
eval(['command_cd=''chmod 777 ' path_L3 '*'';'])

% Print path and 1st filename to double-check
disp(path_L2)
disp(tmp_4)
disp(outfile)

% Clean up
clear tmp_1 tmp_2 tmp_3 tmp_4 tmp_5 tmp_6 tmp_7 tmp_8 tmp_9 tmpdays files_out file_start time_start file_end time_end
system(command_map);
system(command_cd);

end % (files loop)
dummy=1;

