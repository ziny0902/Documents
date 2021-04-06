require "scene"
require "shape"
require "circle"

local scene

function love.keypressed( key, isrepeat )
  scene:keypressed( key, isrepeat )
end

local function loadShape()
  local shape = Shape( {{ 1.0, 2.0, 3.0 }, { 1.0, 3.0, 2.0 }} )
  scene:addShape( shape )
  shape = Shape( {{ 5.0, 6.5, 8.0 }, { 3.0, 6.0, 3.0 }} )
  scene:addShape( shape )
  shape = Circle( {{ 5.0 }, { 1.0 }}, 0.5 )
  scene:addShape( shape )
  shape = Circle( {{ 7.0 }, { 2.0 }}, 0.5 )
  scene:addShape( shape )
  shape = Shape( {
      { 3.0, 5.0, 5.0, 3.0 }
    , { 8.0, 8.0, 7.0, 6.0 }
  } )
  scene:addShape( shape )
end

function love.mousepressed(x, y, button, istouch)
  scene:mousepressed( x, y, button, istouch )
end

function love.mousereleased(x, y, button, istouch, presses)
  scene:mousereleased( x, y, button, istouch )
end

function love.mousemoved( x, y, dx, dy, istouch )
  scene:mousemoved(x, y, dx, dy, istouch)
end

function love.load()
  --scene = { w, h, xrange }
  scene = Scene( 800, 600, {0, 10} )
  loadShape()
  love.keyboard.setKeyRepeat( true )
end

function love.update(dt)
  scene:update(dt)
end

function love.draw()
  scene:draw()
end
