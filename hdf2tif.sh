#!/bin/bash
################################################################################
# Export an HDF file to TIF
#------------------------------------------ TODO: do int one band at the time!!!!!!!!!!!!1
# Usage:
# ./hdf2tif.sh /home/scidb/MODIS/2006/MOD13Q1.A2006161.h12v10.006.2015161172946.hdf 3
################################################################################
hdf=$1
if [ $# -eq 1 ] ; then
    #echo "Exporting all subdatasets..."
    sds=$(      gdalinfo $hdf | grep "SUBDATASET_._NAME"  | awk -F "=" '{ print $2 }' | awk -F ":" '{print $1":"$2":"$3":"$4}')
    fnames=$(   gdalinfo $hdf | grep "SUBDATASET_._NAME"  | awk -F "=" '{ print $2 }' | awk -F ":" '{ print $5 }' |  tr -s ' ' | tr ' ' '_')
    tilenames=$(gdalinfo $hdf | grep "SUBDATASET_._NAME"  | awk -F "=" '{ print $2 }' | awk -F '"' '{ print $2 }' | awk -F "/" '{ print $NF }' | awk -F "." '{ print $1"_"$3"_"$4"_"$2 }')
    array=($sds)                # subdata set names
    array2=($fnames)            # output filenames
    array3=($tilenames)         # info regarding the MODIS tile
    for ((i=0;i<${#array[@]};++i)); do
        bname=$(echo "${array2[i]}" | tr '_' ' ') # build band name from output filename
        eval "gdal_translate -of GTiff '${array[i]}:$bname' ${array3[i]}_${array2[i]}.tif"
    done
elif [ $# -eq 2 ] ; then
    echo "Export a single subdataset..."
    sdsid=$2
    sds=$(      gdalinfo $hdf | grep "SUBDATASET_"$sdsid"_NAME"  | awk -F "=" '{ print $2 }' | awk -F ":" '{print $1":"$2":"$3":"$4}')
    fnames=$(   gdalinfo $hdf | grep "SUBDATASET_"$sdsid"_NAME"  | awk -F "=" '{ print $2 }' | awk -F ":" '{ print $5 }' |  tr -s ' ' | tr ' ' '_')
    tilenames=$(gdalinfo $hdf | grep "SUBDATASET_"$sdsid"_NAME"  | awk -F "=" '{ print $2 }' | awk -F '"' '{ print $2 }' | awk -F "/" '{ print $NF }' | awk -F "." '{ print $1"_"$3"_"$4"_"$2 }')
    array=($sds)                # subdata set names
    array2=($fnames)            # output filenames
    array3=($tilenames)         # info regarding the MODIS tile
    for ((i=0;i<${#array[@]};++i)); do
        bname=$(echo "${array2[i]}" | tr '_' ' ') # build band name from output filename
        eval "gdal_translate -of GTiff '${array[i]}:$bname' ${array3[i]}_${array2[i]}.tif"
    done
else
    echo 'ERROR: Wrong number of parameters'
    echo ''
    echo 'Usage: '
    echo 'hdf2tif.sh HDF_file [subdataset]'
    echo '  HDF_file    Path to a HDF file'
    echo '  subdataset  Number. A subdataset ID (See gdalinfo)'
    exit 1
fi

exit 0

