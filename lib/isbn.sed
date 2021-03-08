/@book/{
s/@book{//
H
d
}
/isbn/{
s/^[[:blank:]]*//
s/isbn = *//
s/[{}]//g
s/,$/\t/
G
s/\n//g
s/,$//
p
s/.*//
x
d
}
