-- Craft Camera

function setup()
    -- Create a new craft scene
    scene = craft.scene()
    scene.sky.active = false
    
    myEntity = scene:entity()
    myEntity.model = craft.model("CastleKit:siegeTrebuchet")
    myEntity.eulerAngles = vec3(0, 180, 0)
    
    -- From the Cameras library project (added as dependency - see the + button)
    -- parameters are (target position, initial distance, min dist, max dist)
    viewer = scene.camera:add(OrbitViewer, myEntity.model.bounds.center, 30, 20, 100)
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
    print("To simplify camera setup, you can use the Cameras library which contains same viewer classes")
    print("OrbitViewer is useful for controlling the camera via simple gestures")
    print("OrbitViewer supports rotating, zooming and panning (via one and two fingers)")   
end