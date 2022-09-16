#!/usr/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. $SCRIPT_DIR/env.sh 
printf "1\n/@[a-zA-Z]*{.*${1}/;/^\}/p\n" | ed -s $bibfile
