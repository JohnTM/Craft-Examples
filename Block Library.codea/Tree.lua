
function treeGenerator()
    local tree = scene.voxels.blocks:new("Tree Generator")
    tree.scripted = true
    tree.geometry = EMPTY
        
    function tree:created()
        self:schedule(60)
    end
    
    function tree:blockUpdate(t)
        local x,y,z = self:xyz()
        if self.voxels:isRegionLoaded(x-3, y, z-3, x+3, y,z+3) then
            self:generate()
        else
            self:schedule(60)
        end
    end
    
    function tree:generate()
        local x,y,z = self:xyz()
        math.randomseed(x^2 * y^3 + z)
        local height = math.random(4,7)
        local size = math.floor(height/2)
        local branches = math.random(2,3) -- TODO
        self.voxels:set(x,y,z,"empty")

        local ground = self.voxels:get(x,y-1,z, BLOCK_NAME)
        if ground ~= "Dirt" and ground ~= "Grass" then
            return
        end
        
        local clear = true
        self.voxels:iterateBounds(x-1,y,z-1,x+1,y,z+1, function(x,y,z,id)
            if id and id ~= 0 then
                clear = false
            end
        end)
        self.voxels:iterateBounds(x-2,y+1,z-2,x+2,y+height,z+2, function(x,y,z,id)
            if id and id ~= 0 then
                clear = false
            end
        end)
        
        if clear == false then return end
        
        -- Trunk        
        self.voxels:set(x,y-1,z,"dirt")    
        self.voxels:fill("wood")
        self.voxels:box(x,y,z,x,y+height,z)
        
        -- Leaves
        self.voxels:fill("leaves")
        self.voxels:fillStyle(UNION)
        self.voxels:sphere(x,y+height,z,size)
        
    end
end
