#!/usr/bin/Rscript

# Read dates YEAR-DOY from the command line, convert them to YYYY-MM-DD, and save them to a text file.

args <- commandArgs(TRUE)
fpath <- args[[1]]
nd_txt <- as.Date(substr(readLines(fpath), 2, 8), "%Y%j")
writeLines(as.character(nd_txt), fpath)

