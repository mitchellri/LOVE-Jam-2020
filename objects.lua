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
  local index, object
  for index, object in ipairs(self) do
    object:draw()
  end
end

--[[ Objects ]]
function objects.baseObject()
  local o = {}
  o.destroy = false
  o.spawned = 0
  --[[ Callback ]]
  function o:update(dt)
    self.spawned = self.spawned + dt
  end
  function o:draw() end
  --[[ Collision ]]
  function beginContact(a, b, col)
  end
  function endContact(a, b, col)
  end
  function preSolve(a, b, col)
  end
  function postSolve(a, b, col, normalImpulse, tangentImpulse)
  end

  return o
end

function objects:waterCircle(world, x, y)
  local o = objects.baseObject()
  local body = love.physics.newBody(world, x, y, "dynamic")
  body:setMass(body:getMass() / 8)
  o.shape = love.physics.newCircleShape(5)
  o.fixture = love.physics.newFixture(body, o.shape, 1)
  o.fixture:setUserData(o)

  function o:draw()
    local world, x, y
    world = self.fixture:getBody():getWorld()
    x, y = self.fixture:getBody():getWorldPoint(self.shape:getPoint(world))
    love.graphics.setColor(0,0.5,1)
    love.graphics.circle("fill", x, y, self.shape:getRadius())
    love.graphics.setColor(1,1,1)
  end

  function beginContact(object, col)
    print("Collide")
  end

  table.insert(objects,o)

  return o
end

function objects:circle(world)
  local o = objects.baseObject()
  local body = love.physics.newBody(world, 0, 0, "dynamic")
  o.shape = love.physics.newCircleShape(10)
  o.fixture = love.physics.newFixture(body, o.shape, 0)
  o.fixture:setUserData(o)

  function o:update(dt)
    local force
    local x, y = self.fixture:getBody():getWorldPoint(self.shape:getPoint())
    if love.keyboard.isDown("lctrl") then
      force = 25
      self.fixture:getBody():setLinearVelocity(0,0)
      if love.keyboard.isDown("left") and x > 0 then self.fixture:getBody():setX(self.fixture:getBody():getX()-force) end
      if love.keyboard.isDown("right") then self.fixture:getBody():setX(self.fixture:getBody():getX()+force) end
      if love.keyboard.isDown("up") then self.fixture:getBody():setY(self.fixture:getBody():getY()-force) end
      if love.keyboard.isDown("down") then self.fixture:getBody():setY(self.fixture:getBody():getY()+force) end
      if love.keyboard.isDown("down") or love.keyboard.isDown("up") or love.keyboard.isDown("left") or love.keyboard.isDown("right") then
        --print("Positioned at",self.fixture:getBody():getX(), self.fixture:getBody():getY())
      end
    else
      force = 500
      if love.keyboard.isDown("right") then self.fixture:getBody():applyForce(force, 0) end
      if love.keyboard.isDown("left") and x > 0 then self.fixture:getBody():applyForce(-force, 0) end
      if love.keyboard.isDown("up") then self.fixture:getBody():applyForce(0, -force) end
      if love.keyboard.isDown("down") then self.fixture:getBody():applyForce(0, force) end
    end
  end
  function o:draw()
    local world = self.fixture:getBody():getWorld()
    local x, y = self.fixture:getBody():getWorldPoint(self.shape:getPoint(world))
    love.graphics.circle("fill", x, y, self.shape:getRadius())
    love.graphics.print(x ..","..y, x, y + 10)
  end

  table.insert(objects,o)

  return o
end

return objects
