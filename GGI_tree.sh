#! /bin/bash

seq=$1
ML_tree=$2
ML_sitelh=$3
cons_tree=$4

tempdir=`mktemp -d`
name=cons

runRAxML_constraint.sh $seq $cons_tree $name $tempdir > $tempdir/RAxML_constraint.log 2>&1
runRAxML_sitelh.sh $seq $tempdir/RAxML_bestTree.$name $name $tempdir > $tempdir/RAxML_sitelh.log 2>&1
combine_llh_files.py $ML_sitelh $tempdir/RAxML_perSiteLLs.$name\.sitelh $tempdir/$name\.sitelh
runCONSEL.sh $tempdir/$name > $tempdir/consel.log 2>&1
pval=`grep "#    2" $tempdir/$name\.consel | awk '{print $5;}'`

echo $pval  $tempdir/RAxML_bestTree.$name
