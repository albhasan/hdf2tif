#!/bin/bash
################################################################################
# CREATE THE MOD13Q1 TILES OF BRAZILIAN CERRADO
#-------------------------------------------------------------------------------
# Last update 2018-06-26
################################################################################
./hdf2tif_parallel.sh 12 10 0 0 4800 4800 0 407 /home/scidb/MODIS/MOD13Q1 /home/scidb/tmp /disks/d7/hdf2tif_01_new 16 0 
./hdf2tif_parallel.sh 12 11 0 0 4800 4800 0 407 /home/scidb/MODIS/MOD13Q1 /home/scidb/tmp /disks/d7/hdf2tif_01_new 16 0
./hdf2tif_parallel.sh 13 09 0 0 4800 4800 0 407 /home/scidb/MODIS/MOD13Q1 /home/scidb/tmp /disks/d7/hdf2tif_01_new 16 0
./hdf2tif_parallel.sh 13 10 0 0 4800 4800 0 407 /home/scidb/MODIS/MOD13Q1 /home/scidb/tmp /disks/d7/hdf2tif_01_new 16 0
./hdf2tif_parallel.sh 13 11 0 0 4800 4800 0 407 /home/scidb/MODIS/MOD13Q1 /home/scidb/tmp /disks/d7/hdf2tif_01_new 16 0

