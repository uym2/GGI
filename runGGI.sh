#! /bin/bash

while [[ $# -gt 1 ]]; do
    key="$1"

case $key in
-i|--input)
MLTrees="$2"
shift # past argument
;;
-b|--beta)
beta="$2"
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


if [ -z $MLTrees ]; then echo "MLTrees are required"; else echo "MLTrees: " $MLTrees; fi
if [ -z $alpha ]; then echo "alpha is set to default value"; alpha=0.05; fi; echo "alpha: " $alpha;
if [ -z $beta ]; then echo "beta is set to default beta = 0.90"; beta=0.90; else echo "beta: `echo $beta | sed "s/,/ /g"`"; fi
if [ -z $gamma ]; then echo "gamma is set to default value"; gamma=0.50; fi; echo "alpha: " $alpha;
if [ -z $outdir ]; then outdir=`dirname $MLTrees`/`basename $MLTrees .trees`.GGI_Output; fi; echo "outdir: " $outdir;

echo "Create output directory"
mkdir $outdir

echo "Estimating ASTRAL species tree ..."
cp $MLTrees $outdir/MLTrees
cd $outdir
runAstral.sh `pwd`/MLTrees astral

echo "Collapsing gene trees ..."
collapse_low_support.sh MLTrees MLTrees.collapsed $gamma

echo "Scoring the ASTRAL tree ..."
scoreAstral.sh MLTrees.collapsed astral.tre astral.qtscore


































