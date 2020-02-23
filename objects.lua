local base = require("base")
local objects = setmetatable({}, {__index = base})

--[[ Callback ]]
function objects:update(dt)
  local index, object
  for index, object in ipairs(self) do
    object:update(dt)
  end
end

function objects:draw()
  local index, object, world, x, y
  for index, object in ipairs(self) do
    world = object.body:getWorld()
    x, y = object.body:getWorldPoint(object.shape:getPoint(world))
    love.graphics.circle("fill", x, y, object.shape:getRadius())
    love.graphics.print(x ..","..y, x, y + 10)
  end
end

--[[ Objects ]]
function objects.baseObject()
  local o = {}
  o.destroy = false
  o.spawned = 0
  function o:update(dt)
    self.spawned = self.spawned + dt
  end
  return o
end

function objects:circle(world)
  local o = setmetatable(objects.baseObject(), {})
  function o:update(dt)
    local force = 25
    local x, y = self.body:getWorldPoint(self.shape:getPoint())
    if love.keyboard.isDown("lctrl") then
      self.body:setLinearVelocity(0,0)
      if love.keyboard.isDown("left") and x > 0 then self.body:setX(self.body:getX()-force) end
      if love.keyboard.isDown("right") then self.body:setX(self.body:getX()+force) end
      if love.keyboard.isDown("up") then self.body:setY(self.body:getY()-force) end
      if love.keyboard.isDown("down") then self.body:setY(self.body:getY()+force) end
      if love.keyboard.isDown("down") or love.keyboard.isDown("up") or love.keyboard.isDown("left") or love.keyboard.isDown("right") then
        --print("Positioned at",self.body:getX(), self.body:getY())
      end
    else
      if love.keyboard.isDown("right") then self.body:applyForce(force, 0) end
      if love.keyboard.isDown("left") and x > 0 then self.body:applyForce(-force, 0) end
      if love.keyboard.isDown("up") then self.body:applyForce(0, -force) end
      if love.keyboard.isDown("down") then self.body:applyForce(0, force) end
    end
  end
  o.body = love.physics.newBody(world, 0, 0, "dynamic")
  o.shape = love.physics.newCircleShape(10)
  o.fixture = love.physics.newFixture(o.body, o.shape, 1)

  table.insert(objects,o)

  return o
end

return objects
