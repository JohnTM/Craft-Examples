---------------------------------------------------------
-- **** Platform ****
-- A single platform component, attach to an entity
---------------------------------------------------------

Platform = class()

function Platform:init(e, position, size, col, moving, direction, distance)
    self.entity = e
    self.size = vec3(size:unpack())

    -- Setup renderer using cube mesh and specular material for basic shading
    self.r = self.entity:add(craft.renderer, craft.mesh.cube(self.size))
    self.r.material = craft.material("Materials:Specular")
    self.r.material.diffuse = col
    
    -- Setup initial state, movement direction, position, etc...
    self.entity.position = position
    self.initial = position
    self.moving = moving
    self.direction = direction
    self.direction2 = (self.direction == 1) and 3 or 1
    self.distance = distance
    self.time = 0
    self.effectTime = 0
end

function Platform:update()
    -- Side-to-side motion using a sine wave
    if self.moving then
        self.time = self.time + DeltaTime * 0.5 
        self.entity.position = self.initial + axes[self.direction] * (self.distance * (math.cos(self.time) * 0.5 + 0.5))
    end
    
    -- Update combo effect (grow and fade via lerp)
    if self.effect and self.effectTime < 1 then
        self.effect.scale = lerp(self.size, vec3(self.size.x+1,0,self.size.z+1), self.effectTime)
        self.effectRenderer.material.opacity = lerp(1,0,self.effectTime)
    end
end

-- Return the 1D interval im the direction this platform is moving (min, max)
function Platform:bounds(dir)
    return self.entity.position[dir] - self.size[dir] / 2,
           self.entity.position[dir] + self.size[dir] / 2   
end

function Platform:spawnComboEffect()
    self.effect = scene:entity()
    self.effectRenderer = self.effect:add(craft.renderer)
    local m = craft.mesh.cube(vec3(1, 0, 1))
    self.effectRenderer.mesh = m
    
    self.effectRenderer.material = comboEffectMaterial
    
    self.effect.position = self.entity.position - vec3(0,0.5,0)
    tween(1, self, {effectTime = 1.0}, tween.easing.cubicOut, function()
        self.effect:destroy()
        self.effect = nil
        self.effectRenderer = nil
    end)
end

-- Drop platform and perform splitting if needed
function Platform:drop(previous)
    self.moving = false
    
    local min1, max1 = self:bounds(self.direction)
    local min2, max2 = previous:bounds(self.direction)
    
    local diff = previous.entity.position[self.direction] - self.entity.position[self.direction]
    
    if math.abs(diff) < PERFECT_THRESHOLD then
        self.entity.position = previous.entity.position + vec3(0,1,0) -- perfect
        return true, true
    else
        local a = math.min(max1, max2)
        local b = math.max(min1, min2)
        local overlap = math.max(0, a - b)
        
        
        if overlap == 0 then
            self.entity:add(craft.rigidbody, DYNAMIC)
            self.entity:add(craft.shape.box, self.size)           
            return false, false
        end 
        
        local length1 = overlap
        local length2 = (max1 - min1) - overlap
        
        local newPos = vec3()
        newPos[self.direction] = (a+b) * 0.5
        newPos[self.direction2] = self.entity.position[self.direction2]       
        newPos.y = self.entity.y
        
        self.entity.position = newPos
        self.size[self.direction] = length1
        self.r.mesh = craft.mesh.cube(self.size)
        
        local angVel = vec3()

        if min1 > min2 then
            newPos[self.direction] = a + length2 * 0.5 
            angVel[self.direction2] = -90       
        else
            newPos[self.direction] = b - length2 * 0.5 
            angVel[self.direction2] = 90        
        end
        
        if self.direction == Z then
            angVel[self.direction2] = -angVel[self.direction2]
        end
        
        newPos[self.direction2] = self.entity.position[self.direction2]       
        newPos.y = newPos.y
        
        local newSize = vec3(self.size:unpack())
        newSize[self.direction] = length2
        
        local chip = scene:entity()
        chip.position = newPos
        local r = chip:add(craft.renderer, craft.mesh.cube(newSize))
        r.material = self.r.material

        local rb = chip:add(craft.rigidbody, DYNAMIC)
        rb.angularVelocity = angVel
        chip:add(craft.shape.box, newSize)        
    end
    
    self.entity:add(craft.rigidbody, STATIC)
    self.entity:add(craft.shape.box, self.size)           
    
    return true, false
    
end