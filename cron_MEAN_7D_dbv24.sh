#/bin/bash

matlab -nodisplay -r "cd('/srv/imars-objects/homes/dotis/DB_files/DB_v24/');run_MEAN_7D_dbv24;quit"

# GOM
# VSNPP
chmod 776 /srv/imars-objects/tpa_pgs/rois2/gom/MEAN_7D_VSNPP/OC/*
chmod 776 /srv/imars-objects/tpa_pgs/rois2/gom/MEAN_7D_VSNPP/SSTN/*
# chmod 776 /srv/imars-objects/tpa_pgs/rois2/gom/MEAN_7D_VSNPP/SST/*
# MODA
chmod 776 /srv/imars-objects/tpa_pgs/rois2/gom/MEAN_7D_MODA/OC/*
# chmod 776 /srv/imars-objects/tpa_pgs/rois2/gom/MEAN_7D_MODA/SST4/*

# SEUS
# VSNPP
chmod 776 /srv/imars-objects/tpa_pgs/rois2/seus/MEAN_7D_VSNPP/OC/*
chmod 776 /srv/imars-objects/tpa_pgs/rois2/seus/MEAN_7D_VSNPP/SSTN/*
# chmod 776 /srv/imars-objects/tpa_pgs/rois2/seus/MEAN_7D_VSNPP/SST/*
# GOM
chmod 776 /srv/imars-objects/tpa_pgs/rois2/seus/MEAN_7D_MODA/OC/*
# chmod 776 /srv/imars-objects/tpa_pgs/rois2/seus/MEAN_7D_MODA/SST4/*