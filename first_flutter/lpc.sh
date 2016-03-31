#!/bin/sh

SPTKBIN="../../SPTK-3.7/bin"

./center.sh $1 | ${SPTKBIN}/lpc/lpc -l 1024 -m 20
