% GENERATE_XML.M 
% Written by Dan Otis, August 2024
% Script to generate xml files in "blocks"
% Motivation: Use for PACE data with many products
% Will save time writing new xml files for mosaic, ERDDAP, etc.
% Inputs:
% 1. Block format (mosaic, CRS, bandmath, etc.)
% 2. Blocks to include
% 3. Products
% 4. Conditions (masks)
% 5. Lat/Lon limits, spatial resolution
% 6. Other metadata (ERDDAP)

clear
% DEFINE VARIABLES
% VARIABLES
var_list={'Rrs_339','Rrs_341','Rrs_344','Rrs_346','Rrs_348','Rrs_351','Rrs_353','Rrs_356','Rrs_358','Rrs_361','Rrs_363','Rrs_366','Rrs_368','Rrs_371','Rrs_373','Rrs_375','Rrs_378','Rrs_380','Rrs_383','Rrs_385','Rrs_388','Rrs_390','Rrs_393','Rrs_395','Rrs_398',...
    'Rrs_400','Rrs_403','Rrs_405','Rrs_408','Rrs_410','Rrs_413','Rrs_415','Rrs_418','Rrs_420','Rrs_422','Rrs_425','Rrs_427','Rrs_430','Rrs_432','Rrs_435','Rrs_437','Rrs_440','Rrs_442','Rrs_445','Rrs_447','Rrs_450','Rrs_452','Rrs_455','Rrs_457','Rrs_460','Rrs_462','Rrs_465','Rrs_467','Rrs_470','Rrs_472','Rrs_475','Rrs_477','Rrs_480','Rrs_482','Rrs_485','Rrs_487','Rrs_490','Rrs_492','Rrs_495','Rrs_497',...
    'Rrs_500','Rrs_502','Rrs_505','Rrs_507','Rrs_510','Rrs_512','Rrs_515','Rrs_517','Rrs_520','Rrs_522','Rrs_525','Rrs_527','Rrs_530','Rrs_532','Rrs_535','Rrs_537','Rrs_540','Rrs_542','Rrs_545','Rrs_547','Rrs_550','Rrs_553','Rrs_555','Rrs_558','Rrs_560','Rrs_563','Rrs_565','Rrs_568','Rrs_570','Rrs_573','Rrs_575','Rrs_578','Rrs_580','Rrs_583','Rrs_586','Rrs_588','Rrs_591','Rrs_593','Rrs_596','Rrs_598',...
    'Rrs_601','Rrs_603','Rrs_605','Rrs_608','Rrs_610','Rrs_613','Rrs_615','Rrs_618','Rrs_620','Rrs_623','Rrs_625','Rrs_627','Rrs_630','Rrs_632','Rrs_635','Rrs_637','Rrs_640','Rrs_641','Rrs_642','Rrs_643','Rrs_645','Rrs_646','Rrs_647','Rrs_648','Rrs_650','Rrs_651','Rrs_652','Rrs_653','Rrs_655','Rrs_656','Rrs_657','Rrs_658','Rrs_660','Rrs_661','Rrs_662','Rrs_663','Rrs_665','Rrs_666','Rrs_667','Rrs_668','Rrs_670','Rrs_671','Rrs_672','Rrs_673','Rrs_675','Rrs_676','Rrs_677','Rrs_678','Rrs_679','Rrs_681','Rrs_682','Rrs_683','Rrs_684','Rrs_686','Rrs_687','Rrs_688','Rrs_689','Rrs_691','Rrs_693','Rrs_694','Rrs_696','Rrs_697','Rrs_698','Rrs_699'...
    'Rrs_701','Rrs_702','Rrs_703'};%,'Rrs_704','Rrs_706','Rrs_707','Rrs_708','Rrs_709','Rrs_711','Rrs_712','Rrs_713','Rrs_714','Rrs_717','Rrs_719'};
% LAT/LON LIMITS AND RESOLUTION
west_bound = '-85.0';
east_bound = '-78.5';
north_bound = '28.0';
south_bound = '24.0';
resolution = '1011.7'; % m per pixel (assumes square pixels)

% HEADER INFO
filename = 'map_POCI_florida_OC_AOP.xml';
graph_name = 'mosaic_PACE_GOM_BGC';

