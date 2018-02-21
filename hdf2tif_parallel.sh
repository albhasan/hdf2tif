#!/bin/bash
################################################################################
# Export HDF files to TIF in parallel
#-------------------------------------------------------------------------------
# TODO:
#-------------------------------------------------------------------------------
# ./hdf2tif_parallel.sh 12 10 0 0 400 400 /home/scidb/MOD13Q1 /home/scidb/alber/ghprojects/hdf2tif/tmp /home/scidb/alber/ghprojects/hdf2tif/output 16
#-------------------------------------------------------------------------------
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
################################################################################

# Adapted from https://stackoverflow.com/questions/8455991/elegant-way-for-verbose-mode-in-scripts#33597663
# set verbose level to info
__VERBOSE=6
declare -A LOG_LEVELS
# https://en.wikipedia.org/wiki/Syslog#Severity_level
LOG_LEVELS=([0]="emerg" [1]="alert" [2]="crit" [3]="err" [4]="warning" [5]="notice" [6]="info" [7]="debug")
function .log () {
  local LEVEL=${1}
  shift
  if [ ${__VERBOSE} -ge ${LEVEL} ]; then
    d=$(date +%Y-%m-%d:%H:%M:%S)
    echo "[${LOG_LEVELS[$LEVEL]} $d]" "$@" >> hdf2tif_parallel.log
  fi
}

# Are parallel & Rscript installed?
command -v parallel >/dev/null 2>&1 || { echo >&2 "ERROR: GNU parallel not found."; .log 0 "GNU parallel not found" ; exit 1; }
command -v Rscript >/dev/null 2>&1 || { echo >&2 "ERROR: Rscript not found."; .log 0 "Rscript not found" ;exit 1; }

if [ $# -ne 10 ] ; then
    echo 'ERROR: Wrong number of parameters'
    echo ''
    echo 'Usage: '
    echo 'hdf2bin_parallel.sh tile_H tile_V xoff yoff xsize ysize path_modis path_tmp njobs'
    echo '  tile_H      Number. The MODIS tile in the H direction'
    echo '  tile_V      Number. The MODIS tile in the V direction'
    echo '  xoff        Number. First pixel to export'
    echo '  yoff        Number. First pixel to export'
    echo '  xsize       Number of pixels to export'
    echo '  ysize       Number of pixels to export'
    echo '  path_modis  Path to a repository of MODIS data (HDF files)'
    echo '  path_tmp    Path to a temporal directory'
    echo '  path_output Path to store the results'
    echo '  njobs Path  Maximum number of jubs to run in parallel'
    exit 1
fi

.log 6 "START--------------------" 
.log 6 "$@"

H=$1
V=$2
xoff=$3
yoff=$4
xsize=$5
ysize=$6
path_modis=$7
path_tmp=$8
path_output=$9
njobs=$10

.log 6 "Getting files to export..."
FILES=$(find -L "$path_modis" -type f | grep "MOD13Q1\.A[0-9]\{7\}\.h""$H""v""$V""\.006\.[0-9]\{13\}\.hdf$" | sort | head -n $FIRST)

.log 6 "Writting down the images's dates (julian)..." >> hdf2tif_parallel.log
FNAMES=($FILES)
for ((i=0;i<${#FNAMES[@]};++i)); do
    basename "${FNAMES[i]}" | awk -F "." '{ print $2 }' >> "$path_output"/MOD13Q1_h"$H"v"$V"_006_dates.txt
done

.log 6 "Writting down the images's dates..." >> hdf2tif_parallel.log
Rscript julday2date.R "$path_output"/MOD13Q1_h"$H"v"$V"_006_dates.txt

.log 6 "Processing NDVI..."
BAND=1
parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" "$BAND" "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
               FILES_NDVI=$(find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_NDVI.*\.tif$"             | sort | head -n $FIRST)
gdal_merge.py $FILES_NDVI -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_NDVI.tif
rm            $FILES_NDVI

.log 6 "Processing EVI..."
BAND=2
parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
               FILES_EVI=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_EVI.*\.tif$"              | sort | head -n $FIRST)
gdal_merge.py $FILES_EVI  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_EVI.tif
rm            $FILES_EVI

#.log 6 "Processing QUALITY..."
#BAND=3
#parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#                FILES_QA=$(  find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_VI_Quality.*\.tif$"       | sort | head -n $FIRST)
#gdal_merge.py $FILES_QA   -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_VI_Quality.tif
#rm            $FILES_QA

.log 6 "Processing RED..."
BAND=4
parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
               FILES_RED=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_red_reflectance.*\.tif$"  | sort | head -n $FIRST)
gdal_merge.py $FILES_RED  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_red_reflectance.tif
rm            $FILES_RED

.log 6 "Processing NIR..."
BAND=5
parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
                FILES_NIR=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_NIR_reflectance.*\.tif$"  | sort | head -n $FIRST)
gdal_merge.py $FILES_NIR  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_NIR_reflectance.tif
rm            $FILES_NIR

.log 6 "Processing BLUE..."
BAND=6
parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
                FILES_BLUE=$(find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_blue_reflectance.*\.tif$" | sort | head -n $FIRST)
gdal_merge.py $FILES_BLUE -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_blue_reflectance.tif
rm            $FILES_BLUE

.log 6 "Processing MIR..."
BAND=7
parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
               FILES_MIR=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_MIR_reflectance.*\.tif$"  | sort | head -n $FIRST)
gdal_merge.py $FILES_MIR  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_MIR_reflectance.tif
rm            $FILES_MIR

#.log 6 "Processing VIEW ZENITH ANGLE..."
#BAND=8
#parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#               FILES_VIEW=$(find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_view_zenith_angle.*\.tif$$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_VIEW -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_view_zenith_angle.tif
#rm            $FILES_VIEW

#.log 6 "Processing SUN ZENITH ANGLE..."
#BAND=9
#parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#               FILES_SUN=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_sun_zenith_angle.*\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_SUN  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_sun_zenith_angle.tif
#rm            $FILES_SUN

#.log 6 "Processing RELATIVE AZIMUTH ANGLE..."
#BAND=10
#parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#                FILES_REL=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_relative_azimuth_angle.*\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_REL  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_relative_azimuth_angle.tif
#rm            $FILES_REL

#.log 6 "Processing COMPOSITE DAY OF THE YEAR..."
#BAND=11
#parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#               FILES_DOY=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_composite_day_of_the_year.*\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_DOY  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_composite_day_of_the_year.tif
#rm            $FILES_DOY

#.log 6 "Processing PIXEL RELIABILITY..."
#BAND=12
#parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#               FILES_PRE=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_pixel_reliability.*\.tif$" | sort | head -n $FIRST)
#gdal_merge.py $FILES_PRE  -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_pixel_reliability.tif
#rm            $FILES_PRE

.log 6 "END"

exit 0
