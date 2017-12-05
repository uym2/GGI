#! /bin/bash

gtrees=$1
name=$2

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

java -Xmx200m -jar $DIR/Astral/astral.5.5.5.jar -i $gtrees -o `dirname $gtrees`/$name.tre > `dirname $gtrees`/$name.log 2>&1
