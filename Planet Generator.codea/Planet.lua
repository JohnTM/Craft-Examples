Planet = class()

function Planet:init(entity, radius, gridSize, maxLod, atmos)
    self.entity = entity
    self.radius = radius
    self.gridSize = gridSize
    self.maxLod = maxLod
    
    self.material = craft.material("Project:StandardSphere")
    self.material.roughness = 0.7
    --self.material.roughnessMap = self.roughnessMap
    
    
    self.chunks = 
    {
        -- Top
        scene:entity():add(TerrainChunk, self, {vec3(1,0,0), vec3(0,1,0), vec3(0,0,1)}),
        -- Left
        scene:entity():add(TerrainChunk, self, {vec3(0,0,1), vec3(1,0,0), vec3(0,1,0)}),        
        -- Right
        scene:entity():add(TerrainChunk, self, {vec3(0,0,1), vec3(-1,0,0), vec3(0,-1,0)}),
        -- Bottom
        scene:entity():add(TerrainChunk, self, {vec3(-1,0,0), vec3(0,-1,0), vec3(0,0,1)}),
        -- Front
        scene:entity():add(TerrainChunk, self, {vec3(1,0,0), vec3(0,0,1), vec3(0,-1,0)}),        
        -- Back
        scene:entity():add(TerrainChunk, self, {vec3(1,0,0), vec3(0,0,-1), vec3(0,1,0)}),
    }
    
    
    self.oceanEntity = scene:entity()
    self.oceanEntity.parent = entity
    self.ocean = self.oceanEntity:add(craft.renderer, craft.mesh.icosphere(1.0, 4, false))
    local s = self.radius + 10
    self.oceanEntity.scale = vec3(s,s,s)
    self.ocean.material = craft.material("Materials:Standard")
    self.ocean.material.blendMode = NORMAL
    self.ocean.material.opacity = 0.8
    self.ocean.material.roughness = 0.45
    self.ocean.material.diffuse = color(23, 132, 171, 255)  
    self.oceanEntity.active = false
  
    if atmos then
        local atmosEntity = scene:entity()
        atmosEntity.parent = entity  
        self.atmos = atmosEntity:add(craft.renderer, craft.mesh.icosphere(-self.radius -100, 3, false))
        self.atmos.material = craft.material("Project:Basic")
        self.atmos.material.blendMode = ADDITIVE
        self.atmos.material.opacity = 0.5
        self.atmos.material.diffuse = color(0, 163, 255, 255)    
    end
end

function Planet:readMaps(gen)
    self.material.map = gen.map
    self.material.displacementMap = gen.heightMap
    self.material.displacementScale = Displacement
    self.material.normalMap = gen.normalMap
end


function Planet:update()
    self.material.displacementScale = Displacement * self.radius
end

function Planet:generate(gen, options)
    self.entity.active = false
    gen:generate(Seed, options)
    self.entity.active = true
    
    self:readMaps(gen)   
    
    if options.ocean.active then
        self.oceanEntity.active = true
        local s = self.radius + options.ocean.depth
        self.oceanEntity.scale = vec3(s,s,s)
        self.ocean.material.opacity = options.ocean.opacity
        self.ocean.material.diffuse = options.ocean.color 
    else
        self.oceanEntity.active = false
    end
end
