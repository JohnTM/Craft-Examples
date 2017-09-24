-- Craft Camera

function setup()
    -- Create a new craft scene
    scene = craft.scene()
    scene.sky.active = false
    createGround(-1.125)
  
    -- The scene.camera entity only lets you control the camera postion / rotation
    -- The camera component has settings for things like the field of view and helper methods 
    cameraSettings = scene.camera:get(craft.camera)

    myEntity = scene:entity()
    myEntity.model = craft.model("Blocky Characters:Orc")
    myEntity.y = -1
    myEntity.z = 0
    myEntity.scale = vec3(1,1,1) / 8
    myEntity.eulerAngles = vec3(0, 180, 0)
    
    scene.camera.z = -4
    
    parameter.number("CameraX", 0, 360, 0)   
    parameter.number("CameraY", 0, 360, 0)   
    parameter.number("FieldOfView", 45, 90, 60)
    parameter.boolean("Ortho", false)
    parameter.number("OrthoSize", 1,10,5)

end

function update(dt)
   
    if CurrentTouch.state == MOVING then 
        CameraX = CameraX - CurrentTouch.deltaX * 0.25
        CameraY = CameraY - CurrentTouch.deltaY * 0.25
    end
    
    cameraSettings.fieldOfView = FieldOfView
    -- Orthographic mode
    cameraSettings.ortho = Ortho
    cameraSettings.orthoSize = OrthoSize
    
    --Set the camera rotation to look at the center of the scene
    scene.camera.eulerAngles = vec3(CameraY, CameraX, 0)
    scene.camera.position = -scene.camera.forward * 5
    
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
