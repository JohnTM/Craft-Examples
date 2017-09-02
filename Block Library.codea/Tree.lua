
function treeGenerator()
    local tree = scene.voxels.blocks:new("Tree Generator")
    tree.scripted = true
    
    function tree:isRegionLoaded(x1,y1,z1,x2,y2,z2)
        local b1 = self.voxels:get(x1,y1,z1)
        local b2 = self.voxels:get(x2,y1,z1) 
        local b3 = self.voxels:get(x1,y1,z2)
        local b4 = self.voxels:get(x2,y1,z2) 
        
        return b1 ~= nil and b2 ~= nil and b3 ~= nil and b4 ~= nil         
    end
        
    function tree:created()
        self:schedule(60)
    end
    
    function tree:blockUpdate(t)
        local x,y,z = self:xyz()
        if self:isRegionLoaded(x-3, y, z-3, x+3, y+6,z+3) then
            self:generate()
        else
            self:schedule(60)
        end
    end
    
    function tree:generate()
        local x,y,z = self:xyz()
        self.voxels:set(x,y,z,"wood")
    end
end
