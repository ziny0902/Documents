local  Matrix = require "matrix"

function isOverlaped( ax, a, b )
  local r, c, projA, projB, len
  r, c = Matrix.size(a)
  projA = Matrix.sort( Matrix.transpos(ax) * a )
  projB = Matrix.sort( Matrix.transpos(ax) * b )
  r, c = Matrix.size(projA)
  if projB[1][1] > projA[1][c] then
    return false
  end
  r, c = Matrix.size(projB)
  if projB[1][c] < projA[1][1] then
    return false
  end
  return true
end

function collisonTest( a, b )
  local r, c = Matrix.size(a)
  local ax, result
  for i = 1, c, 1 do
    if i == c then
      ax = Matrix.new({{0, -1},{1, 0}}) 
          * ( Matrix.col(a, i) - Matrix.col(a, 1) )
    else
      ax = Matrix.new({{0, -1},{1, 0}}) 
          * ( Matrix.col(a, i) - Matrix.col(a, i+1) )
    end
    result = isOverlaped(ax, a, b)
    if result == false then
      return false
    end
  end
  r, c = Matrix.size(b)
  for i = 1, c, 1 do
    if i == c then
      ax = Matrix.new({{0, -1},{1, 0}}) 
          * ( Matrix.col(b, i) - Matrix.col(b, 1) )
    else
      ax = Matrix.new({{0, -1},{1, 0}}) 
          * ( Matrix.col(b, i) - Matrix.col(b, i+1) )
    end
    result = isOverlaped(ax, b, a)
    if result == false then
      return false
    end
  end
  return true
end


function simulator()
  objA = Matrix.new( {{ 1.0, 2.0, 3.0 }, { 1.0, 3.0, 2.0 }} )
  objB = Matrix.new( {{ 5.0, 6.5, 8.0 }, { 3.0, 6.0, 3.0 }} )
  scene = { w = 800, h = 600 , xrange={0, 10}, yrange={0, 10} }
  print(objA)
  print(objB)
  print( collisonTest( objA, objB ) )
end
