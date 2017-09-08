function depositGenerator()
    
    local deposit = scene.voxels.blocks:new("Deposit")
    deposit.scripted = true
    deposit.geometry = EMPTY
    deposit.static.hasIcon = false
    
    function deposit:generate()
        local x,y,z = self:xyz()
    
        local depositType = "Coal Ore"
        
        if y < 64 then
            depositType = "Gold Ore"
        end
        
        if y < 32 then
            depositType = "Diamond Ore"
        end

        local r = 3
        local r2 = r*r
        
        self.voxels:set(x,y,z,"Stone")
        
        self.voxels:iterateBounds(x-r, y-r, z-r, x+r, y+r, z+r, function(i,j,k,id)
            -- Scale density based on distance from deposit center
            local dx, dy, dz = x-i, y-j, z-k
            local d = dx*dx + dy*dy + dz*dz              
            local p = 1.0 - (d / (r2+0.0)) 
            
            if math.random() < p and self.voxels:get(i,j,k,BLOCK_NAME) == "Stone" then
                self.voxels:set(i,j,k,depositType)
            end
        end)
    
    end
    
    function deposit:blockUpdate(t)
        local x,y,z = self:xyz()

        if self.voxels:isRegionLoaded(x-3, y-3, z-3, x+3, y+3, z+3) then
            self:generate()
        else
            self:schedule(60)
        end
    end
    
    function deposit:created()
        self:schedule(1)
    end
end
