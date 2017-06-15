-- A set of basic blocks (mainly cubes)
function basicBlocks()
    
    -- Assets must be added to blocks for them to be available to voxels
    scene.voxels.blocks:addAssetPack("Blocks")
    
    -- Add some helper functions to the block class
    local directions =
    {
        [NORTH] = vec3(0,0,-1),
        [EAST] = vec3(1,0,0),
        [SOUTH] = vec3(0,0,1),
        [WEST] = vec3(-1,0,0),
        [UP] = vec3(0,1,0),
        [DOWN] = vec3(0,-1,0)
    }
    
    function craft.block.static.faceToDirection(face)
        return directions[face]
    end   
    
    function craft.block.static.directionToFace(dir)
        dir = vec3(dir.x, dir.y/2, dir.z):normalize()
        local minFace = nil
        local minDot = nil
        for k,v in pairs(directions) do
            local dot = dir:dot(v)
            if minFace == nil or dot < minDot then
                minFace = k
                minDot = dot
            end
        end
        return minFace
    end
    
    -- By default all blocks can be dug, have icons and cam be placed by the player
    -- Individual block types can override these defaults
    craft.block.static.canDig = true
    craft.block.static.hasIcon = true
    craft.block.static.canPlace = true   
    
    -- Empty block cannot be placed and has no icon
    scene.voxels.blocks.Empty.static.hasIcon = false
    scene.voxels.blocks.Empty.static.canPlace = false        
    
    local redstone = scene.voxels.blocks:new("Redstone")
    redstone.setTexture(ALL, "Blocks:Redstone")
    
    
    local grass = scene.voxels.blocks:new("Grass")
    grass.setTexture(ALL, "Blocks:Dirt Grass")
    grass.setTexture(DOWN, "Blocks:Dirt")
    grass.setTexture(UP, "Blocks:Grass Top")
    
    
    local dirt = scene.voxels.blocks:new("Dirt")
    dirt.setTexture(ALL, "Blocks:Dirt")
    
  
    local stone = scene.voxels.blocks:new("Stone")
    stone.setTexture(ALL, "Blocks:Gravel Stone")
    
    
    local water = scene.voxels.blocks:new("Water")
    water.setTexture(ALL, "Blocks:Water")
    water.setColor(ALL, color(100,100,200,170))
    -- Translucent geometry prevents blocks from rendering internal faces between each other
    water.geometry = TRANSLUCENT  
    -- Translucent renderPass is for semi-transparent blocks (i.e alpha less than 255 and greater than 0)
    water.renderPass = TRANSLUCENT
    
        
    local sand = scene.voxels.blocks:new("Sand")
    sand.setTexture(ALL, "Blocks:Sand")
    
    
    local glassFrame = scene.voxels.blocks:new("Glass Frame")
    glassFrame.setTexture(ALL, "Blocks:Glass Frame")
    glassFrame.geometry = TRANSLUCENT
    glassFrame.renderPass = TRANSLUCENT
    
        
    local glass = scene.voxels.blocks:new("Glass")
    glass.setTexture(ALL, "Blocks:Glass")
    glass.geometry = TRANSLUCENT
    glass.renderPass = TRANSLUCENT
    
        
    local brickRed = scene.voxels.blocks:new("Red Brick")
    brickRed.setTexture(ALL, "Blocks:Brick Red")
    
    
    local brick = scene.voxels.blocks:new("Brick")
    brick.setTexture(ALL, "Blocks:Brick Grey")
    
    
    local goldOre = scene.voxels.blocks:new("Gold Ore")
    goldOre.setTexture(ALL, "Blocks:Stone Gold")
    
    
    local diamondOre = scene.voxels.blocks:new("Diamond Ore")
    diamondOre.setTexture(ALL, "Blocks:Stone Diamond")
    

    local craftingTable = scene.voxels.blocks:new("Crafting Table")
    craftingTable.setTexture(ALL, "Blocks:Table")

        
    local planks = scene.voxels.blocks:new("Pplanks")
    planks.setTexture(ALL, "Blocks:Wood")
    
    
    local wood = scene.voxels.blocks:new("Wood")
    wood.setTexture(ALL, "Blocks:Trunk Side")
    wood.setTexture(DOWN, "Blocks:Trunk Top")
    wood.setTexture(UP, "Blocks:Trunk Top")
    wood.scripted = true 
    
    local soundb = scene.voxels.blocks:new("Sound")
    soundb.setTexture(ALL, "Blocks:Blank White")
    soundb.tinted = true
    soundb.scripted = true

    function soundb:newd()
        local x,y,z = self:xyz()
        math.randomseed = x * y * z
        local c =color(math.random(128,255), math.random(128,255), math.random(128,255))
        self.voxels:set(x,y,z,"color", c)
    end
    
    function soundb:interact()
        local x,y,z = self:xyz()
        sound(SOUND_RANDOM, x * y * z)
    end   
end