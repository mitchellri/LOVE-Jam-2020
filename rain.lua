local base = require("chunk")
local rain = setmetatable({}, {__index = base})
rain.x = 0
rain.world = nil
rain.spacing = rain.chunkSize + 1
rain.maxRainChance = 0.2
local terrain = require("terrain")
local objects = require("objects")
local perlin = require("lib/perlin")
perlin = setmetatable({}, {__index = perlin})

--[[ Callback ]]
function rain:generateChunk(chunk, dt)
  print("Starting rain", chunk)
  self:generateAt(chunk)
end

function rain:updateChunk(chunk, dt)
  local x = self:getX(chunk)
  local index, object
  local rainSpot, rainChance
  for index, object in ipairs(self[chunk]) do
    rainChance = love.math.random(1, 10) / 10
    if rainChance < self[chunk][index] then
      rainSpot = love.math.random(x + (index - 1) * self.spacing, x + index * self.spacing)
      objects:waterCircle(self.world, rainSpot, -500)
    end
  end
end

function rain:draw()

end

--[[ Utility ]]

function rain:generateAt(chunk)
  local x = self:getX(chunk)
  local index
  for index = x, x+self.chunkSize, self.spacing do
    self:setVertex(index, chunk)
  end
end

function rain:setVertex(x, chunk)
  if chunk < 1 then return end
  if self[chunk] == nil then self[chunk] = {} end
  local index = self:getChunkIndex(x, chunk)
  if self[chunk][index] ~= nil then return end
  table.insert(self[chunk], index, (perlin:fbm(x) % self.maxRainChance))
  print("RainChance", "Chunk", chunk, "Chance", self[chunk][index])
end

return rain
