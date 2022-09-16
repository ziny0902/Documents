#!/usr/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. $SCRIPT_DIR/env.sh
i=1
while IFS=$'\t' read -r -d $'\n' path file; do
  files[$i]=$(echo ${file} | sed -E 's/^[ \t]*(.*)[ \t]*$/\1/')
  paths[$i]=$(echo ${path} | sed -E 's/^[ \t]*(.*)[ \t]*$/\1/')
  i=$(("$i"+1))
done < <(find $epub_home -name "*.epub" | sed -E 's/(.*\/)([^/]+\.epub)/\1\t\2/')
open_file=$(  printf '%s\n' "${files[@]}"  | fzf )
LEN=${#open_file}
if [[ $LEN -eq 0 ]] # if file was not selected
then
  exit 0
fi
for i in $(seq 1 ${#files[@]})
do
  if [[ ${files[$i]} == $open_file ]]
  then
    open_file="${paths[$i]}""${files[$i]}"
    break
  fi 
done
#echo $open_file
nohup ${EPUB_OPEN[@]} "$open_file" 2> /dev/null 1>&2 &
