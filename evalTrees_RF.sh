# !/bin/bash

# compute averaged triplet distance

truetrees=$1
estimatedtrees=$2

ttre=`mktemp`
etre=`mktemp`

while read tt && read -u 3 et; do 
	echo $tt > $ttre
	echo $et > $etre
	compareTrees.missingBranch $ttre $etre
done < $truetrees 3< $estimatedtrees

rm $ttre $etre
