#!/bin/bash
################################################################################
# Export HDF files to TIF in parallel
#-------------------------------------------------------------------------------
# 
################################################################################
export H=12
export V=10
export FIRST=512

# get files to export
export FILES=$(find /home/scidb/MODIS -type f | grep "MOD13Q1\.A[0-9]\{7\}\.h"$H"v"$V"\.006\.[0-9]\{13\}\.hdf$" | sort | head -n $FIRST)

# write the dates down
export FNAMES=($FILES)
for ((i=0;i<${#FNAMES[@]};++i)); do
    echo $(basename ${FNAMES[i]} | awk -F "." '{ print $2 }') >> MOD13Q1_h"$H"v"$V"_006_dates.txt
done

# NDVI
export BAND=1
parallel --jobs 0 /home/scidb/hdf2tif/./hdf2tif.sh {1} $BAND ::: $FILES
export         FILES_NDVI=$(find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_NDVI\.tif$"             | sort | head -n $FIRST)
gdal_merge.py $FILES_NDVI -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_NDVI.tif
rm            $FILES_NDVI

# EVI
export BAND=2
parallel --jobs 0 /home/scidb/hdf2tif/./hdf2tif.sh {1} $BAND ::: $FILES
export         FILES_EVI=$( find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_EVI\.tif$"              | sort | head -n $FIRST)
gdal_merge.py $FILES_EVI  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_EVI.tif
rm            $FILES_EVI

# QUALITY
#export BAND=3
#parallel --jobs 0 /home/scidb/hdf2tif/./hdf2tif.sh {1} $BAND ::: $FILES
#export         FILES_QA=$(  find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_VI_Quality\.tif$"       | sort | head -n $FIRST)
#gdal_merge.py $FILES_QA   -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_VI_Quality.tif
#rm            $FILES_QA

# RED
export BAND=4
parallel --jobs 0 /home/scidb/hdf2tif/./hdf2tif.sh {1} $BAND ::: $FILES
export         FILES_RED=$( find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_red_reflectance\.tif$"  | sort | head -n $FIRST)
gdal_merge.py $FILES_RED  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_red_reflectance.tif
rm            $FILES_RED

# NIR
export BAND=5
parallel --jobs 0 /home/scidb/hdf2tif/./hdf2tif.sh {1} $BAND ::: $FILES
export         FILES_NIR=$( find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_NIR_reflectance\.tif$"  | sort | head -n $FIRST)
parallel --jobs 0 /home/scidb/hdf2tif/./hdf2tif.sh {1} $BAND ::: $FILES
gdal_merge.py $FILES_NIR  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_NIR_reflectance.tif
rm            $FILES_NIR

# BLUE
export BAND=6
parallel --jobs 0 /home/scidb/hdf2tif/./hdf2tif.sh {1} $BAND ::: $FILES
export         FILES_BLUE=$(find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_blue_reflectance\.tif$" | sort | head -n $FIRST)
gdal_merge.py $FILES_BLUE -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_blue_reflectance.tif
rm            $FILES_BLUE

# MIR
export BAND=7
parallel --jobs 0 /home/scidb/hdf2tif/./hdf2tif.sh {1} $BAND ::: $FILES
export         FILES_MIR=$( find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_MIR_reflectance\.tif$"  | sort | head -n $FIRST)
gdal_merge.py $FILES_MIR  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_MIR_reflectance.tif
rm            $FILES_MIR

# VIEW ZENITH ANGLE
#export BAND=8
#parallel --jobs 0 /home/scidb/hdf2tif/./hdf2tif.sh {1} $BAND ::: $FILES
#export         FILES_VIEW=$(find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_view_zenith_angle\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_VIEW -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_view_zenith_angle.tif
#rm            $FILES_VIEW

# SUN ZENITH ANGLE
#export BAND=9
#parallel --jobs 0 /home/scidb/hdf2tif/./hdf2tif.sh {1} $BAND ::: $FILES
#export         FILES_SUN=$( find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_sun_zenith_angle\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_SUN  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_sun_zenith_angle.tif
#rm            $FILES_SUN

# RELATIVE AZIMUTH ANGLE
#export BAND=10
#parallel --jobs 0 /home/scidb/hdf2tif/./hdf2tif.sh {1} $BAND ::: $FILES
#export         FILES_REL=$( find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_relative_azimuth_angle\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_REL  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_relative_azimuth_angle.tif
#rm            $FILES_REL

# COMPOSITE DAY OF THE YEAR
#export BAND=11
#parallel --jobs 0 /home/scidb/hdf2tif/./hdf2tif.sh {1} $BAND ::: $FILES
#export         FILES_DOY=$( find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_composite_day_of_the_year\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_DOY  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_composite_day_of_the_year.tif
#rm            $FILES_DOY

# PIXEL RELIABILITY
#export BAND=12
#parallel --jobs 0 /home/scidb/hdf2tif/./hdf2tif.sh {1} $BAND ::: $FILES
#export         FILES_PRE=$( find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_pixel_reliability\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_PRE  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_pixel_reliability.tif
#rm            $FILES_PRE

exit 0

