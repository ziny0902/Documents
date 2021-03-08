local basic = { 1, 2, 3, 4, 5 }

print(basic[1])
basic[1] = 10
print(basic[1])

-- table length
print(#basic)

for i = 1, #basic do
  print(basic[i])
end

table.insert(basic, 20)
table.insert(basic, 30)
table.insert(basic, "string")

for i = 1, #basic do
  print(basic[i])
end

local key_val = {
  1, 2, 3,
  ["hello"] = 123,
  simple = 200
}

print(#key_val)
print(key_val["hello"])
print(key_val["simple"])
print(key_val.simple)

local multi_dim = {
  {1, 2, 3},
  {4, 5, 6},
  {7, 8, 9}
}

print ( multi_dim[2][2])
