#!/bin/sh

SPTKBIN="../../SPTK-3.7/bin"
SAMPLE=2205

${SPTKBIN}/x2x/x2x +sf temp.raw | ${SPTKBIN}/zcross/zcross -l ${SAMPLE} | ${SPTKBIN}/dmp/dmp +f 
