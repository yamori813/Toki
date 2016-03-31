#!/bin/sh

SPTKBIN="../../SPTK-3.7/bin"
SAMPLE=2205

sox $1 temp.raw

NUM=`${SPTKBIN}/x2x/x2x +sf temp.raw | ${SPTKBIN}/zcross/zcross -l ${SAMPLE} | ${SPTKBIN}/dmp/dmp +f | sort -r -n +1 | head -1 | awk '{print $1}'`

TIME=`echo "scale=2; ${NUM} * ${SAMPLE} / 44100" | bc`

echo ${TIME} s

