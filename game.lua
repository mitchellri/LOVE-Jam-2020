local base = require("base")
local game = setmetatable({}, {__index = base})
game.objects = require("objects")
game.terrain = require("terrain")
game.rain = require("rain")
game.world = love.physics.newWorld(0, 9.81 * 64, true)
require('lib/camera')

--[[ Callback ]]
function game:load()
  local index, object
  for index, object in pairs(self) do
    if type(object) == "table" then
      object:load()
    end
  end
  self.world:setCallbacks(self.beginContact, self.endContact, self.preSolve, self.postSolve)--
  self.objects:circle(self.world)
  self.terrain.x = self.objects[1].fixture:getBody():getWorldPoint(self.objects[1].shape:getPoint())
  self.terrain.world = self.world
  self.rain.world = self.world
end

function game:update(dt)
  local index, object
  for index, object in pairs(self) do
    if type(object) ~= "function" then
      object:update(dt)
    end
  end
  self.terrain.x = self.objects[1].fixture:getBody():getWorldPoint(self.objects[1].shape:getPoint())
  self.rain.x = self.objects[1].fixture:getBody():getWorldPoint(self.objects[1].shape:getPoint())
  camera:follow(self.objects[1].fixture:getBody(), dt)
end

function game:draw()
  camera:set()
  local index, object
  for index, object in pairs(self) do
    if type(object) == "table" then
      object:draw()
    end
  end
  camera:unset()
end

function game:mousepressed(x, y, button, isTouch, presses)
  local index, object
  x, y = camera:screenToLocal(x, y)
  print("Click", x, y)
  for index, object in pairs(self) do
    if type(object) == "table" then
      object:mousepressed(x, y, button, isTouch, presses)
    end
  end
  if (button == 1) then
    self.objects:waterCircle(self.world, x, y)
  end
end

--[[ Collision ]]
function game.beginContact(a, b, col)
  a = a:getUserData()
  b = b:getUserData()
  a:beginContact(b, col)
  b:beginContact(a, col)
end
function game.endContact(a, b, col)
  a = a:getUserData()
  b = b:getUserData()
  a:endContact(b, col)
  b:endContact(a, col)
end
function game.preSolve(a, b, col)
  a = a:getUserData()
  b = b:getUserData()
  a:preSolve(b, col)
  b:preSolve(a, col)
end
function game.postSolve(a, b, col, normalImpulse, tangentImpulse)
  a = a:getUserData()
  b = b:getUserData()
  a:postSolve(b, col, normalImpulse, tangentImpulse)
  b:postSolve(a, col, normalImpulse, tangentImpulse)
end

return game
