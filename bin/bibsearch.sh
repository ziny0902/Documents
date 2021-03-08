#!/usr/bin/bash

printf "1\n/@book{.*${1}/;/^\}/p\n" | ed -s ~/Documents/citations.bib
