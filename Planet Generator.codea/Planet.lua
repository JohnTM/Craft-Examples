Planet = class()

function Planet:init(entity, radius, gridSize, maxLod, atmos)
    -- The entity this planet component is being attached to
    self.entity = entity
    -- The radius of the planet
    self.radius = radius
    -- The detail of each grid that makes up the 6 faces of the planet
    self.gridSize = gridSize
    -- The maximum levels of detail for this planet (unused)
    self.maxLod = maxLod
    
    self.material = craft.material("Project:StandardSphere")
    self.material.roughness = 0.7
    
    -- The top level chunks of the planet, one for each of the 6 faces
    self.chunks = 
    {
        -- Right
        scene:entity():add(TerrainChunk, self, {vec3(0,0,-1), vec3(1,0,0), vec3(0,-1,0)}),        
        -- Left
        scene:entity():add(TerrainChunk, self, {vec3(0,0,1), vec3(-1,0,0), vec3(0,-1,0)}),
        -- Top
        scene:entity():add(TerrainChunk, self, {vec3(1,0,0), vec3(0,1,0), vec3(0,0,1)}),
        -- Bottom
        scene:entity():add(TerrainChunk, self, {vec3(1,0,0), vec3(0,-1,0), vec3(0,0,-1)}),
        -- Front
        scene:entity():add(TerrainChunk, self, {vec3(1,0,0), vec3(0,0,1), vec3(0,-1,0)}),        
        -- Back
        scene:entity():add(TerrainChunk, self, {vec3(-1,0,0), vec3(0,0,-1), vec3(0,-1,0)}),
    }
    
    -- The ocean, rendered using a transparent icosphere
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
  
    -- The atmosphere, rendered using an inside-out icosphere with a special material
    if atmos then
        local atmosEntity = scene:entity()
        atmosEntity.parent = entity  
        self.atmos = atmosEntity:add(craft.renderer, craft.mesh.icosphere(-self.radius -100, 3, false))
        self.atmos.material = craft.material("Project:Atmosphere")
        self.atmos.material.blendMode = ADDITIVE
        self.atmos.material.opacity = 0.5
        self.atmos.material.diffuse = color(0, 163, 255, 255)    
    end
end

-- Takes in the maps from a generator and applies them to the planet's material
function Planet:readMaps(gen)
    self.material.map = gen.map
    self.material.displacementMap = gen.heightMap
    self.material.displacementScale = Displacement
    self.material.normalMap = gen.normalMap
    
    --[[
    for i = 1,6 do
        self.chunks[i].renderer.material.map = gen.heightMaps[i] 
        self.chunks[i].renderer.material.displacementMap = gen.heightMaps[i] 
        self.chunks[i].renderer.material.normalMap = gen.normalMaps[i] 
        self.chunks[i].renderer.material.displacementScale = Displacement * self.radius
    end]]
end

-- Updates the displacement setting on the material for interactive height adjustments
function Planet:update()
    self.material.displacementScale = Displacement * self.radius
end

-- Uses a generator and some style options to create and apply terrain to this planet
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
