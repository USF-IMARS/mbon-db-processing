% GENERATE_SPECTRA.M
% Written by Dan Otis, November 2024
% This script will open PACE-OCI AOP files and generate full spectra
% Two methods for location choice:
% 1. Point and click based on an image
% 2. Direct lat/lon input (list of SFP cruise stations)
% Save output as .mat (wavelength vector and rrs array)


clear
addpath('~/MATLAB_files/');
addpath('~/MATLAB_files/m_map');
addpath('~/MATLAB_files/export_fig');
addpath('~/DB_files/DB_v24');

% INPUT AND OUTPUT PATHS (PACE only)
% These are 1D mosaics - could use mapped 1D individual L3 files
% Would need to create (overlap between scenes is minimal)
file_path='/srv/imars-objects/tpa_pgs/rois2/florida/L3_1D_POCI/OC_AOP/';
path_out='/srv/imars-objects/tpa_pgs/rois2/florida/L3_1D_POCI/AOP_SPEC/';
path_main='~/DB_files/DB_v24';

% Location selection
% List of SFP locations
load('~/DB_files/loc_files/FK_ROI_out_v2021.mat')
% Filter out unneeded locations
FK_ROI_out(1:20)=[];

% Quick test map
% xsz=1000; ysz=1000;
% % Use lat/lon above to get center of map (approx.)
% lat_lims=[24,26.5];
% lon_lims=[-83.5,-79];
% [lat,lon]=def_grid_nomat(xsz,ysz,lat_lims,lon_lims);
% figure('Position', [300, 300, 1000, 800]);
% m_proj('equidistant cylindrical','long',lon_lims,'lat',lat_lims);
% clf;
% % m_pcolor(Plg,Plt,img_disp);shading flat;
% m_gshhs_f('patch',[0 0 0],'edgecolor',[1 1 1]','Linewidth',2); % Patch
% % m_grid('box','fancy','linestyle','-','gridcolor','w','backcolor',[.2 .65 1],'fontsize',20,'fontweight','bold'); % Blue background
% m_grid('box','fancy','linestyle','-','gridcolor','w','backcolor',[.5 .5 .5],'fontsize',20,'fontweight','bold'); % Blue background
% % Plot locations
% for i=1:length(FK_ROI_out)
%     m_text(FK_ROI_out(i).lon,FK_ROI_out(i).lat,'\bullet','color','r','FontSize',15,'HorizontalAlignment','center','VerticalAlignment','middle','Interpreter','tex')
% end

% Image selection (loop through images)
% From each image, extract spectra at each location (N = 83)
% Add wavelength vector and Rrs arrays to structure variable
FK_spec_out = FK_ROI_out;

% Get image list
eval(['flnms_tmp=struct2cell(dir(''' file_path '/*.nc''));'])
flnms_tmp=flnms_tmp(1,:);
flnms_str=char(flnms_tmp');
fileID=flnms_str(:,1:9);
len_flnms=length(flnms_str(1,:));
num_files=size(flnms_str,1);
% Wavelength list 
lams={'Rrs_339','Rrs_341','Rrs_344','Rrs_346','Rrs_348','Rrs_351','Rrs_353','Rrs_356','Rrs_358','Rrs_361','Rrs_363','Rrs_366','Rrs_368','Rrs_371','Rrs_373','Rrs_375','Rrs_378','Rrs_380','Rrs_383','Rrs_385','Rrs_388','Rrs_390','Rrs_393','Rrs_395','Rrs_398',...
    'Rrs_400','Rrs_403','Rrs_405','Rrs_408','Rrs_410','Rrs_413','Rrs_415','Rrs_418','Rrs_420','Rrs_422','Rrs_425','Rrs_427','Rrs_430','Rrs_432','Rrs_435','Rrs_437','Rrs_440','Rrs_442','Rrs_445','Rrs_447','Rrs_450','Rrs_452','Rrs_455','Rrs_457','Rrs_460','Rrs_462','Rrs_465','Rrs_467','Rrs_470','Rrs_472','Rrs_475','Rrs_477','Rrs_480','Rrs_482','Rrs_485','Rrs_487','Rrs_490','Rrs_492','Rrs_495','Rrs_497',...
    'Rrs_500','Rrs_502','Rrs_505','Rrs_507','Rrs_510','Rrs_512','Rrs_515','Rrs_517','Rrs_520','Rrs_522','Rrs_525','Rrs_527','Rrs_530','Rrs_532','Rrs_535','Rrs_537','Rrs_540','Rrs_542','Rrs_545','Rrs_547','Rrs_550','Rrs_553','Rrs_555','Rrs_558','Rrs_560','Rrs_563','Rrs_565','Rrs_568','Rrs_570','Rrs_573','Rrs_575','Rrs_578','Rrs_580','Rrs_583','Rrs_586','Rrs_588','Rrs_591','Rrs_593','Rrs_596','Rrs_598',...
    'Rrs_601','Rrs_603','Rrs_605','Rrs_608','Rrs_610','Rrs_613','Rrs_615','Rrs_618','Rrs_620','Rrs_623','Rrs_625','Rrs_627','Rrs_630','Rrs_632','Rrs_635','Rrs_637','Rrs_640','Rrs_641','Rrs_642','Rrs_643','Rrs_645','Rrs_646','Rrs_647','Rrs_648','Rrs_650','Rrs_651','Rrs_652','Rrs_653','Rrs_655','Rrs_656','Rrs_657','Rrs_658','Rrs_660','Rrs_661','Rrs_662','Rrs_663','Rrs_665','Rrs_666','Rrs_667','Rrs_668','Rrs_670','Rrs_671','Rrs_672','Rrs_673','Rrs_675','Rrs_676','Rrs_677','Rrs_678','Rrs_679','Rrs_681','Rrs_682','Rrs_683','Rrs_684','Rrs_686','Rrs_687','Rrs_688','Rrs_689','Rrs_691','Rrs_693','Rrs_694','Rrs_696','Rrs_697','Rrs_698','Rrs_699'...
    'Rrs_701','Rrs_702','Rrs_703'};%,'Rrs_704','Rrs_706','Rrs_707','Rrs_708','Rrs_709','Rrs_711','Rrs_712','Rrs_713','Rrs_714','Rrs_717','Rrs_719'};
num_lams = size(lams,2);

%%%%%% TEST FILE TO FIND X-Y COORDS OF PTS/POLYS %%%%%%
tfile=flnms_str(1,:);
cd(file_path)
[lat]=open_nc(tfile,'lat');
[lon]=open_nc(tfile,'lon');
cd(path_main)
 
% Define polygons in x-y coords.
for k=1:length(FK_ROI_out)
% For point locations, use an offset of 2 (5x5 pixel box)
bx_offset=1; % 3x3 box  
[pt_pix,pt_line]=latlon2pixline(FK_ROI_out(k).lat,FK_ROI_out(k).lon,lat(:,1),lon(1,:));
loc_pts_tmp=false(size(lat,1),size(lon,2));
loc_pts_tmp(pt_line-bx_offset:pt_line+bx_offset,pt_pix-bx_offset:pt_pix+bx_offset)=1;
ROI_tmp(:,:,k)=loc_pts_tmp;
end 

%%%%%% MAIN LOOP(S) %%%%%%
for f=1:num_files
cd(file_path)
% Image selection (loop through images)
% From each image, extract spectra at each location (N = 83)
% Add wavelength vector and Rrs arrays to structure variable
FK_spec_out = FK_ROI_out;

file = flnms_str(f,:);
for s=1:length(FK_ROI_out)
for l=1:num_lams
sl_mask=open_nc(file,'STRAYLIGHT_MASK');
eval(['[img_tmp]=open_nc(file,''' lams{l} ''');'])
img_tmp(img_tmp == 0) = NaN; % Remove zero vals.
img_tmp(sl_mask==1)=NaN; % Apply straylight mask
% Use mask to extract 
data = img_tmp(ROI_tmp(:,:,s));
spectra_med(l)=median(data(:),'omitnan');
spectra_std(l)=std(data(:),'omitnan');
end % l: wavelengths
% Add spectra to structire var.
FK_spec_out(s).lambda=lams;
FK_spec_out(s).spectra = spectra_med;
FK_spec_out(s).stdev = spectra_std;
end % s: stations
% Output (output one .mat file for each station)
cd(path_out)
eval(['save ' fileID(f,:) '_FK_SPECTRA.mat FK_spec_out;']) 
disp(f)
end % f:files 




