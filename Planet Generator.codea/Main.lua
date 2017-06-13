-- Planet Test

-- Use this function to perform your initial setup
function setup()   
    
    skyMat = craft.scene.sky:get(craft.renderer).material
    skyMat.skyColor = color(0, 0, 0, 255)
    skyMat.horizonColor = color(0, 0, 0, 255)
    
    PLANET_RADIUS = 200

    gen = craft.entity():add(PlanetGenerator, PLANET_RADIUS, 512)
    moonGen = craft.entity():add(PlanetGenerator, PLANET_RADIUS, 128)
    
    
    viewer = craft.scene.camera:add(OrbitViewer, vec3(0,0,0), 800, 300, 1000)
    
    cmv = CubeMapViewer(gen)
    
    parameter.integer("Seed", 0, 1000, 121)
    parameter.action("Generate", function() 
        craft.camera.main.nearPlane = 0.1
        planet:generate(gen, planets.earth)
        moon:generate(moonGen, planets.moon)
        craft.camera.main.nearPlane = 10
        craft.camera.main.farPlane = 4000        
    end)
    parameter.boolean("ShowCubeMap", false)
    parameter.integer("Map", 1,3,1)
    parameter.number("Displacement", 0, 50/200.0, 35/200.0)

    planet = craft.entity():add(Planet, PLANET_RADIUS, 128, 4, true)  
    moon = craft.entity():add(Planet, PLANET_RADIUS / 6, 32, 4)  
    moon.entity.z = PLANET_RADIUS * 2
    
    frog = craft.entity()
    frog.parent = moon.entity
    frog.x = PLANET_RADIUS / 6 + 15
    frog.scale = vec3(1,1,1)
    
    local model = craft.entity()
    model.parent = frog

    local vm = model:add(craft.volume, 1,1,1)
    vm:load("Documents:Frog")
    local sx, sy, sz = vm:size()
    model.x = -sx/2
    model.y = -sy/2
    model.z = -sz/2
end

function createRoughnessRamp()
    local grad = GradientRamp(256,16)
   
    local c1 = color(60, 60, 60, 255)
    local c2 = color(231, 231, 231, 255)

    grad:addPoint(0.0, c1)
    grad:addPoint(0.1, c1)
    grad:addPoint(0.15, c2)
    grad:addPoint(1.0, c2)
    grad:update()
    
    return grad
end

function createTerrainRamp()
    local grad = GradientRamp(256,16)

    local c2 = color(30, 47, 70, 255)
    local c3 = color(220, 209, 172, 255)
    local c4 = color(29, 86, 51, 255) 
    local c42 = color(156, 93, 62, 255) 
    local c43 = color(129, 149, 126, 255) 
    local c5 = color(255, 255, 255, 255) 

    grad:addPoint(0.0, c2)
    grad:addPoint(0.22, c2)
    grad:addPoint(0.25, c3)
    grad:addPoint(0.3, c4)
    grad:addPoint(0.5, c4)
    grad:addPoint(0.8, c42)
    grad:addPoint(0.9, c43)
    grad:addPoint(0.99, c5)
    grad:addPoint(1.0, c5)
    grad:update()
    
    return grad
end

function update()
    craft.scene.ambientColor = color(80, 55, 84, 255)
    craft.scene.sun:get(craft.light).color = vec3(0.9,0.9,0.9)
    craft.scene.sun.rotation = quat.eulerAngles(25,0,95)
    
    local orbit = ElapsedTime * 12
    moon.entity.rotation = quat.eulerAngles(0, 0, orbit)    
    moon.entity.position = moon.entity.forward * PLANET_RADIUS * 2.0
    
    frog.rotation = quat.eulerAngles(0, 0, ElapsedTime * 180/2)
    frog.position = frog.forward * (PLANET_RADIUS / 6 + 15)
end

-- This function gets called once every frame
function draw()
    if cmv and ShowCubeMap then
        cmv:draw() 
    end
end
    

