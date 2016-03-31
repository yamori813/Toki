#!/bin/sh

SPTKBIN="../../SPTK-3.7/bin"
SAMPLE=2205

if [ $# -ne 2 ]; then
  echo "findtw.sh in_dir out_dir"
  exit
fi

FILES=`ls -1 $1/*`
COUNT=0

for f in ${FILES}; do

  sox ${f} temp.raw

  NUM=`${SPTKBIN}/x2x/x2x +sf temp.raw | ${SPTKBIN}/zcross/zcross -l ${SAMPLE} | ${SPTKBIN}/dmp/dmp +f | sort -r -n +1 | head -1 | awk '{print $1}'`

  TIME=`echo "scale=2; ${NUM} * ${SAMPLE} / 44100" | bc`


  LEN=0.4
  START=`echo "scale=2; ${TIME} - ${LEN} / 2" | bc`

  sox ${f} $2/T${COUNT}.aiff trim ${START} ${LEN}

  echo "${f} ${TIME} s => $2/T${COUNT}.aiff"

  COUNT=`expr ${COUNT} + 1` 
done
