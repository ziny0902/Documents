cat ~/Documents/citations.bib| sed -n -f ~/Documents/lib/isbn.sed | sh ~/Documents/lib/gen_bib_tag.sh > tag.tmp
sort tag.tmp > bib_tags
\rm tag.tmp
