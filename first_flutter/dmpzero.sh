#!/bin/sh

SPTKBIN="../../SPTK-3.7/bin"

# 0.05sec at 44100K
SAMPLE=2205

${SPTKBIN}/x2x/x2x +sf temp.raw | ${SPTKBIN}/zcross/zcross -l ${SAMPLE} | ${SPTKBIN}/dmp/dmp +f | awk '{print $1*0.05 " " $2}'
