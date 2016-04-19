#!/bin/sh

SPTKBIN="../../SPTK-3.7/bin"

#./center.sh $1 | ${SPTKBIN}/fftr/fftr -l 1024 -A | ${SPTKBIN}/dmp/dmp +f | head -512
${SPTKBIN}/x2x/x2x +sf temp.raw | ${SPTKBIN}/pitch/pitch -a 1 -s 44.1 -p 80 -L 1000 -H 10000 | ${SPTKBIN}/dmp/dmp +f | awk '{print $1 * 80.0 / 44100 " " $2}'
