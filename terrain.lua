local base = require("base")
local objects = require("objects")
local terrain = setmetatable({}, {__index = base})
terrain.x = 0
terrain.world = nil
terrain.chunkSize = 1000 -- Do not change after startup
terrain.spacing = 10 -- Do not change after startup
terrain.scale = 25 -- Do not change after startup
terrain.halfDrawRange = 2
terrain.minimumVerticesPerChunk = terrain.chunkSize / terrain.spacing
terrain.lines = {}
local perlin = require("lib/perlin")
local lastDrawChunk = nil
local lastUpdateChunk = nil
local flag = false

--[[ Callback ]]
function terrain:update()
 local chunk = self:getChunk(self.x)

 if lastUpdateChunk ~= chunk then -- Debug
   print("Update chunk changed", lastUpdateChunk, chunk)
 end

 local chunkIndex
 for chunkIndex = chunk - self.halfDrawRange, chunk + self.halfDrawRange do
   if self[chunkIndex] == nil and chunkIndex > 0 then
     self:generateVerticesAt(chunkIndex)
     self:generateLinesAt(chunkIndex)

     if lastUpdateChunk == chunk and not flag then -- Debug
       print("Chunk update failed and repeating", chunkIndex)
     end
   end
 end

 if lastUpdateChunk == chunk then flag = true end -- Debug

 lastUpdateChunk = chunk
end

function terrain:draw()
  local chunk = self:getChunk(self.x)

  if lastDrawChunk ~= chunk then -- Debug
    print("Draw chunk changed", lastDrawChunk, chunk)
  end

  local index, object, point, _
  local chunkIndex
  local firstChunk = math.max(chunk - self.halfDrawRange, 1)
  local lastChunk = chunk + self.halfDrawRange
  local points = {}
  for chunkIndex = firstChunk, lastChunk do
    if self.lines[chunkIndex] ~= nil then
      for index, object in ipairs(self.lines[chunkIndex]) do
        if index == 1 then -- Debug
          love.graphics.setColor(1, 0, 0)
        else
          love.graphics.setColor(0.5, 0.5, 0.5)
        end
        love.graphics.line(object.fixture:getBody():getX(), object.fixture:getBody():getY(), object.fixture:getBody():getX(), -500)
        love.graphics.setColor(1, 1, 1)

        object:draw()
      end
    elseif lastDrawChunk ~= chunk then -- Debug
      print("Cannot draw nil chunk", chunk)
    end
  end

  lastDrawChunk = chunk -- Debug
end

--[[ Utility ]]
function terrain:getX(chunk)
  return (chunk - 1)  * self.chunkSize
end

function terrain:getChunk(x)
  return math.floor(x / (self.chunkSize)) + 1
end

function terrain:generateVerticesAt(chunk)
  print("Starting vertices", chunk)

  if chunk < 1 then -- Debug
    print("Invalid chunk location")
    return
  end

  local x = self:getX(chunk)
  local index
  for index = x, x+self.chunkSize, self.spacing do
    self:setVertex(index, chunk)
  end
end

function terrain:setVertex(x, chunk)
  if chunk < 1 then -- Debug
    print("Invalid chunk location")
    return
  end

  if self[chunk] == nil then self[chunk] = {} end
  local index = (x - self.chunkSize * (chunk - 1)) / self.spacing + 1
  if self[chunk][index] ~= nil then return end
  table.insert(self[chunk], index, perlin:fbm(x) * self.scale)
  print("Vertex", x,
    "Chunk", chunk,
    "Index", index,
    "getn", table.getn(self[chunk]))
end

function terrain:generateLinesAt(chunk)
  print("Starting lines", chunk)
  if self.world == nil then
    print("No world")
    return
  end
  if chunk < 1 or self[chunk] == nil then
    print("Invalid chunk")
    return
  end
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
      else
        print("Exists", self.lines[chunk][lastIndex], chunk, lastIndex)
      end
    end
    lastIndex = index
    lastObject = object
  end
end

function terrain:terrainLine(world, x1, y1, x2, y2)
  local o = setmetatable({}, {__index = objects.baseObject()})
  local body = love.physics.newBody(world, x1, y1, "static")
  x1, y1 = body:getLocalPoint(x1, y1)
  x2, y2 = body:getLocalPoint(x2, y2)
  o.shape = love.physics.newEdgeShape(x1, y1, x2, y2)
  o.fixture = love.physics.newFixture(body, o.shape, 1)
  o.fixture:setUserData(o)

  function o:draw()
    local points = {}
    for _, point in ipairs({self.fixture:getBody():getWorldPoints(self.shape:getPoints())}) do
      table.insert(points, point)
    end
    if table.getn(points) >= 4 then
      love.graphics.line(unpack(points))
    end
  end

  return o
end

return terrain
