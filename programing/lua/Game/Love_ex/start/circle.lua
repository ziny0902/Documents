local Matrix = require "matrix"
require "shape"

Circle = {}

setmetatable(Circle
    , { 
      __index = Shape
      , __call =  function (o, center, r) return o:new( center, r ) end
    })

function Circle:new( center, radius ) 
  local o = {}
  setmetatable( o, {__index = Circle})
  o.mat = Matrix.new( center ) 
  o.R = radius
  o.color = {1, 1, 1, 1}
  o.action = "fill"
  return o
end

function Circle:draw( scene )
  love.graphics.setColor( self.color )
  local v = self:getVertices( scene, self.mat ) 
  love.graphics.circle( 
    self.action
    , v[1]
    , v[2]
    , self.R * scene:getUnitPixel() 
  )
--  if self.ortho then
--    love.graphics.setColor( {1, 1, 1, 1})
--    v = self:getVertices( scene, self.ortho ) 
--    love.graphics.line( v[1], v[2], v[3], v[4] )
--  end
--  if self.norm then
--    v = self:getVertices( scene, self.norm ) 
--    love.graphics.line( v[1], v[2], v[3], v[4] )
--  end
end

function Circle:getType()
  return "Circle"
end

-- a : polygon, b: point
local function nearest_segments( a, b, r_sqaure )
  local r, c = Matrix.size( a )
  local segments = {}
  local dist
  for i = 1, c, 1 do
    local v, A2
    local A1 = Matrix.col( a, i )
    if not (i == c) then
      A2 = Matrix.col( a, i+1)
    else
      A2 = Matrix.col( a, 1)
    end
    v = A2 - A1
    local scale = math.sqrt( v[1][1]^2 + v[2][1]^2 )
    local norm = (1/scale)*v
    local w = ( b - Matrix.col(a, i) )
    local proj = Matrix.transpos(w) * norm 
    local ortho, adj
    if proj > scale  then
      if i < c then
        ortho = b - Matrix.col( a, i+1 )
        adj = { i, i+1, i + 2 <= c and i + 2 or 1 }
      else
        ortho = b - Matrix.col( a, 1 )
        adj = { c, 1, 2 }
      end
      norm = nil
    elseif proj < 0 then
      ortho = b - Matrix.col( a, i )
      adj = { i > 1 and i - 1 or c, i, i < c and i + 1 or 1 }
      norm = nil
    else
      ortho = w - proj*norm
    end
    dist = ortho[1][1]^2 + ortho[2][1]^2
    if dist < r_sqaure then
      table.insert( segments, 
        { 
          ["adj"] = adj 
          , ["ortho"] = ortho
          , ["norm"] = norm
          , ["dist"] = math.sqrt(r_sqaure) - math.sqrt(dist)
        } 
      ) 
    end
  end
  return segments
end

local function getAdjVect( station, moving, adj )
  local norm
  local A1 = Matrix.col( station.mat, adj[2] )
  local A2 = Matrix.col( station.mat, adj[1] )
  local A3 = Matrix.col( station.mat, adj[3] )
  local A12 = Matrix.join( A1, A2 )
  local A13 = Matrix.join( A1, A3 )
  local cx, cy = Shape.getCentroid( station.mat )
  local center = Matrix.new( { {cx}, {cy} } )
  local c2c = Matrix.join( center, moving.mat)
  local A12C = find_segment_intersection( A12, c2c )
  local A13C = find_segment_intersection( A13, c2c )
  A12 = A2 - A1
  A13 = A3 - A1
  if not A12C then
    norm = ( 1/ vect_len( A13 ) ) * A13 
  elseif not A13C then
    norm = ( 1/ vect_len( A12 ) ) * A12
  else
    norm = 
      vect_len(A12C - moving.mat) < vect_len(A13C - moving.mat)
        and 
       ( 1/ vect_len( A12 ) ) * A12 or ( 1/ vect_len( A13 ) ) * A13 
  end
  return norm
end

function Circle.slidingPoly( poly, circle, dx, dy )
  local r_sqaure = circle.R * circle.R
  local segments = nearest_segments( poly.mat, circle.mat, r_sqaure )
  local D = Matrix.new( { {dx}, {dy} } )
  local dist = math.huge
  local ortho
  local norm, adj
  for i = 1, #segments, 1 do
    if dist > segments[i]["dist"] then
      ortho = segments[i]["ortho"]
      dist = segments[i]["dist"]
      norm = segments[i]["norm"]
      adj = segments[i]["adj"]
    end
  end
  if ortho then
    local scale = vect_len( ortho )
    ortho = dist*(1/scale)*ortho 
  end
  circle.ortho = Matrix.join( circle.mat, ortho + circle.mat)

  if not norm then
    norm = getAdjVect( poly, circle, adj )
  end
  local movement = ortho
  if norm then
    circle.norm = Matrix.join( circle.mat, 0.5*norm + circle.mat)
    movement = movement + ( Matrix.transpos( D ) * norm ) * norm
  end
  return movement
end

function Circle.slideCircle( poly, circle, dx, dy )
  local r_sqaure = circle.R * circle.R
  local segments = nearest_segments( poly.mat, circle.mat, r_sqaure )
  local D = Matrix.new( { {dx}, {dy} } )
  local dist = math.huge
  local ortho
  local norm, adj
  for i = 1, #segments, 1 do
    if dist > segments[i]["dist"] then
      ortho = segments[i]["ortho"]
      dist = segments[i]["dist"]
      norm = segments[i]["norm"]
    end
  end
  if not ortho then
    return nil
  end
  local scale = vect_len( ortho )
  ortho = -1*dist*(1/scale)*ortho 
  if not norm then
    return ortho 
  end
  local movement = ortho
  movement = movement + ( Matrix.transpos( D ) * norm ) * norm
  return movement
end

function CCC( c1, c2 )
  local CCR = ( c1.R + c2.R )^2
  local dist 
    = ( c1.mat[1][1] - c2.mat[1][1] )^2
    + ( c1.mat[2][1] - c2.mat[2][1] )^2

  if CCR > dist then
    return true 
  end
  return false 
end

function CCResolver( station, moving )
  local CCR = station.R + moving.R
  local ccv = Matrix.new( { 
     { moving.mat[1][1] - station.mat[1][1] }
    ,{ moving.mat[2][1] - station.mat[2][1] }
  } )
  local scale = vect_len( ccv )
  local norm = (1/scale) * ccv
  local diff = CCR - scale
  return -1*diff * norm
end

function Circle:resolve( dx, dy, o )
  local movement
  if o:getType() == "Circle" then
    movement = CCResolver( self, o )
  else
    movement = Circle.slidingPoly( o, self, dx, dy ) 
  end
  self:move( movement[1][1], movement[2][1] )
end


function Circle:is_collieded( o )
  if o:getType() == "Circle" then
    return CCC( self, o )
  end
  local r_sqaure = self.R * self.R
  local segments = nearest_segments( o.mat, self.mat, r_sqaure )
  if #segments > 0 then
    return true
  end
  return false
end

