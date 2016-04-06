#!/bin/sh

SPTKBIN="../../SPTK-3.7/bin"
SAMPLE=2205

sox $1 temp.raw

NUM=`${SPTKBIN}/x2x/x2x +sf temp.raw | ${SPTKBIN}/zcross/zcross -l ${SAMPLE} | ${SPTKBIN}/dmp/dmp +f | awk 'BEGIN{max=0;time=0}NR==1{y1=$2};NR==2{y2=$2};NR==3{y3=$2};NR>3{y4=$2;av=(y1 + y2 + y3 + y4) / 4 + $1 / 20;if(av > max){max = av;time = $1}y1=y2;y2=y3;y3=y4}END{print time}'`

TIME=`echo "scale=2; ${NUM} * ${SAMPLE} / 44100" | bc`

echo ${TIME} s
