% GET_DISCHARGE_USGS.M
% Written by Dan Otis, November 2018
% Retrieves USGS daily river discharge data from URL


clear

addpath('/srv/imars-objects/homes/dotis/MATLAB_files/');
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/m_map');
addpath('/srv/imars-objects/homes/dotis/MATLAB_files/export_fig');

% Set directories (use server)
path_main = '/srv/imars-objects/homes/dotis/DB_files/DB_v24/';
file_path = '/srv/imars-objects/tpa_pgs/rois2/gom/USGS_temp/';
path_out='/srv/imars-objects/tpa_pgs/rois2/gom/csv_ts_data/data/';

% Set years for start and end of climatologies
yr_mac_st=2013;
yr_mac_end=2019;

% Names of rivers (N and S)
% short_name={'Shark','Harney','Broad','Lostmans','Chatham','Barron','East','Faka','Pumpkin','Blackwater','Canal135','Lox','StLucie'}; 
% Leave out Barron (issue with file)
short_name={'Shark','Harney','Broad','Lostmans','Chatham','East','Faka','Pumpkin','Blackwater','Canal135','Lox','StLucie','Black','Snapper','Tamiami'}; 

% for k=1
for k=1:length(short_name)

% if (k==1) || (k==2) || (k==3) || (k==4) || (k==5) || (k==6) || (k==7) || (k==8) || (k==9) || (k==10)
% Remove Harney river (Equipment failure??)
if (k==1) || (k==3) || (k==4) || (k==5) || (k==6) || (k==7) || (k==8) || (k==9)
eval(['fid = fopen(''' file_path '' short_name{k} 'Rv_disch.txt'');'])
raw_data=textscan(fid, '%s %d %s %f %s %f %s %f %s' ,'HeaderLines',33);
raw_data(:,6:9)=[];
fclose(fid);

time_raw=raw_data{3};
mltime=datenum(time_raw);
dttime=datetime(mltime,'ConvertFrom','datenum');
disch_ts=single(raw_data{4});
disch_ts(disch_ts==0)=NaN;

% Convert to m^3/sec
disch_m3=disch_ts*0.0283; 

% eval(['disch_' short_name{k} '=daily;'])
eval(['TT_' short_name{k} '=timetable(dttime,disch_m3);'])
end 

% East FL rivers (gage height, NOT discharge)
% Remove Lox (no data input file)
if (k==10) || (k==12) || (k==13) || (k==14) || (k==15)
eval(['fid = fopen(''' file_path '' short_name{k} 'Rv_disch.txt'');'])
raw_data=textscan(fid, '%s %d %s %f %s %f %s %f %s' ,'HeaderLines',33);
raw_data(:,6:9)=[];
fclose(fid);

time_raw=raw_data{3};
mltime=datenum(time_raw);
dttime=datetime(mltime,'ConvertFrom','datenum');
disch_ts=single(raw_data{4});
disch_ts(disch_ts==0)=NaN;

% Convert to m (from feet)
gh_m=disch_ts*.3048; 

% eval(['disch_' short_name{k} '=daily;'])
eval(['TT_' short_name{k} '=timetable(dttime,gh_m);']) 
end

clear disch_ts disch_m3 mltime time_raw raw_data gh_m

end

% Combine time-series over common time window
% TT=synchronize(TT_Shark,TT_Harney,TT_Broad,TT_Lostmans,TT_Chatham,TT_Barron,TT_East,TT_Faka,TT_Pumpkin,TT_Blackwater,TT_Canal135,TT_Lox,TT_StLucie,'daily','mean');
TT=synchronize(TT_Shark,TT_Broad,TT_Lostmans,TT_Chatham,TT_East,TT_Faka,TT_Pumpkin,TT_Blackwater,TT_Black,TT_Snapper,TT_Tamiami,TT_Canal135,TT_StLucie,'daily','mean');

