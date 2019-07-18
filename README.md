# hdf2tif
Export MODIS MOD13Q1 images to Geotif


## Pre-requisites:
- LINUX
- [GDAL](http://gdal.org/)
- [R](https://cran.r-project.org/)
- [GNU parallel](https://www.gnu.org/software/parallel/) (optional)


## Files
- LICENSE 	        License file.
- README.md             This file.
- hdf2tif.sh 	        Script. Export a single MOD13Q1 file to GeoTIF.
- hdf2tif_parallel.sh   Script. Export images in parallel. Depends on *hdf2tif.sh* and *GNU parallel*.
- julday2date.R         Script. Convert julian-day dates to year-month-day and save them to a text file.

## Instructions
- Clone this repository.
- Call `hdf2tif.sh` and `hdf2tif_parallel.sh` to see their help.

