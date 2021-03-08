function first_fnc()
  print "Hello function"
end

function add(a, b)
  return a + b
end

sub = function (a, b)
  return a - b
end

function operation( a, b, op )
  return op(a, b)
end

function factorial(num)
  if num== 0 then
    return 1
  else
    return num * factorial( num  - 1)
  end
end

function nest_fnc()
  local function internal()
    print "internal"
  end
  internal()
end

first_fnc()

print(add( 10, 200))
print(sub( 10, 200))
print(operation(10, 200, add))
print(operation(10, 200, sub))
print(factorial(5))

nest_fnc()
