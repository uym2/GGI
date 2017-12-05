#! /bin/bash

tree1=$1
tree2=$2
conselfile=$3
threshold=$4

pval=`grep "#    2" $conselfile | awk '{print $5;}'`


if [ $pval \> $threshold ]; then cat $tree2; else cat $tree1; fi
