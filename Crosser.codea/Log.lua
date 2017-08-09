-------------------------------------------------------------------------------
-- Log
-- Written by John Millard
-------------------------------------------------------------------------------
-- Description:
-- A variable length log that the player can jump on to cross rivers.
--------------------------------------------------------------------------------

Log = class()

function Log:init(e, length, direction, speed)
    self.entity = e
    
    -- Load and cache the log mesh
    if logMesh == nil then
        local temp = scene:entity()
        logMesh = temp:add(craft.volume, "Project:Log").model
        logMeshCenter = logMesh.bounds.size * 0.5
        logScale = 1.0 / logMesh.bounds.size.x
        temp:destroy()
    end
    
    self.direction = direction
    self.speed = speed
    self.length = length
    self.parts = {}
    self.bounds = bounds(vec3(), vec3())
    
    for i = 1,length do
        self:addPart()
    end
    
end

function Log:addPart()
    local part = {} 
    part.pivot = scene:entity()
    
    part.pivot.parent = self.entity
    part.pivot.rotation = quat.eulerAngles(0,0,90)
    part.pivot.scale = vec3(logScale * 0.5, logScale * 0.5, logScale)
        
    part.model = scene:entity()
    part.model.parent = part.pivot
    part.model.x = -logMeshCenter.x
    part.model.z = -logMeshCenter.z 

    local mr = part.model:add(craft.renderer, logMesh)
    
    part.pivot.x = #self.parts * (logMesh.bounds.size.x * logScale)
    
    table.insert(self.parts, part) 
end

function Log:update()
    -- Move the log based on direction and speed
    self.entity.x = self.entity.x + self.direction * self.speed * DeltaTime

    -- Update the bounds of the log for collision checks
    self.bounds:set(vec3(self.length, 1,1), self.entity.worldPosition - vec3(0.5,0.5,0.5))
        
    -- Wrap the log's position around when it goes off the edge of the screen
    if self.entity.x > ROAD_MAX_X then
        self.entity.x = (self.entity.x - ROAD_MAX_X) + ROAD_MIN_X
    elseif self.entity.x < ROAD_MIN_X then
        self.entity.x = (self.entity.x - ROAD_MIN_X) + ROAD_MAX_X
    end
end

