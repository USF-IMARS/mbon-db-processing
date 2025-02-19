% CMR_INGEST_FUNCTION.M
% Written by Dan Otis, February 2025

% Queries and downloads data from NASA's Common Metadata Repository (CMR)
% Avoids OBPG subscriptions, which will deprecate at some point
% Need to call bash script with arguments
% This function will work for any data from CMR; must know collection ID

% Params:
% Sensor
% Collection
% # of recent files to ingest
% Bounding Box
% Product class (pc) (OC, SST, AOP, BGC, IOP)
% Output directory



%%%%%%%% Test %%%%%%%%
% clear
% sensor='PACE_OCI';
% roi='florida';
% pc='AOP';
% version='V3';
% rec_files=5; % Days to go back in time; Set to zero for full time series

% Add paths
% addpath('~/MATLAB_files/');
% addpath('~/MATLAB_files/m_map');
% addpath('~/MATLAB_files/export_fig');
% addpath('~/MATLAB_files/jsonlab-2.0/jsonlab-2.0/');
% addpath('~/DB_files/DB_v24');
%%%%%%%%%%%%%%%%%%%%%

% Set function here:
function[dummy]=CMR_Ingest_Function_v2(sensor,pc,collection,bbox_str,startdate,enddate,outpath)

% Set path to temp directory (all sensors and ROI)
cd('/srv/pgs/rois2/ingest_tmp/')

% Set main directory
path_main='~/DB_files/DB_v24';

% Set URL for curl call
eval(['call_bash=''bash ./Ingest_CMR.sh ' char(collection) ' ' char(startdate) ' ' char(enddate) ' ' char(bbox_str) ' ' char(sensor) ' ' char(pc) ' ' char(outpath) ''';'])

system(call_bash);
cd(path_main)

dummy=1;
