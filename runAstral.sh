#! /bin/bash

gtrees=$1
name=$2

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

java -Xmx500m -jar $DIR/Astral/astral.5.5.5.jar -i $gtrees -o $name.tre > $name.log 2>&1
