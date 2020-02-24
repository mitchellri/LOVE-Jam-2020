local base = require("chunk")
local objects = require("objects")
local terrain = setmetatable({}, {__index = base})
terrain.x = 0
terrain.world = nil
terrain.lines = {}
local perlin = require("lib/perlin")
perlin = setmetatable({}, {__index = perlin})
local flag = false

--[[ Callback ]]
function terrain:updateChunk(chunk, dt)
  self:generateVerticesAt(chunk)
  self:generateLinesAt(chunk)
end

function terrain:draw()
  local chunk = self:getChunk(self.x)
  local index, object
  local chunkIndex
  local firstChunk = math.max(chunk - self.halfDrawRange, 1)
  local lastChunk = chunk + self.halfDrawRange
  for chunkIndex = firstChunk, lastChunk do
    if self.lines[chunkIndex] ~= nil then
      for index, object in ipairs(self.lines[chunkIndex]) do
        object:draw()
      end
    end
  end
end

-- [[ Utility ]]

function terrain:generateVerticesAt(chunk)
  print("Starting vertices", chunk)
  if chunk < 1 then return end
  local x = self:getX(chunk)
  local index
  for index = x, x+self.chunkSize, self.spacing do
    self:setVertex(index, chunk)
  end
end

function terrain:setVertex(x, chunk)
  if chunk < 1 then return end
  if self[chunk] == nil then self[chunk] = {} end
  local index = self:getChunkIndex(x, chunk)
  if self[chunk][index] ~= nil then return end
  table.insert(self[chunk], index, perlin:fbm(x) * self.scale)
  print("Vertex", x, self[chunk],
    "Chunk", chunk,
    "Index", index,
    "getn", table.getn(self[chunk]))
end

function terrain:generateLinesAt(chunk)
  print("Starting lines", chunk)
  if self.world == nil then return end
  if chunk < 1 or self[chunk] == nil then return end
  local index, object
  local lastObject, lastIndex
  local from, to
  for index, object in ipairs(self[chunk]) do
    if index > 1 then
      if self.lines[chunk] == nil then self.lines[chunk] = {} end
      if self.lines[chunk][lastIndex] == nil then
        from = (lastIndex + (chunk - 1) * self.minimumVerticesPerChunk) * self.spacing - self.spacing -- Do not use minimumVerticesPerChunk
        to = (index + (chunk - 1) * self.minimumVerticesPerChunk) * self.spacing - self.spacing -- Do not use minimumVerticesPerChunk
        table.insert(self.lines[chunk], lastIndex,
          self:terrainLine(self.world, from, lastObject, to, object)
        )
        print("Line", from, to,
          "Chunk", chunk,
          "Index", lastIndex,
          "getn", table.getn(self.lines[chunk]))
      end
    end
    lastIndex = index
    lastObject = object
  end
end

--[[ Objects ]]

function terrain:terrainLine(world, x1, y1, x2, y2)
  local o = setmetatable({}, {__index = objects.baseObject()})
  local body = love.physics.newBody(world, x1, y1, "static")
  x1, y1 = body:getLocalPoint(x1, y1)
  x2, y2 = body:getLocalPoint(x2, y2)
  o.shape = love.physics.newEdgeShape(x1, y1, x2, y2)
  o.fixture = love.physics.newFixture(body, o.shape, 1)
  o.fixture:setUserData(o)

  o.color = {0.4, 1, 0.4, 1}
  function o:draw()
    local points = {}
    for _, point in ipairs({self.fixture:getBody():getWorldPoints(self.shape:getPoints())}) do
      table.insert(points, point)
    end
    if table.getn(points) >= 4 then
      love.graphics.setColor(unpack(self.color))
      love.graphics.line(unpack(points))
      love.graphics.setColor(1,1,1,1)
    end
  end

  return o
end

return terrain
