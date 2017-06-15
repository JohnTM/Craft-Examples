Tree = class()

function Tree:init(e)
    self.entity = e

    if treeMesh == nil then
        local temp = scene:entity()
        treeMesh = temp:add(craft.volume, "Project:Tree").mesh
        temp:destroy()
    end
       
    self.model = scene:entity()
    self.mr = self.model:add(craft.renderer, treeMesh)
    self.model.parent = self.entity
    
    self.model.scale = vec3(0.15, 0.15, 0.15)
    self.model.x = -treeMesh.bounds.center.x * 0.15
    self.model.z = -treeMesh.bounds.center.z * 0.15
end
