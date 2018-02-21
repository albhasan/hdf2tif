#!/usr/bin/Rscript

args <- commandArgs(TRUE)
#fpath <- "/home/alber/Documents/tmp/MOD13Q1_h13v11_006_dates.txt"
fpath <- args[[1]]
nd_txt <- as.Date(substr(readLines(fpath), 2, 8), "%Y%j")
writeLines(as.character(nd_txt), fpath)
