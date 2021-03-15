#!/usr/bin/bash
jq ".block.Child | .[] 
| if .Local then . else empty end 
| .Local.Child
| if .[1].\"Function body\" then .[0].Name.Value else empty end
" ast.json

jq ".block.Child | .[] 
| if .Assignment then . else empty end 
| .Assignment.Child
| (.[1].Explist.Child[].Exp.Child | map(has(\"Function body\"))) as \$x 
| if \$x[] then if .[0].Varlist then .[0].Varlist.Chid else [.[0]]  end 
  else empty end
| [ .[].Var.Child[] | keys as [\$k] | .[].Value ]
| join(\"\")

" ast.json

