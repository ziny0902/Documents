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
while IFS=$'\t' read -r -d $'\0' file title; do
  files[$i]=$file
  titles[$i]=$title
  i=$(("$i"+1))
done < <(cat -- "$bibfile" | sed -n -f $SCRIPT_DIR/../lib/file.sed | grep --color=auto -i ${filter} | awk -F '\t' '{ print $3, "\t" , $2 , "\0"}' )
open_file=$(  printf '%s\n' "${titles[@]}"  | fzf )
LEN=${#open_file}
if [[ $LEN -eq 0 ]] # if file was not selected
then
  exit 0
fi
for i in $(seq 1 ${#files[@]})
do
  if [[ ${titles[$i]} == $open_file ]]
  then
    open_file=$(echo ${files[$i]} | xargs echo -n) 
    break
  fi 
done
TYPE=$( echo $open_file | sed 's/.*\.\(.*\)$/\1/')
if [[ "$TYPE" == "pdf" ]]
then
  nohup $PDF_OPEN "$open_file" 2> /dev/null 1>&2 &
fi
if [[ "$TYPE" == "epub" ]]
then
  nohup ${EPUB_OPEN[@]} "$open_file" 2> /dev/null 1>&2 &
fi
