#!/usr/bin/bash

ctags -f - -R --languages=lua --langmap=lua:.lua * | sed 's/ \t/\t/g' > tags
