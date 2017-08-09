-- Cameras

-- Use this function to perform your initial setup
function setup()
    print("Hello Cameras!")

    scene = craft.scene()
    local m = craft.model("CastleKit:knightBlue")
    model = scene:entity()
    model:add(craft.renderer, m)
    
    scene.camera:add(OrbitViewer, vec3(0,5,0), 5, 10, 20)
end

function update(dt)
    scene:update(dt)
end

-- This function gets called once every frame
function draw()
    update(DeltaTime)
    scene:draw()
end

