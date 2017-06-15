-- Voxel Terrain

-- Use this function to perform your initial setup
function setup()
    
    print([[
    Voxel Terrain Example
    ]])
    
    allBlocks = blocks()
  
    skyMat = scene.sky:get(craft.renderer).material
    horizonColor = skyMat.horizonColor
    skyColor = skyMat.skyColor
  
    scene.ambientColor = color(61, 61, 61, 255)
    scene.sun:get(craft.light).color = vec3(0.75,0.75,0.75)
    scene.sun.rotation = quat.eulerAngles(25,0,125)
    scene.fogEnabled = false
    scene.fogNear = 5*16
    scene.fogFar = 7*16
    
    camera = scene.camera
    
    parameter.integer("Seed", 0, 1000000, readLocalData("seed"))
    
    parameter.action("Restart", function()
        saveLocalData("seed", Seed)
        restart()
    end)
    
    parameter.number("OrthoSize", 40, 200, 100, function(s)
        camera:get(craft.camera).orthoSize = s        
    end)
    
    parameter.number("Angle", 0, 360, 45)
    
    parameter.watch("scene.voxels.visibleChunks")
    parameter.watch("scene.voxels.generatingChunks")
    parameter.watch("scene.voxels.meshingChunks")
    
    camera:get(craft.camera).ortho = true

    
    -- TODO Make this easier to change
    skyMaterial = scene.sky:get(craft.renderer).material

    -- Setup disk based streaming (Not Available Yet)
    --voxels.enableStorage("Save01")
    --voxels.disableStorage()     
    --voxels.deleteStorage("Save01")
    --voxels.save(progressCallback)
    
    sizeX = 100
    sizeZ = 100
    
    scene.voxels:resize(vec3(sizeX,1,sizeZ))
    
    -- Set the maximum visible distance for voxels
    scene.voxels.visibleRadius = 8
    
    -- Set the initial coordinates for viewing the voxel terrain
    scene.voxels.coordinates = vec3(16*sizeX/2,0,16*sizeZ/2)
    
    -- Generate the terrain using the code in the 'Generation' tab
    local seedCode = "\nseed = "..tostring(Seed)
    scene.voxels:generate(readProjectTab("Generation")..seedCode, "generateTerrain")
    
    -- TODO Force regen by calling generate a second time with no params
    -- TODO Allow extra options to be passed in via json or a lua table
    
    parameter.action("Spawn Player", function()
        local pos = vec3(16*sizeX/2,128,16*sizeZ/2)
    
        -- Get surface position
        scene.voxels:raycast(pos, vec3(0,-1,0), 128, function(coord, id, face)
            if id and id ~= 0 then
                pos.y = coord.y + 2
                return true
            end
        end)
        
        player = craft.entity():add(BasicPlayer, scene.camera:get(craft.camera), pos:unpack())
        scene.fogEnabled = true
    end)
end

function update(dt)
    scene:update(dt)

    if player then
        scene.voxels.coordinates = player.entity.position
    else
        local angle = Angle
        local orbitDist = 120
        camera.rotation = quat.eulerAngles(45,0,angle)    
        camera.position = vec3(math.sin(math.rad(angle)) * -orbitDist,
                                    140,
                                    math.cos(math.rad(angle)) * -orbitDist) + vec3(16*sizeX/2,0,16*sizeZ/2)
    end
end

-- This function gets called once every frame
function draw()
    update(DeltaTime)

    scene:draw()

    if player then 
        player:draw() 
        
        local fogInterp = 1 - (player.viewer.rx + 90) / 180
        local fogColor = horizonColor * (1-fogInterp) + skyColor * fogInterp
        skyMat.horizonColor = fogColor
        skyMat.skyColor = fogColor
        scene.fogColor = color((fogColor * 255):unpack())
    end   
    

end

