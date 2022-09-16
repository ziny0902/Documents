#!/usr/bin/bash
filter=${1}
LEN=$#
if [[ $LEN -eq 0 ]]
then
  filter="."
fi
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. $SCRIPT_DIR/env.sh
while IFS=$'\t' read -r -d $'\0' refId file; do
  refId=$(echo ${refId} | xargs echo -n)
  file=$(echo ${file} | xargs echo -n)
  pdf_file=$(printf "$refId.pdf")
  pdf_file=$bibpdf_home$pdf_file
  [ ! -f $pdf_file ] && { echo "$pdf_file doesn't exist  path: $file"; cp "$file" "$pdf_file"; }
done < <(cat -- "$bibfile" | sed -En -f $SCRIPT_DIR/../lib/file.sed | grep --color=auto -i ${filter} | awk -F '\t' '{ print $1, "\t",  $3, "\0" }' )
