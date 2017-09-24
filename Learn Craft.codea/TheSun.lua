-- Craft Sun

function setup()
    -- Create a new craft scene
    scene = craft.scene()
    
    myEntity = scene:entity()
    myEntity.model = craft.model("Primitives:Monkey")
    myEntity.material = craft.material("Materials:Standard")
    myEntity.eulerAngles = vec3(0, 180, 0)
   
    sunModel = scene:entity()
    sunModel.model = craft.model.icosphere(10, 3, false)
    sunModel.material = craft.material("Materials:Basic")
    
    
    -- From the Cameras library project (added as dependency - see the + button)
    -- parameters are (target position, initial distance, min dist, max dist)
    viewer = scene.camera:add(OrbitViewer, vec3(0), 30, 20, 100)
    
    parameter.color("AmbientLight", 
        color(65, 65, 65, 255), 
        function(c) 
            scene.ambientColor = c
        end)   
    
    parameter.boolean("SunActive", true, function(b) 
        scene.sun.active = b
    end)
    
    parameter.number("SunIntensity", 0, 10, 0.7, function(n) 
        scene.sun:get(craft.light).intensity = n
    end)
    
    parameter.color("SunColor", 
        color(255, 255, 255), 
        function(c) 
            scene.sun:get(craft.light).color = c
        end)
    
    parameter.color("SkyColor", 
        color(120, 190, 250))
    
    parameter.color("HorizonColor", 
        color(40, 40, 70))
end

function update(dt)
    -- Update the scene (physics, transforms etc)
    scene:update(dt)
end

-- Called automatically by codea 
function draw()
    update(DeltaTime)
    
    scene.sky.material.sky = SkyColor * SunIntensity
    scene.sky.material.horizon = HorizonColor * SunIntensity
    
    sunModel.position = scene.sun.up * 300
    
    -- Draw the scene
    scene:draw()	
    
    -- 2D drawing goes here  
    drawStepName()	         
end

function PrintExplanation()
    output.clear()
    print("The craft scene has a built-in light entity - scene.sun")
    print("The sun is a directional light so all that matters is its' rotation and light properties")
    print("To alter the light intensity and color you must get the sun's light component")
    print("Use scene.sun:get(craft.light) to get the light component")
    print("See the Lights example for more details")
end