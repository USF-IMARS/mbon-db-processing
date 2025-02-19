#/bin/bash

# Execute MATLAB routine to mosaic OC and SST products into 1-day output NetCDF files
# Set up to get PACE OCI data from NASA CMR
# Replaces subscriptions and ftp scripts in home directory
# PACE only for now, will add others later (updated 2/18/2025)
matlab -nodisplay -r "cd('~/DB_files/DB_v24');Run_CMR_Ingest_vPACE_OCI_cron;quit"

