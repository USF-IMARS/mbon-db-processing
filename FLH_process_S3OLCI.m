% FLH_PROCESS_S3OLCI.M
% Written by Dan Otis, September 2024
% Revised February 2025
% Function which uses GPT mosaic operator to process FLH on S3 OLCI data
% Need xml graph file
% Add a subset node? - May want to add; files are large
% Should add a cloud mask somehow IdePix.Olci operator)
% OLCI IdePix requires tensorflow(?
% Not currently written as a function, but could be

% TEST
clear
path_main='~/DB_files/DB_v24';
pc='FLH'; % PACE files are OC_BGC (chlor_a and others) or AOP (rrs)
roi='florida';
platform='S3OLCI';
sub=0; % Indicates to be used with recent files from subscription directories
rec_files=0; % Number of most recent files to process; Set to zero for all recent files 

% Fix here to run as function
% function[dummy]=RESMPL_C2RCC_process_S2MSI(roi,roi_2,roi_out,pc,sub,rec_files,sensor)

% Output path
eval(['path_L2=''/srv/pgs/rois2/' roi '/L2_' pc '_' platform '/'';'])

% XML files w/product and projection info
eval(['xml_file=''~/DB_files/DB_v24/xml_files/' platform '_RayCorr_' pc '_graph.xml'';']) % Need to add sensor

% Input folders (may need to use manifest file
if sub==0
eval(['path_L1=''/srv/pgs/rois2/gom/L1_OLCI_EFR/L1_EFR/'';']) % Updated OC files in separate directory
end

% if sub==1
% eval(['path_L2=''/srv/pgs/rois2/' roi '/L2_' sensor '_sub/'';']) % For GOM only 
% end

% List input files
if sub==0
eval(['flnms_tmp=struct2cell(dir(''' path_L1 '/*.zip''));']) 
end

% if sub==1 && strcmp(pc,'OC')==1
% eval(['flnms_tmp=struct2cell(dir(''' path_L2 '*.L2.' pc '.*nc''));']) % Use for subscription files
% end

% Extract filename
flnms_str=char(flnms_tmp(1,:));
num_files=size(flnms_str,1);

% Extract sensor, date and tileID from filename
sensor = flnms_str(:,1:3);
tileID = flnms_str(:,17:31);

% Use full time stamp from input files
datestamp=flnms_str(:,17:31);
% However, tile_ID MUST be added to output filename
% Files with same datestamp and different tile_IDs will get overwritten

begin=1; % All files

cd(path_L1)
%%%% MAIN LOOP %%%%
for i=begin%:size(flnms_str,1)

filename=flnms_str(i,:);
% Need to unzip file (will create a folder)

eval(['unzip_map=''unzip ' path_L1 '' filename ''';'])
system(unzip_map)

outfile=strcat(sensor(i,:),'_',datestamp(i,:),'_',pc,'.nc');

% Need to find manifest file as input
% Define new (unzipped) folder


% Call gpt
eval(['command_map=''/opt/esa-snap/bin/gpt ' xml_file ' -t ' path_L2 '' outfile ' -f NetCDF4-CF ' path_L1 '' flnms_str(i,1:end-4) '.SEN3'';'])

% Print path and 1st filename to double-check
disp(path_L1)
disp(outfile)

% command_test = '/opt/esa-snap/bin/gpt ~/DB_files/DB_v24/xml_files/S3OLCI_FLH_graph.xml -t /srv/pgs/rois2/florida/L2_FLH_S3OLCI/S3A_20250101T155159_FLH.nc -f NetCDF4-CF /srv/pgs/rois2/gom/L1_OLCI_EFR/L1_EFR/S3A_OL_1_EFR____20250101T155159_20250101T155459_20250102T161055_0179_121_054_2520_PS1_O_NT_004.SEN3/xfdumanifest.xml';



system(command_map);
% Clean up
clear command_map
cd(path_main)

end % (files loop)
dummy=1;

