% TXT2CSV_USGS_SEUS_DBV24.M
% Written by Dan Otis, November 2018
% Revised June 2024
% Retrieves USGS daily river discharge data from downloaded txt files


clear

addpath('~/MATLAB_files/');
addpath('~/MATLAB_files/m_map');
addpath('~/MATLAB_files/export_fig');

% Set directories (use server)
path_main = '~/DB_files/DB_v24/';
file_path = '/srv/pgs/rois2/seus/USGS_temp/';
path_out='/srv/pgs/rois2/seus/csv_ts_data/data/';

% Set years for start and end of climatologies
yr_mac_st=2013;
yr_mac_end=2019;

% Names of rivers (add others later)
short_name={'SavannahRv','HudsonCr','AltamahaRv','SatillaRv','StJohnsRv','OgeecheeRv','BrunswickRv','StMarysRv'}; 

% for k=1
for k=1:length(short_name)
% Use line below to omit certain files if needed
% Or, treat some files differently (# of headerlines)
if (k==1) || (k==2) || (k==3) || (k==4) || (k==6)
eval(['fid = fopen(''' file_path '' short_name{k} '_GH.txt'');'])
raw_data=textscan(fid, '%s %d %s %f %s %f %s' ,'HeaderLines',32);
fclose(fid);
time = datetime(raw_data{:,3});
% Create mltime vector for binning
mltime = datenum(time);
gh_high = raw_data{:,4};
% Convert GH to m
gh_m = gh_high*0.3048;
% Bin to create clims and anoms
[daily,~,~,~,~]=time_series_bin_vFGBdb(double(gh_m),mltime,yr_mac_st,yr_mac_end);
dttime=datetime(daily(:,1),'ConvertFrom','datenum','Format','yyyy-MM-dd');
dttime.Format = 'MM-dd-yyyy''T''HH:mm:ss''Z'; % Add comma to start of each row

% OUTPUT
cd(path_out)
eval(['filename = ''USGS_gh_' short_name{k} '_SEUSdb.csv'';'])
fileID=fopen(filename,'w');
% Add header
fprintf(fileID,'%1s,%2s,%3s,%4s\n','time','mean','climatology','anomaly');

% Write output
for m=1:length(dttime)
fprintf(fileID,'%1s,%.3f,%.3f,%.3f\n',dttime(m),daily(m,2:4));
end
fclose(fileID);
end
clear raw_data time mltime daily dttime gh_m gh_high
cd(path_main)

% Separate StJohnsRv (extra fields, more headerlines)
if k==5 || (k==7) || (k==8) 
eval(['fid = fopen(''' file_path '' short_name{k} '_GH.txt'');'])
raw_data=textscan(fid, '%s %d %s %f %s %f %s %f %s %f %s %f %s %f %s %f %s' ,'HeaderLines',37);
fclose(fid);
time = datetime(raw_data{:,3});
% Create mltime vector for binning
mltime = datenum(time);
gh_high = raw_data{:,4};
% Convert GH to m
gh_m = gh_high*0.3048;
% Bin to create clims and anoms
[daily,~,~,~,~]=time_series_bin_vFGBdb(double(gh_m),mltime,yr_mac_st,yr_mac_end);
dttime=datetime(daily(:,1),'ConvertFrom','datenum','Format','yyyy-MM-dd');
dttime.Format = 'MM-dd-yyyy''T''HH:mm:ss''Z'; % Add comma to start of each row

% OUTPUT
cd(path_out)
eval(['filename = ''USGS_gh_' short_name{k} '_SEUSdb.csv'';'])
fileID=fopen(filename,'w');
% Add header
fprintf(fileID,'%1s,%2s,%3s,%4s\n','time','mean','climatology','anomaly');

% Write output
for m=1:length(dttime)
fprintf(fileID,'%1s,%.3f,%.3f,%.3f\n',dttime(m),daily(m,2:4));
end
fclose(fileID);
end    
    
end
clear raw_data time mltime daily unixtime usertime gh_m gh_high
cd(path_main)


