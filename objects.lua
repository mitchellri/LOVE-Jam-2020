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
  local index, object, world
  for index, object in ipairs(self) do
    world = object.body:getWorld()
    love.graphics.circle("fill", object.body:getX(world), object.body:getY(world), object.shape:getRadius())
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

  o.body = love.physics.newBody(world, 0, 0, "dynamic")
  o.shape = love.physics.newCircleShape(10)
  o.fixture = love.physics.newFixture(o.body, o.shape, 1)

  table.insert(objects,o)

  return o
end

return objects
