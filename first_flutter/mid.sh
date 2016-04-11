#!/bin/sh

SPTKBIN="../../SPTK-3.7/bin"
FRAMES=$1

sox $2 temp.raw

LEN=`ls -l temp.raw | awk '{print $5}'`

SPOS=`expr ${LEN} / 2 / 512 / 2 - 2`
EPOS=`expr ${SPOS} + ${FRAMES} - 1`

${SPTKBIN}/x2x/x2x +sf temp.raw | ${SPTKBIN}/frame/frame -p 512 -l 1024 | ${SPTKBIN}/bcut/bcut +f -l 1024 -s ${SPOS} -e ${EPOS} | ${SPTKBIN}/window/window -l 1024 
