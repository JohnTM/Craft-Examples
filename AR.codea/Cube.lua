Cube = class()

function Cube:init(entity, position, size)
    self.entity = entity
    self.entity.model = craft.model.cube(vec3(size, size, size))
    self.entity.material = craft.material("Materials:Standard") 
    self.entity.position = position
    self.entity:add(craft.rigidbody, DYNAMIC, 1)
    self.entity:add(craft.shape.box, vec3(size, size, size))
end
