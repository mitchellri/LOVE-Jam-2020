local base = require("base")
local objects = setmetatable({}, {__index = base})
local properties = {
  water = 2
}

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
  o.velocityMod = 1
  o.spawned = 0
  --[[ Callback ]]
  function o:update(dt)
    self.spawned = self.spawned + dt
    if self.velocityMod ~= 1 then self.velocityMod = 1 end
  end
  function o:draw() end
  --[[ Collision ]]
  function o:beginContact(a, b, col)
  end
  function o:endContact(a, b, col)
  end
  function o:preSolve(a, b, col)
  end
  function o:postSolve(a, b, col, normalImpulse, tangentImpulse)
  end

  return o
end

function objects:waterCircle(world, x, y)
  local o = setmetatable({}, {__index = objects.baseObject()})
  local body = love.physics.newBody(world, x, y, "dynamic")
  body:setMass(body:getMass() / 8)
  o.shape = love.physics.newCircleShape(5)
  o.fixture = love.physics.newFixture(body, o.shape, 1)
  o.fixture:setUserData(o)
  o.fixture:setMask(properties.water)

  function o:draw()
    local world, x, y
    world = self.fixture:getBody():getWorld()
    x, y = self.fixture:getBody():getWorldPoint(self.shape:getPoint(world))
    love.graphics.setColor(0,0.5,1)
    love.graphics.circle("fill", x, y, self.shape:getRadius())
    love.graphics.setColor(1,1,1)
  end

  function o:preSolve(object, col)
    local index, mask
    if object.fixture:getBody():getType() == "dynamic" then
      for index, mask in ipairs({object.fixture:getMask()}) do
        if mask == properties.water then return end
      end
      -- Non-water dynamic
      col:setEnabled(false)

      -- Manual force calculation
      local f1x, f1y, f2x, f2y
      local body
      local x, y
      local m
      local d = self.shape:getRadius() / 4
      -- Force applied by self
      body = self.fixture:getBody()
      x, y = body:getLinearVelocity()
      m = body:getMass()
      f1x = m * x * x / (2 * d)
      f1y = m * y * y / (2 * d)
      -- Force applied by object
      body = object.fixture:getBody()
      x, y = body:getLinearVelocity()
      m = body:getMass()
      f2x = m * x * x / (2 * d)
      f2y = m * y * y / (2 * d)
      -- Resulting force
      x, y = col:getNormal()
      x = x * (f2x + f1x) / love.physics.getMeter() / 3 -- not so sure
      y = y * (f2y + f1y) / love.physics.getMeter() / 3 -- not so sure
      self.fixture:getBody():applyForce(x, y)

      -- Slow object in water
      object.velocityMod = 0.75
      object.fixture:getBody():applyForce(0, -99)
    end
  end

  table.insert(objects,o)
  return o
end

function objects:circle(world)
  local o = setmetatable({}, {__index = objects.baseObject()})
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
    else
      force = 500 * self.velocityMod
      if love.keyboard.isDown("right") then self.fixture:getBody():applyForce(force, 0) end
      if love.keyboard.isDown("left") and x > 0 then self.fixture:getBody():applyForce(-force, 0) end
      if love.keyboard.isDown("up") then self.fixture:getBody():applyForce(0, -force) end
      if love.keyboard.isDown("down") then self.fixture:getBody():applyForce(0, force) end
    end
    objects:baseObject().update(self,dt)
  end
  function o:draw()
    local world = self.fixture:getBody():getWorld()
    local x, y = self.fixture:getBody():getWorldPoint(self.shape:getPoint(world))
    love.graphics.circle("fill", x, y, self.shape:getRadius())
    love.graphics.print(self.velocityMod, x, y + 40)
    love.graphics.print(x ..","..y, x, y + 20)
  end

  table.insert(objects,o)

  return o
end

return objects
