-- Craft Entities

function setup()
    -- Create a new craft scene
    scene = craft.scene()
    scene.sky.active = false
    createGround(-1.125)

    -- Create a new entity
    myEntity = scene:entity()
    
    -- Set its model for drawing
    myEntity.model = craft.model("Blocky Characters:Robot")
    
    -- Adjust position and scale
    myEntity.y = -1
    myEntity.z = 0
    myEntity.scale = vec3(1,1,1) / 8
    
    -- Move camera back a little
    scene.camera.z = -4
    
    parameter.number("Rotate", 0, 360, 180)
end

-- Creates the ground using a box model and applies a simple textured material
function createGround(y)
    local ground = scene:entity()
    ground.model = craft.model.cube(vec3(4,0.125,4))
    ground.material = craft.material("Materials:Specular")
    ground.material.map = readImage("Blocks:Dirt")
    ground.material.specular = color(0, 0, 0, 255)
    ground.material.offsetRepeat = vec4(0,0,5,5)
    ground.y = y
    return ground
end

function update(dt)
    -- Rotate the entity 
    myEntity.eulerAngles = vec3(0, Rotate, 0)
    
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
    print("Entities are flexible objects used for displaying 3D models, simulating physics and more")
    print("To create an entity use - myEntiy = scene:entity()")
    print("To attach a 3D model, use myEntity.model = craft.model(...)")
    print("Use the x, y, z and position properties to move entities around")
    print("Use the eulerAngles and rotation properties to rotate an entity")
end
