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
end

function Circle:getType()
  return "Circle"
end

-- a : polygon, b: point
function nearest_dist( a, b )
  local r, c = Matrix.size(a)
  local dist = {}
  for i = 1, c, 1 do
    local v
    local w = ( b - Matrix.col(a, i) )
    if not (i == c) then
      v = Matrix.new({ {a[1][i+1] - a[1][i]}, {a[2][i+1] - a[2][i]} })
    else
      v = Matrix.new({ {a[1][1] - a[1][i]}, {a[2][1] - a[2][i]} })
    end
    local scale = math.sqrt( v[1][1]^2 + v[2][1]^2 )
    local norm = (1/scale)*v
    local proj = Matrix.transpos(w) * norm 
    if proj > scale  then
      if not (i == c) then
        dist[i] = (a[1][i+1] - b[1][1])^2 + (a[2][i+1] - b[2][1])^2
      else
        dist[i] = (a[1][1] - b[1][1])^2 + (a[2][1] - b[2][1])^2
      end
    elseif proj < 0 then
      dist[i] = w[1][1]^2 + w[2][1]^2
    else
      local otho = w - proj*norm
      dist[i] = otho[1][1]^2 + otho[2][1]^2
    end
  end
  return dist
end

function Circle:is_collieded( o )
  local dist = nearest_dist( o.mat, self.mat )
  local r, c = Matrix.size( o.mat )
  local r_sqaure = self.R * self.R
  for i = 1, #dist, 1 do
    if dist[i] <= r_sqaure then
      return true
    end
  end
  return false
end
