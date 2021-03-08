OLD_IFS=$IFS
IFS=$'\t'
while read ISBN BIBICODE
do
  IFS=$' '
  for el in $ISBN; do
    printf "$el\tcitations.bib\t/${BIBICODE}/\n"
  done
  IFS=$'\t'
done
IFS=$OLD_IFS
