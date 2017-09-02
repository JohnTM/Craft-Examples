-- Craft Template

function setup()
    -- Create a new craft scene
    scene = craft.scene()
    
    myEntity = scene:entity()
    myEntity.model = craft.model("Blocky Characters:Robot")
    myEntity.y = -7
    myEntity.z = 30
    myEntity.eulerAngles = vec3(0, 0, 180)
    
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
end

function PrintExplanation()
    print([[A blank scene.]])
end