fileID = fopen(filename,'w');
format_spec = '%s\n';
eval(['fprintf(fileID,format_spec,''<graph id="' graph_name '">'');'])
fprintf(fileID,format_spec,'<version>1.0</version>');
fprintf(fileID,format_spec,'<node id="mosaicNode">');
fprintf(fileID,format_spec,'<operator>Mosaic</operator>');
fprintf(fileID,format_spec,'<sources>');
fprintf(fileID,format_spec,'<sourceProducts>${sourceProducts}</sourceProducts>');
fprintf(fileID,format_spec,'</sources>');
fprintf(fileID,format_spec,'<parameters>');
fprintf(fileID,format_spec,'<variables>');
% VARIABLE BLOCK
for i=1:length(var_list)
fprintf(fileID,format_spec,'<variable>');
eval(['fprintf(fileID,format_spec,''<name>' var_list{i} '</name>'');'])
eval(['fprintf(fileID,format_spec,''<expression>' var_list{i} '</expression>'');'])
fprintf(fileID,format_spec,'</variable>');
end    
% END VARIABLE BLOCK AND ADD L2_FLAGS/STRAYLIGHT MASK AND CONDITIONS
% AVW (PACE ONLY)
fprintf(fileID,format_spec,'<variable>');
fprintf(fileID,format_spec,'<name>avw</name>');
fprintf(fileID,format_spec,'<expression>avw</expression>');
fprintf(fileID,format_spec,'</variable>');
% L2_FLAGS
fprintf(fileID,format_spec,'<variable>');
fprintf(fileID,format_spec,'<name>l2_flags</name>');
fprintf(fileID,format_spec,'<expression>l2_flags</expression>');
fprintf(fileID,format_spec,'</variable>');
% STRAYLIGHT MASK
fprintf(fileID,format_spec,'<variable>');
fprintf(fileID,format_spec,'<name>STRAYLIGHT_MASK</name>');
fprintf(fileID,format_spec,'<expression>l2_flags.STRAYLIGHT ? 1 : 0</expression>');
fprintf(fileID,format_spec,'</variable>');
% END VARIABLES
fprintf(fileID,format_spec,'</variables>');
% ADD CONDITIONS
fprintf(fileID,format_spec,'<conditions>');
fprintf(fileID,format_spec,'<condition>');

