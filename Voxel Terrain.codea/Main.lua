-- Voxel Terrain

-- Use this function to perform your initial setup
function setup()
    
    print([[
    Voxel Terrain Example
    ]])
    
    allBlocks = blocks()
  
    skyMat = craft.scene.sky:get(craft.renderer).material
    horizonColor = skyMat.horizonColor
    skyColor = skyMat.skyColor
  
    craft.scene.ambientColor = color(61, 61, 61, 255)
    craft.scene.sun:get(craft.light).color = vec3(0.75,0.75,0.75)
    craft.scene.sun.rotation = quat.eulerAngles(25,0,125)
    craft.scene.fogEnabled = false
    craft.scene.fogNear = 5*16
    craft.scene.fogFar = 7*16
    
    camera = craft.scene.camera
    
    parameter.integer("Seed", 0, 1000000, readLocalData("seed"))
    
    parameter.action("Restart", function()
        saveLocalData("seed", Seed)
        restart()
    end)
    
    parameter.number("OrthoSize", 40, 200, 100, function(s)
        camera:get(craft.camera).orthoSize = s        
    end)
    
    parameter.number("Angle", 0, 360, 45)
    
    parameter.watch("craft.voxels.visibleChunks")
    parameter.watch("craft.voxels.generatingChunks")
    parameter.watch("craft.voxels.meshingChunks")
    
    camera:get(craft.camera).ortho = true

    
    -- TODO Make this easier to change
    skyMaterial = craft.scene.sky:get(craft.renderer).material

    -- Setup disk based streaming (Not Available Yet)
    --voxels.enableStorage("Save01")
    --voxels.disableStorage()     
    --voxels.deleteStorage("Save01")
    --voxels.save(progressCallback)
    
    sizeX = 100
    sizeZ = 100
    
    craft.voxels:resize(vec3(sizeX,1,sizeZ))
    
    -- set the maximum visible distance for voxels
    craft.voxels.visibleRadius = 8
    
    -- set the initial coordinates for viewing the voxel terrain
    craft.voxels.coordinates = vec3(16*sizeX/2,0,16*sizeZ/2)
    
    -- generate the terrain using the code in the 'Generation' tab
    local seedCode = "\nseed = "..tostring(Seed)
    craft.voxels:generate(readProjectTab("Generation")..seedCode, "generateTerrain")
    --todo force regen by calling generate a second time with no params
    -- todo allow extra options to be passed in via json or something
    
    parameter.action("Spawn Player", function()
        local pos = vec3(16*sizeX/2,128,16*sizeZ/2)
    
        -- Get surface position
        craft.voxels:raycast(pos, vec3(0,-1,0), 128, function(coord, id, face)
            if id and id ~= 0 then
                pos.y = coord.y + 2
                return true
            end
        end)
        
        player = craft.entity():add(BasicPlayer, craft.camera.main, pos:unpack())
        craft.scene.fogEnabled = true
    end)
end

-- This function gets called once every frame
function draw()
    if player then 
        player:draw() 
        
        local fogInterp = 1 - (player.viewer.rx + 90) / 180
        local fogColor = horizonColor * (1-fogInterp) + skyColor * fogInterp
        skyMat.horizonColor = fogColor
        skyMat.skyColor = fogColor
        craft.scene.fogColor = color((fogColor * 255):unpack())
    end   
    

end

function update()
    if player then
        craft.voxels.coordinates = player.entity.position
    else
        local angle = Angle
        local orbitDist = 120
        camera.rotation = quat.eulerAngles(45,0,angle)    
        camera.position = vec3(math.sin(math.rad(angle)) * -orbitDist,
                                    140,
                                    math.cos(math.rad(angle)) * -orbitDist) + vec3(16*sizeX/2,0,16*sizeZ/2)
    end
end
