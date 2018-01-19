#! /bin/bash

while [[ $# -gt 1 ]]; do
    key="$1"

case $key in
-d|--wdir)
wdir="$2"
shift # past argument
;;
-b|--beta)
beta="$2"
shift # past argument
;;
-a|--alpha)
alpha="$2"
shift # past argument
;;
-g|--gamma)
gamma="$2"
shift # past argument
;;
-f|--full)
full=1
;;
-j|--createjobs)
jobfile="$2"
shift # past argument
;;
-r|--runAstral)
spTree="astral"
;;
--default)
DEFAULT=YES
;;
*)
# unknown option
;;
esac
shift # past argument or value
done


if [ -z $wdir ]; then echo "working directory is required"; else echo "Working directory: " $wdir; fi
[ -z $alpha ] && alpha=0.05; echo "alpha: " $alpha
if [ -z $beta ]; then beta=90; fi
echo beta: $beta
[ -z $gamma ] && gamma=10; echo "gamma: " $gamma
[ -z $spTree ] && spTree="sp"; echo "species tree: " $spTree\.tre


cd $wdir

if [ ! -s $spTree\.qtscore$gamma.tre ]; then
    cat */ML.tre > MLTrees
    echo "Collapsing gene trees ..."
    collapse_low_support.sh MLTrees MLTrees.collapsed$gamma $gamma
    
    if [ $spTree == "astral" ]; then
        echo "Estimating ASTRAL species tree ..."
        runAstral.sh MLTrees astral
        echo "Scoring the ASTRAL tree ..."
        scoreAstral.sh MLTrees.collapsed$gamma astral.tre astral\.qtscore$gamma
    fi

fi    


echo "Running RAxML: generating constrained gene trees"
for x in $wdir/*/aln.fasta; do
    d=`dirname $x`
    if [ ! -s $d/RAxML_perSiteLLs.ML.sitelh ]; then
        runRAxML_sitelh.sh $x $d/ML.tre ML $d
    fi
done


for b in $beta; do
    name=cons$b
    if [ $spTree == "astral" ]; then
        scoredTree=astral\.qtscore$gamma
    else
        scoredTree=$spTree
    fi
    collapse_low_support.sh $scoredTree\.tre "$scoredTree"\.$name\.tre $b
    for x in $wdir/*/aln.fasta; do 
        d=`dirname $x`
        job="constrain.sh $x $wdir/"$scoredTree".$name\.tre $d/ML.tre $d/RAxML_perSiteLLs.ML.sitelh "$spTree""$name" $alpha"
        if [ -z $jobfile ]; then
            #constrain.sh $x $wdir/astral$gamma\.$name\.tre $d/ML.tre $d/RAxML_perSiteLLs.ML.sitelh $name
            eval $job
        else
            echo $job >> $jobfile
        fi
        #runRAxML_constraint.sh $x astral$gamma\.$name\.tre $name $d
        #runRAxML_sitelh.sh $x $d/RAxML_bestTree.$name $name $d
        #combine_llh_files.py $d/RAxML_perSiteLLs.ML.sitelh $d/RAxML_perSiteLLs.$name\.sitelh $d/$name\.sitelh
        #cd $d
        #runCONSEL.sh $name
        #pval=`grep "#    2" $name\.consel | awk '{print $5;}'`
        #if (( $(echo "$pval > $alpha" |bc -l) )); then
        #    cp RAxML_bestTree.$name $name\.GGI.tre
        #else
        #    cp ML.tre $name\.GGI.tre
        #fi
        #cd ../
    done
done

