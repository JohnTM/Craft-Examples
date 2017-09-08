-- A TNT block
function tnt()
    
    local tnt = scene.voxels.blocks:new("TNT")
    tnt.setTexture(ALL, "Blocks:Blank White")
    tnt.setColor(ALL, color(203, 57, 53, 255))
    tnt.scripted = true
    
    function tnt:interact()
        local x,y,z = self:xyz()
        self.voxels:fill(0)
        self.voxels:sphere(x,y,z,10)
        sound(SOUND_EXPLODE, 10526)
    end
    
    return tnt
end
