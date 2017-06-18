-- Lights

-- Use this function to perform your initial setup
function setup()
    print("Hello Lighting!")
    
    scene = craft.scene()
    scene.sun.active = false  
    scene.sky.active = false
    scene.ambientColor = color(31, 31, 31, 255)
    
    local floor = scene:entity()
    local r = floor:add(craft.renderer, craft.mesh.cube(vec3(50,0.1,50)))
    r.material = craft.material("Materials:Standard")
    floor.z = 5
    floor.y = -1
    
    local sphere = scene:entity()
    sphere.scale = vec3(0.5, 0.5, 0.5)
    sphere.rotation = quat.eulerAngles(0,0,180)
    r = sphere:add(craft.renderer, craft.mesh("Primitives:Monkey"))
    r.material = craft.material("Materials:Standard")
    r.material.roughness = 0.6
    r.material.metalness = 0.25
    sphere.position = vec3(0, -0.25, 5)
    
    
    parameter.color("Ambient", color(37, 37, 37))
    parameter.integer("Type", DIRECTIONAL, SPOT, SPOT)
    types = {"DIRECTIONAL", "POINT", "SPOT"}
    parameter.watch("types[Type+1]")
    parameter.number("Height", -1, 10, 5)
    parameter.number("Angle", 0.0, 60, 20)
    parameter.number("Penumbra", 0.0, 60, 0.0)
    parameter.number("Intensity", 0.0, 10.0, 1.0)
    parameter.number("Decay", 0.0, 10.0, 1.0)
    parameter.boolean("Animate", true)
    
    lights = {}
    colors = 
    {
        color(255, 0, 0, 255),
        color(0, 255, 21, 255),
        color(0, 44, 255, 255)
    }
    
    for i = 1,3 do
        local light = scene:entity():add(craft.light, SPOT)
        light.angle = 15
        light.penumbra = Penumbra
        light.color = colors[i]
        light.entity.y = 5
        light.entity.z = 5
        local r = light.entity:add(craft.renderer, craft.mesh.icosphere(0.1, 2))
        r.material = craft.material("Materials:Basic")
        r.material.diffuse = light.color
        table.insert(lights, light)
    end

end

function update(dt)
    scene:update(dt)
    
    scene.ambientColor = Ambient
    
    for k,light in pairs(lights) do
        if Animate then
            light.entity.x = math.cos(math.rad(90*ElapsedTime+(90*k)))
            light.entity.z = 5 + math.cos(math.rad(90*ElapsedTime+(-45*k)))
        end
            
        light.entity.y = Height
        light.type = Type
        light.penumbra = Penumbra
        light.angle = Angle    
        light.intensity = Intensity    
        light.decay = Decay    
    end

end

-- This function gets called once every frame
function draw()
    update(DeltaTime)
    
    background(0, 0, 0, 255)
    scene:draw()    
end
