-- Craft Camera

function setup()
    -- Create a new craft scene
    scene = craft.scene()
    
    myEntity = scene:entity()
    myEntity.model = craft.model("Primitives:Monkey")
    myEntity.eulerAngles = vec3(0, 180, 0)
    
    local env = craft.cubeTexture(
    {
        readImage("Environments:right"),
        readImage("Environments:left"),
        readImage("Environments:bottom"),
        readImage("Environments:top"),
        readImage("Environments:back"),
        readImage("Environments:front")    
    })
    scene.sky.material.envMap = env


    local mat = craft.material("Materials:Standard")
    mat.diffuse = color(241, 163, 45, 255)
    mat.metalness = 0.7
    mat.roughness = 0.5
    mat.envMap = env
    myEntity.material = mat
    myEntity.material.offsetRepeat = vec4(0,0,10,10)

    
    -- From the Cameras library project (added as dependency - see the + button)
    -- parameters are (target position, initial distance, min dist, max dist)
    viewer = scene.camera:add(OrbitViewer, vec3(0,0,0), 5, 5, 30)
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