% Convert back to table and then sum over rivers
table_TT=timetable2table(TT);
time_TT=table2array(table_TT(1:end-2,1));
data_SFL=table2array(table_TT(1:end-2,2:5));
data_NFL=table2array(table_TT(1:end-2,6:9));
data_EFL=table2array(table_TT(1:end-2,11)); % SnapperCr only (Tamiami has gaps)
data_STL=table2array(table_TT(1:end-2,14));
data_all=table2array(table_TT(1:end-2,2:14));
sum_SFL=nansum(data_SFL,2);
sum_NFL=nansum(data_NFL,2);
% sum_EFL=nansum(data_EFL,2);
sum_all=nansum(data_all,2);

% Convert time to unix time
ts_SFL=sum_SFL; % Choose southern rivers here
ts_EFL=data_EFL; % Eastern FL (Tamiami only - no sum needed)
ts_STL=data_STL; % St. Lucie (no sum needed)
ts_time=datenum(time_TT); % Same time vector for both

% Bin data here to daily intervals to create clim, anoms
[daily_SFL,~,~,~,~]=time_series_bin_vFGBdb(double(ts_SFL),ts_time,yr_mac_st,yr_mac_end);

[daily_EFL,~,~,~,~]=time_series_bin_vFGBdb(double(ts_EFL),ts_time,yr_mac_st,yr_mac_end);

[daily_STL,~,~,~,~]=time_series_bin_vFGBdb(double(ts_STL),ts_time,yr_mac_st,yr_mac_end);

% Convert time to unix time
disch_txt_out_SFL=daily_SFL;
disch_txt_out_EFL=daily_EFL;
disch_txt_out_STL=daily_STL;
dttime=datetime(daily_SFL(:,1),'ConvertFrom','datenum','Format','yyyy-MM-dd');
dttime.Format = 'MM-dd-yyyy''T''HH:mm:ss''Z'; % Add comma to start of each row

% Plots of summed river indeces
% plot_time=datetime(daily_EFL(:,1),'ConvertFrom','datenum');
% plot(plot_time,daily_STL(:,2))

% % Test plot
% tstart=datetime(2012,1,1);
% tend=datetime(2020,5,1);
% subplot(4,1,1)
% plot(table_TT{:,1},table_TT{:,12},'c')
% xlim([tstart tend]);
% subplot(4,1,2)
% % hold on
% plot(table_TT{:,1},table_TT{:,13},'r')
% xlim([tstart tend]);
% subplot(4,1,3)
% % hold on
% plot(table_TT{:,1},table_TT{:,14},'b')
% xlim([tstart tend]);
% subplot(4,1,4)
% % hold on
% plot(table_TT{1:end-2,1},sum_EFL)
% xlim([tstart tend]);


%%%% OUTPUT %%%%
% Southwest FL rivers
cd(path_out)
filename = 'USGS_disch_FKdb.csv';
fileID=fopen(filename,'w');
% Add header
fprintf(fileID,'%1s,%2s,%3s,%4s\n','time','mean','climatology','anomaly');

% Write output
for m=1:length(disch_txt_out_SFL(:,1))
fprintf(fileID,'%1s,%.3f,%.3f,%.3f\n',dttime(m),disch_txt_out_SFL(m,2:4));
end
fclose(fileID);

% EFL rivers for FWC dashboard
filename2 = 'USGS_disch_FWCdb_EFL.csv';
fileID2=fopen(filename2,'w');
% Add header
fprintf(fileID2,'%1s,%2s,%3s,%4s\n','time','mean','climatology','anomaly');

for m=1:length(disch_txt_out_EFL(:,1))
fprintf(fileID2,'%1s,%.3f,%.3f,%.3f\n',dttime(m),disch_txt_out_EFL(m,2:4));
end
fclose(fileID2);

% St. Lucie River for FWC dashboard
filename3 = 'USGS_disch_FWCdb_STL.csv';
fileID3=fopen(filename3,'w');
% Add header
fprintf(fileID3,'%1s,%2s,%3s,%4s\n','time','mean','climatology','anomaly');

for m=1:length(disch_txt_out_STL(:,1))
fprintf(fileID3,'%1s,%.3f,%.3f,%.3f\n',dttime(m),disch_txt_out_STL(m,2:4));
end
fclose(fileID3);

% Clean up
% clear disch_txt_out
cd(path_main)



