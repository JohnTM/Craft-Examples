function tnt()
    scene.voxels.blocks:addAsset("Dropbox:TNT")
    
    local tnt = scene.voxels.blocks:create("TNT")
    tnt.setTexture(ALL, "Dropbox:TNT")
    tnt.scripted = true
    
    function tnt:interact()
        local x,y,z = self:xyz()
        self.voxels:fill(0)
        self.voxels:sphere(x,y,z,10)
        sound(SOUND_EXPLODE, 10526)
    end
    
    return tnt
end
