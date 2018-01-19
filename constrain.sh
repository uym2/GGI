#! /bin/bash

aln=$1
consTree=$2
MLTree=$3
MLllh=$4
name=$5
alpha=$6

d=`dirname $MLTree`

runRAxML_constraint.sh $aln $consTree $name $d
runRAxML_sitelh.sh $aln $d/RAxML_bestTree.$name $name $d
combine_llh_files.py $MLllh $d/RAxML_perSiteLLs.$name\.sitelh $d/$name\.sitelh


cd $d
runCONSEL.sh $name
pval=`grep "#    2" $name\.consel | awk '{print $5;}'`
if (( $(echo "$pval > $alpha" |bc -l) )); then
cp RAxML_bestTree.$name $name\.GGI.tre
else
cp $MLTree $name\.GGI.tre
fi

