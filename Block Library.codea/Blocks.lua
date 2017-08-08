-- Loads all blocks
function blocks()
    basicBlocks()
    stairsBlock("stoneStairs", "Blocks:Stone")
    signBlock()
    piston()
    fence("Wooden Fence", "Blocks:Wood")    
    chest(40)
        
    -- Get a list of all block types
    local allBlocks = scene.voxels.blocks:all()
    
    -- Generate preview icons for all blocks
    for k,v in pairs(allBlocks) do
        if v.hasIcon == true then
            v.static.icon = generateBlockPreview(v)
        end
    end
    
    return allBlocks
end
