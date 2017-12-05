#! /bin/bash

gtrees=$1
stree=$2
name=$3

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

java -Xmx200m -jar $DIR/Astral/astral.5.5.5.jar -i $gtrees -q $stree -t 1 -o `dirname $gtrees`/$name.tre > `dirname $gtrees`/$name.log 2>&1

