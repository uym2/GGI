#!/bin/bash

seqfile=$1
trees=$2
name=$3 # output

raxmlHPC -f g -s $seqfile -m GTRGAMMA -z $trees -n $name\.sitelh -w `dirname $seqfile`
