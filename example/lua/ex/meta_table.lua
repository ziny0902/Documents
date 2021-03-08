function Vec2(x, y) end
local vec2_meta = {
  __add = function(a, b)
    return Vec2(
    a.x + b.x,
    a.y + b.y
    )
  end,
  __sub = function(a, b)
    return Vec2(
    a.x - b.x,
    a.y - b.y
    )
  end,

  __call = function(self)
    print("(" .. self.x .. ", " .. self.y ..")")
  end, 

  __tostring = function(self)
    return ("(" .. self.x .. ", " .. self.y ..")")
  end

}

function Vec2(x, y)
  local v = {
    x = x or 0,
    y = y or 0
  }

  return setmetatable(v, vec2_meta)
end

local a = Vec2(10, 2)
local b = Vec2(23, 1)
local c = Vec2(0, 0)

c = a + b
print(c.x, c.y)

c = a - b
print(c.x, c.y)

a()
b()
c()
print(c)

local myTable_meta= {
  -- 동작 되는지 확인 필요.
  __index = function (self, index)
    print(index)
  end,
  __newindex = function (self, index)
    print(index)
  end
}

local myTable = {10, 20, 30}
setmetatable(myTable, myTable_meta)
myTable[4] = "hello"
myTable[2] = 2

function const(tab)
  local meta_table = {
    __index = function(self, key)
      if tab[key] == nil then
        error("Access violation")
      else 
        return tab[key]
      end
    end,

    __newindex = function(self, key, value)
        error("Attempted to modify const table: " .. key .. " ".. value)
    end
  }
  return setmetatable({}, meta_table)
end

local Constant = const{
  GRAVITY = 200,
  PLAYER_SPEED = 100
}


--Constant.GRAVITY = 10
local vy = Constant.PLAYER_SPEED
