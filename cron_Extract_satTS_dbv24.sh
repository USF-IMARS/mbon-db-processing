#/bin/bash

# Execute MATLAB routine to extract daily data at box and polygon locations
matlab -nodisplay -r "cd('~/DB_files/DB_v24');run_EXT_sat_1D_dbv24;quit"
