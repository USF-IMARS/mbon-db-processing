% GET_DISCHARGE_USGS.M
% Written by Dan Otis, November 2018
% Retrieves USGS daily river discharge data from URL


clear

addpath('~/MATLAB_files/');
addpath('~/MATLAB_files/m_map');
addpath('~/MATLAB_files/export_fig');

% Set directories (use server)
path_main = '~/DB_files/DB_v24';
file_path = '/srv/pgs/rois2/gom/USGS_temp/';
path_out='/srv/pgs/rois2/gom/csv_ts_data/data/';

% Texas Rivers and the Mississippi
short_name={'Sabine','Brazos','Colorado','Trinity','Neches','Miss'}; 

% Set years for start and end of climatologies
yr_mac_st=2013;
yr_mac_end=2019;


for k=[1:4,6] % skip Neches
    
% Define input file
% eval(['fid = fopen(''/srv/imars-objects/modis_aqua_fgbnms/FGB_USGS_tmp/' short_name{k} 'Rv_disch.txt'');'])
% raw_data=textscan(fid, '%s %d %s %f %s','HeaderLines',33);
% fclose(fid);

% Workaround for TX rivers (three cols. - mean,min,max)
% if k==7
eval(['fid = fopen(''' file_path '' short_name{k} 'Rv_disch.txt'');'])
raw_data=textscan(fid, '%s %d %s %f %s %f %s %f %s' ,'HeaderLines',33);
raw_data(:,6:9)=[];
fclose(fid);
% end

% Workaround NOT needed for Miss
time_raw=raw_data{3};
mltime=datenum(time_raw);
dttime=datetime(mltime,'ConvertFrom','datenum');
disch_ts=single(raw_data{4});
disch_ts(disch_ts==0)=NaN;

% Convert to m^3/sec
disch_m3=disch_ts*0.0283; 

% Bin
% [daily,~,~,~,~]=time_series_bin_v2(disch_m3,mltime);
% daily(isnan(daily(:,2)),:)=[];

% eval(['disch_' short_name{k} '=daily;'])
eval(['TT_' short_name{k} '=timetable(dttime,disch_m3);'])

clear disch_ts disch_m3 mltime time_raw raw_data

end

% Combine time-series over common time window
% TT=synchronize(TT_Sabine,TT_Brazos,TT_Colorado,TT_Trinity,TT_Neches,TT_Miss,'daily','mean');
TT=synchronize(TT_Sabine,TT_Brazos,TT_Colorado,TT_Trinity,TT_Miss,'daily','mean');

% Convert back to table and then sum over rivers - No Neches
table_TT=timetable2table(TT);
time_TT=table2array(table_TT(:,1));
data_TX=table2array(table_TT(:,2:5));
data_MS=table2array(table_TT(:,6));
data_all=table2array(table_TT(:,2:6));
sum_TX=nansum(data_TX,2);
sum_all=nansum(data_all,2);

% TX rivers
ts=sum_TX; 
ts_time=datenum(time_TT);
[daily_TX,~,~,~,~]=time_series_bin_vFGBdb(double(ts),ts_time,yr_mac_st,yr_mac_end);
disch_txt_out_TX=daily_TX;
dttime_TX=datetime(daily_TX(:,1),'ConvertFrom','datenum','Format','yyyy-MM-dd');
dttime_TX.Format = 'MM-dd-yyyy''T''HH:mm:ss''Z'; % Add comma to start of each row


% Mississippi
ts=data_MS; 
ts_time=datenum(time_TT);
[daily_MS,~,~,~,~]=time_series_bin_vFGBdb(double(ts),ts_time,yr_mac_st,yr_mac_end);
disch_txt_out_MS=daily_MS;
dttime_MS=datetime(daily_MS(:,1),'ConvertFrom','datenum','Format','yyyy-MM-dd');
dttime_MS.Format = 'MM-dd-yyyy''T''HH:mm:ss''Z'; % Add comma to start of each row

%%%% OUTPUT %%%%
cd(path_out)
% TX rivers
filename = 'USGS_disch_FGBdb_TX.csv';
fileID=fopen(filename,'w');
% Add header
fprintf(fileID,'%1s,%2s,%3s,%4s\n','time','mean','climatology','anomaly');
for m=1:length(disch_txt_out_TX(:,1))
fprintf(fileID,'%1s,%.3f,%.3f,%.3f\n',dttime_TX(m),disch_txt_out_TX(m,2:4));
end
fclose(fileID);
% MS river
filename2 = 'USGS_disch_FGBdb_MS.csv';
fileID2=fopen(filename2,'w');
% Add header
fprintf(fileID2,'%1s,%2s,%3s,%4s\n','time','mean','climatology','anomaly');
for m=1:length(disch_txt_out_MS(:,1))
fprintf(fileID2,'%1s,%.3f,%.3f,%.3f\n',dttime_MS(m),disch_txt_out_MS(m,2:4));
end
fclose(fileID2);

% Clean up
clear disch_txt_out_TX disch_txt_out_MS 
cd(path_main)




% Test plots
% plot(disch_txt_out_TX(:,1),disch_txt_out_TX(:,2))

