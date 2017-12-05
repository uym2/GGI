#! /bin/bash

in_trees=$1
out_trees=$2
bs_thres=$3 # bootstrap threshold

nw_ed $in_trees "i & b < $bs_thres" o > $out_trees
