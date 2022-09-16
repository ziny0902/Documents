/@article{/{
s/@article{//
s/,$/\t/
H
d
}
/@book{/{
s/@book{//
s/,$/\t/
H
d
}
/^[[:blank:]]*title =/{
s/^[[:blank:]]*//
s/title = *//
s/[{}]//g
s/,$/\t/
H
d
}
/^[[:blank:]]*file =/{
s/^[[:blank:]]*//
s/file = *//
s/[{}]//g
s/,$/\t/
H
d
}
/^\}/{
x
s/\n//g
s/,$/\n/
p
s/.*//
x
d
}
