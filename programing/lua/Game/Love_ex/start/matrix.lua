local Matrix = {}

local function index(m, idx)
  return m.arr[idx]
end
local function newindex(m, key, value)
  if not type(key) == "number" then
    error("Invalid operation: index must be number")
  end
  if type(value) == "number" then
    m.arr[key][1] = value
  elseif type(value) == "table" then
    m.arr[key] = value
  else
    error("Invalid operation: value must be number or table")
  end
  return m
end

local function add(left, right)
  if not( #left.arr[1] == #right.arr[1] ) then
    error("left have a different number of column")
  end
  if not( #left.arr == #right.arr ) then
    error("left have a different number of row")
  end
  local r = #left.arr
  local c = #left.arr[1]
  local ret = Matrix.new(nil) 
  for i = 1, r, 1 do
    ret.arr[i]={}
    for j = 1, c, 1 do
      ret.arr[i][j] = left.arr[i][j] + right.arr[i][j]
    end
  end
  return ret
end

local function sub(left, right)
  if not( #left.arr[1] == #right.arr[1] ) then
    print( "left column number: ", #left.arr[1] )
    print( "right column number: ", #right.arr[1] )
    error("left have a different number of column")
  end
  if not( #left.arr == #right.arr ) then
    error("left have a different number of row")
  end
  local r = #left.arr
  local c = #left.arr[1]
  local ret = Matrix.new(nil) 
  for i = 1, r, 1 do
    ret.arr[i]={}
    for j = 1, c, 1 do
      ret.arr[i][j] 
      = math.floor( ( left.arr[i][j] - right.arr[i][j] )*1000 + 0.5 )/1000
    end
  end
  return ret
end

local function mul(left, right)
  local ret = Matrix.new(nil)
  if type(left) == "number" then 
    for i = 1, #right.arr, 1 do
      ret.arr[i] = {}
      for j = 1, #right.arr[i], 1 do
        ret.arr[i][j] = left * right.arr[i][j]
      end
    end
    return ret
  end
  if type(right) == "number" then 
    for i = 1, #left.arr, 1 do
      ret.arr[i] = {}
      for j = 1, #left.arr[i], 1 do
        ret.arr[i][j] = right * left.arr[i][j]
      end
    end
    return ret
  end
  local c = #left.arr[1]
  local r = #right.arr
  if not ( c == r ) then
    error("Invalid operation: left column don't match right row")
  end
  for i = 1, #left.arr, 1 do
    ret.arr[i] = {}
    for j = 1, #right.arr[i], 1 do
      ret.arr[i][j] = 0
      for k = 1, #right.arr, 1 do
        ret.arr[i][j] = ret.arr[i][j] + left.arr[i][k] * right[k][j] 
      end
    end
  end
  r = #ret.arr
  c = #ret.arr[1]
  if r == 1 and c == 1 then
    return ret.arr[1][1]
  end
  return ret
end

local function m2string( m )
  local r = #m.arr
  local c = #m.arr[1]
  local str = ""
  for i = 1, r, 1 do
    for j = 1, c, 1 do
      str = str .. tostring(m[i][j]) .. " "
    end
    str = str .. "\n"
  end
  return str
end

function Matrix.new(arr)
  local ret = { }
  ret.arr = arr or {}
  setmetatable( ret, 
    { __index = index
    , __add = add
    , __sub = sub 
    , __mul = mul
    , __tostring = m2string 
    , __newindex = newindex
    })
  return ret
end

function Matrix.size(m)
  local r = #m.arr
  local c = #m.arr[1]
  return r, c
end

Matrix.size = function(m)
  local r = #m.arr
  local c = #m.arr[1]
  return r, c
end

Matrix.col = function(m, col)
  local r = #m.arr
  local ret = Matrix.new(nil)
  for i = 1, r, 1 do
    ret.arr[i] = {}
    ret.arr[i][1] = m[i][col]
  end
  return ret
end

Matrix.join = function( left, right )
  local lr, lc = Matrix.size( left )
  local rr, rc = Matrix.size( right )
  local ret = {}
  if not ( lr == rr ) then
    error("a left row don't match a right row")
  end
  for i = 1, lr, 1 do
    ret[i] = {}
    for j = 1, rc, 1 do
      ret[i][j] = left[i][j]
    end
  end
  for i = 1, lr, 1 do
    for j = 1, rc, 1 do
      ret[i][lc+j] = right[i][j]
    end
  end
  return Matrix.new( ret )
end

Matrix.shift = function( m, shift )
  local r, c = Matrix.size( m )
  for i = 1, r, 1 do
    for j = 1, c, 1 do
      m[i][j] = m[i][j] + shift[i][1]
    end
  end
end

Matrix.transpos = function(m)
  local r = #m.arr
  local c = #m.arr[1]
  local ret = Matrix.new(nil)
  for i = 1, c, 1 do
    ret[i] = {}
    for j = 1, r, 1 do
      ret[i][j] = m[j][i]
    end
  end
  return ret
end

Matrix.sort = function(m)
  r = #m.arr
  for i = 1, r, 1 do
    table.sort( m.arr[i] )
  end
  return m
end

Matrix.ones = function( r, c )
  local ret = Matrix.new(nil)
  for i = 1, r, 1 do
    ret.arr[i] = {}
    for j = 1, c, 1 do
      ret.arr[i][j] = 1
    end
  end
  return ret
end

--[[ test
local lm = Matrix.new( {
  {1, 2, 3}, 
  {1, 2, 3},
  {2, 3, 4},
} )
local rm = Matrix.new( {
  { 1, 1, 1 }, 
  { 2, 2, 2 },
  { 2, 3, 1 },
} )
local ret = lm * rm
print(ret)
local column = Matrix.col(ret, 2)
column[2]=77
print(column)
print(Matrix.transpos(column))
local num = Matrix.transpos(column)*column
print( num/100 )
local r,c = Matrix.size( column)
print( r, c)
local mul = Matrix.transpos(column) * rm
print(mul)
Matrix.sort(mul)
print(mul)
--]]

return Matrix
