-- Basic Player

displayMode(FULLSCREEN)

function setup()
    scene = craft.scene()

    -- Setup camera and lighting
    scene.sun.rotation = quat.eulerAngles(25,0,125)

    -- Set the scenes ambient lighting
    scene.ambientColor = color(127, 127, 127, 255)   
    
    allBlocks = blocks()    
    
    -- Setup voxel terrain
    scene.voxels:resize(vec3(5,1,5))      
    scene.voxels.coordinates = vec3(0,0,0)
    
    -- Create ground put of grass
    scene.voxels:fill("Grass")
    scene.voxels:box(0,10,0,16*5,10,16*5)
    scene.voxels:fill("Dirt")
    scene.voxels:box(0,0,0,16*5,9,16*5)

    player = scene:entity():add(BasicPlayer, craft.camera.main, 40, 20, 40)

end

function update(dt)
    scene:update(dt)
end

function draw()
    update(DeltaTime)

    scene:draw()
    player:draw()
end

