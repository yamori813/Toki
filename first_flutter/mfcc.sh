#!/bin/sh

SPTKBIN="../../SPTK-3.7/bin"

./center.sh $1 | ${SPTKBIN}/mfcc/mfcc -l 1024 -s 44.1 -m 16 -n 20 -a 0.97 
