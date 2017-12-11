#!/bin/bash
################################################################################
# Export HDF files to TIF in parallel
#-------------------------------------------------------------------------------
# TODO:
# - addapt to new version of hdf2bin which support output paths
#-------------------------------------------------------------------------------
# ./hdf2bin_parallel.sh 12 10 0 0 400 400 /home/scidb/MODIS /home/scidb/alber/ghprojects/hdf2tif/output
################################################################################

# is parallel installed?
command -v parallel >/dev/null 2>&1 || { echo >&2 "ERROR: GNU parallel not found."; exit 1; }

if [ $# -ne 9 ] ; then
    echo 'ERROR: Wrong number of parameters'
    echo ''
    echo 'Usage: '
    echo 'hdf2bin_parallel.sh tile_H tile_V xoff yoff xsize ysize path_modis path_tmp'
    echo '  tile_H      Number. The MODIS tile in the H direction'
    echo '  tile_V      Number. The MODIS tile in the V direction'
    echo '  xoff        Number. First pixel to export'
    echo '  yoff        Number. First pixel to export'
    echo '  xsize       Number of pixels to export'
    echo '  ysize       Number of pixels to export'
    echo '  path_modis  Path to a repository of MODIS data (HDF files)'
    echo '  path_tmp    Path to a temporal directory'
    echo '  path_output Path to store the results'
    exit 1
fi

#H=12
#V=10
FIRST=512
#xoff=0
#yoff=0
#xsize=400
#ysize=400
#path_modis=/home/scidb/MODIS
#path_output=/home/scidb/alber/ghprojects/hdf2tif/output
#path_tmp="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

H=$1
V=$2
xoff=$3
yoff=$4
xsize=$5
ysize=$6
path_modis=$7
path_tmp=$8
path_output=$9

date

# get files to export
FILES=$(find "$path_modis" -type f | grep "MOD13Q1\.A[0-9]\{7\}\.h""$H""v""$V""\.006\.[0-9]\{13\}\.hdf$" | sort | head -n $FIRST)

# write the dates down
FNAMES=($FILES)
for ((i=0;i<${#FNAMES[@]};++i)); do
    basename "${FNAMES[i]}" | awk -F "." '{ print $2 }' >> "$path_output"/MOD13Q1_h"$H"v"$V"_006_dates.txt
done

# NDVI
BAND=1
parallel --jobs 16 "$path_tmp"/./hdf2tif.sh {1} "$path_tmp" "$BAND" "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
               FILES_NDVI=$(find "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_NDVI.*\.tif$"             | sort | head -n $FIRST)
gdal_merge.py $FILES_NDVI -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_NDVI.tif
rm            $FILES_NDVI

# EVI
BAND=2
time parallel --jobs 16 "$path_tmp"/./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
               FILES_EVI=$( find "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_EVI.*\.tif$"              | sort | head -n $FIRST)
gdal_merge.py $FILES_EVI  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_EVI.tif
rm            $FILES_EVI

# QUALITY
#BAND=3
#time parallel --jobs 16 "$path_tmp"/./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#                FILES_QA=$(  find "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_VI_Quality.*\.tif$"       | sort | head -n $FIRST)
#gdal_merge.py $FILES_QA   -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_VI_Quality.tif
#rm            $FILES_QA

# RED
BAND=4
time parallel --jobs 16 "$path_tmp"/./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
               FILES_RED=$( find "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_red_reflectance.*\.tif$"  | sort | head -n $FIRST)
gdal_merge.py $FILES_RED  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_red_reflectance.tif
rm            $FILES_RED

# NIR
BAND=5
time parallel --jobs 16 "$path_tmp"/./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
                FILES_NIR=$( find "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_NIR_reflectance.*\.tif$"  | sort | head -n $FIRST)
gdal_merge.py $FILES_NIR  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_NIR_reflectance.tif
rm            $FILES_NIR

# BLUE
BAND=6
time parallel --jobs 16 "$path_tmp"/./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
                FILES_BLUE=$(find "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_blue_reflectance.*\.tif$" | sort | head -n $FIRST)
gdal_merge.py $FILES_BLUE -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_blue_reflectance.tif
rm            $FILES_BLUE

# MIR
BAND=7
time parallel --jobs 16 "$path_tmp"/./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
               FILES_MIR=$( find "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_MIR_reflectance.*\.tif$"  | sort | head -n $FIRST)
gdal_merge.py $FILES_MIR  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_MIR_reflectance.tif
rm            $FILES_MIR

# VIEW ZENITH ANGLE
#BAND=8
#time parallel --jobs 16 "$path_tmp"/./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#               FILES_VIEW=$(find "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_view_zenith_angle.*\.tif$$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_VIEW -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_view_zenith_angle.tif
#rm            $FILES_VIEW

# SUN ZENITH ANGLE
#BAND=9
#time parallel --jobs 16 "$path_tmp"/./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#               FILES_SUN=$( find "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_sun_zenith_angle.*\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_SUN  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_sun_zenith_angle.tif
#rm            $FILES_SUN

# RELATIVE AZIMUTH ANGLE
#BAND=10
#time parallel --jobs 16 "$path_tmp"/./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#                FILES_REL=$( find "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_relative_azimuth_angle.*\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_REL  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_relative_azimuth_angle.tif
#rm            $FILES_REL

# COMPOSITE DAY OF THE YEAR
#BAND=11
#time parallel --jobs 16 "$path_tmp"/./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#               FILES_DOY=$( find "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_composite_day_of_the_year.*\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_DOY  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_composite_day_of_the_year.tif
#rm            $FILES_DOY

# PIXEL RELIABILITY
#BAND=12
#time parallel --jobs 16 "$path_tmp"/./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#               FILES_PRE=$( find "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_pixel_reliability.*\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_PRE  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_pixel_reliability.tif
#rm            $FILES_PRE

date

exit 0
