#!/usr/bin/bash
cat ~/Documents/citations.bib| sed -n -f ~/Documents/lib/block_txt.sed | grep --color=auto -i "${1}"
