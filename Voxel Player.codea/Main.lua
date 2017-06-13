-- Basic Player

displayMode(FULLSCREEN)

function setup()
    -- Setup camera and lighting
    craft.scene.sun.rotation = quat.eulerAngles(25,0,125)

    -- Set the scenes ambient lighting
    craft.scene.ambientColor = color(127, 127, 127, 255)   
    
    allBlocks = blocks()    
    
    -- Setup voxel terrain
    craft.voxels:resize(vec3(5,1,5))      
    craft.voxels.coordinates = vec3(0,0,0)
    
    -- Create ground put of grass
    craft.voxels:fill("Grass")
    craft.voxels:box(0,10,0,16*5,10,16*5)
    craft.voxels:fill("Dirt")
    craft.voxels:box(0,0,0,16*5,9,16*5)

    player = craft.entity():add(BasicPlayer, craft.camera.main, 40, 20, 40)

end

function draw()
    if player then 
        player:draw()
    end
end

