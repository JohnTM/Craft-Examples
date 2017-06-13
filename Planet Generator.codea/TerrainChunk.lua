TerrainChunk = class()

function TerrainChunk:init(entity, planet, axes)
    self.entity = entity
    self.entity.parent = planet.entity
    self.planet = planet
    self.entity.position = vec3(0,0,0)
    --self.entity.rotation = quat.lookRotation(axes[3], axes[2])
    self.axes = axes

    self.mesh = self:makeGridMesh()  
    self.renderer = self.entity:add(craft.renderer, self.mesh)
    self.renderer.material = self.planet.material

end

function TerrainChunk:makeGridMesh()
    local axes = self.axes -- {vec3(1,0,0), vec3(0,1,0), vec3(0,0,1)}
    local gs = self.planet.gridSize
    local r = self.planet.radius
    local r2 = r * math.sqrt(2) / 2
    
    local m = craft.mesh()
    
    m:resizeVertices((gs + 1) * (gs + 1))
    m:resizeIndices(gs * gs * 6)
    
    local positions = {}
    local normals = {}
    local colors = {}
    local white = color(255, 255, 255, 255)
    local indices = {}
    
    
    local p = vec3()
    local i = 1
    for z = 0,gs do
        for x = 0,gs do
            
            local xx = (((x+0.0) / gs) * 2.0 - 1.0)
            local zz = (((z+0.0) / gs) * 2.0 - 1.0)
                   
            p:set(0,0,0)
            p:add(axes[1] * (xx * r2))
            p:add(axes[2] * r2)
            p:add(axes[3] * (zz * r2))
            p = p:normalize()
        
            table.insert(normals, vec3(p:unpack()))
            table.insert(positions, p*r)
            table.insert(colors, white)           
            
            --m:position(i, p*r)
            --m:normal(i, p:normalize())
            --m:color(i, 255, 255, 255, 255)
            
            --m:uv(i, (xx+1.0)*0.5, (zz+1.0)*0.5)
            
            i = i + 1
        end
    end
    
    m.positions = positions
    m.normals = normals
    m.colors = colors
    
    i = 1
    for z = 0,gs-1 do
        for x = 0,gs-1 do
            table.insert(indices, z*(gs+1)+x+1)                                     
            table.insert(indices, z*(gs+1)+x+2)                                     
            table.insert(indices, (z+1)*(gs+1)+x+1)                                     
            table.insert(indices, (z+1)*(gs+1)+x+1)                                     
            table.insert(indices, z*(gs+1)+x+2)   
            table.insert(indices,(z+1)*(gs+1)+x+2)  
                                                                                 
            --[[m:index(i, z*(gs+1)+x+1)    
            m:index(i+1, z*(gs+1)+x+2)                  
            m:index(i+2, (z+1)*(gs+1)+x+1) 
            m:index(i+3, (z+1)*(gs+1)+x+1)  
            m:index(i+4, z*(gs+1)+x+2)                  
            m:index(i+5, (z+1)*(gs+1)+x+2)]]  
            i = i + 6
        end
    end
    
    m.indices = indices
    
    return m
end
