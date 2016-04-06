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

  TIME=`./chkzero.sh ${f} | awk '{print $1}'`

  LEN=0.4
  START=`echo "scale=2; ${TIME} - ${LEN} / 2" | bc`

  sox ${f} $2/T${COUNT}.aiff trim ${START} ${LEN}

  echo "${f} ${TIME} s => $2/T${COUNT}.aiff"

  COUNT=`expr ${COUNT} + 1` 
done
