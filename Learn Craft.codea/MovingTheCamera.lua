-- Craft Camera

function setup()
    -- Create a new craft scene
    scene = craft.scene()
    scene.sky.active = false
    createGround(-1.125)

    myEntity = scene:entity()
    myEntity.model = craft.model("Blocky Characters:Orc")
    myEntity.y = -1
    myEntity.z = 0
    myEntity.scale = vec3(1,1,1) / 8
    myEntity.eulerAngles = vec3(0, 180, 0)
    
    scene.camera.z = -4
    
    parameter.number("CameraX", -20, 20, 0)   
    parameter.number("CameraY", 0, 10, 0)   
    parameter.number("CameraZ", -8, 8, -4)
end

function update(dt)
    scene.camera.x = CameraX  
    scene.camera.y = CameraY   
    scene.camera.z = CameraZ   
    
    local dir = (-scene.camera.position):normalize()
    scene.camera.rotation = quat.lookRotation(dir, vec3(0,1,0))
    
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
    print("The scene contains a built-in camera entity that you can move around")
    print("Since the camera is an entity you can use all the same properties to move it as the previous example")
end
