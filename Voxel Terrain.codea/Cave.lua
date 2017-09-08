function caveGenerator()
    
    -- A cave system generator that carves out tunnels.
    local cave = scene.voxels.blocks:new("Cave")
    cave.dynamic = true
    cave.geometry = EMPTY
    cave.static.hasIcon = false

    function cave:carve()
        local x,y,z = self.cx, self.cy, self.cz
        local caveID = cave.id
        local waterID = self.voxels.blocks.water.id
        local bedrockID = self.voxels.blocks.bedrock.id        
        
        local r = math.floor( (self.gr:getValue(x/16.0, y/16.0, z/16.0)+1)*0.5 * 2.5 + 1.5 )
        local r2 = r*r
        
        self.voxels:iterateBounds(x-r, y-r, z-r, x+r, y+r, z+r, function(i,j,k,id)
            local dx, dy, dz = x-i, y-j, z-k
            local d = dx*dx + dy*dy + dz*dz       
            
            if id ~= caveID and id ~= waterID and id ~= bedrockID and d < r2 then
                self.voxels:set(i,j,k,0)
            end
        end)
        
        local dir = vec3(self.gx:getValue(x/16.0, y/16.0, z/16.0), 
                            self.gy:getValue(self.cx/16.0, self.cy/16.0, self.cz/16.0), 
                            self.gz:getValue(self.cx/16.0, self.cy/16.0, self.cz/16.0))
        dir.y = dir.y - 0.1
        dir.x = dir.x * 1.5
        dir.z = dir.z * 1.5        
        dir = dir:normalize()
            
        self.pos = self.pos + dir
            
        self.cx = math.tointeger(math.floor(self.pos.x))
        self.cy = math.tointeger(math.floor(self.pos.y))
        self.cz = math.tointeger(math.floor(self.pos.z))
        
        self.length = self.length - 1
        return self.length > 0
    end
    
    function cave:blockUpdate(t)
        local x,y,z = self:xyz()

        if self.gx == nil then
            return
        end

        if self.voxels:isRegionLoaded(x-3, y-3, z-3, x+3, y+3, z+3) then
            if self:carve() then
                self:schedule(1)
            else
                self.voxels:set(x,y,z,0)
                if math.random() < 0.25 then
                    self.voxels:set(x+3, y+1, z-2, cave.id)
                end
                if math.random() < 0.25 then
                    self.voxels:set(x-3, y+1, z+2, cave.id)
                end
            end
        else
            self:schedule(60)
        end
    end
    
    function cave:setup()
        self.gx = craft.noise.perlin()
        self.gx.frequency = 0.5
        self.gx.seed = self.x
        self.gy = craft.noise.perlin()        
        self.gy.frequency = 0.5
        self.gy.seed = self.y
        self.gz = craft.noise.perlin()                
        self.gz.frequency = 0.5
        self.gz.seed = self.z
        
        self.gr = craft.noise.perlin()                
        self.gr.frequency = 0.5
        self.gr.seed = self.x * self.z
            
        self.cx = self.x
        self.cy = self.y
        self.cz = self.z 
        
        self.pos = vec3(self.x, self.y, self.z)

        self.length = math.random(50,150)
        
        local x,y,z = self:xyz()
        if self.voxels:get(x,y-1,z,BLOCK_NAME) ~= "Grass" then
            self.voxels:set(x,y,z,0)
            return
        end
        
        self:schedule(1)  
    end

    function cave:load()
        self:setup()
    end
        
    function cave:created()
        self:setup()
    end
    
end
