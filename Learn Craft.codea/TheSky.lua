-- Craft Sky

function setup()
    -- Create a new craft scene
    scene = craft.scene()
    
    myEntity = scene:entity()
    myEntity.model = craft.model.cube(vec3(2,2,2))
    myEntity.material = craft.material.preset("Surfaces:Basic Bricks")
    myEntity.material.normalScale = vec2(-1,-1)
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
        color(152, 204, 223, 255), 
        function(c) 
        scene.sky.material.horizon = c
    end)

    parameter.color("Ground",
        color(37, 37, 37, 255), 
        function(c) 
        scene.sky.material.ground = c
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
    
    parameter.color("CameraClearColor",
        color(0, 0, 0, 255), 
        function(c)
        -- You have to get the camera component first to change camera settings 
        scene.camera:get(craft.camera).clearColor = c
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
    print("With craft instead of calling background() each frame to set the background color we use the sky entity")
    print("scene.sky draws the background and defaults to a blue sky gradient")
    print("Use sky.active to turn it on and off")
    print("Use sky.material.horizon, sky and ground to change the gradient colors themselves")
    print("When the sky is disabled you can set the camera's clear color instead")
end