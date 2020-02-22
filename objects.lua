local objects = {}

-- Callback

function objects:update(dt)
  for index, object in ipairs(objects) do
    object:update(dt)
  end
end

function objects:draw()
  for index, object in ipairs(objects) do
    love.graphics.circle("fill", object.body:getX(world), object.body:getY(), object.shape:getRadius())
  end
end

-- Objects

function objects.baseObject()
  local o = {}
  function o:update(dt)

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
