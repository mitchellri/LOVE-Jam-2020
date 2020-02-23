local base = require("base")
local game = setmetatable({}, {__index = base})
game.objects = require("objects")
game.terrain = require("terrain")
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
  game.objects:circle(game.world)
  game.terrain.x = game.objects[1].body:getWorldPoint(game.objects[1].shape:getPoint())
  game.terrain.world = game.world
end

function game:update(dt)
  local index, object
  for index, object in pairs(self) do
    if type(object) ~= "function" then
      object:update(dt)
    end
  end
  game.terrain.x = game.objects[1].body:getWorldPoint(game.objects[1].shape:getPoint())
  camera:follow(game.objects[1].body, dt)
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

return game
