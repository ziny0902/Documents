local Matrix = require "matrix"

function AABB( A, B )
  if A[1][2] < B[1][1] then
    return false
  end
  if B[1][2] < A[1][1] then
    return false
  end
  if A[2][1] < B[2][3] then
    return false
  end
  if B[2][1] < A[2][3] then
    return false
  end
  return true
end

function find_segment_intersection( A, B )
--  print ( A )
--  print ( B )
  local numerator_t = 
    ( A[1][1] - B[1][1] ) * ( B[2][1] - B[2][2] )
    - ( A[2][1] - B[2][1] ) * ( B[1][1] - B[1][2] )
  local numerator_u = 
    ( A[1][2] - A[1][1] ) * ( A[2][1] - B[2][1] )
    - ( A[2][2] - A[2][1] ) * ( A[1][1] - B[1][1] )
  local denominator =
    ( A[1][1] - A[1][2] ) * ( B[2][1] - B[2][2] )
    - ( A[2][1] - A[2][2]) * ( B[1][1] - B[1][2] )
  denominator = math.floor(denominator*100 + 0.5)/100
  if denominator == 0 then
    return nil
  end
  local t = math.floor( 0.5+100*(numerator_t / denominator) ) /100
  local u = math.floor( 0.5+100*(numerator_u / denominator) ) /100
--  print ( "t, u : ", t, u )
  local x = A[1][1] + t * ( A[1][2] - A[1][1] )
  local y = A[2][1] + t * ( A[2][2] - A[2][1] )
  x = math.floor( x*100+0.5 )/100
  y = math.floor( y*100+0.5 )/100

--  print ( "x, y : ", x, y )
  if  ( t <= 0 or t >= 0.99 or u <= 0 or u >= 0.99  ) then
    return nil 
  end
  -- compensate conversion error 
  -- minimum error : 1 pixel
  if math.abs( A[1][2] - x ) < 0.01  and math.abs( A[2][2] - y ) < 0.01 then
    return nil
  end
  if math.abs( A[1][1] - x ) < 0.01  and math.abs( A[2][1] - y ) < 0.01 then
    return nil
  end
  return Matrix.new( {{x}, {y}} )
end

local function isOverlaped( ax, a, b )
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

function SAT(a, b)
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
      return false, -1 
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
      return false, -1
    end
  end
  return true
end

