% TS_BIN_CSV_FUNC_vDBV2.M
% Written by Dan Otis, January 2019
% Revised January 2022
% Generic function to bin and filter extracted satellite data
% Extracts data from .mat files
% Outputs to .csv for dashboard
% This could be replaced by a py/R routine to extract direct from ERDDAP

% Test
% clear
% sensor='VSNPP';
% roi_2='SEUS';
% roi='seus';
% prod_class='OC';
% prods={'chlor_a','Rrs_671','Kd_490'}; % VSNPP OC

function[dummy]=MAT2CSV_sat_func_dbv24(sensor,roi,roi_2,prod_class,prods)

cloud_thresh=0.75; % Cloud % to use as filtering threshold

% Set years for MAC (MODA)
if strcmp(sensor,'MODA')==1
yr_mac_st=2003;
yr_mac_end=2019;
end

% Set years for MAC (VSNPP)
if strcmp(sensor,'VSNPP')==1
yr_mac_st=2013;
yr_mac_end=2019;
end

% Set filepaths, lat/lon limits, and x/y sizes
path_main='~/DB_files/DB_v24';

% OUTPUT PATH
% For now, output csv to "gom"
eval(['path_out=''/srv/pgs/rois2/' roi '/csv_ts_data/data'';'])

% In the future, use this directory:
% eval(['path_out=''/srv/imars-objects/tpa_pgs/rois/' roi '/extracted_sat_ts_seus_csv_data/data'';'])

%%%% PRODUCT LOOP %%%%
for p=1:length(prods)  
   
% Load raw, unbinned t-s data from file by roi and prod(s) to extract
% Load both recent and historical data
% Old (clip at 12/31/2022)
eval(['load /srv/pgs/rois2/' roi '/EXT_TS_' sensor '/' roi_2 'dbv24_' prods{p} '_TS_' sensor '_1D_raw_vHISTORICAL.mat'])
ts_old_tmp = ts_tmp;
clear ts_tmp

% Recent (append from 1/1/2023)
eval(['load /srv/pgs/rois2/' roi '/EXT_TS_' sensor '/' roi_2 'dbv24_' prods{p} '_TS_' sensor '_1D_raw_vRECENT.mat'])

%%%% BINNING AND OUPUT %%%%%
% Point extractions
% Set list of indeces here to indicate which stations to extract

% Use list of indeces here to only process certain stations
for s=1:length(ts_tmp) 
    % Need to pull out of structure variable
ts_time=ts_old_tmp(s).dttime;
%%%%%% NEEDS TO BE UPDATED EACH YEAR %%%%%%
% Only 365 days are processed for "recent" files
% At the beginning of each year, need to re-extract and update "old" files and change "cut" dates
time_cut=find(ts_time=='01-Jan-2025'); % 1/1/2025
% Can we use dttime here?

ts_time(time_cut:end)=[];
ts=ts_old_tmp(s).mn; ts(time_cut:end)=[];% Mean of 3x3 box
tscld=ts_old_tmp(s).bxcld; tscld(time_cut:end)=[];% Cloud/bad pixels of 3x3 box 
tsbox=ts_old_tmp(s).bxtot; tsbox(time_cut:end)=[];% Cloud/bad pixels of 3x3 box 
tscldperc=tscld./tsbox; % Cloud perc. 3x3

% ts5=ts_old_tmp(s).mn5; ts5(time_cut:end)=[];% Mean of 5x5 box
% tscld5=ts_old_tmp(s).bxcld5; tscld5(time_cut:end)=[]; % Cloud/bad pixels of 5x5 box 
% tsbox5=ts_old_tmp(s).bxtot; tsbox5(time_cut:end)=[]; % Cloud/bad pixels of 5x5 box 
% tscldperc5=tscld5/tsbox5; % Cloud perc. 5x5

% Cloud filter (by % - set threshold above)
ts(tscldperc>cloud_thresh)=NaN; 
% ts5(tscldperc5>cloud_thresh)=NaN; 

% RECENT VALUES
ts_timenew=ts_tmp(s).dttime;
%%%%%% NEEDS TO BE UPDATED EACH YEAR %%%%%%
% Only 365 days are processed for "recent" files
% At the beginning of each year, need to re-extract and update "old" files and change "cut" dates
time_cutnew=find(ts_timenew=='31-Dec-2024'); % 12/31/2024
ts_timenew(1:time_cutnew)=[];
tsnew=ts_tmp(s).mn; tsnew(1:time_cutnew)=[];% Mean of 3x3 box
tscldnew=ts_tmp(s).bxcld; tscldnew(1:time_cutnew)=[];% Cloud/bad pixels of 3x3 box 
tsboxnew=ts_tmp(s).bxtot; tsboxnew(1:time_cutnew)=[];% Cloud/bad pixels of 3x3 box 
tscldpercnew=tscldnew./tsboxnew; % Cloud perc. 3x3

% ts5new=ts_tmp(s).mn5; ts5new(1:time_cutnew)=[];% Mean of 5x5 box
% tscld5new=ts_tmp(s).bxcld5; tscld5new(1:time_cutnew)=[]; % Cloud/bad pixels of 5x5 box 
% tsbox5new=ts_tmp(s).bxtot; tsbox5new(1:time_cutnew)=[]; % Cloud/bad pixels of 5x5 box 
% tscldperc5new=tscld5new/tsbox5new; % Cloud perc. 5x5

% Cloud filter (by % - set threshold above)
tsnew(tscldpercnew>cloud_thresh)=NaN; 
% ts5new(tscldperc5new>cloud_thresh)=NaN; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create unified data series here
ts_time_out = cat(2,ts_time,ts_timenew);
ts_out = cat(2,ts,tsnew);
% ts5_out = cat(2,ts5,ts5new);

% Standard deviation filter? Maybe if not using STRAYLIGHT mask

% Need to convert to mltime for binning
ts_time_out=datenum(ts_time_out);

% Bin to daily and weekly intervals
[daily,~,~,~,~]=time_series_bin_vFGBdb(double(ts_out)',double(ts_time_out)',yr_mac_st,yr_mac_end);
% [daily5,weekly5,~,~,~]=time_series_bin_vFGBdb(double(ts5_out)',double(ts_time_out)',yr_mac_st,yr_mac_end);

disp(s)
%%%% OUTPUT %%%%
cd(path_out)
%%% Output to .csv files (Separate file for each location)
loc_name=char(ts_tmp(s).roiname);
% Daily
% [dummy]=output_sat_csv_func_dbv2(daily,prods{p},'daily',roi_2,loc_name,path_out,sensor);

%%%% SELECT BOX SIZE %%%%
% 5x5
[dummy]=output_sat_csv_func_dbv24(daily,prods{p},'daily',roi_2,loc_name,path_out,sensor);
% Weekly
% [dummy]=output_csv_func(weekly,prods{p},'weekly',roi,loc_name,path_out);
end
clear ts_time ts_tmp ts3 ts5 tscld3 tscld5 tsbox3 tsbox5 tscldperc3 tscldperc5





end % Prod Loop (p)

cd(path_main)
dummy=1;