fprintf(fileID,format_spec,'<name>not_LAND</name>');
fprintf(fileID,format_spec,'<expression>NOT l2_flags.LAND</expression>');
fprintf(fileID,format_spec,'<output>false</output>');
fprintf(fileID,format_spec,'</condition>');
fprintf(fileID,format_spec,'<condition>');
fprintf(fileID,format_spec,'<name>not_CLDICE</name>');
fprintf(fileID,format_spec,'<expression>NOT l2_flags.CLDICE</expression>');
fprintf(fileID,format_spec,'<output>false</output>');
fprintf(fileID,format_spec,'</condition>');
fprintf(fileID,format_spec,'<condition>');
fprintf(fileID,format_spec,'<name>not_HIGLINT</name>');
fprintf(fileID,format_spec,'<expression>NOT l2_flags.HIGLINT</expression>');
fprintf(fileID,format_spec,'<output>false</output>');
fprintf(fileID,format_spec,'</condition>');
fprintf(fileID,format_spec,'</conditions>');
fprintf(fileID,format_spec,'<combine>AND</combine>');
% ADD CRS BLOCK
fprintf(fileID,format_spec,'<crs>');
fprintf(fileID,format_spec,'PROJCS["Equidistant_Cylindrical / World Geodetic System 1984",');
fprintf(fileID,format_spec,'GEOGCS["World Geodetic System 1984",'); 
fprintf(fileID,format_spec,'DATUM["World Geodetic System 1984",'); 
fprintf(fileID,format_spec,'SPHEROID["WGS 84", 6378137.0, 298.257223563, AUTHORITY["EPSG","7030"]],'); 
fprintf(fileID,format_spec,'AUTHORITY["EPSG","6326"]],'); 
fprintf(fileID,format_spec,'PRIMEM["Greenwich", 0.0, AUTHORITY["EPSG","8901"]],'); 
fprintf(fileID,format_spec,'UNIT["degree", 0.017453292519943295],'); 
fprintf(fileID,format_spec,'AXIS["Geodetic longitude", EAST],'); 
fprintf(fileID,format_spec,'AXIS["Geodetic latitude", NORTH]],'); 
fprintf(fileID,format_spec,'PROJECTION["Equidistant_Cylindrical"],'); 
fprintf(fileID,format_spec,'PARAMETER["central_meridian", 0.0],'); 
fprintf(fileID,format_spec,'PARAMETER["latitude_of_origin", 0.0],'); 
fprintf(fileID,format_spec,'PARAMETER["standard_parallel_1", 0.0],'); 
fprintf(fileID,format_spec,'PARAMETER["false_easting", 0.0],'); 
fprintf(fileID,format_spec,'PARAMETER["false_northing", 0.0],'); 
fprintf(fileID,format_spec,'UNIT["m", 1.0],'); 
fprintf(fileID,format_spec,'AXIS["Easting", EAST],');
fprintf(fileID,format_spec,'AXIS["Northing", NORTH]]'); 
fprintf(fileID,format_spec,'</crs>');
fprintf(fileID,format_spec,'<orthorectify>false</orthorectify>');
fprintf(fileID,format_spec,'<elevationModelName>GETASSE30</elevationModelName>');
fprintf(fileID,format_spec,'<resampling>Nearest</resampling>');
eval(['fprintf(fileID,format_spec,''<westBound>' west_bound '</westBound>'');'])
eval(['fprintf(fileID,format_spec,''<northBound>' north_bound '</northBound>'');'])
eval(['fprintf(fileID,format_spec,''<eastBound>' east_bound '</eastBound>'');'])
eval(['fprintf(fileID,format_spec,''<southBound>' south_bound '</southBound>'');'])
eval(['fprintf(fileID,format_spec,''<pixelSizeX>' resolution '</pixelSizeX>'');'])
eval(['fprintf(fileID,format_spec,''<pixelSizeY>' resolution '</pixelSizeY>'');'])
% CLOSE PARAMS AND MOSAIC NODE
fprintf(fileID,format_spec,'</parameters>');
fprintf(fileID,format_spec,'</node>');
% BANDMATH NODE
fprintf(fileID,format_spec,'<node id="selectBandsNode">');
fprintf(fileID,format_spec,'<operator>BandMaths</operator>');
fprintf(fileID,format_spec,'<sources>');
fprintf(fileID,format_spec,'<sourceProducts>mosaicNode</sourceProducts>');
fprintf(fileID,format_spec,'</sources>');
fprintf(fileID,format_spec,'<parameters>');
fprintf(fileID,format_spec,'<targetBands>');
% TARGET BAND DEFINITION FOR EACH VARIABLE
for i=1:length(var_list)
wavelength = var_list{i}; wavelength = wavelength(5:7);    
fprintf(fileID,format_spec,'<targetBand>');
eval(['fprintf(fileID,format_spec,''<name>' var_list{i} '</name>'');'])
eval(['fprintf(fileID,format_spec,''<expression>' var_list{i} '</expression>'');'])
eval(['fprintf(fileID,format_spec,''<description>Remote sensing reflectance at ' wavelength 'nm</description>'');'])
fprintf(fileID,format_spec,'<type>float32</type>');
eval(['fprintf(fileID,format_spec,''<validExpression>(' var_list{i} ' > -0.01 and ' var_list{i} ' &lt; 0.2 and ' var_list{i} ' !=0)</validExpression>'');'])
fprintf(fileID,format_spec,'<noDataValue>NaN</noDataValue>');
eval(['fprintf(fileID,format_spec,''<spectralWavelength>' wavelength '.0</spectralWavelength>'');'])
fprintf(fileID,format_spec,'<unit>sr^-1</unit>');
fprintf(fileID,format_spec,'</targetBand>');
end
% ADD OTHER BANDS (PRODUCT SPECIFIC)
% AVW (PACE)
fprintf(fileID,format_spec,'<targetBand>');
fprintf(fileID,format_spec,'<name>avw</name>');
fprintf(fileID,format_spec,'<expression>avw</expression>');
fprintf(fileID,format_spec,'<description>Apparent Visible Wavelength</description>');
fprintf(fileID,format_spec,'<type>float32</type>');   
fprintf(fileID,format_spec,'<noDataValue>NaN</noDataValue>');
fprintf(fileID,format_spec,'<unit>nm</unit>');
fprintf(fileID,format_spec,'</targetBand>');
% STRAYLIGHT MASK (ALL SENSORS)
fprintf(fileID,format_spec,'<targetBand>');
fprintf(fileID,format_spec,'<name>STRAYLIGHT_MASK</name>');
fprintf(fileID,format_spec,'<expression>STRAYLIGHT_MASK</expression>');
fprintf(fileID,format_spec,'<description>Straylight affected pixels</description>');
fprintf(fileID,format_spec,'<type>float32</type>');             
fprintf(fileID,format_spec,'</targetBand>');
% CLOSE BANDS
fprintf(fileID,format_spec,'</targetBands>');
% END BANDMATH NODE AND GRAPH
fprintf(fileID,format_spec,'</parameters>');
fprintf(fileID,format_spec,'</node>');
fprintf(fileID,format_spec,'</graph>');
% CLOSE FILE
fclose(fileID);









