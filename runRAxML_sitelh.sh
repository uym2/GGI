#!/bin/bash

seqfile=$1
trees=$2
name=$3 # output
outdir=$4 # optional

[ -z $outdir ] && outdir=`dirname $seqfile`

raxmlHPC -f g -s $seqfile -m GTRGAMMA -z $trees -n $name\.sitelh -w $outdir
