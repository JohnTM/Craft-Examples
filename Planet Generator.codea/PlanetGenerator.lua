PlanetGenerator = class()

function PlanetGenerator:init(entity, radius, width)
    self.entity = entity
    
    --self.camera = craft.entity():add(craft.camera, 90, 0.1, 10, false)
    --self.camera.entity.parent = self.entity
    --self.camera.mask = 2

    self.radius = 1
    self.width = width
    self.height = width
    
    self.cubePadding = 2
    self.scratchPadded = image(self.width + self.cubePadding, self.height + self.cubePadding)
    
    self.maxFilter = shader("Project:TerrainMax")
    self.maxFilter.maxThreshold = 0.09
    
    self.terrainFilter = shader("Project:TerrainColor")
    
    self.normalMapFilter = shader("Project:TerrainNormals")
    self.normalMapStrength = 15
end

function PlanetGenerator:generate(seed, options)
    self.splats = {}
    self.options = options
    
    if seed then
        math.randomseed(seed)
    end
    
    for k,brush in pairs( self.options.brushes ) do   
        for i = 1,math.random(unpack(brush.count)) do
            local size = randomRange(unpack(brush.size))
            local x,y,z = math.random(0,360), math.random(0,360), math.random(0,360)
            local opacity = randomRange(unpack(brush.opacity))
            self:addSplat(brush.image, size, opacity, x, y, z)        
        end
    end
    
    self.colorMaps = {}
    self.heightMaps = {}
    self.normalMaps = {}
    self.roughnessMaps = {}
    
    self.terrainFilter.ramp = GradientRamp(256,16, options.terrainRamp).img
    
    local c = craft.camera.main
    c.entity.position = vec3(0,0,0)
    c.fieldOfView = 2.0 * math.deg( math.atan((2.0 + self.cubePadding / self.width) * 0.5) )
    craft.scene.ambientColor = color(255, 255, 255, 255)
    craft.scene.sun.active = false
    --craft.scene.sun:get(craft.light).mask = ~2
    
     
    self:renderPlane(c, vec3(-1,0,0), vec3(0,1,0), vec2(1,1))    
    self:renderPlane(c, vec3(1,0,0), vec3(0,1,0), vec2(1,1))       
    self:renderPlane(c, vec3(0,-1,0), vec3(0,0,1), vec2(1,1))           
    self:renderPlane(c, vec3(0,1,0), vec3(0,0,-1), vec2(1,1))  
    self:renderPlane(c, vec3(0,0,1), vec3(0,1,0), vec2(1,1))           
    self:renderPlane(c, vec3(0,0,-1), vec3(0,1,0), vec2(1,1))                               
    
    self.map = craft.cubeTexture(self.colorMaps)
    self.heightMap = craft.cubeTexture(self.heightMaps)
    self.normalMap = craft.cubeTexture(self.normalMaps)
    
    c.fieldOfView = 45
    craft.scene.sun.active = true
    
    for k,v in pairs(self.splats) do
        v:destroy()
    end
end

function PlanetGenerator:addSplat(img, size, opacity, x, y, z)    
    local s = craft.entity() 
    s.rotation = quat.eulerAngles(x,y,z)
    s.position = -s.forward * self.radius
    
    local splatMesh = craft.mesh.cube(vec3(size,size,0))
    
    local r = s:add(craft.renderer, splatMesh)
    --r.mask = 2
    r.material = craft.material("Materials:Standard")
    r.material.map = img
    r.material.blendMode = ADDITIVE   
    r.material.opacity = opacity
    
    table.insert(self.splats, s)   
end

function PlanetGenerator:renderPlane(c, forward, up, flipNormals)

    pushStyle()
    noSmooth()
    
    c.entity.rotation = quat.lookRotation(forward, up)
    
    setContext(self.scratchPadded, true)
    c:draw()
    setContext()

    self.normalMapFilter.right = -forward:cross(up)
    self.normalMapFilter.forward = forward
    self.normalMapFilter.up = up
    
    if forward.x ~= 0 then
        self.normalMapFilter.right = forward:cross(up)
        self.normalMapFilter.forward = -forward
        self.normalMapFilter.up = up
    end
    
    if forward.y ~= 0 then
        self.normalMapFilter.right = up:cross(forward)
        self.normalMapFilter.forward = -forward
        self.normalMapFilter.up = -up
    end    
    
    self.normalMapFilter.strength = flipNormals * self.normalMapStrength
    local normalMap = self:filterImage(self.scratchPadded, self.normalMapFilter):copy(self.cubePadding/2, self.cubePadding/2, self.width, self.height)   
    
    table.insert(self.normalMaps, normalMap)
    
    local heightMap = image(self.width, self.height)
    setContext(heightMap)
    sprite(self.scratchPadded, self.width/2, self.height/2)
    setContext()
    
    table.insert(self.heightMaps, heightMap)

    table.insert(self.colorMaps, self:filterImage(heightMap, self.terrainFilter))
    
    popStyle()
    
    collectgarbage()
end

function PlanetGenerator:filterImage(img, filter)
    local copy = img:copy()
    
    local m = mesh()
    noSmooth()
    m:addRect(img.width/2, img.height/2, img.width, img.height)
    m.texture = img
    m.shader = filter
    
    setContext(copy)
    m:draw()
    setContext()
    
    return copy
end