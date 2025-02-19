#!/bin/bash

# Get all buoy data via ERRDAP (SECOORA, can add others)
# Download .csv, 
# Then replace NaN with blank space and add comma to start of each row (sed)

##### SEUS Buoys with stdmet and waves
# prefix = 'gov-ndbc'
# roi = 'seus'
# suite = 'STDMET'
# station_name = {'Charleston_Buoy','Grays_Reef_Buoy','Fernadina_Buoy'}
# station_ID = {'41004','41008','41112'}
# parameter = {'air_pressure_at_mean_sea_level','air_temperature','sea_surface_temperature','wind_speed','wind_from_direction','wind_speed_of_gust','sea_surface_wave_significant_height','sea_surface_wave_mean_period','sea_surface_wave_from_direction','sea_surface_wave_period_at_variance_spectral_density_maximum'}

##### GOM Buoys with temp and salinity
# prefix = 'gov-nps-ever'
# roi = 'gom'
# suite = 'WTMP_SAL'
# station_name = {'Peterson_Key','Butternut_Key','Bob_Allen_Key','Whipray_Basin','Little_Rabbit_Key'}
# station_ID = {'pkyf1','bnkf1','bobf1','wrbf1',lrkf1'}
# parameter = {'sea_water_temperature','sea_water_practical_salinity'}

##### GOM Buoys with temp only
# prefix = 'gov-ndbc'
# roi = 'gom'
# suite = 'WTMP'
# station_name = {'Satan_Shoal'}
# station_ID = {'42095'}
# parameter = {'sea_water_temperature'}

# SECOORA ERDDAP URL will be different for various buoy types
# Type 1: NPS buoys in FL Bay (water temp and salinity only)
curl -o /srv/pgs/rois2/gom/csv_ts_data/data/Peterson_Key_Buoy_WTMP_SAL.csv 'https://erddap.secoora.org/erddap/tabledap/gov-nps-ever-pkyf1.csv?time%2Csea_water_temperature%2Csea_water_practical_salinity'
curl -o /srv/pgs/rois2/gom/csv_ts_data/data/Butternut_Key_Buoy_WTMP_SAL.csv 'https://erddap.secoora.org/erddap/tabledap/gov-nps-ever-bnkf1.csv?time%2Csea_water_temperature%2Csea_water_practical_salinity'
curl -o /srv/pgs/rois2/gom/csv_ts_data/data/Bob_Allen_Key_Buoy_WTMP_SAL.csv 'https://erddap.secoora.org/erddap/tabledap/gov-nps-ever-bobf1.csv?time%2Csea_water_temperature%2Csea_water_practical_salinity'
curl -o /srv/pgs/rois2/gom/csv_ts_data/data/Whipray_Basin_Buoy_WTMP_SAL.csv 'https://erddap.secoora.org/erddap/tabledap/gov-nps-ever-wrbf1.csv?time%2Csea_water_temperature%2Csea_water_practical_salinity'
curl -o /srv/pgs/rois2/gom/csv_ts_data/data/Little_Rabbit_Key_Buoy_WTMP_SAL.csv 'https://erddap.secoora.org/erddap/tabledap/gov-nps-ever-lrkf1.csv?time%2Csea_water_temperature%2Csea_water_practical_salinity'

# Example 2: 41004 buoy (stdmet params)
curl -o /srv/pgs/rois2/seus/csv_ts_data/data/Charleston_Buoy_STDMET.csv 'https://erddap.secoora.org/erddap/tabledap/gov-ndbc-41004.csv?time%2Cair_pressure_at_mean_sea_level%2Cair_temperature%2Csea_surface_temperature%2Cwind_speed%2Cwind_from_direction%2Cwind_speed_of_gust%2Csea_surface_wave_significant_height%2Csea_surface_wave_mean_period%2Csea_surface_wave_from_direction%2Csea_surface_wave_period_at_variance_spectral_density_maximum'
curl -o /srv/pgs/rois2/seus/csv_ts_data/data/Grays_Reef_Buoy_STDMET.csv 'https://erddap.secoora.org/erddap/tabledap/gov-ndbc-41008.csv?time%2Cair_pressure_at_mean_sea_level%2Cair_temperature%2Csea_surface_temperature%2Cwind_speed%2Cwind_from_direction%2Cwind_speed_of_gust%2Csea_surface_wave_significant_height%2Csea_surface_wave_mean_period%2Csea_surface_wave_from_direction%2Csea_surface_wave_period_at_variance_spectral_density_maximum'
# Fernandina Buoy is not NDBC (has different params)
curl -o /srv/pgs/rois2/seus/csv_ts_data/data/Fernandina_Buoy_STDMET.csv 'https://erddap.secoora.org/erddap/tabledap/edu_ucsd_cdip_132.csv?time%2Csea_water_temperature%2Csea_surface_wave_significant_height%2Csea_surface_wave_mean_period%2Csea_surface_wave_from_direction%2Csea_surface_wave_period_at_variance_spectral_density_maximum'

# Example 2 w/variable substitutions
# curl -o /srv/pgs/rois2/{roi}/NDBC_temp/{station}_{suite}.csv 'https://erddap.secoora.org/erddap/tabledap/{prefix}-{station}.csv?time%2C{parameter(0)%2Cparameter(1)%2C....}' (param names need to be separated by '%2C')

# Sed to replace NaN values with blank space
# sed -i 's/NaN/ /g' /srv/pgs/rois2/gom/csv_ts_data/data/*_Buoy_*.csv
# sed -i 's/NaN/ /g' /srv/pgs/rois2/seus/csv_ts_data/data/*_Buoy_*.csv

# Sed to place comma at the start of each row
# sed -i 's/^/,/' /srv/pgs/rois2/gom/csv_ts_data/data/*_Buoy_*.csv
# sed -i 's/^/,/' /srv/pgs/rois2/seus/csv_ts_data/data/*_Buoy_*.csv

# Sed to place comma at the end of each row (needed?)
# sed -i 's/$/,/' /srv/pgs/rois2/gom/csv_ts_data/data/*_Buoy_*.csv
# sed -i 's/$/,/' /srv/pgs/rois2/seus/csv_ts_data/data/*_Buoy_*.csv


