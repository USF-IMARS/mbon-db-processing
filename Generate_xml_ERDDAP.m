% GENERATE_XML.M 
% Written by Dan Otis, August 2024
% Script to generate xml files in "blocks"
% Motivation: Use for PACE data with many products
% Will save time writing new xml files for mosaic, ERDDAP, etc.
% Inputs:
% 1. Block format (file info, keywords, prods)
% 2. Blocks to include
% 3. Products
% 4. Products
% 5 . Other metadata (ERDDAP)

clear

% LAT/LON LIMITS AND RESOLUTION
west_bound = '-85.0';
east_bound = '-78.5';
north_bound = '31.0';
south_bound = '24.0';
resolution = '1011.7'; % m per pixel (assumes square pixels)

% HEADER INFO
filename = 'pace_oc_aop_1d_sfl.xml';
datasetID = 'pace_oc_aop_1d_sfl';
file_dir = '/mnt/sdb/pace_oc_aop_1d_sfl';
filename_format = 'yyyyMMdd,POCI_(\d{8})_1D_SFL_OC_AOP_ED\.nc,1';
summary = 'USF IMaRS PACE-OCI FL 1-Day Composite Ocean Color BGC';
title = 'PACE-OCI Ocean Color AOP 1-Day composite for South Florida';
% BAND INFO
var_list={'Rrs_339','Rrs_341','Rrs_344','Rrs_346','Rrs_348','Rrs_351','Rrs_353','Rrs_356','Rrs_358','Rrs_361','Rrs_363','Rrs_366','Rrs_368','Rrs_371','Rrs_373','Rrs_375','Rrs_378','Rrs_380','Rrs_383','Rrs_385','Rrs_388','Rrs_390','Rrs_393','Rrs_395','Rrs_398',...
    'Rrs_400','Rrs_403','Rrs_405','Rrs_408','Rrs_410','Rrs_413','Rrs_415','Rrs_418','Rrs_420','Rrs_422','Rrs_425','Rrs_427','Rrs_430','Rrs_432','Rrs_435','Rrs_437','Rrs_440','Rrs_442','Rrs_445','Rrs_447','Rrs_450','Rrs_452','Rrs_455','Rrs_457','Rrs_460','Rrs_462','Rrs_465','Rrs_467','Rrs_470','Rrs_472','Rrs_475','Rrs_477','Rrs_480','Rrs_482','Rrs_485','Rrs_487','Rrs_490','Rrs_492','Rrs_495','Rrs_497',...
    'Rrs_500','Rrs_502','Rrs_505','Rrs_507','Rrs_510','Rrs_512','Rrs_515','Rrs_517','Rrs_520','Rrs_522','Rrs_525','Rrs_527','Rrs_530','Rrs_532','Rrs_535','Rrs_537','Rrs_540','Rrs_542','Rrs_545','Rrs_547','Rrs_550','Rrs_553','Rrs_555','Rrs_558','Rrs_560','Rrs_563','Rrs_565','Rrs_568','Rrs_570','Rrs_573','Rrs_575','Rrs_578','Rrs_580','Rrs_583','Rrs_586','Rrs_588','Rrs_591','Rrs_593','Rrs_596','Rrs_598',...
    'Rrs_601','Rrs_603','Rrs_605','Rrs_608','Rrs_610','Rrs_613','Rrs_615','Rrs_618','Rrs_620','Rrs_623','Rrs_625','Rrs_627','Rrs_630','Rrs_632','Rrs_635','Rrs_637','Rrs_640','Rrs_641','Rrs_642','Rrs_643','Rrs_645','Rrs_646','Rrs_647','Rrs_648','Rrs_650','Rrs_651','Rrs_652','Rrs_653','Rrs_655','Rrs_656','Rrs_657','Rrs_658','Rrs_660','Rrs_661','Rrs_662','Rrs_663','Rrs_665','Rrs_666','Rrs_667','Rrs_668','Rrs_670','Rrs_671','Rrs_672','Rrs_673','Rrs_675','Rrs_676','Rrs_677','Rrs_678','Rrs_679','Rrs_681','Rrs_682','Rrs_683','Rrs_684','Rrs_686','Rrs_687','Rrs_688','Rrs_689','Rrs_691','Rrs_693','Rrs_694','Rrs_696','Rrs_697','Rrs_698','Rrs_699'...
    'Rrs_701','Rrs_702','Rrs_703','avw','STRAYLIGHT_MASK'};%,'Rrs_704','Rrs_706','Rrs_707','Rrs_708','Rrs_709','Rrs_711','Rrs_712','Rrs_713','Rrs_714','Rrs_717','Rrs_719'};
