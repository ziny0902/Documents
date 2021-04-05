require "collison"
local Matrix = require "matrix"

local function vect_len( v )
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
  x_inc = math.floor(x_inc*1000+0.5)/1000
  y_inc = math.floor(y_inc*1000+0.5)/1000
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
  local r, c, projA, projB
  r, c = Matrix.size(a)
  projA = Matrix.transpos(ax) * a
  sortedA = Matrix.sort( projA )
  projB = Matrix.transpos(ax) * b 
  sortedB = Matrix.sort( projB )
  local last = #projA[1]
  for i = 1, #projB[1], 1 do
    if projB[1][i] > sortedA[1][1] and projB[1][i] < sortedA[1][last] then
      return true, i
    end
  end
  last = #projB[1]
  for i = 1, #projA[1], 1 do
    if projA[1][i] > sortedB[1][1] and projA[1][i] < sortedB[1][last] then
      return true, i
    end
  end
  return false, -1
end

function Shape.SAT(a, b)
  local r, c = Matrix.size(a)
  local ax, result, overlapPt
  for i = 1, c, 1 do
    if i == c then
      ax = Matrix.new({{0, -1},{1, 0}}) 
          * ( Matrix.col(a, i) - Matrix.col(a, 1) )
    else
      ax = Matrix.new({{0, -1},{1, 0}}) 
          * ( Matrix.col(a, i) - Matrix.col(a, i+1) )
    end
    result, overlapPt = Shape.isOverlaped(ax, a, b)
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
  return true, overlapPt
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
  local ax = (1/1000)*( 1000*Matrix.col(vect, 2) - 1000*Matrix.col(vect, 1))
  local len = vect_len( ax ) 
  local norm = (1/len)*ax
  local w = vertices - Matrix.col(vect, 1)
  len = Matrix.transpos(w) * norm
  -- caculate orthogonal vector
  local ortho = w - len*norm
  return ( ortho[1][1]^2 + ortho[2][1]^2 ), ortho
end

local function find_collision_pt(a, b)
  local pt = -1
  for i = 1, #a[1], 1 do
    local col = Matrix.col(a, i)
    col = Matrix.join(col, col)
    local ret = collisonTest( col, b) 
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

local function find_segment_intersection( A, B )
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
  denominator = math.floor(denominator*1000 + 0.5)/1000
  if denominator == 0 then
    if (A[1][1] -A[1][2] + B[1][1] - B[1][2] ) == 0 then
      return Matrix.new( { {A[1][1]+B[1][1] - A[1][1]}, {A[2][1]} })
    else
      return Matrix.new( { {A[1][1]}, {A[2][1] + B[2][1] - A[2][1]} })
    end
  end
  local t = math.floor( 0.5+1000*(numerator_t / denominator) ) /1000
  local u = math.floor( 0.5+1000*(numerator_u / denominator) ) /1000
  print ( "t, u : ", t, u )
  if  ( u < 0 or u > 1  ) then
    return nil 
  end
  A = A
  local x = A[1][1] + t * ( A[1][2] - A[1][1] )
  local y = A[2][1] + t * ( A[2][2] - A[2][1] )
  x = math.floor( x*1000+0.5 )/1000
  y = math.floor( y*1000+0.5 )/1000
  print ( "x, y : ", x, y )
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

local function nearest_direction( A, B, C )
  local AB = vect_len( A - B ) 
  local AC = vect_len( A - C )
  print("AB, AC: ", AB, AC)
  if AB <= AC then
    return B
  end
  return C
end

local function find_boundary( adjA, matA, adjB, matB, dx, dy, sign )
  local A1 = Matrix.col( matA, adjA[1] ) 
  local A2 = Matrix.col( matA, adjA[2] ) 
  local A3 = Matrix.col( matA, adjA[3] ) 
  local B1 = Matrix.col( matB, adjB[1] ) 
  local B2 = Matrix.col( matB, adjB[2] ) 
  local B3 = Matrix.col( matB, adjB[3] ) 
  local B12 = Matrix.join( B1, B2 )
  local B13 = Matrix.join( B1, B3 )
