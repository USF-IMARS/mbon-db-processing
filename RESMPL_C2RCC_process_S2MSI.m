% RSMPL_C2RCC_PROCESS_S2MSI.M
% Written by Dan Otis, September 2024
% Revised January 2025
% Function which uses GPT mosaic operator to process the C2RCC on S2 MSI data
% Need xml graph file
% Add a subset node?
% Also need to work on file queries/downloads
% Not currently written as a function, but could be

% TEST
clear
pc='C2RCC'; % PACE files are OC_BGC (chlor_a and others) or AOP (rrs)
roi='florida';
platform='S2MSI';
sub=0; % Indicates to be used with recent files from subscription directories
rec_files=0; % Number of most recent files to process; Set to zero for all recent files 

% Fix here to run as function
% function[dummy]=RESMPL_C2RCC_process_S2MSI(roi,roi_2,roi_out,pc,sub,rec_files,sensor)

% Output path
eval(['path_L2=''/srv/pgs/rois2/' roi '/L2_' pc '_' platform '/'';'])

% XML files w/product and projection info
eval(['xml_file=''~/DB_files/DB_v24/xml_files/' platform '_' pc '_graph.xml'';']) % Need to add sensor

% Input folders (may need to use manifest file
if sub==0
eval(['path_L1C=''/srv/pgs/rois2/' roi '/L1C_' platform '/'';']) % Updated OC files in separate directory
end

% if sub==1
% eval(['path_L2=''/srv/pgs/rois2/' roi '/L2_' sensor '_sub/'';']) % For GOM only 
% end

% List input files
if sub==0
eval(['flnms_tmp=struct2cell(dir(''' path_L1C '/''));']) 
end

% if sub==1 && strcmp(pc,'OC')==1
% eval(['flnms_tmp=struct2cell(dir(''' path_L2 '*.L2.' pc '.*nc''));']) % Use for subscription files
% end

% Extract filename
flnms_str=char(flnms_tmp(1,3:end));
num_files=size(flnms_str,1);

% Extract sensor, date and tileID from filename
sensor = flnms_str(:,1:3);
tileID = flnms_str(:,39:44);

% NEW filenames: Define DOY using function from Y/M/D;
% CHANGED AS OF 8/1/2022
% UPDATE (6/12/24): Output files now have Y/M/D format (not DOY)
% UPDATE (6/26/24): Deprecate use of datenum 
% If not binning by day, this is not really needed
% datestr_in=flnms_str(:,[12:19,21:26]);
% dateformat='yyyyMMddHHmmss';
% dttime=datetime(datestr_in,'InputFormat',dateformat);
% years=year(dttime);
% months=month(dttime);
% days=day(dttime);
% doy=day(dttime,'dayofyear');
% yrs_tmp = num2str(years,'%02.f');
% day_tmp = num2str(days,'%02.f');
% month_tmp = num2str(months,'%02.f');
% datestamp=strcat(yrs_tmp,month_tmp,day_tmp);

% Use full time stamp from input files
datestamp=flnms_str(:,[12:26]);
% However, tile_ID MUST be added to output filename
% Files with same datestamp and different tile_IDs will get overwritten


bins_peryr=366;
ind_1D=(1:1:366);

% Define year range here
years_lp=(min(years):max(years));
num_years=size(years_lp,2);

% No compositing is done here (for now) - will result in huge files
% % Can do in a subsequent step (one a subset of products)

% Find indeces of images in each 1d bin for OC and SST
% j=1;
% for h=1:num_years
% for i=1:bins_peryr
% oc_tmp=find(years == years_lp(h) & doy == ind_1D(i));
% oc_tmp2=length(oc_tmp);
% DAY_bin_ind(j,1:oc_tmp2)=oc_tmp;
% j=j+1;
% end % i
% end % h

% Remove rows where 1st column is zero in XX_8d-bin_ind arrays
% DAY_bin_ind(DAY_bin_ind(:,1)==0,:)=[];

% Loop through input files (Or, can subset using yrs, doy)
begin=1; % All files
% if rec_files>0    
% begin=size(DAY_bin_ind,1)-rec_files; % Most recent files only
% end
% 
% if begin <= 0; begin=1; end

% % Manual override
% begin=size(DAY_bin_ind,1)-130; % Recent files
% begin=1800; % Manual start

%%%% MAIN LOOP %%%%
for i=begin%:size(flnms_str,1)

% tmpdays=(DAY_bin_ind(i,:)>0);
% 
% % Define files to open
% tmp_1=DAY_bin_ind(i,tmpdays);
% if sum(tmp_1)>=0; tmp_2=tmp_1(tmp_1>0); end
% tmp_3=flnms_str(tmp_2,:);
% tmp_4=flnms_tmp(1,tmp_1);
% % Concatenate input filenames into single string(!)
% for k=1:size(tmp_3,1)
% tmp_6=cat(2,path_L2,tmp_4(k));
% tmp_7=strjoin(tmp_6);
% tmp_8=tmp_7(~isspace(tmp_7));
% tmp_9{k}=tmp_8;
% files_out=strjoin(tmp_9);
% % Create filename for output (Keep doy convention for now)
% date_tmp=datestamp(tmp_2,:);
% time_start=date_tmp(1,:);
% time_end=date_tmp(end,:);
% end

outfile=strcat(sensor(i,:),'_',datestamp(i,:),'_',tileID(i,:),'_',pc,'.nc');
% Call to mangillo gpt
eval(['command_map=''/opt/esa-snap/bin/gpt ' xml_file ' -t ' path_L2 '' outfile ' -f NetCDF4-CF ' path_L1C '' flnms_str(i,:) ''';'])

% Call to seashell gpt
% eval(['command_map=''/opt/snap_6_0/bin/gpt ' xml_file ' -t ' path_L3 '' sensor_prefix '' time_start '_' roi_2 '_' pc '_1D.nc -f NetCDF4-CF ' files_out ''';'])

% eval(['command_cd=''chmod 777 ' path_L3 '*'';'])

% Print path and 1st filename to double-check
disp(path_L1C)
disp(outfile)


system(command_map);
% Clean up
% clear command_map

% system(command_cd);

end % (files loop)
dummy=1;

