#!/bin/bash

seqfile=$1
constree=$2
name=$3 # output
outdir=$4 # optional

[ -z $outdir ] && outdir=`dirname $seqfile`

#raxmlHPC -s $seqfile -m GTRGAMMA -g $constree -n $name -p 123456 -w `dirname $seqfile` -N 10
raxmlHPC -s $seqfile -m GTRGAMMA -g $constree -n $name -p 654321 -w $outdir -N 10


