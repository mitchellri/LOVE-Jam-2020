local base = require("base")
local game = setmetatable({}, {__index = base})
game.objects = require("objects")
game.world = love.physics.newWorld(0, 9.81 * 64, true)

--[[ Callback ]]
function game:load()
  local index, object
  for index, object in pairs(self) do
    if type(object) == "table" then
      object:load()
    end
  end
  game.objects:circle(game.world)
end

function game:update(dt)
  local index, object
  for index, object in pairs(self) do
    if type(object) ~= "function" then
      object:update(dt)
    end
  end
end

function game:draw()
  local index, object
  for index, object in pairs(self) do
    if type(object) == "table" then
      object:draw()
    end
  end
end

return game
