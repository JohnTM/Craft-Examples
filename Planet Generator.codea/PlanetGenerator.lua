PlanetGenerator = class()

function PlanetGenerator:init(entity, radius, width)
    self.entity = entity
    
    --self.camera = scene:entity():add(craft.camera, 90, 0.1, 10, false)
    --self.camera.entity.parent = self.entity
    --self.camera.mask = 2

    -- The radius of the internal splat sphere
    self.radius = 1

    -- The width and height of the individual cube textures
    self.width = width
    self.height = width
    
    -- The amount of padding (in pixels) for intermediate cube images
    self.cubePadding = 2
    -- Reusable image for rending out cube images
    self.scratchPadded = image(self.width + self.cubePadding, self.height + self.cubePadding)
    
    -- Used to apply max operation to cube images (for setting the minimum height)
    self.maxFilter = shader("Project:TerrainMax")
    self.maxFilter.maxThreshold = 0.09
    
    -- Used to generate terrain color from the height map
    self.terrainFilter = shader("Project:TerrainColor")
    
    -- Used to generate a normal map from the height map
    self.normalMapFilter = shader("Project:TerrainNormals")
    -- How strong the normal map effect should be
    self.normalMapStrength = 15
    
end

function PlanetGenerator:generateAsync(seed, options, callback)
    self.thread = coroutine.create(self.generate)
    self.callback = callback
end

function PlanetGenerator:update()
    if self.thread then
        local status, result = coroutine.resume(self, seed, options)
        if result then
            self.thread = nil
            self.callback(self)
        end
    end
end

function blendEdgesV(a,b,x)
    for i = 1,a.height do
        local h1 = a:get(x, i)
        local h2 = b:get(a.width-x+1, i)
        local avg = math.floor( (h1+h2)/2.0 )
        
        a:set(x, i, avg, avg, avg)
        b:set(a.width-x+1, i, avg, avg, avg)        
    end    
end

function blendEdgesH(a,b,y)
    for i = 1,a.width do
        local h1 = a:get(i, y)
        local h2 = b:get(i, a.height-y+1)
        local avg = math.floor( (h1+h2)/2.0 )
        
        a:set(i, y, avg, avg, avg)
        b:set(i, a.height-y+1, avg, avg, avg)        
    end
end

function blendEdges(images)
    local w,h = images[1].width, images[1].height
    -- TODO: determine which edges to blend
    blendEdgesH(images[5], images[4], h)
    blendEdgesH(images[5], images[4], h)
    blendEdgesH(images[5], images[4], h)
    blendEdgesH(images[5], images[4], h)
    blendEdgesH(images[5], images[4], h)
    blendEdgesH(images[5], images[4], h)
    blendEdgesH(images[5], images[4], h)
    blendEdgesH(images[5], images[4], h)
    blendEdgesH(images[5], images[4], h)
    blendEdgesH(images[5], images[4], h)
    blendEdgesH(images[5], images[4], h)
    blendEdgesH(images[5], images[4], h)
end

-- Generates the color, height and normal maps to be used on a planet model
-- Seed is used to control the initial random values and options controls the appearance
-- of the generated terrain
function PlanetGenerator:generate(seed, options)
    self.splats = {}
    self.splatParent = scene:entity()
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
    
    local c = camera
    c.entity.position = vec3(0,0,0)
    c.fieldOfView = 2.0 * math.deg( math.atan((2.0 + 2.0 * self.cubePadding / self.width) * 0.5) )
    c.nearPlane = 0.1
    c.farPlane = 20
         
    self:renderPlane(c, vec3(-1,0,0), vec3(0,1,0), vec2(1,1))    
    self:renderPlane(c, vec3(1,0,0), vec3(0,1,0), vec2(1,1))       
    self:renderPlane(c, vec3(0,-1,0), vec3(0,0,1), vec2(1,1))           
    self:renderPlane(c, vec3(0,1,0), vec3(0,0,-1), vec2(1,1))  
    self:renderPlane(c, vec3(0,0,1), vec3(0,1,0), vec2(1,1))           
    self:renderPlane(c, vec3(0,0,-1), vec3(0,1,0), vec2(1,1))                               
    
    --blendEdges(self.heightMaps)
    
    self.map = craft.cubeTexture(self.colorMaps)
    self.heightMap = craft.cubeTexture(self.heightMaps)
    self.normalMap = craft.cubeTexture(self.normalMaps)
    
    c.fieldOfView = 45
    
    self.splatParent:destroy()
    self.splatParent = nil
end

-- Adds a single splat given an image and size, opacity and position values
function PlanetGenerator:addSplat(img, size, opacity, x, y, z)    
    local s = scene:entity() 
    s.parent = self.splatParent
    s.rotation = quat.eulerAngles(x, z, y)
    s.position = -s.forward * self.radius
    
    local splatMesh = craft.model.cube(vec3(size,size,0))
    
    local r = s:add(craft.renderer, splatMesh)
    --r.mask = 2
      
    r.material = craft.material("Materials:Basic")
    r.material.blendMode = ADDITIVE   
    r.material.map = img
    r.material.opacity = opacity
    
    table.insert(self.splats, s)   
end

-- Renders a single plane of the cube map given a camera and forward/up vector combination
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
    
    local heightMap = self.scratchPadded:copy(self.cubePadding/2, self.cubePadding/2, self.width, self.height)   
    --[[local heightMap = image(self.width, self.height)
    setContext(heightMap)
    smooth()
    sprite(self.scratchPadded, self.width/2, self.height/2, self.width + 2.0, self.width + 2.0)
    setContext()]]
    
    table.insert(self.heightMaps, heightMap)

    table.insert(self.colorMaps, self:filterImage(heightMap, self.terrainFilter))
    
    popStyle()
    
    collectgarbage()
end

-- Applies a filter to an image using a shader and returns it as a new image
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
    
    smooth()
    
    return copy
end