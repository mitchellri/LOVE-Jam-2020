-- LIBRARIES
local objects = require("objects")
local world

-- LOVE
function love.load()
  world = love.physics.newWorld(0, 9.81 * 64, true)
end

function love.update(dt)
  world:update(dt)
  objects:update(dt)
end

function love.draw()
  objects:draw()
end