units_rrs={'sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','sr^-1','nm','none'}; 
long_name='Remote_Sensing_Reflectance(Rrs)';

color_bar_min = '0.0';
color_bar_max = '0.01';
color_bar_scale = 'Linear';

% BEGIN FILE
fileID = fopen(filename,'w');
format_spec1 = '%s\n'; % no tabs
format_spec2 = '\t%s\n'; % 1 tab
format_spec3 = '\t\t%s\n'; % 2 tabs
format_spec4 = '\t\t\t%s\n'; % 3 tabs
eval(['fprintf(fileID,format_spec1,''<dataset type="EDDGridFromNcFiles" datasetID="' datasetID '" active="true">'');'])
fprintf(fileID,format_spec2,'<reloadEveryNMinutes>10080</reloadEveryNMinutes>');
fprintf(fileID,format_spec2,'<updateEveryNMillis>10000</updateEveryNMillis>');
eval(['fprintf(fileID,format_spec2,''<fileDir>' file_dir '</fileDir>'');'])
fprintf(fileID,format_spec2,'<fileNameRegex>.*\.nc</fileNameRegex>');
fprintf(fileID,format_spec2,'<recursive>true</recursive>');
fprintf(fileID,format_spec2,'<pathRegex>.*</pathRegex>');
fprintf(fileID,format_spec2,'<metadataFrom>last</metadataFrom>');
fprintf(fileID,format_spec2,'<matchAxisNDigits>20</matchAxisNDigits>');
fprintf(fileID,format_spec2,'<fileTableInMemory>false</fileTableInMemory>');
fprintf(fileID,format_spec2,'<addAttributes>');
fprintf(fileID,format_spec3,'<att name="cdm_data_type">Grid</att>');
fprintf(fileID,format_spec3,'<att name="Contact">null</att>');
fprintf(fileID,format_spec3,'<att name="contact">Dan Otis - dotis@usf.edu</att>');
fprintf(fileID,format_spec3,'<att name="Conventions">COARDS, CF-1.6, ACDD-1.3</att>');
fprintf(fileID,format_spec3,'<att name="creator_email">dotis@usf.edu</att>');
fprintf(fileID,format_spec3,'<att name="creator_name">DOTIS</att>');
fprintf(fileID,format_spec3,'<att name="creator_type">institution</att>');
fprintf(fileID,format_spec3,'<att name="infoUrl">imars.usf.edu</att>');
fprintf(fileID,format_spec3,'<att name="institution">USF IMaRS</att>');
fprintf(fileID,format_spec3,'<att name="keywords">PACE,apparent_optical_properties,remote_sensing_reflectance</att>');
fprintf(fileID,format_spec3,'<att name="keywords_vocabulary">GCMD Science Keywords</att>');
fprintf(fileID,format_spec3,'<att name="Lat-Lon_Limits">null</att>');
eval(['fprintf(fileID,format_spec3,''<att name="Lat_Lon_Limits">' south_bound 'N to ' north_bound 'N ' west_bound 'E to ' east_bound 'E</att>'');'])
fprintf(fileID,format_spec3,'<att name="license">[standard]</att>');
fprintf(fileID,format_spec3,'<att name="standard_name_vocabulary">CF Standard Name Table v70</att>');
eval(['fprintf(fileID,format_spec3,''<att name="summary">' summary '</att>'');'])
eval(['fprintf(fileID,format_spec3,''<att name="title">' title '</att>'');'])
fprintf(fileID,format_spec2,'</addAttributes>');
fprintf(fileID,format_spec2,'<axisVariable>');
eval(['fprintf(fileID,format_spec3,''<sourceName>***fileName,timeFormat=' filename_format '</sourceName>'');'])
fprintf(fileID,format_spec3,'<destinationName>time</destinationName>');
fprintf(fileID,format_spec3,'<addAttributes>');
fprintf(fileID,format_spec4,'<att name="ioos_category">Unknown</att>');
fprintf(fileID,format_spec4,'<att name="units">seconds since 1970-01-01T00:00:00Z</att>');
fprintf(fileID,format_spec3,'</addAttributes>');
fprintf(fileID,format_spec2,'</axisVariable>');
fprintf(fileID,format_spec2,'<axisVariable>');
fprintf(fileID,format_spec3,'<sourceName>latitude</sourceName>');
fprintf(fileID,format_spec3,'<destinationName>latitude</destinationName>');
fprintf(fileID,format_spec2,'</axisVariable>');
fprintf(fileID,format_spec2,'<axisVariable>');
fprintf(fileID,format_spec3,'<sourceName>longitude</sourceName>');
fprintf(fileID,format_spec3,'<destinationName>longitude</destinationName>');
fprintf(fileID,format_spec2,'</axisVariable>');
% VARIABLE BLOCK
for i=1:size(var_list,2)-2
wavelength = var_list{i}; wavelength = wavelength(5:7); 
fprintf(fileID,format_spec2,'<dataVariable>');
eval(['fprintf(fileID,format_spec3,''<sourceName>' var_list{i} '</sourceName>'');'])
eval(['fprintf(fileID,format_spec3,''<destinationName>' var_list{i} '</destinationName>'');'])
fprintf(fileID,format_spec3,'<dataType>double</dataType>');
fprintf(fileID,format_spec3,'<addAttributes>');
eval(['fprintf(fileID,format_spec4,''<att name="colorBarMaximum" type="double">' color_bar_max '</att>'');'])
eval(['fprintf(fileID,format_spec4,''<att name="colorBarMinimum" type="double">' color_bar_min '</att>'');'])
eval(['fprintf(fileID,format_spec4,''<att name="colorBarScale">' color_bar_scale '</att>'');'])
fprintf(fileID,format_spec4,'<att name="ioos_category">Ocean Color</att>');
eval(['fprintf(fileID,format_spec4,''<att name="long_name">' long_name '</att>'');'])
eval(['fprintf(fileID,format_spec4,''<att name="standard_name">Remote_Sensing_Reflectance_at_' wavelength 'nm</att>'');'])
eval(['fprintf(fileID,format_spec4,''<att name="spectral_wavelength">' wavelength '.0</att>'');'])
fprintf(fileID,format_spec4,'<att name="Units">null</att>');
eval(['fprintf(fileID,format_spec4,''<att name="units">' units_rrs{i} '</att>'');'])
fprintf(fileID,format_spec3,'</addAttributes>');
fprintf(fileID,format_spec2,'</dataVariable>');
end
% OTHER VARIABLES
% AVW
fprintf(fileID,format_spec2,'<dataVariable>');
fprintf(fileID,format_spec3,'<sourceName>avw</sourceName>');
fprintf(fileID,format_spec3,'<destinationName>avw</destinationName>');
fprintf(fileID,format_spec3,'<dataType>double</dataType>');
fprintf(fileID,format_spec3,'<addAttributes>');
fprintf(fileID,format_spec4,'<att name="colorBarMaximum" type="double">705.0</att>');
fprintf(fileID,format_spec4,'<att name="colorBarMinimum" type="double">335.0</att>');
fprintf(fileID,format_spec4,'<att name="colorBarScale">Linear</att>');
fprintf(fileID,format_spec4,'<att name="ioos_category">Ocean Color</att>');
fprintf(fileID,format_spec4,'<att name="long_name">Apparent_Visible_Wavelength</att>');
fprintf(fileID,format_spec4,'<att name="standard_name">Apparent_Visible_Wavelength</att>');
fprintf(fileID,format_spec4,'<att name="Units">null</att>');
fprintf(fileID,format_spec4,'<att name="units">nm</att>');
fprintf(fileID,format_spec3,'</addAttributes>');
fprintf(fileID,format_spec2,'</dataVariable>');
% STRAYLIGHT MASK
fprintf(fileID,format_spec2,'<dataVariable>');
fprintf(fileID,format_spec3,'<sourceName>STRAYLIGHT_MASK</sourceName>');
fprintf(fileID,format_spec3,'<destinationName>STRAYLIGHT_MASK</destinationName>');
fprintf(fileID,format_spec3,'<dataType>double</dataType>');
fprintf(fileID,format_spec3,'<addAttributes>');
fprintf(fileID,format_spec4,'<att name="colorBarMaximum" type="double">1.0</att>');
fprintf(fileID,format_spec4,'<att name="colorBarMinimum" type="double">0.0</att>');
fprintf(fileID,format_spec4,'<att name="ioos_category">Ocean Color</att>');
fprintf(fileID,format_spec4,'<att name="long_name">Straylight mask based on Level-2 straylight flag</att>');
fprintf(fileID,format_spec4,'<att name="Units">null</att>');
fprintf(fileID,format_spec4,'<att name="units">none</att>');
fprintf(fileID,format_spec3,'</addAttributes>');
fprintf(fileID,format_spec2,'</dataVariable>');
fprintf(fileID,format_spec1,'</dataset>');
% CLOSE FILE
fclose(fileID);




