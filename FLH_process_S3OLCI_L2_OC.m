% FLH_PROCESS_S3OLCI.M
% Written by Dan Otis, September 2024
% Revised February 2025
% Function which uses GPT mosaic operator to process FLH on S3 OLCI data
% Need xml graph file
% Add a subset node? - May want to add; files are large
% This version uses L2 EFR files from OBPG
% Not currently written as a function, but could be

% TEST
clear
path_main='~/DB_files/DB_v24';
pc='OC'; % PACE files are OC_BGC (chlor_a and others) or AOP (rrs)
roi='florida';
platform='S3OLCI';
sub=0; % Indicates to be used with recent files from subscription directories
rec_files=0; % Number of most recent files to process; Set to zero for all recent files 

% Fix here to run as function
% function[dummy]=RESMPL_C2RCC_process_S2MSI(roi,roi_2,roi_out,pc,sub,rec_files,sensor)

% Input path
eval(['path_L2=''/srv/pgs/rois2/' roi '/L2_OLCI_OBPG/' pc '/'';']) % Updated OC files in separate directory

% Output path
eval(['path_L3=''/srv/pgs/rois2/' roi '/L3_1D_OLCI/' pc '/'';'])

% XML files w/product and projection info
eval(['xml_file=''~/DB_files/DB_v24/xml_files/OLCI_L2_OBPG_nLw_FLH_graph.xml'';']) % Need to add sensor



% List input files
if sub==0
eval(['flnms_tmp=struct2cell(dir(''' path_L2 '/*.nc''));']) 
end

% Extract filename
flnms_str=char(flnms_tmp(1,:));
num_files=size(flnms_str,1);

% Extract sensor, date and tileID from filename
sensor = flnms_str(:,1:3);
% Use full time stamp from input files
datestamp=flnms_str(:,16:30);
date_out=flnms_str(:,16:23); % Remove HHmmSS for mosaics 

begin=1; % All files

% cd(path_L2_OC)
%%%% MAIN LOOP %%%%
for i=1%begin:size(flnms_str,1)

outfile=strcat(sensor(i,:),'_',datestamp(i,:),'_',pc,'.nc');

% Call gpt
eval(['command_map=''/opt/esa-snap/bin/gpt ' xml_file ' -t ' path_L3 '' outfile ' -f NetCDF4-CF ' path_L2 '' flnms_str(i,:) ''';'])

% Print path and 1st filename to double-check
disp(path_L2)
disp(outfile)

system(command_map);
% Clean up
clear command_map
% cd(path_main)

end % (files loop)
dummy=1;

