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
export BAND=1

# call the export script using in parallel
parallel --jobs 0 /home/scidb/hdf2tif/./hdf2tif.sh {1} $BAND ::: $FILES


# get the files
export         FILES_BLUE=$(find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_blue_reflectance\.tif$" | sort | head -n $FIRST)
gdal_merge.py $FILES_BLUE -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_blue_reflectance.tif
rm            $FILES_BLUE
export         FILES_EVI=$( find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_EVI\.tif$"              | sort | head -n $FIRST)
gdal_merge.py $FILES_EVI  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_EVI.tif
rm            $FILES_EVI
export         FILES_MIR=$( find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_MIR_reflectance\.tif$"  | sort | head -n $FIRST)
gdal_merge.py $FILES_MIR  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_MIR_reflectance.tif
rm            $FILES_MIR
export         FILES_NDVI=$(find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_NDVI\.tif$"             | sort | head -n $FIRST)
gdal_merge.py $FILES_NDVI -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_NDVI.tif
rm            $FILES_NDVI
export         FILES_NIR=$( find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_NIR_reflectance\.tif$"  | sort | head -n $FIRST)
gdal_merge.py $FILES_NIR  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_NIR_reflectance.tif
rm            $FILES_NIR
export         FILES_RED=$( find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_red_reflectance\.tif$"  | sort | head -n $FIRST)
gdal_merge.py $FILES_RED  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_red_reflectance.tif
rm            $FILES_RED
export         FILES_SUN=$( find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_sun_zenith_angle\.tif$" | sort | head -n $FIRST)
gdal_merge.py $FILES_SUN  -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_sun_zenith_angle.tif
rm            $FILES_SUN
export         FILES_VIEW=$(find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_view_zenith_angle\.tif$" | sort | head -n $FIRST)
gdal_merge.py $FILES_VIEW -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_view_zenith_angle.tif
rm            $FILES_VIEW
export         FILES_QA=$(  find /home/scidb/hdf2tif -type f | grep "MOD13Q1_h"$H"v"$V"_006_A[0-9]\{7\}_250m_16_days_VI_Quality\.tif$"       | sort | head -n $FIRST)
gdal_merge.py $FILES_QA   -separate -o MOD13Q1_h"$H"v"$V"_006_250m_16_days_VI_Quality.tif
rm            $FILES_QA

exit 0
