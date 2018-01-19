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
-t|--temp)
tempdir="$2"
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
if [ -z $beta ]; then beta=90; else beta=`echo $beta | sed "s/,/ /g"`; fi; echo beta: $beta
[ -z $gamma ] && gamma=50; echo "gamma: " $gamma
if [ -z $tempdir ]; then tempdir=`mktemp -d`; else mkdir $tempdir; fi; echo "tempdir: " $tempdir

if [ ! -s $wdir/astral.qtscore$gamma ]; then
    echo "Estimating ASTRAL species tree ..."
    cat $wdir/*.ML.tre > $tempdir/MLTrees
    cd $tempdir
    runAstral.sh MLTrees astral

    echo "Collapsing gene trees ..."
    collapse_low_support.sh MLTrees MLTrees.collapsed$gamma $gamma

    echo "Scoring the ASTRAL tree ..."
    scoreAstral.sh MLTrees.collapsed$gamma astral.tre astral.qtscore$gamma
    if [ $full -eq 1 ]; then
        cp MLTrees $wdir
        cp MLTrees.collapsed $wdir
        cp astral* $wdir
    fi
else
    cp $wdir/astral.qtscore$gamma .
fi


echo "Running RAxML: generating constrained gene trees"
for x in $wdir/*fasta; do
    name=`basename $x .fasta`
    if [ ! -s $wdir/$name\.ML.sitelh ]; then
        runRAxML_sitelh.sh $x $wdir/$name\.ML.tre $name\.ML $tempdir
        [ $full -eq 1 ] && cp RAxML_perSiteLLs.$name\.ML.sitelh $wdir/$name\.ML.sitelh
    else
        cp $wdir/$name\.ML.sitelh RAxML_perSiteLLs.$name\.ML.sitelh
    fi
done

for b in $beta; do
    collapse_low_support.sh astral.qtscore$gamma\.tre astral$gamma\.cons$b\.tre $b
    for x in $wdir/*fasta; do 
        name=`basename $x .fasta`_cons$b
        runRAxML_constraint.sh $x astral$gamma\.cons$b\.tre $name $tempdir
        [ $full -eq 1 ] && cp RAxML_bestTree.$name $wdir/$name\.tre 
        runRAxML_sitelh.sh $x RAxML_bestTree.$name $name $tempdir
        combine_llh_files.py RAxML_perSiteLLs.`basename $x .fasta`\.ML.sitelh RAxML_perSiteLLs.$name\.sitelh $name\.sitelh
        [ $full -eq 1 ] && cp $name\.sitelh $wdir
        runCONSEL.sh $name
        pval=`grep "#    2" $name\.consel | awk '{print $5;}'`
        if (( $(echo "$pval > $alpha" |bc -l) )); then
            cp RAxML_bestTree.$name $wdir/$name\.GGI.tre
        else
            cp $wdir/`basename $x .fasta`.ML.tre $wdir/$name\.GGI.tre
        fi
    done
done

