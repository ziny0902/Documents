Scene = { }

setmetatable(Scene
    , { __call =  function (o, w, h, x, y)
    return o:new(w, h, x, y) end
    })

local overlapColor = { 0.96, 0.019, 0.921, 0.8 }
local selColor = { 0.517, 0.258, 0.96, 0.8 }
local normColor = { 0.258, 0.7, 0.96, 0.8}

function Scene:new( w, h, xrange)
  local o = {}
  setmetatable( o, self)
  self.__index = self
  o.w = w
  o.h = h
  o.xrange = xrange
  o.shapes = {}
  o.x_inc = 0
  o.y_inc = 0
  o.selectShape = 0
  o.isdraged = false
  return o
end

function Scene:addShape( shape )
  shape:setColor( normColor )
  table.insert(self.shapes, 1, shape)
end

function Scene:draw()
  for i = 1, #self.shapes, 1 do
    self.shapes[i]:draw( self )
  end
end

function Scene:keypressed( key, isrepeat )
  if key == "up" then
    self.y_inc = self.y_inc + 0.03
  elseif key == "down" then
    self.y_inc = self.y_inc - 0.03
  elseif key == "left" then
    self.x_inc = self.x_inc - 0.03
  elseif key == "right" then
    self.x_inc = self.x_inc + 0.03
  end
end

function Scene:getUnitPixel()
  return self.w * (1/( self.xrange[2] - self.xrange[1] ))
end

function Scene:getUnitScene()
 return ( self.xrange[2] - self.xrange[1] )* ( 1 /self.w )
end

function Scene:screen2scene(x, y)
    -- x coordinate
    local scene_x = ( self.xrange[2] - self.xrange[1] )* ( x /self.w )
    -- y coordinate
    local scene_y 
    = (( self.h - y ) / self.w) * ( self.xrange[2] - self.xrange[1] )
    return scene_x, scene_y
end

function Scene:scene2screen(x, y)
    local screen_x 
      = x * self:getUnitPixel() 
    local screen_y 
      = self.h - y * self:getUnitPixel()
    return screen_x, screen_y
end

function Scene:mousereleased(x, y, button, istouch, presses)
  if button == 1 then
--[[
    self.isdraged = false
    local sel = self.selectShape
    self.selectShape = -1
    if sel > 1 then
      self.shapes[sel]:setColor( normColor )
    end
--]]
  end
end

function Scene:mousemoved( x, y, dx, dy, istouch )
  if not self.isdraged then
    return
  end
  local unit = self:getUnitScene()
  dx = dx * unit
  dy = dy * -unit
  self.x_inc = self.x_inc + dx
  self.y_inc = self.y_inc + dy
end

function Scene:mousepressed(x, y, button, istouch)
 local sx, sy = self:screen2scene(x, y)
 if button == 1 then 
   local area = Shape( { 
       { sx - 0.05, sx + 0.05, sx + 0.05, sx - 0.05 }
     , { sy + 0.05, sy + 0.05, sy - 0.05, sy - 0.05 } 
   } )
   local selected = -1
   self.isdraged = false
   for i = 1, #self.shapes, 1 do
     if self.shapes[i]:is_collieded( area ) then
       if self.selectShape == i then
         self.shapes[i]:setColor( normColor )
       else
         selected = i
         self.isdraged = true
         self.shapes[i]:setColor( selColor )
       end
     else
       self.shapes[i]:setColor( normColor )
     end
   end
   self.selectShape = selected
 end
end

function Scene:update(dt)
  if( self.selectShape <= 0) then
    -- initialize
    self.x_inc = 0
    self.y_inc = 0
    return
  end
  if self.x_inc == 0 and self.y_inc == 0 then
    return
  end
  local sel = self.selectShape
  self.shapes[sel]:move( self.x_inc, self.y_inc )
  for i = 1, #self.shapes, 1 do
    if i == sel then
      goto continue
    end
    local isCollied, pt = self.shapes[sel]:is_collieded( self.shapes[i] )
    if isCollied then
      self.shapes[sel]:setColor( overlapColor )
      local ortho 
        = self.shapes[sel]:resolve( self.x_inc, self.y_inc, self.shapes[i] )
      if ortho then
        -- i = i - 1
        self.x_inc = ortho[1][1]
        self.y_inc = ortho[2][1]
      end
    else
      self.shapes[sel]:setColor( selColor )
    end
    ::continue::
  end
  -- initialize
  self.x_inc = 0
  self.y_inc = 0
end

function Scene:__tostring()
  local str = ""
  str = str .. "width: " .. tostring(self.w) .. "\n"
  str = str .. "height: " .. tostring(self.h) .. "\n"
  str = str .. "x range: " .. tostring(self.xrange[1]) 
            .. " - " .. tostring(self.xrange[2]) .. "\n"
  str = str .. "number of shape: " .. tostring(#self.shapes) .. "\n"
  return str
end
