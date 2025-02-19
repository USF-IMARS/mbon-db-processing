% CMR_PACE_OCI_INGEST.M
% Written by Dan Otis, February 2025

% Queries and downloads data from NASA's
% Common Metadata Repository (CMR)
% Avoids OBPG subscriptions, which will deprecate at some point
% Need to call bash script with arguments

% Params:
% Sensor
% Collection
% # of recent files to ingest
% Bounding Box
% Product class (pc) (AOP, BGC, IOP)
% Output directory

% Test
clear
roi='florida';
sensor='PACE_OCI';
pc='AOP';
rec_files=0; % Days to go back in time; Set to zero for full time series

% Bounding box (define one for each AOI)
bbox=([-86,24,-78.5,30]); % Florida
bbox_str=strcat(string(bbox(1)),',',string(bbox(2)),',',string(bbox(3)),',',string(bbox(4)));


% Set start date
today_mltime=now;
if rec_files > 0
start_date=datestr(today_mltime-rec_files,'YYYY-mm-DD');
eval(['collection=''' sensor '_L2_' pc '_NRT'';']) % NRT Collection for last 30 days of recent files only
end

if rec_files==0
start_date='2024-03-05';
eval(['collection=''' sensor '_L2_' pc ''';']) % full Collection for all files (around a month behind)
end

end_date=datestr(today_mltime+2,'YYYY-mm-DD'); % Last five days



% Set URL for curl call
% Set path
eval(['cd(''/srv/pgs/rois2/' roi '/L2_' char(sensor) '_V3/'')'])

eval(['call_bash=''bash ./' char(sensor) '_CMR.sh ' char(collection) ' ' char(start_date) ' ' char(end_date) ' ' char(bbox_str) ' ' char(pc) ''';'])


system(call_bash);