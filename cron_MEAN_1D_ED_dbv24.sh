#/bin/bash

# Execute MATLAB routine to mosaic OC and SST products into 1-day output NetCDF files
# Set up to loop through multiple roi
# These files are for select roi and products
matlab -nodisplay -r "cd('~/DB_files/DB_v24');run_MEAN_1D_ED_dbv24;quit"

