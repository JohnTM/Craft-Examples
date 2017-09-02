TerrainChunk = class()

function TerrainChunk:init(entity, planet, axes)
    self.entity = entity
    self.entity.parent = planet.entity
    self.planet = planet
    self.entity.position = vec3(0,0,0)
    --self.entity.rotation = quat.lookRotation(axes[3], axes[2])
    self.axes = axes

    self.thread = coroutine.create(self.makeGridMesh)
    
    self.renderer = self.entity:add(craft.renderer)
    self.renderer.material = self.planet.material
    --self.renderer.material = craft.material("Materials:Standard")
end

function TerrainChunk:update()
    if self.thread then
        local status, result = coroutine.resume(self.thread, self)
        if result then
            self.renderer.model = result
            self.thread = nil
        end
    end
end

function TerrainChunk:makeGridMesh()
    local axes = self.axes -- {vec3(1,0,0), vec3(0,1,0), vec3(0,0,1)}
    local gs = self.planet.gridSize
    local r = self.planet.radius
    local r2 = r * math.sqrt(2) / 2
    
    local m = craft.model()
    
    m:resizeVertices((gs + 1) * (gs + 1))
    m:resizeIndices(gs * gs * 6)
    
    local positions = {}
    local normals = {}
    local colors = {}
    local white = color(255, 255, 255, 255)
    local indices = {}
    
    local padding = 2.0
    local mapSize = (256.0 + padding) * 2.0
    local inset = padding
    
    local p = vec3()
    local i = 1
    for z = 0,gs do       
        for x = 0,gs do
            
            if x % 60 == 0 then coroutine.yield() end
            
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
            
            local s = (xx+1.0)*0.5
            local t = (zz+1.0)*0.5
            
            if (s == 0 or s == 1) and t == 0 then
            end

            --s = (inset + (512) * s + 0.5) / (mapSize)
            --t = (inset + (512) * t + 0.5) / (mapSize)
            
            m:uv(i, s, t)
            
            i = i + 1
        end
    end
    
    m.positions = positions
    coroutine.yield()
    m.normals = normals
    coroutine.yield()
    m.colors = colors
    coroutine.yield()
    
    i = 1
    for z = 0,gs-1 do
        for x = 0,gs-1 do
            table.insert(indices, z*(gs+1)+x+1)                                     
            table.insert(indices, z*(gs+1)+x+2)                                     
            table.insert(indices, (z+1)*(gs+1)+x+1)                                     
            table.insert(indices, (z+1)*(gs+1)+x+1)                                     
            table.insert(indices, z*(gs+1)+x+2)   
            table.insert(indices,(z+1)*(gs+1)+x+2)  
            
            if x % 120 == 0 then coroutine.yield() end
                                                                                 
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
