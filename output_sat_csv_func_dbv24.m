% OUTPUT_CSV_FUNC.M
% Written by Dan Otis, January 2019
% Output function for .csv files

%%% Output to .csv files (Separate file for each location)
function[dummy]=output_sat_csv_func_dbv24(ts,prod,interval,roi_2,loc_name,path_out,sensor)
 
ts2=ts(:,2:4);

dt_tmp=datetime(ts(:,1),'ConvertFrom','datenum','Format','yyyy-MM-dd');
dt_tmp.Format = 'MM-dd-yyyy''T''HH:mm:ss''Z'; 

% Write .csv file
cd(path_out)
eval(['filename = ''' roi_2 '_' prod '_TS_' sensor '_' interval '_' loc_name '.csv'';'])
fileID=fopen(filename,'w');
% Add header
fprintf(fileID,'%1s,%2s,%3s,%4s\n','Time','mean','climatology','anomaly');

% Write out_tmp_daily to file
for m=1:length(ts(:,1)) 
fprintf(fileID,'%s,%.6f,%.6f,%.6f\n',dt_tmp(m),ts2(m,:));

end
fclose(fileID);
clear ts ts2

dummy=1;