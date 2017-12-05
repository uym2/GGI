#! /bin/bash

input=$1 # per-site log likelihood for each tree (typically an output of RAxML using -f g)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$DIR/CONSEL/seqmt --puzzle $input\.sitelh
$DIR/CONSEL/makermt --puzzle  $input\.sitelh
$DIR/CONSEL/consel $input
$DIR/CONSEL/catpv `echo $input | sed "s/\..*//g"`\.pv  > $input\.consel
