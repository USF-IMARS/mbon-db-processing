#/bin/bash

# Execute MATLAB routine to mosaic OC and SST products into 1-day output NetCDF files
# Set up to loop through multiple roi
# All ROI, all sensors (updated 7/9/2024)
matlab -nodisplay -r "cd('/srv/imars-objects/homes/dotis/DB_files/DB_v24');run_mosaic_1D_dbv24;quit"

