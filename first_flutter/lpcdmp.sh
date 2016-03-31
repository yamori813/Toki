#!/bin/sh

SPTKBIN="../../SPTK-3.7/bin"

./lpc.sh $1 | ${SPTKBIN}/dmp/dmp +f 
