#!/bin/sh

SPTKBIN="../../SPTK-3.7/bin"

./center.sh $1 | ${SPTKBIN}/fftr/fftr -l 1024 -A | ${SPTKBIN}/dmp/dmp +f | head -512
