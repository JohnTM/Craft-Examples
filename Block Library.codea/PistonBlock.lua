-- A piston block (pushes other blocks 1 unit in a given direction)
function piston()
    -- By default all blocks can be pushed
    craft.block.static.canPush = true
    
    -- Helper function to move a block
    local function moveBlock(x,y,z,u,v,w)
        local id, state = scene.voxels:get(x,y,z, BLOCK_ID, BLOCK_STATE)
        scene.voxels:set(u,v,w, BLOCK_ID, id, BLOCK_STATE, state)
        scene.voxels:set(x,y,z, 0)
    end
    
    -- Block representing the piston's pusher
    local pusher = scene.voxels.blocks:new("Pusher")
    pusher.setTexture(ALL, "Blocks:Wood")  
    pusher.scripted = true
    pusher.geometry = TRANSPARENT   
    pusher.state:addRange("facing", 0,3,0)
    -- Cannot be dug or pushed as this will break the piston it's attached to
    pusher.static.canDig = false
    pusher.static.canPush = false
    pusher.static.hasIcon = false
    pusher.static.canPlace = false

    -- Custom appearance
    function pusher:buildModel(model)
        model:clear()
        model:addElement
        {
            lower = vec3(0,0,190),
            upper = vec3(255,255,255), 
            textures = "Blocks:Wood",           
            ao = false
        }
        
        model:addElement
        {
            lower = vec3(100,100,0),
            upper = vec3(156,156,190),  
            textures = "Blocks:Wood",    
            ao = false
        }  
    
        model:rotateY(self:get("facing"))
    end
    
    
    local piston = scene.voxels.blocks:new("Piston")  
    piston.setTexture(ALL, "Blocks:Stone")
    piston.geometry = TRANSPARENT
    piston.scripted = true    
    piston.state:addFlag("on", false)
    piston.state:addRange("facing", 0,3,0)
    piston.static.maxPush = 5
    piston.static.hasIcon = true
        
    function piston:buildModel(model)
        model:clear()
        model:addElement
        {
            lower = vec3(0,0,0),
            upper = vec3(255,255,190),        
            ao = false
        } 
        
        if not self:get("on") then
            model:addElement
            {
                lower = vec3(0,0,190),
                upper = vec3(255,255,255), 
                textures = "Blocks:Wood",           
                ao = false
            }            
        else
            model:addElement
            {
                lower = vec3(80,80,190),
                upper = vec3(176,176,255),  
                textures = "Blocks:Wood",    
                ao = false
            }            
        end  
        
        model:rotateY(self:get("facing"))
    end
    
    function piston:placed(entity, normal, forward)
        self:set("facing", (craft.block.directionToFace(forward)+1)%4 )
    end
    
    function piston:destroyed()
        local on = self:get("on")   
        
        if on then
            local px,py,pz = self:pushPos()
            self.voxels:set(px, py, pz, 0)            
        end
    end
    
    function piston:pushPos()
        local facing = self:get("facing")
        local x,y,z = self:xyz()
        if facing == 0 then z = z + 1 end
        if facing == 1 then x = x - 1 end
        if facing == 2 then z = z - 1 end
        if facing == 3 then x = x + 1 end   
        return x,y,z                            
    end
    
    -- this function will push a line of blocks in tne direction of the piston up
    -- to a set maximum after which it will fail to push
    function piston:push()
        local x,y,z = self:xyz()
        local px,py,pz = self:pushPos()
        local dx, dy, dz = px-x, py-y, pz-z
     
        -- Check for empty air
        local mp = 0       
        for i = 1,self.class.maxPush do
            local sx,sy,sz = x + dx*i, y + dy*i, z + dz*i 
            local b = self.voxels:get(sx, sy, sz)  
            if b and b.name == "piston" and b:get("on") then
                return false
            elseif b and not b.class.canPush then
                return false
            elseif b and b.class.id == 0 then
                break
            end
            mp = mp + 1
        end
        
        if mp == 0 then return true end
        
        if self.voxels:get(px + dx*mp, py + dy*mp, pz + dz*mp, BLOCK_ID) == 0 then
            for i = mp,1,-1 do
                local sx,sy,sz = x + dx*i, y + dy*i, z + dz*i            
                moveBlock(sx,sy,sz,sx+dx,sy+dy,sz+dz)     
            end  
            return true                
        end
            
        return false   
    end
    
    function piston:interact()
        
        local on = self:get("on")
        
        local px,py,pz = self:pushPos()
        local facing = self:get("facing")
        if not on then                
            if self:push() then
                self.voxels:set(px, py, pz, "name", "Pusher", "facing", facing)
                self:set("on", true)
            end
        else
            self.voxels:set(px, py, pz, 0) 
            self:set("on", false)         
        end         
    end
     
    return piston
end
