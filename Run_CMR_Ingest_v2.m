% RUN_CMR_INGEST_v2.M
% Written by Dan Otis, February 2025
% Runs function to download data using CMR

% Sensor/Collection IDs:
% PACE: PACE_OCI_L2_BGC_NRT, PACE_OCI_L2_AOP_NRT, PACE_OCI_L2_IOP_NRT
% MODA: MODISA_L2_OC_NRT
% VSNPP: VIIRSN_L2_OC_NRT, VIIRSN_L2_SST_NRT (how to specify SSTN?)
% VIIRS-NOAA20: VIIRSJ1_L2_OC_NRT
% VIIRS-NOAA21: VIIRSJ2_L2_OC_NRT

% Questions:
% How to merge files w/NRT data (cron job each month to fill in)?

% OPTIONS:
% Could set up more of the params in function and simplify script
% Could have a separate function call for each sensor (w/simplified script)
% Could have a "recent" function call to just get last 5 days (cron)

% Version 2:
% Set params here in this script to call a more generalized function

clear
% Add paths
addpath('~/MATLAB_files/');
addpath('~/MATLAB_files/m_map');
addpath('~/MATLAB_files/export_fig');
addpath('~/MATLAB_files/jsonlab-2.0/jsonlab-2.0/');
addpath('~/DB_files/DB_v24');
addpath('/srv/pgs/rois2/ingest_tmp/');

% Set params (PACE)
sensor='PACE_OCI';
roi='florida';
pc='OC_BGC';
version='V3';
% Days to go back in time; 
% Set to zero for full time series
% Set to 999 for manual dates
rec_files=0;
% Set flag to use "NRT" collection with manual dates
NRT_flag=0;
startdate_mnl='2024-12-10';
enddate_mnl='2025-02-17';

% Set params (MODISA)
% sensor='MODISA';
% roi='gom';
% pc='OC';
% version='r2022';
% Days to go back in time; 
% Set to zero for full time series
% rec_files=5;

% Define output path (using new sensor names to match CMR collection IDs)
eval(['outpath = ''/srv/pgs/rois2/' roi '/L2_' sensor '_' version '/' pc ''';'])

% Define Bounding box (define one for each AOI)
% florida
if strcmp(roi,'florida')==1
bbox=([-86,24,-78.5,30]);
end
% gom
if strcmp(roi,'gom')==1
bbox=([-98,18,-78.5,31]);
end
% seus
if strcmp(roi,'seus')==1
bbox=([-82,29,-73,40.5]);
end
bbox_str=strcat(string(bbox(1)),',',string(bbox(2)),',',string(bbox(3)),',',string(bbox(4)));

% Set start date
today_mltime=now;
if rec_files > 0 && rec_files < 30 % Defaults to NRT
startdate=datestr(today_mltime-rec_files,'YYYY-mm-DD');
enddate=datestr(today_mltime+2,'YYYY-mm-DD');
eval(['collection=''' sensor '_L2_' pc '_NRT'';']) % NRT Collection for last 30 days of recent files only
end

if rec_files > 30  % Defaults to non-NRT
startdate=datestr(today_mltime-rec_files,'YYYY-mm-DD');
eval(['collection=''' sensor '_L2_' pc ''';']) % NRT Collection for last 30 days of recent files only
enddate=datestr(today_mltime+2,'YYYY-mm-DD');
disp('WARNING: Need NRT collection for recent files')
end

if rec_files==0
startdate='2000-01-01'; 
eval(['collection=''' sensor '_L2_' pc ''';']) % full Collection for all files (around a month behind)
enddate=datestr(today_mltime+2,'YYYY-mm-DD'); % Last five days
end

% Manual date entry
if rec_files==999
startdate=startdate_mnl;
endate=enddate_mnl;
if NRT_flag==1
eval(['collection=''' sensor '_L2_' pc '_NRT'';']) % NRT Collection for last 30 days of recent files only
end
if NRT_flag==0
eval(['collection=''' sensor '_L2_' pc ''';']) % NRT Collection for last 30 days of recent files only
end
end

% [dummy]=CMR_Ingest_Function_v2(sensor,pc,collection,bbox_str,startdate,enddate,outpath);


