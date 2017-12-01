#!/bin/bash
################################################################################
# Export HDF files to TIF in parallel
#-------------------------------------------------------------------------------
#
################################################################################
export H=12
export V=10
export FIRST=512
export xoff=0
export yoff=0
export xsize=400
export ysize=400
export path_modis=/home/scidb/MODIS
export path_tmp="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export FILES=$(find $path_modis -type f | grep "MOD13Q1\.A[0-9]\{7\}\.h"$H"v"$V"\.006\.[0-9]\{13\}\.hdf$" | sort | head -n $FIRST)

date

# get files to export
export FILES=$(find $path_modis -type f | grep "MOD13Q1\.A[0-9]\{7\}\.h"$H"v"$V"\.006\.[0-9]\{13\}\.hdf$" | sort | head -n $FIRST)

# write the dates down
export FNAMES=($FILES)
for ((i=0;i<${#FNAMES[@]};++i)); do
    echo $(basename ${FNAMES[i]} | awk -F "." '{ print $2 }') >> MOD13Q1_h"$H"v"$V"_006_dates.txt
done

# NDVI
export BAND=1
time parallel --jobs 16 $path_tmp/./hdf2tif.sh {1} $BAND $xoff $yoff $xsize $ysize ::: $FILES > /dev/null
export         FILES_NDVI=$(find $path_tmp -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_NDVI\.tif$"             | sort | head -n $FIRST)
gdal_merge.py $FILES_NDVI -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_NDVI.tif
rm            $FILES_NDVI

# EVI
export BAND=2
time parallel --jobs 16 $path_tmp/./hdf2tif.sh {1} $BAND $xoff $yoff $xsize $ysize ::: $FILES > /dev/null
export         FILES_EVI=$( find $path_tmp -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_EVI\.tif$"              | sort | head -n $FIRST)
gdal_merge.py $FILES_EVI  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_EVI.tif
rm            $FILES_EVI

# QUALITY
#export BAND=3
#time parallel --jobs 16 $path_tmp/./hdf2tif.sh {1} $BAND $xoff $yoff $xsize $ysize ::: $FILES > /dev/null
#export         FILES_QA=$(  find $path_tmp -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_VI_Quality\.tif$"       | sort | head -n $FIRST)
#gdal_merge.py $FILES_QA   -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_VI_Quality.tif
#rm            $FILES_QA

# RED
export BAND=4
time parallel --jobs 16 $path_tmp/./hdf2tif.sh {1} $BAND $xoff $yoff $xsize $ysize ::: $FILES > /dev/null
export         FILES_RED=$( find $path_tmp -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_red_reflectance\.tif$"  | sort | head -n $FIRST)
gdal_merge.py $FILES_RED  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_red_reflectance.tif
rm            $FILES_RED

# NIR
export BAND=5
time parallel --jobs 16 $path_tmp/./hdf2tif.sh {1} $BAND $xoff $yoff $xsize $ysize ::: $FILES > /dev/null
export         FILES_NIR=$( find $path_tmp -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_NIR_reflectance\.tif$"  | sort | head -n $FIRST)
gdal_merge.py $FILES_NIR  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_NIR_reflectance.tif
rm            $FILES_NIR

# BLUE
export BAND=6
time parallel --jobs 16 $path_tmp/./hdf2tif.sh {1} $BAND $xoff $yoff $xsize $ysize ::: $FILES > /dev/null
export         FILES_BLUE=$(find $path_tmp -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_blue_reflectance\.tif$" | sort | head -n $FIRST)
gdal_merge.py $FILES_BLUE -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_blue_reflectance.tif
rm            $FILES_BLUE

# MIR
export BAND=7
time parallel --jobs 16 $path_tmp/./hdf2tif.sh {1} $BAND $xoff $yoff $xsize $ysize ::: $FILES > /dev/null
export         FILES_MIR=$( find $path_tmp -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_MIR_reflectance\.tif$"  | sort | head -n $FIRST)
gdal_merge.py $FILES_MIR  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_MIR_reflectance.tif
rm            $FILES_MIR

# VIEW ZENITH ANGLE
#export BAND=8
#time parallel --jobs 16 $path_tmp/./hdf2tif.sh {1} $BAND $xoff $yoff $xsize $ysize ::: $FILES > /dev/null
#export         FILES_VIEW=$(find $path_tmp -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_view_zenith_angle\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_VIEW -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_view_zenith_angle.tif
#rm            $FILES_VIEW

# SUN ZENITH ANGLE
#export BAND=9
#time parallel --jobs 16 $path_tmp/./hdf2tif.sh {1} $BAND $xoff $yoff $xsize $ysize ::: $FILES > /dev/null
#export         FILES_SUN=$( find $path_tmp -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_sun_zenith_angle\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_SUN  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_sun_zenith_angle.tif
#rm            $FILES_SUN

# RELATIVE AZIMUTH ANGLE
#export BAND=10
#time parallel --jobs 16 $path_tmp/./hdf2tif.sh {1} $BAND $xoff $yoff $xsize $ysize ::: $FILES > /dev/null
#export         FILES_REL=$( find $path_tmp -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_relative_azimuth_angle\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_REL  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_relative_azimuth_angle.tif
#rm            $FILES_REL

# COMPOSITE DAY OF THE YEAR
#export BAND=11
#time parallel --jobs 16 $path_tmp/./hdf2tif.sh {1} $BAND $xoff $yoff $xsize $ysize ::: $FILES > /dev/null
#export         FILES_DOY=$( find $path_tmp -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_composite_day_of_the_year\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_DOY  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_composite_day_of_the_year.tif
#rm            $FILES_DOY

# PIXEL RELIABILITY
#export BAND=12
#time parallel --jobs 16 $path_tmp/./hdf2tif.sh {1} $BAND $xoff $yoff $xsize $ysize ::: $FILES > /dev/null
#export         FILES_PRE=$( find $path_tmp -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_pixel_reliability\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_PRE  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_pixel_reliability.tif
#rm            $FILES_PRE

date

exit 0
