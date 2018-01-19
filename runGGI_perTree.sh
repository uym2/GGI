#! /bin/bash

while [[ $# -gt 1 ]]; do
    key="$1"

case $key in
-d|--wdir)
wdir="$2"
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
[ -z $gamma ] && gamma=50; echo "gamma: " $gamma

cd $wdir

if [ ! -s astral.qtscore$gamma ]; then
    echo "Estimating ASTRAL species tree ..."
    cat *.ML.tre > MLTrees
    runAstral.sh MLTrees astral

    echo "Collapsing gene trees ..."
    collapse_low_support.sh MLTrees MLTrees.collapsed$gamma $gamma

    echo "Scoring the ASTRAL tree ..."
    scoreAstral.sh MLTrees.collapsed$gamma astral.tre astral.qtscore$gamma
fi

echo "Computing per-site log-likelihood for ML trees"

for x in *fasta; do
    id=`basename $x .fasta`
    if [ ! -s RAxML_perSiteLLs.$id\.ML.sitelh ]; then
        runRAxML_sitelh.sh $x $id\.ML.tre $id\.ML `pwd` 
    fi
done

echo "Binary searching for GGI trees"
for x in *.fasta; do
    ID=`basename $x .fasta`
    if [ ! -s $ID\.GGI.RF ]; then
        echo $ID 
        GGITree=`GGI_binary_search.py $x $ID\.ML.tre RAxML_perSiteLLs.$ID\.ML.sitelh astral.qtscore$gamma\.tre`
        cp $GGITree $ID\.GGI.tre
        compareTrees.missingBranch $ID\.true.tre $ID\.ML.tre > $ID\.ML.RF
        compareTrees.missingBranch $ID\.true.tre $ID\.GGI.tre > $ID\.GGI.RF
    fi    
done
