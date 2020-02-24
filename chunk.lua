local base = require("base")
local chunk = setmetatable({}, {__index = base})
chunk.x = 0
chunk.chunkSize = 1000 -- Do not change after startup
chunk.spacing = 25 -- Do not change after startup
chunk.minimumVerticesPerChunk = chunk.chunkSize / chunk.spacing
chunk.halfDrawRange = 2
chunk.scale = 25

--[[ Callback ]]
function chunk:update(dt)
 local chunk = self:getChunk(self.x)

 local chunkIndex
 for chunkIndex = chunk - self.halfDrawRange, chunk + self.halfDrawRange do
   if self[chunkIndex] == nil and chunkIndex > 0 then
     self:updateChunk(chunkIndex, dt)
   end
 end
end

--[[ Utility ]]
function chunk:getX(chunk)
  return (chunk - 1)  * self.chunkSize
end

function chunk:getChunk(x)
  return math.floor(x / (self.chunkSize)) + 1
end

function chunk:getChunkIndex(x, chunk)
  return (x - self.chunkSize * (chunk - 1)) / self.spacing + 1
end

function chunk:updateChunk(dt) end

return chunk
