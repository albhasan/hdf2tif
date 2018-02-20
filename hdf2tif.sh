#!/bin/bash
################################################################################
# Export an HDF file to TIF
# TODO:
# - TEST this new version!!!!
# - add an OUTPUT DIRECTORY parameter
#-------------------------------------------------------------------------------
# Usage:
# ./hdf2tif.sh /home/scidb/MODIS/2006/MOD13Q1.A2006161.h12v10.006.2015161172946.hdf /path/to/output
# ./hdf2tif.sh /home/scidb/MODIS/2006/MOD13Q1.A2006161.h12v10.006.2015161172946.hdf /path/to/output 3
# ./hdf2tif.sh /home/scidb/MODIS/2006/MOD13Q1.A2006161.h12v10.006.2015161172946.hdf /path/to/output 0 0 40 40
# ./hdf2tif.sh /home/scidb/MODIS/2006/MOD13Q1.A2006161.h12v10.006.2015161172946.hdf /path/to/output 3 0 0 40 40
################################################################################

# is gdal & R installed?
command -v gdal_translate >/dev/null 2>&1 || { echo >&2 "ERROR: gdal_translate not found."; exit 1; }

hdf=$1
outputdir=$2
if [ $# -eq 2 -o $# -eq 6 ] ; then
    #echo "Exporting all subdatasets..."
    sds=$(      gdalinfo "$hdf" | grep "SUBDATASET_[0-9]\{1,2\}_NAME"  | awk -F "=" '{ print $2 }' | awk -F ":" '{print $1":"$2":"$3":"$4}')
    fnames=$(   gdalinfo "$hdf" | grep "SUBDATASET_[0-9]\{1,2\}_NAME"  | awk -F "=" '{ print $2 }' | awk -F ":" '{ print $5 }' |  tr -s ' ' | tr ' ' '_')
    tilenames=$(gdalinfo "$hdf" | grep "SUBDATASET_[0-9]\{1,2\}_NAME"  | awk -F "=" '{ print $2 }' | awk -F '"' '{ print $2 }' | awk -F "/" '{ print $NF }' | awk -F "." '{ print $1"_"$3"_"$4"_"$2 }')
elif [ $# -eq 3 -o $# -eq 7 ] ; then
    #echo "Export a single subdataset..."
    sdsid=$3
    sds=$(      gdalinfo "$hdf" | grep "SUBDATASET_""$sdsid""_NAME"  | awk -F "=" '{ print $2 }' | awk -F ":" '{print $1":"$2":"$3":"$4}')
    fnames=$(   gdalinfo "$hdf" | grep "SUBDATASET_""$sdsid""_NAME"  | awk -F "=" '{ print $2 }' | awk -F ":" '{ print $5 }' |  tr -s ' ' | tr ' ' '_')
    tilenames=$(gdalinfo "$hdf" | grep "SUBDATASET_""$sdsid""_NAME"  | awk -F "=" '{ print $2 }' | awk -F '"' '{ print $2 }' | awk -F "/" '{ print $NF }' | awk -F "." '{ print $1"_"$3"_"$4"_"$2 }')
else
    echo 'ERROR: Wrong number of parameters'
    echo ''
    echo 'Usage: '
    echo 'hdf2tif.sh HDF_file output [subdataset] [xoff yoff xsize ysize]'
    echo '  HDF_file    Path to a HDF file'
    echo '  output      Path to the output directory'
    echo '  subdataset  Number. A subdataset ID (See gdalinfo)'
    echo '  xoff        Number. First pixel to export'
    echo '  yoff        Number. First pixel to export'
    echo '  xsize       Number of pixels to export'
    echo '  ysize       Number of pixels to export'
    exit 1
fi

win=""
fsuffix=""
if [ $# -eq 6 ] ; then
    xoff=$3
    yoff=$4
    xsize=$5
    ysize=$6
    win="-srcwin $xoff $yoff $xsize $ysize"
    fsuffix=_"$xoff"_"$yoff"_"$xsize"_"$ysize"
elif [ $# -eq 7 ] ; then
    xoff=$4
    yoff=$5
    xsize=$6
    ysize=$7
    win="-srcwin $xoff $yoff $xsize $ysize"
    fsuffix=_"$xoff"_"$yoff"_"$xsize"_"$ysize"
fi

array=($sds)                # subdata set names
array2=($fnames)            # output filenames
array3=($tilenames)         # info regarding the MODIS tile
for ((i=0;i<${#array[@]};++i)); do
    bname=$(echo "${array2[i]}" | tr '_' ' ') # build band name from output filename
    eval "gdal_translate -of GTiff $win '${array[i]}:$bname' $outputdir/${array3[i]}_${array2[i]}$fsuffix.tif"
done

exit 0
