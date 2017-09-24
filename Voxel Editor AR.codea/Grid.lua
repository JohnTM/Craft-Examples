-- A reusable grid class for drawing the voxel editor grid

Grid = class()

function Grid:init(normal, origin, spacing, size, enabled)
    self.normal = normal
    self.origin = origin
    self.spacing = spacing
    self.size = size
    self.axes = {vec3(), vec3()}
    self.enabled = enabled
    
    if self.normal.x ~= 0 then
        self.axes[1].y = 1
        self.axes[2].z = 1
        self.axes2 = {3, 2, 1}
    elseif self.normal.y ~= 0 then
        self.axes[1].x = 1
        self.axes[2].z = 1
        self.axes2 = {1, 3, 2}
    elseif self.normal.z ~= 0 then
        self.axes[1].x = 1
        self.axes[2].y = 1  
        self.axes2 = {1, 2, 3}      
    end
    
    self.entity = scene:entity()
    self.entity.parent = root
    self.r = self.entity:add(craft.renderer, craft.model.cube(vec3(1,1,1), vec3(0.5,0.5,0.5)))
    self.r.material = craft.material("Materials:Basic")
    self.r.material.blendMode = NORMAL
    self.r.material.opacity = 0.4
    
    self:modified()
end

-- Checks if the grid is visible based on where the camera is pointed
function Grid:isVisible()
    --local camVec = scene.camera.worldPosition - self.origin      
    --return self.enabled and self.normal:dot(camVec) > 0.0
    return true
end

function Grid:modified()
    local gx = self.size[self.axes2[1]]
    local gy = self.size[self.axes2[2]]

    self.img = image(gx * 20, gy * 20)            
        
    self.r.material.map = self.img
    
    -- Pre-render the grid to an image to make it look nicer (anti-aliasing)
    setContext(self.img)
    background(0,0,0,0)
    pushStyle()
    stroke(255, 255, 255, 255)
    strokeWidth(5)
    noFill()
    rectMode(CORNER)
    rect(-2,-2,self.img.width+4, self.img.height+4)
    
    strokeWidth(2)
    stroke(255, 255, 255, 255)
    
    for x = 1,gx-1 do
        line(x * (self.img.width/gx), 3, x * (self.img.width/gx), self.img.height-3)
    end  
    
    for y = 1,gy-1 do
        line(3, y * (self.img.height/gy), self.img.width-3, y * (self.img.height/gy))
    end  
    
    popStyle()
    setContext()
    
    local s = vec3()
    s[self.axes2[1]] = self.size[self.axes2[1]]
    s[self.axes2[2]] = self.size[self.axes2[2]]
    self.entity.scale = s
    local p = vec3()
    p[self.axes2[3]] = self.origin[self.axes2[3]]
    self.entity.position = p
end

function Grid:update()
    self.entity.active = self:isVisible()
end