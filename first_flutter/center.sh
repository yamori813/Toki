#!/bin/sh

SPTKBIN="../../SPTK-3.7/bin"

sox $1 temp.raw

LEN=`ls -l temp.raw | awk '{print $5}'`

POS=`expr ${LEN} / 2 / 1024 / 2`

${SPTKBIN}/x2x/x2x +sf temp.raw | ${SPTKBIN}/frame/frame -p 1024 -l 1024 | ${SPTKBIN}/bcut/bcut +f -l 1024 -s ${POS} -e ${POS} | ${SPTKBIN}/window/window -l 1024 
