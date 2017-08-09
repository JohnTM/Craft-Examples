-------------------------------------------------------------------------------
-- Lights
-- Written by John Millard
-------------------------------------------------------------------------------
-- Description:
-- Demonstrates realtime lighting in Craft.
-------------------------------------------------------------------------------

-- Use this function to perform your initial setup
function setup()
    print("Hello Lighting!")
    
    -- Create and setup a basic scene
    scene = craft.scene()
    -- Disable the sky and sun to emphasise our custom lights
    scene.sun.active = false  
    scene.sky.active = false
    scene.ambientColor = color(31, 31, 31, 255)
    
    basicMat = craft.material("Materials:Standard")

    local floor = scene:entity()
    local r = floor:add(craft.renderer, craft.model.cube(vec3(50,0.1,50)))
    r.material = basicMat
    floor.z = 5
    floor.y = -1
    
    -- Create a monkey model to shine our lights on
    local monkey = scene:entity()
    monkey.scale = vec3(0.625, 0.625, 0.625)
    monkey.rotation = quat.eulerAngles(0,0,180)
    r = monkey:add(craft.renderer, craft.model("Primitives:Monkey"))
    r.material = basicMat
    r.material.roughness = 0.6
    r.material.metalness = 0.25
    monkey.position = vec3(0, 0.25, 5)
    
    -- Set up some parameters to control the lights
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

    -- Define the initial light colors
    colors = 
    {
        color(255, 0, 190, 255),
        color(0, 187, 255, 255),
        color(255, 231, 0, 255)
    }
    
    for i = 1,3 do
        local light = scene:entity():add(craft.light, SPOT)
        light.angle = 15
        light.penumbra = Penumbra
        light.color = colors[i]
        light.entity.y = 5
        light.entity.z = 5

        -- Represent each of the lights with a basic material sphere (which is unlit)
        local r = light.entity:add(craft.renderer, craft.model.icosphere(0.1, 2))
        r.material = craft.material("Materials:Basic")
        r.material.diffuse = light.color
        table.insert(lights, light)
    end

end

function update(dt)
    scene:update(dt)
    
    -- Update ambient lighting based on the parameter
    scene.ambientColor = Ambient
    
    for k,light in pairs(lights) do
        if Animate then
            light.entity.x = math.cos(math.rad(90*ElapsedTime*0.1+(90*k)))
            light.entity.z = 5 + math.cos(math.rad(90*ElapsedTime*0.1+(-45*k)))
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

