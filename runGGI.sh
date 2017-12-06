#! /bin/bash

while [[ $# -gt 1 ]]; do
    key="$1"

case $key in
-i|--indir)
indir="$2"
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
-d|--outdir)
outdir="$2"
shift # past argument
;;
-a|--alpha)
alpha="$2"
shift # past argument
;;
-g|--gamma)
gamma="$3"
shift # past argument
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


if [ -z $indir ]; then echo "input directory is required"; else echo "Input directory: " $indir; fi
if [ -z $alpha ]; then echo "alpha is set to default value"; alpha=0.05; fi; echo "alpha: " $alpha
if [ -z $beta ]; then echo "beta is set to default beta = 0.90"; beta=0.90; else echo "beta: `echo $beta | sed "s/,/ /g"`"; fi
if [ -z $gamma ]; then echo "gamma is set to default value"; gamma=0.50; fi; echo "gamma: " $gamma
if [ -z $outdir ]; then outdir=`dirname $indir`/`basename $indir`_GGI_Output; fi; echo "outdir: " $outdir
if [ -z $tempdir ]; then tempdir=`mktemp -d`; else mkdir $tempdir; fi; echo "tempdir: " $tempdir

echo "Create output directory"
mkdir $outdir

echo "Estimating ASTRAL species tree ..."
cat $indir/*.tre > $outdir/MLTrees
cd $outdir
runAstral.sh `pwd`/MLTrees astral

echo "Collapsing gene trees ..."
collapse_low_support.sh MLTrees MLTrees.collapsed $gamma

echo "Scoring the ASTRAL tree ..."
scoreAstral.sh MLTrees.collapsed astral.tre astral.qtscore

echo "Running RAxML: generating constrained gene trees"
for b in $beta; do
    collapse_low_support.sh astral.qtscore.tre astral.cons$b\.tre  $b
    for x in $indir/*fasta; do 
        name=`basename $x .fasta`.cons$b
        runRAxML_constraint.sh $x astral.cons$b\.tre $name $tempdir
        cp $tempdir/RAxML_bestTree.$name $outdir/$name\.tre 
    done
done






































