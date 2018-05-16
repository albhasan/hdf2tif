#!/bin/bash
################################################################################
# Export HDF files to TIF in parallel
#-------------------------------------------------------------------------------
# TODO:
# ERROR 1: TIFFAppendToStrip:Maximum TIFF file size exceeded. Use BIGTIFF=YES creation option.
#-------------------------------------------------------------------------------
# ./hdf2tif_parallel.sh 12 10 0 0 40 40 312 23 /home/scidb/MOD13Q1 /home/scidb/tmp /home/scidb 16 0
#-------------------------------------------------------------------------------
#H=10
#V=10
#xoff=0
#yoff=0
#xsize=4799
#ysize=4799
#first=69
#nimgs=23
#path_modis='/home/scidb/MODIS'
#path_tmp='/home/scidb/Documents/tmp'
#path_output='/home/scidb/Documents/tmp'
#njobs=2
#dry_run=3
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

if [ $# -ne 13 ] ; then
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
    echo '  first       Index of the first image'
    echo '  nimgs       Number of image to take starting at first'
    echo '  path_modis  Path to a repository of MODIS data (HDF files)'
    echo '  path_tmp    Path to a temporal directory'
    echo '  path_output Path to store the results'
    echo '  njobs       Maximum number of jobs to run in parallel'
    echo '  dry_run     Any value different from 0 causes the script to print the list of files process and exit'
    exit 1
fi

.log 6 "START--------------------" 
.log 6 "$@"

H="${1}"
V="${2}"
xoff="${3}"
yoff="${4}"
xsize="${5}"
ysize="${6}"
first="${7}"
nimgs="${8}"
path_modis="${9}"
path_tmp="${10}"
path_output="${11}"
njobs="${12}"
dry_run="${13}"

.log 6 "Getting files to export..."
#sort_start=41
#sort_end=47
#FILES=$(find -L "$path_modis" -type f | grep "M[O|Y]D13Q1\.A[0-9]\{7\}\.h""$H""v""$V""\.006\.[0-9]\{13\}\.hdf$" | sort  -k 1.41,1.47 | head -n $(( $first + $nimgs )) | tail -n $nimgs)
FILES=$(find -L "$path_modis" -type f | grep "MOD13Q1\.A[0-9]\{7\}\.h""$H""v""$V""\.006\.[0-9]\{13\}\.hdf$" | sort | head -n $(( $first + $nimgs )) | tail -n $nimgs)  
FNAMES=($FILES)

# Print the files and exit
if [ "$dry_run" -ne "0" ] ; then
    for ((i=0;i<${#FNAMES[@]};++i)); do
        echo "${FNAMES[i]}"
    done
    exit 0
fi

.log 6 "Writting down the images's dates (julian)..." >> hdf2tif_parallel.log
for ((i=0;i<${#FNAMES[@]};++i)); do
    basename "${FNAMES[i]}" | awk -F "." '{ print $2 }' >> "$path_output"/MOD13Q1_h"$H"v"$V"_006_dates.txt
done

.log 6 "Writting down the images's dates..." >> hdf2tif_parallel.log
Rscript julday2date.R "$path_output"/MOD13Q1_h"$H"v"$V"_006_dates.txt

.log 6 "Processing NDVI..."
BAND=1
parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" "$BAND" "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
               FILES_NDVI=$(find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_NDVI.*\.tif$"             | sort )
gdal_merge.py $FILES_NDVI -co "COMPRESS=LZW" -co "PREDICTOR=2" -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_NDVI.tif
rm            $FILES_NDVI

.log 6 "Processing EVI..."
BAND=2
parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
               FILES_EVI=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_EVI.*\.tif$"              | sort )
gdal_merge.py $FILES_EVI -co "COMPRESS=LZW" -co "PREDICTOR=2" -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_EVI.tif
rm            $FILES_EVI

#.log 6 "Processing QUALITY..."
#BAND=3
#parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#                FILES_QA=$(  find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_VI_Quality.*\.tif$"       | sort )
#gdal_merge.py $FILES_QA   -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_VI_Quality.tif
#rm            $FILES_QA

.log 6 "Processing RED..."
BAND=4
parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
               FILES_RED=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_red_reflectance.*\.tif$"  | sort )
gdal_merge.py $FILES_RED -co "COMPRESS=LZW" -co "PREDICTOR=2" -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_red_reflectance.tif
rm            $FILES_RED

.log 6 "Processing NIR..."
BAND=5
parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
                FILES_NIR=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_NIR_reflectance.*\.tif$"  | sort )
gdal_merge.py $FILES_NIR -co "COMPRESS=LZW" -co "PREDICTOR=2" -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_NIR_reflectance.tif
rm            $FILES_NIR

.log 6 "Processing BLUE..."
BAND=6
parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
                FILES_BLUE=$(find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_blue_reflectance.*\.tif$" | sort )
gdal_merge.py $FILES_BLUE -co "COMPRESS=LZW" -co "PREDICTOR=2" -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_blue_reflectance.tif
rm            $FILES_BLUE

.log 6 "Processing MIR..."
BAND=7
parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
               FILES_MIR=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_MIR_reflectance.*\.tif$"  | sort )
gdal_merge.py $FILES_MIR -co "COMPRESS=LZW" -co "PREDICTOR=2" -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_MIR_reflectance.tif
rm            $FILES_MIR

#.log 6 "Processing VIEW ZENITH ANGLE..."
#BAND=8
#parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#               FILES_VIEW=$(find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_view_zenith_angle.*\.tif$$" | sort )
#gdal_merge.py $FILES_VIEW -co "COMPRESS=LZW" -co "PREDICTOR=2" -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_view_zenith_angle.tif
#rm            $FILES_VIEW

#.log 6 "Processing SUN ZENITH ANGLE..."
#BAND=9
#parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#               FILES_SUN=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_sun_zenith_angle.*\.tif$" | sort )
#gdal_merge.py $FILES_SUN -co "COMPRESS=LZW" -co "PREDICTOR=2" -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_sun_zenith_angle.tif
#rm            $FILES_SUN

#.log 6 "Processing RELATIVE AZIMUTH ANGLE..."
#BAND=10
#parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#                FILES_REL=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_relative_azimuth_angle.*\.tif$" | sort )
#gdal_merge.py $FILES_REL -co "COMPRESS=LZW" -co "PREDICTOR=2" -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_relative_azimuth_angle.tif
#rm            $FILES_REL

#.log 6 "Processing COMPOSITE DAY OF THE YEAR..."
#BAND=11
#parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#               FILES_DOY=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_composite_day_of_the_year.*\.tif$" | sort )
#gdal_merge.py $FILES_DOY -co "COMPRESS=LZW" -co "PREDICTOR=2" -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_composite_day_of_the_year.tif
#rm            $FILES_DOY

#.log 6 "Processing PIXEL RELIABILITY..."
#BAND=12
#parallel --jobs "$njobs" ./hdf2tif.sh {1} "$path_tmp" $BAND "$xoff" "$yoff" "$xsize" "$ysize" ::: "$FILES" > /dev/null
#               FILES_PRE=$( find -L "$path_tmp" -type f | grep "MOD13Q1_h""$H""v""$V""_006_A[0-9]\{7\}_250m_16_days_pixel_reliability.*\.tif$" | sort )
#gdal_merge.py $FILES_PRE -co "COMPRESS=LZW" -co "PREDICTOR=2" -separate -o "$path_output"/MOD13Q1_h"$H"v"$V"_006_250m_16_days_pixel_reliability.tif
#rm            $FILES_PRE

.log 6 "END"

exit 0
