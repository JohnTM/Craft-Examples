Plane = class()

function Plane:init(entity, anchor, map)
    self.entity = entity
    self.entity.model = craft.model.plane(vec2(1,1))
    self.entity:get(craft.renderer).mask = 1<<2
    
    local mat = craft.material("Materials:Basic")
    mat.map = map
    mat.blendMode = NORMAL
    mat.diffuse = color(120, 200, 255)
    self.entity.material = mat
    
    -- Collisions   
    self.entity:add(craft.rigidbody, STATIC)
    self.entity:add(craft.shape.box, 
        vec3(1,0.1,1), vec3(0,-0.05,0))
    
    self:updateWithAnchor(anchor, true)
end

function Plane:updateWithAnchor(anchor, s)
    self.entity.position = anchor.position
    self.entity.scale = anchor.extent + vec3(0,1,0)
    self.entity.rotation = anchor.rotation 
    self.entity.material.offsetRepeat = 
        vec4(0,0,anchor.extent.x, anchor.extent.z)   
end
