-- Loads all blocks
function blocks()
    basicBlocks()
    signBlock()
    piston()
    stairsBlock("Wooden Stairs", "Blocks:Wood")    
    stairsBlock("Stone Stairs", "Blocks:Stone")
    fence("Wooden Fence", "Blocks:Wood") 
    fence("Stone Fence", "Blocks:Stone")       
    chest(40)
    soundb()
    treeGenerator()
    tnt()
        
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
