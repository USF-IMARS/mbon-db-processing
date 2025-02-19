#!/bin/bash

echo downloading dods files from USGS gages...
 
# FK South 
curl -o /srv/pgs/rois2/gom/USGS_temp/SharkRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_72137=on&format=rdb&site_no=252230081021300&referred_module=sw&period=&begin_date=1910-01-01'  
curl -o /srv/pgs/rois2/gom/USGS_temp/HarneyRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_72137=on&format=rdb&site_no=252551081050900&referred_module=sw&period=&begin_date=1910-01-01'
curl -o /srv/pgs/rois2/gom/USGS_temp/BroadRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_72137=on&format=rdb&site_no=02290878&referred_module=sw&period=&begin_date=1910-01-01' 
curl -o /srv/pgs/rois2/gom/USGS_temp/LostmansRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_72137=on&format=rdb&site_no=02290918&referred_module=sw&period=&begin_date=1910-01-01' 
curl -o /srv/pgs/rois2/gom/USGS_temp/ChathamRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_72137=on&format=rdb&site_no=02290888&referred_module=sw&period=&begin_date=1910-01-01'     
  
# FK North
curl -o /srv/pgs/rois2/gom/USGS_temp/BarronRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00060=on&format=rdb&site_no=02291001&referred_module=sw&period=&begin_date=1910-01-01'      
curl -o /srv/pgs/rois2/gom/USGS_temp/EastRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_72137=on&format=rdb&site_no=255327081275900&referred_module=sw&period=&begin_date=1910-01-01'     
curl -o /srv/pgs/rois2/gom/USGS_temp/FakaRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_72137=on&format=rdb&site_no=255432081303900&referred_module=sw&period=&begin_date=1910-01-01'     
curl -o /srv/pgs/rois2/gom/USGS_temp/PumpkinRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_72137=on&format=rdb&site_no=255534081324000&referred_module=sw&period=&begin_date=1910-01-01'     
curl -o /srv/pgs/rois2/gom/USGS_temp/BlackwaterRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_72137=on&format=rdb&site_no=255654081350200&referred_module=sw&period=&begin_date=1910-01-01'     

# FK East (for FWC and FKNMS coral dashboards)
# These locations have gage height, not discharge
curl -o /srv/pgs/rois2/gom/USGS_temp/Canal135Rv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00065=on&format=rdb&site_no=02286328&referred_module=sw&period=&begin_date=1910-01-01'     
curl -o /srv/pgs/rois2/gom/USGS_temp/LoxRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00065=on&format=rdb&site_no=265906080093500&referred_module=sw&period=&begin_date=1910-01-01'     
curl -o /srv/pgs/rois2/gom/USGS_temp/StLucieRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00065=on&format=rdb&site_no=02277100&referred_module=sw&period=&begin_date=1910-01-01'     
# Updated 4/19/2021 - Added new rivers in East FL
curl -o /srv/pgs/rois2/gom/USGS_temp/BlackRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00065=on&format=rdb&site_no=02290709&referred_module=sw&period=&begin_date=1910-01-01'
curl -o /srv/pgs/rois2/gom/USGS_temp/TamiamiRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00065=on&format=rdb&site_no=02289500&referred_module=sw&period=&begin_date=1910-01-01'
curl -o /srv/pgs/rois2/gom/USGS_temp/SnapperRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00065=on&format=rdb&site_no=254157080213800&referred_module=sw&period=&begin_date=1910-01-01'

# FGB  
curl -o /srv/pgs/rois2/gom/USGS_temp/SabineRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00060=on&format=rdb&site_no=08030500&referred_module=sw&period=&begin_date=1910-01-01'  
curl -o /srv/pgs/rois2/gom/USGS_temp/BrazosRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00060=on&format=rdb&site_no=08116650&referred_module=sw&period=&begin_date=1910-01-01'
curl -o /srv/pgs/rois2/gom/USGS_temp/ColoradoRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00060=on&format=rdb&site_no=08162000&referred_module=sw&period=&begin_date=1910-01-01'
curl -o /srv/pgs/rois2/gom/USGS_temp/TrinityRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00060=on&format=rdb&site_no=08066500&referred_module=sw&period=&begin_date=1910-01-01' 
curl -o /srv/pgs/rois2/gom/USGS_temp/NechesRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00060=on&format=rdb&site_no=08041780&referred_module=sw&period=&begin_date=1910-01-01' 
curl -o /srv/pgs/rois2/gom/USGS_temp/MissRv_disch.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00060=on&format=rdb&site_no=07374000&referred_module=sw&period=&begin_date=1910-01-01'     

