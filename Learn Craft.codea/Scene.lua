-- Craft Scenes

function setup()
    -- Create a new craft scene
    scene = craft.scene()
    scene.sky.active = false
end

function cleanup()
    if viewer then
        touches.removeHandler(viewer)
        viewer = nil
    end
    scene = nil
    collectgarbage()
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
    print("Where is everything? This is a blank scene, the starting point for a 3D project.")
    print("To setup an initial blank scene:")
    print("Create an instance of craft.scene in setup()")
    print("The scene then needs to be updated and drawn each frame to work.")
    print("Theres no need to clear the background as scene will do it for you.")
    print("2D drawing can be done after scene:draw() as normal.")
end
