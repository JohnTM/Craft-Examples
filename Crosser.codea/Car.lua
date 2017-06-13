Car = class()

function Car:init(e, section, direction, speed)
    self.entity = e
    
    self.pivot = craft.entity()
    self.pivot.parent = self.entity
    self.pivot.rotation = quat.eulerAngles(0,0,(direction == DIRECTION_LEFT) and 90 or -90)
    
    if carMesh == nil then
        local temp = craft.entity()
        carMesh = temp:add(craft.volume, "Project:Car").mesh
        carMeshCenter = carMesh.bounds.size * 0.5
        temp:destroy()
    end
    
    self.model = craft.entity()
    self.model.parent = self.pivot
    self.model.x = -carMeshCenter.x
    self.model.z = -carMeshCenter.z 

    local mr = self.model:add(craft.renderer, carMesh)

    self.size = vec3(1.2,0.8,0.6)       
        
    self.section = section
    self.speed = speed
    self.direction = direction
    
    self.bounds = craft.bounds(vec3(), vec3())
    
    --self.box = craft.entity()
    --self.box.parent = self.entity
    --self.box:add(craft.renderer, Mesh.Cube(self.size)).material = Material("Materials:Standard")
    
    self.pivot.scale = vec3(0.1,0.1,0.1)
end

function Car:update()
    self.entity.x = self.entity.x + self.direction * self.speed * DeltaTime
    self.bounds:set(self.size, self.entity.worldPosition - self.size * 0.5)

    --craft.scene.debug:line(self.bounds.min, self.bounds.max, color(255,255,255))   
    
    if self.entity.x > ROAD_MAX_X then
        self.entity.x = ROAD_MIN_X
    elseif self.entity.x < ROAD_MIN_X then
        self.entity.x = ROAD_MAX_X
    end
end