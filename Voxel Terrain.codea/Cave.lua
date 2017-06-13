function loadCave()
    
    local cave = craft.voxels.blocks:new("Cave")
    cave.scripted = true
    cave:setTexture(ALL, "Blocks:Blank White")
    cave.tinted = true
    
    function cave:created()
        
        self.gx = craft.noise.perlin()
        self.gx.frequency = 0.5
        self.gx.seed = self.x
        self.gy = craft.noise.perlin()        
        self.gy.frequency = 0.5
        self.gy.seed = self.y
        self.gz = craft.noise.perlin()                
        self.gz.frequency = 0.5
        self.gz.seed = self.z
        
        self.cx = self.x
        self.cy = self.y
        self.cz = self.z 
        
        self.pos = vec3(self.x, self.y, self.z)

        self.voxels:fill(0)
        for i = 1,100 do
            self.voxels:sphere(self.cx, self.cy, self.cz, 3)
             
            local dir = vec3(self.gx:getValue(self.cx/16.0, self.cy/16.0, self.cz/16.0), 
                             self.gy:getValue(self.cx/16.0, self.cy/16.0, self.cz/16.0), 
                             self.gz:getValue(self.cx/16.0, self.cy/16.0, self.cz/16.0))
            dir.y = dir.y - 0.125
            dir = dir:normalize()
            
            self.pos = self.pos + dir
            
            self.cx = math.tointeger(math.floor(self.pos.x))
            self.cy = math.tointeger(math.floor(self.pos.y))
            self.cz = math.tointeger(math.floor(self.pos.z))
        end

        
    end
    
end
