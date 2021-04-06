local Matrix = require "matrix"

function vect_len( v )
  return math.sqrt( v[1][1]^2 + v[2][1]^2 )
end

Shape = {}

setmetatable(Shape
    , { __call =  function (o, vertices)
    return o:new(vertices) end
    })

function Shape:new( vertices ) 
  local o = {}
  setmetatable( o, {__index = self})
  o.mat = Matrix.new( vertices ) 
  o.color = {1, 1, 1, 1}
  o.action = "fill"
  return o
end

function Shape:move( x_inc, y_inc )
  x_inc = math.floor(x_inc*100+0.5)/100
  y_inc = math.floor(y_inc*100+0.5)/100
  shiftx = x_inc * Matrix.ones(1, #self.mat[1])
  shifty = y_inc * Matrix.ones(1, #self.mat[1])
  self.mat = self.mat + Matrix.new( { shiftx[1], shifty[1] } )
end

function Shape.getCentroid( mat )
  local r, c = Matrix.size(mat)
  local xsum = 0
  local ysum = 0
  for i = 1, c, 1 do
    xsum = xsum + mat[1][i]
    ysum = ysum + mat[2][i]
  end
  return xsum/c, ysum/c
end

function Shape:moveto( x, y )
  local center_x, center_y = Shape.getCentroid( self.mat )
  local shiftx = (x - center_x) * Matrix.ones(1, #self.mat[1])
  local shifty = (y - center_y)* Matrix.ones(1, #self.mat[1])
  self.mat = self.mat + Matrix.new( { shiftx[1], shifty[1] } )
end

function Shape:setColor( rgba )
  self.color = rgba
end

function Shape:getColor()
  return self.color
end

function Shape:getAction()
  return self.action
end

function Shape:getType()
  return "Polygon"
end

function Shape.isOverlaped( ax, a, b )
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

function Shape.SAT(a, b)
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
    result = Shape.isOverlaped(ax, a, b)
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
    result = Shape.isOverlaped(ax, b, a)
    if result == false then
      return false, -1
    end
  end
  return true
end

function Shape.pt2ptSort(pt, mat)
  local c = #mat[1]
  local ptsLen = {math.huge, math.huge}
  local pts ={}
  for i = 1, c, 1 do
    ptsLen[i] = ( pt[1][1] - mat[1][i] )^2 + ( pt[2][1] - mat[2][i] )^2
    pts[i] = i
  end
  -- 거리 순서로 sorting
  for i = 1, c, 1 do
    for j = i+1, c, 1 do
      if ptsLen[i] > ptsLen[j] then
        local tmp = ptsLen[i]
        ptsLen[i] = ptsLen[j]
        ptsLen[j] = tmp 
        tmp = pts[i]
        pts[i] = pts[j]
        pts[j] = tmp
      end
    end
  end
  return ptsLen, pts
end

function Shape.vertice2vectorDist( vect, vertices)
  local ax = Matrix.col(vect, 2) - Matrix.col(vect, 1)
  local len = math.floor(100 * vect_len( ax ) + 0.5)/100
  local norm = (1/len)*ax
  local w = vertices - Matrix.col(vect, 1)
  len = math.floor( Matrix.transpos(w) * norm * 100 + 0.5 )/100
  -- caculate orthogonal vector
  local ortho = w - len*norm
  return ( ortho[1][1]^2 + ortho[2][1]^2 ), ortho
end

local function find_collision_pt(a, b)
  local pt = -1
  for i = 1, #a[1], 1 do
    local col = Matrix.col(a, i)
    col = Matrix.join(col, col)
    local ret = Shape.SAT( col, b )
    if ret then
      pt = i
      break
    end
  end
  return pt
end

local function gen_adjacent_vect(vect, col)
  if vect[1] == col then
    vect[2] = 1
  else
    vect[2] = vect[1] + 1
  end
  if vect[1] == 1 then
    vect[3] = col
  else
    vect[3] = vect[1] - 1
  end
  return vect 
end

function find_segment_intersection( A, B )
  print ( A )
  print ( B )
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
  print ( "t, u : ", t, u )
  local x = A[1][1] + t * ( A[1][2] - A[1][1] )
  local y = A[2][1] + t * ( A[2][2] - A[2][1] )
  x = math.floor( x*100+0.5 )/100
  y = math.floor( y*100+0.5 )/100

  print ( "x, y : ", x, y )
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

local function check_segment_intersection( A, B )
  -- scale up for preventing roundoff erro
  local A1 = 100*Matrix.col( A, 1 )
  local A2 = 100*Matrix.col( A, 2 )
  local B1 = 100*Matrix.col( B, 1 )
  local B2 = 100*Matrix.col( B, 2 )
  local A12 = A2 - A1
  A12 = ( 1/vect_len( A12 ) ) * A12
  local B12 = B2 - B1
  B12 = ( 1/vect_len( B12 ) ) * B12
  local A1B1 = B1 - A1
  A1B1= ( 1/vect_len( A1B1 ) ) * A1B1
  local A1B2 = B2 - A1
  A1B2= ( 1/vect_len( A1B2 ) ) * A1B2
  local B1A1 = A1 - B1
  B1A1 = ( 1/vect_len( B1A1 ) ) * B1A1
  local B1A2 = A2 - B1
  B1A2 = ( 1/vect_len( B1A2 ) ) * B1A2

  local A12B1 = A12[1][1]*A1B1[2][1] - A12[2][1]*A1B1[1][1]
  local A12B2 = A12[1][1]*A1B2[2][1] - A12[2][1]*A1B2[1][1]

  local B12A1 = B12[1][1]*B1A1[2][1] - B12[2][1]*B1A1[1][1]
  local B12A2 = B12[1][1]*B1A2[2][1] - B12[2][1]*B1A2[1][1]

  --[[
  print( " A12B1, A12B2 : ", A12B1, A12B2 )
  print( " B12A1, B12A2 : ", B12A1, B12A2 )
  --]]
  
  -- handling roundoff error
  if ( A12B1 * A12B2  <= 1e-3 ) and ( B12A1 * B12A2 <= 1e-3 ) then
    return true, B12A1*B12A2
  end
  return false, B12A1*B12A2
end

local function getAngle(v1, v2)
  local unit_v1 = ( 1/vect_len(v1) ) * v1
  local unit_v2 = ( 1/vect_len(v2) ) * v2 
  return Matrix.transpos( unit_v1 ) * unit_v2
end

local function cal_shift(pt, boundary, dx, dy, sign)
  local dist, ortho, shift
  dist, ortho
    = Shape.vertice2vectorDist(boundary, pt ) 
  local bv = Matrix.col( boundary, 2 ) - Matrix.col( boundary, 1 ) 
  len = vect_len( bv )
  local norm = math.floor(0.5+100/len)/100 * bv 
  norm = Matrix.transpos( 
    Matrix.new( { {dx }, {dy } } ) 
    ) * norm * norm
  print("sign: ", sign)
  shift = ortho - norm 
  shift = -1*sign*shift
  print(" shift : " )
  print( shift )
  return shift
end

local function slide_object( adjA, matA, adjB, matB, dx, dy, sign )
  local A1 = Matrix.col( matA, adjA[1] ) 
  local A2 = Matrix.col( matA, adjA[2] ) 
  local A3 = Matrix.col( matA, adjA[3] ) 
  local B1 = Matrix.col( matB, adjB[1] ) 
  local B2 = Matrix.col( matB, adjB[2] ) 
  local B3 = Matrix.col( matB, adjB[3] ) 
  local B12 = Matrix.join( B1, B2 )
  local B13 = Matrix.join( B1, B3 )
--[

  local moving,target , M1, M2, CB
  if sign > 0 then
    moving = matA
    target = matB
    M1 = A1
    M2 = A2
    M3 = A3
    local cx, cy = Shape.getCentroid( target )
    local center = Matrix.new( { {cx}, {cy} } )
    CB = Matrix.join( center, B1 ) 
  else
    moving = matB
    target = matA
    M1 = B1
    M2 = B2
    M3 = B3
    local cx, cy = Shape.getCentroid( target )
    local center = Matrix.new( { {cx}, {cy} } )
    CB = Matrix.join( center, A1 ) 
  end

  local M12, M13
--  print(" B12 ")
--  print( B12 )
  local shiftB12 = cal_shift( A1, B12, dx, dy, sign)
  M12 = Matrix.join( M1 + shiftB12, M2 + shiftB12 ) 
  M13 = Matrix.join( M1 + shiftB12, M3 + shiftB12 ) 
  local B12M12 = find_segment_intersection( CB, M12 )
  local B12M13 = find_segment_intersection( CB, M13 )
  if B12M12 or B12M13 then
    shiftB12 = nil
  end

--  print(" B13 ")
--  print( B13 )
  local shiftB13 = cal_shift( A1, B13, dx, dy, sign)
  M12 = Matrix.join( M1 + shiftB13, M2 + shiftB13 ) 
  M13 = Matrix.join( M1 + shiftB13, M3 + shiftB13 ) 
  local B13M12 = find_segment_intersection( CB, M12 )
  local B13M13 = find_segment_intersection( CB, M13 )
  if B13M12 or B13M13 then
    shiftB13 = nil
  end

  if shiftB12 and shiftB13 then
    if vect_len( shiftB12 ) < vect_len( shiftB13 ) then
      return shiftB12
    else
      return shiftB13
    end
  end

  if shiftB12 then
    return shiftB12
  end

  if shiftB13 then
    return shiftB13
  end

  return nil
end

function Shape:resolve( dx, dy, obj )
  dx = math.floor( dx * 100 + 0.5 ) /100
  dy = math.floor( dy * 100 + 0.5 ) /100
  -- prevent tunneling 
  if math.sqrt(dx*dx + dy*dy) > 0.5 then
    self:move( -dx, -dy )
    return Matrix.new( { {0}, {0} })
  end
  if obj:getType() == "Circle" then
    local movement = Circle.slideCircle( self, obj, dx, dy )
    if movement then
      self:move( movement[1][1], movement[2][1] )
    end
    return  movement
  end
  
  local dist, sortedPtsA
  local sortedPtsB
  local movement
  local pt = find_collision_pt(self.mat, obj.mat)
  local sign = 1
  local angle
  local actual_dx, actual_dy
  if pt < 0 then
    pt = find_collision_pt(obj.mat, self.mat)
    sortedPtsB = {pt}
    if pt < 0 then
      return
    end
    local col = Matrix.col(obj.mat, pt)
    dist, sortedPtsA = Shape.pt2ptSort(col, self.mat)
    gen_adjacent_vect( sortedPtsA, #self.mat[1] )
    gen_adjacent_vect( sortedPtsB, #obj.mat[1] )
    sign = -1
    movement = slide_object( sortedPtsB, obj.mat, sortedPtsA, self.mat, -dx, -dy, sign )
  else
    sortedPtsA = {pt}
    pt = sortedPtsA[1]
    local col = Matrix.col(self.mat, pt)
    dist, sortedPtsB = Shape.pt2ptSort( col, obj.mat)
    gen_adjacent_vect( sortedPtsA, #self.mat[1] )
    gen_adjacent_vect( sortedPtsB, #obj.mat[1] )
    movement = slide_object( sortedPtsA, self.mat, sortedPtsB, obj.mat, dx, dy, sign )
  end
  print( "movement" )
  print( movement )
  if not movement then
    self:move( -dx, -dy)
    return nil
  end
  Matrix.shift( self.mat, movement )
  return nil 
end

function Shape:is_collieded( o )
  if o:getType() == "Polygon" then
    return Shape.SAT( self.mat, o.mat )
  end
  if o:getType() == "Circle" then
    return o:is_collieded(self)
  end
end

function Shape:draw( scene )
  love.graphics.setColor( self.color )
  love.graphics.polygon( self.action, self:getVertices( scene, self.mat ) )
end

function Shape:getVertices( scene , m)
  local r, c = Matrix.size( m)
  local v = { }
  local k = 1
  for i = 1, c, 1 do
    -- v[k] : x coordinate, v[k+1] : y coordinate
    v[k], v[k+1] = scene:scene2screen( m[1][i], m[2][i] )
    k = k + 2
  end
  return v
end

function Shape:__tostring()
  return tostring(self.mat)
end
