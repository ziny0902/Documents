#!/usr/bin/bash
filter=${1}
LEN=$#
if [[ $LEN -eq 0 ]]
then
  filter="."
fi
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. $SCRIPT_DIR/env.sh
i=1
while IFS=$'\t' read -r -d $'\0' refId title; do
  refIds[$i]=$(echo ${refId} | xargs echo -n)
  titles[$i]=$(echo ${title} | xargs echo -n)
  i=$(("$i"+1))
done < <(cat -- "$bibfile" | sed -En -f $SCRIPT_DIR/../lib/file.sed | grep --color=auto -i ${filter} | awk -F '\t' '{ print $1, "\t" , $2 , "\0"}' )
open_refId=$(  printf '%s\n' "${titles[@]}"  | fzf )
LEN=${#open_refId}
if [[ $LEN -eq 0 ]] # if refId was not selected
then
  exit 0
fi
for i in $(seq 1 ${#refIds[@]})
do
  if [[ ${titles[$i]} == $open_refId ]]
  then
    open_refId=${refIds[$i]}
    break
  fi 
done
bash $SCRIPT_DIR/bibsearch.sh $open_refId
