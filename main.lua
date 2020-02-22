local time = 0

--[[ Components ]]
local main = {}
main.game = require("game")

--[[ Callback ]]
function love.load()
  local index, object
  for index, object in pairs(main) do
    if type(object) == "table" then
      object:load()
    end
  end
end

function love.update(dt)
  local index, object
  time = time + dt
  for index, object in pairs(main) do
    if type(object) ~= "function" then
      object:update(dt)
    end
  end
end

function love.draw()
  local index, object
  for index, object in pairs(main) do
    if type(object) == "table" then
      object:draw()
    end
  end
end
