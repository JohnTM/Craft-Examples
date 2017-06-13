BlockCreator = class()

function BlockCreator:init(entity, x, y, z, ...)
    self.entity = entity
    self.r = self.entity:add(renderer, craft.mesh.cube(vec3(1,1,1), vec3(0,0,0)))
    self.r.material = craft.material("Materials:Specular")
    self.entity.position = vec3(x,y,z)
    
    local args = {...}
    for k,v in pairs(args) do
        if v == "color" then
            self.r.material.diffuse = args[k+1]
        end
    end
end
