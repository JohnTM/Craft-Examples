-- Craft Sky

function setup()
    -- Create a new craft scene
    scene = craft.scene()
    
    myEntity = scene:entity()
    myEntity.model = craft.model("Primitives:RoundedCube")
    myEntity.model:getMaterial(0).shininess = 1
    myEntity.eulerAngles = vec3(0, 180, 0)
    
    scene.sun:get(craft.light).intensity = 0.75
    
    -- From the Cameras library project (added as dependency - see the + button)
    -- parameters are (target position, initial distance, min dist, max dist)
    viewer = scene.camera:add(OrbitViewer, vec3(), 10, 5, 20)
    
    parameter.boolean("SkyActive", true, function(b) 
        scene.sky.active = b
    end)
    
    parameter.color("Sky", 
        color(70, 151, 234, 255), 
        function(c) 
        scene.sky.material.sky = c
    end)
    
    parameter.color("Horizon",
        color(30, 30, 30, 255), 
        function(c) 
        scene.sky.material.horizon = c
    end)
    
    local sunny = readText("Environments:Night")
    local env = craft.cubeTexture(json.decode(sunny))
    
    parameter.boolean("EnvMap", false, function(b)
        if b then
            scene.sky.material.envMap = env                    
        else
            scene.sky.material.envMap = nil                    
        end
    end)

end

function update(dt)
    -- Update the scene (physics, transforms etc)
    scene:update(dt)
end

-- Called automatically by codea 
function draw()
    update(DeltaTime)

    -- Draw the scene
    scene:draw()

    -- 2D drawing goes here  
    drawStepName()	   	
end

function PrintExplanation()
    output.clear()
    print("Woth craft instead of calling background() each frame to set the background color we use the sky entity")
    print("scene.sky draws the background and defaults to a blue sky gradient")
    print("Use sky.active to turn it on and off")
    print("Use sky.material.horizonColor / skyColor to change the gradient colors themselves")
end