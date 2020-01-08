#!/bin/bash

set -ue

FILE_1=${1:-}
FILE_2=${2:-}

yq \
	--yaml-output \
	--yaml-roundtrip \
	--slurp \
	'.[0] * .[1]' $FILE_1 $FILE_2 > $FILE_1.tmp
cat $FILE_1.tmp > $FILE_1
rm $FILE_1.tmp
