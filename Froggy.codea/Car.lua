-------------------------------------------------------------------------------
-- Car
-- Written by John Millard
-------------------------------------------------------------------------------
-- Description:
-- A moving obstacle on road sections that can kill the player.
-------------------------------------------------------------------------------

Car = class()

function Car:init(e, section, direction, speed)
    self.entity = e
    
    self.pivot = scene:entity()
    self.pivot.parent = self.entity
    self.pivot.rotation = quat.eulerAngles(0, (direction == DIRECTION_LEFT) and 90 or -90, 0)
    
    -- Load and cache the car mesh
    if carMesh == nil then
        local temp = scene:entity()
        carMesh = temp:add(craft.volume, "Project:Car").model
        carMeshCenter = carMesh.bounds.size * 0.5
        temp:destroy()
    end
    
    self.model = scene:entity()
    self.model.parent = self.pivot
    self.model.x = -carMeshCenter.x
    self.model.z = -carMeshCenter.z 

    local mr = self.model:add(craft.renderer, carMesh)

    self.size = vec3(1.2,0.8,0.6)       
        
    self.section = section
    self.speed = speed
    self.direction = direction
    
    self.bounds = bounds(vec3(), vec3())

    self.pivot.scale = vec3(0.1,0.1,0.1)
end

function Car:update()
    -- Update the car's position based on speed and direction
    self.entity.x = self.entity.x + self.direction * self.speed * DeltaTime

    -- Update the bounds for collision
    self.bounds:set(self.size, self.entity.worldPosition - self.size * 0.5)

    -- Wrap the cars's position around when it goes off the edge of the screen
    if self.entity.x > ROAD_MAX_X then
        self.entity.x = ROAD_MIN_X
    elseif self.entity.x < ROAD_MIN_X then
        self.entity.x = ROAD_MAX_X
    end
end
