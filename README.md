# hdf2tif
Export MODIS MOD13Q1 images to Geotif


## Pre-requisites:
- LINUX
- [GDAL](http://gdal.org/)
- [GNU parallel](https://www.gnu.org/software/parallel/) (optional)


## Files
- LICENSE 	            License file.
- README.md             This file.
- hdf2tif.sh 	        Script. Export a single MOD13Q1 file to GeoTIF.
- hdf2tif_parallel.sh   Script. Export images in parallel. Depends on *hdf2tif.sh* and *GNU parallel*.


## Instructions
1 Clone this repository.
2 Make the scripts executable.
3 Call `hdf2tif.sh` to see its help.
4 Optionally, modify and run *hdf2tif_parallel.sh* to export the same band of several HDFs.


## Notes:
- *hdf2tif_parallel.sh* is just an example and it doesn't receive arguments. Change its source code to adapt it to your needs.
