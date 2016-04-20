#!/bin/sh

SPTKBIN="../../SPTK-3.7/bin"

${SPTKBIN}/x2x/x2x +sf temp.raw | ${SPTKBIN}/pitch/pitch -a 1 -t 0.2 -s 44.1 -p 80 -L 1000 -H 10000 -o 1 | ${SPTKBIN}/dmp/dmp +f | awk '{print $1 * 80.0 / 44100 " " $2}'