--[[
  local segmentA = Matrix.new( {
      { A1[1][1] - dx, math.floor( A1[1][1]*1000 + 0.5 )/1000 }
      ,{ A1[2][1] - dy, math.floor( A1[2][1]*1000 + 0.5 )/1000 }
  } )

  local AB12 = find_segment_intersection( segmentA, B12 )
  local AB13 = find_segment_intersection( segmentA, B13 )
  if not AB12 and not AB13 then
    return nil, 0, 0
  end
  local AB12_xinc
  local AB12_yinc
  if AB12 then
    AB12_xinc = math.floor( ( AB12[1][1] - segmentA[1][1] ) * 1000 + 0.5)/1000
    AB12_yinc = math.floor( ( AB12[2][1] - segmentA[2][1] ) * 1000 + 0.5)/1000
  end
  print( "AB12_xinc, AB12_yinc", AB12_xinc, AB12_yinc )
  if not AB13 and AB12 then
    return B12, AB12_xinc, AB12_yinc 
  end
  local AB13_xinc = math.floor( ( AB13[1][1] - segmentA[1][1] ) * 1000 + 0.5)/1000
  local AB13_yinc = math.floor( ( AB13[2][1] - segmentA[2][1] ) * 1000 + 0.5)/1000
  print( "AB13_xinc, AB13_yinc", AB13_xinc, AB13_yinc )
  if not AB13 then
    return B12, AB12_xinc, AB12_yinc 
  end
  if not AB12 then
    return B13, AB13_xinc, AB13_yinc 
  end
  -- TODO
  local cx, cy
  if sign > 0 then
    cx, cy = Shape.getCentroid( matB )
  else
    cx, cy = Shape.getCentroid( matA )
  end
  local dir = nearest_direction( Matrix.new({{cx},{cy}}), AB12, AB13 )
  if dir == AB12 then
    return B12, AB12_xinc, AB12_yinc
  else
    return B13, AB13_xinc, AB13_yinc
  end
--]]

  --[[
  print( "B12" )
  print( B12 )
  if not AB12 then
    return B13, segmentA[1][1] - AB13[1][1], segmentA[2][1] - AB13[2][1]
  end

  --[[
  print( "B12" )
  print( B12 )
  print( "B13" )
  print( B13 )
  --]]
  --[
  local xinc, yinc = dx/2, dy/2 
  local xprev = A1[1][1] - dx
  local yprev = A1[2][1] - dy
  local cx, cy = Shape.getCentroid( matA ) 
  for i = 1, 4, 1 do
    local segmentA = Matrix.new( {
        { cx, xprev + xinc }
      , { cy, yprev + yinc }
    } )
    local is_intersectB12, angleB12 = check_segment_intersection( segmentA, B12 )
    local is_intersectB13, angleB13 = check_segment_intersection( segmentA, B13 )
    if is_intersectB12 and is_intersectB13 then
      angleB12 = getAngle( A2-A1, B2 - A1 )
      angleB13 = getAngle( A2-A1, B3 - A1 )
      --print("angle 12, 13: ", angleB12, angleB13 )
      if angleB12 > angleB13 then
        return B12, xinc, yinc
      end
      return B13, xinc, yinc
    end
    if is_intersectB12 then
      return B12, xinc, yinc
    end
    if is_intersectB13 then
      return B13, xinc, yinc
    end
    xinc = xinc + dx/2
    yinc = yinc + dy/2
  end
  return nil, 0, 0
  --]]
end

-- A : moving body
-- B : station body
-- return : dx, dy
local function resolve_edge_condition(A, B, idxA, idxB, dx, dy)
  local adjA = { idxA }
  local adjB = { idxB }
  gen_adjacent_vect( adjA, #A[1] )
  gen_adjacent_vect( adjB, #B[1] )
  local A1 = Matrix.col(A, adjA[1])
  local B1 = Matrix.col(B, adjB[1])
  -- 겹치는 두 점 사이의 vector를 구한다.
  local adj
  -- scale up to prevent roundoff error
  local vectAB = B1 - A1 -Matrix.new( { {dx},{dy} } )
  vectAB = vectAB

  -- 인접한 두 점이 아니면 경계선 문제가 아니다. 
  if vect_len( vectAB ) > 0.1 then 
    return Matrix.new( { {-dx}, {-dy} } ), false
  end

  local dist, ds 
  ds = B1 - A1
  ds = ds
  return ds, true
end


function Shape:resolve( dx, dy, obj )
  -- prevent tunneling 
  if math.sqrt(dx*dx + dy*dy) > 0.5 then
    self:move( -dx, -dy )
    return Matrix.new( { {0}, {0} })
  end
  if self:getType() == "Circle" then
    return nil
  end
  if obj:getType() == "Circle" then
    return nil
  end
  
  local ax = Matrix.new( {
    {  dx }
    ,{ dy }
  })

  local dist, sortedPtsA
  local sortedPtsB
  local boundary, nearest_pt
  local pt = find_collision_pt(self.mat, obj.mat)
  local sign = 1
  local angle
  local actual_dx, actual_dy
  if pt < 0 then
    pt = find_collision_pt(obj.mat, self.mat)
    sortedPtsB = {pt}
    if pt < 0 then
      self:move( -dx, -dy )
      return
    end
    local col = Matrix.col(obj.mat, pt)
    dist, sortedPtsA = Shape.pt2ptSort(col, self.mat)
    gen_adjacent_vect( sortedPtsA, #self.mat[1] )
    gen_adjacent_vect( sortedPtsB, #obj.mat[1] )
    self:move( -dx, -dy )
    sign = -1
    boundary, actual_dx, actual_dy = find_boundary( sortedPtsB, obj.mat, sortedPtsA, self.mat, -dx, -dy, sign )
    actual_dx, actual_dy = -actual_dx, -actual_dy
    nearest_pt = Matrix.new( { 
       {obj.mat[1][pt] }
      ,{obj.mat[2][pt] } 
    } )
    --self:move( dx, dy )
  else
    sortedPtsA = {pt}
    --[
    pt = find_collision_pt(obj.mat, self.mat)
    if pt > 0 then
      local ds, is_edge = resolve_edge_condition( 
         self.mat
        ,obj.mat
        ,sortedPtsA[1], pt
        ,dx, dy 
      ) 
      if is_edge then
        print(" edge condition " )
        print( ds[1][1], ds[2][1] )
        self:move( ds[1][1], ds[2][1] )
        return ds 
      end
    end
    --]]
    pt = sortedPtsA[1]
    local col = Matrix.col(self.mat, pt)
    dist, sortedPtsB = Shape.pt2ptSort( col, obj.mat)
    gen_adjacent_vect( sortedPtsA, #self.mat[1] )
    gen_adjacent_vect( sortedPtsB, #obj.mat[1] )
    boundary, actual_dx, actual_dy = find_boundary( sortedPtsA, self.mat, sortedPtsB, obj.mat, dx, dy, sign )
    nearest_pt = Matrix.new( { 
       {self.mat[1][pt] - dx + actual_dx}
      ,{self.mat[2][pt] - dy + actual_dy} 
    } )
    --self:move( -dx, -dy )
  end
  --[[
  print(" actual_dx, actual_dy :", actual_dx, actual_dy)
  print("boundary")
  print( boundary )
  --]]
  self:move( -dx + actual_dx, -dy + actual_dy )
  if not boundary then
    return nil
  end
  dist, ortho
    = Shape.vertice2vectorDist(boundary, nearest_pt) 
--[[
  print( " dist: ")
  print( dist )
  print( " ortho: ")
  print( ortho )
--]]
  boundary = Matrix.col(boundary, 2) - Matrix.col(boundary, 1)
  len = vect_len( boundary )
  local norm = math.floor(0.5+1000/len)/1000 * boundary
  norm = Matrix.transpos( 
    Matrix.new( { {dx }, {dy } } ) 
    ) * norm * norm
  shift = sign * ortho - norm 
  
  shift = -1*shift
  --[[
  print( "shift" )
  print( shift )
  --]]
  Matrix.shift( self.mat, shift)
  return shift 
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