# SEUS (Some of these locations have WQ params along with discharge - grab data separately)
# Gray's Reef 
# Get gage height (cb_00065) for each site (files should be consistent(?!?))
# Savannah River (2007-present)
curl -o /srv/pgs/rois2/seus/USGS_temp/SavannahRv_GH.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00065=on&format=rdb&site_no=021989773&referred_module=sw&period=&begin_date=1910-01-01'
# HudsonCr (2000-present)       
curl -o /srv/pgs/rois2/seus/USGS_temp/HudsonCr_GH.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00065=on&format=rdb&site_no=022035975&referred_module=sw&period=&begin_date=1910-01-01'     
# SatillaRv (2009-present)
curl -o /srv/pgs/rois2/seus/USGS_temp/SatillaRv_GH.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00065=on&format=rdb&site_no=02228070&referred_module=sw&period=&begin_date=1910-01-01'     
# AltamahaRv (2008-present)
curl -o /srv/pgs/rois2/seus/USGS_temp/AltamahaRv_GH.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00065=on&format=rdb&site_no=02226160&referred_module=sw&period=&begin_date=1910-01-01' 
# StJohnsRv (2015-present)
curl -o /srv/pgs/rois2/seus/USGS_temp/StJohnsRv_GH.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00065=on&format=rdb&site_no=02246500&referred_module=sw&period=&begin_date=1910-01-01' 
# OgeecheeRv (2009-present)
curl -o /srv/pgs/rois2/seus/USGS_temp/OgeecheeRv_GH.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00065=on&format=rdb&site_no=02203536&referred_module=sw&period=&begin_date=1910-01-01' 
# BrunswickRv (2000-present)
curl -o /srv/pgs/rois2/seus/USGS_temp/BrunswickRv_GH.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00065=on&format=rdb&site_no=02226180&referred_module=sw&period=&begin_date=1910-01-01' 
# StMarysRv (2009-present)
curl -o /srv/pgs/rois2/seus/USGS_temp/StMarysRv_GH.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00065=on&format=rdb&site_no=02231254&referred_module=sw&period=&begin_date=1910-01-01' 

# TODO
# SavannahRv and HudsonCr have WQ data as well (need their own import functions)
# Savannah River (2007-present)
# curl -o /srv/pgs/rois2/seus/USGS_temp/SavannahRv_USGS_WQ.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00010&cb_00045=on&cb_00300=on&cb_00400=on&cb_00480=on&cb_63680=on&format=rdb&site_no=021989773&referred_module=sw&period=&begin_date=1910-01-01'
# HudsonCr (2000-present)       
# curl -o /srv/pgs/rois2/seus/USGS_temp/HudsonCr_USGS_WQ.txt 'https://waterdata.usgs.gov/nwis/dv?cb_00010=on&cb_00045=on&cb_00065=on&cb_00095=on&cb_00300=on&cb_00400=on&cb_63680=on&format=rdb&site_no=022035975&referred_module=sw&period=&begin_date=1910-01-01'     

echo updating FK  USGS dashboard files...    
matlab -nodisplay -r "cd('~/DB_files/DB_v24/');TXT2CSV_USGS_FK_dbv24;quit"

echo updating FGB USGS dashboard files...    
matlab -nodisplay -r "cd('~/DB_files/DB_v24/');TXT2CSV_USGS_FGB_dbv24;quit"

# Sed to replace NaN values with blank space (all GOM USGS files)
# sed -i 's/NaN/ /g' /srv/pgs/rois2/gom/csv_ts_data/data/USGS_*.csv

echo updating SEUS USGS dashboard files...    
matlab -nodisplay -r "cd('~/DB_files/DB_v24/');TXT2CSV_USGS_SEUS_dbv24;quit"

# Sed to replace NaN values with blank space (all SEUS USGS files)
# sed -i 's/NaN/ /g' /srv/pgs/rois2/seus/csv_ts_data/data/USGS_*.csv


