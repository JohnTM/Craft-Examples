-- Cameras

-- Use this function to perform your initial setup
function setup()
    print("Hello World!")

    scene = craft.scene()
    local m = craft.mesh("CastleKit:knightBlue")
    model = scene:entity()
    model:add(craft.renderer, m)
    
    scene.camera:add(OrbitViewer, vec3(0,0,0), 5, 5, 20)
end

function update(dt)
    scene:update(dt)
end

-- This function gets called once every frame
function draw()
    update(DeltaTime)
    scene:draw()
end

