/@article\{/{
s/@article\{/refid = /
s/,*$/\t/
H
d
}
/@book\{/{
s/@book\{/refid = /
s/,*$/\t/
H
d
}
/^[[:blank:]]*title = /{
s/^[[:blank:]]*//
s/[{}]//g
s/,*$/\t/
H
d
}
/^[[:blank:]]*file = /{
s/^[[:blank:]]*//
s/[{}]//g
s/,*$/\t/
H
d
}
/^\}/{
# clear hold buffer
s/.*//
x
# initialize between hold and pattern
H
s/\n//g
#trim
s/^[ \t\n]*(.*)[ \t]*$/\1/
# if refid field don't exist, add tab
/^refid =/!{
s/^/\t/
}
# delete 'refid = ' string and all other field except for refid field
s/^refid =\s*([^\t]*)/\1/
s/^([^\t]*).*/\t\1/
# store refid field
H
x
# delete original refid field
s/^[^\t]*\t(.*)/\1/
h
#process title field
# if title field don't exist, add tab
/\s*title =/{
s/([^\t]*)[\t ]*(title =[^\t]*)(.*$)/\2\t\1\3/
}
#trim
s/^[ \t\n]*(.*)*$/\1/
/^title =/!{
s/^/\t/
}
# delete 'title = ' string and all other field except for title field
s/^title =\s*([^\t]*)/\1/
s/^([^\t]*).*/\t\1/
# store title field
H
x
# delete title field in hold buffer
s/^[^\t]*\t(.*)/\1/
h
#process file field
/\s*file=/{
s/([^\t]*)[\t ]*(file=[^\t]*)(.*$)/\2\t\1\3/
}
#trim
s/^[ \t\n]*(.*)[ \t]*$/\1/
# if file field don't exist, add tab
/^file =/!{
s/^/\t/
}
# delete 'file = ' string and all other field except for file field
s/^file =\s*([^\t]*)/\1/
s/^([^\t]*).*/\t\1/
# store file field
H
x
# delete file field in hold buffer
s/^[^\t]*\t(.*)/\1/
#trim
s/\n//g
s/^[ \t]*([.\n]*)/\1/
p
# clear hold buffer
s/.*//
x
}
#debug
#p
#q 0
#
