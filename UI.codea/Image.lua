-- ** Image **

ui.image = class(ui.panel)

IMAGE_FILL = 1
IMAGE_FIT = 2
IMAGE_STRETCH = 3

function ui.image:init(params)
    ui.panel.init(self, params)
    -- you can accept and set parameters here

    self.flipX = params.flipX or false
    self.flipY = params.flipY or false
    self.fillMode = params.fillMode or IMAGE_FIT
    self.fill = params.fill or color(255, 255, 255, 255)
    self.opaque = params.opaque or false
    self.rotation = params.rotation or 0
    
    if params.inset and type(params.inset) == "table" then
        self.inset = params.inset
    else
        local i = params.inset
        self.inset = i and {t = i, r = i, b = i, l = i} or 
            {t = 0, r = 0, b = 0, l = 0}
    end
    
    self:setImage(params.image)
    self.model = mesh()
end

function ui.image:setImage(img)
    self.img = img
end

function ui.image:draw()
    if not self.visible then return end
    
    ui.panel.draw(self)
    
    pushStyle() pushMatrix()
    
    --noFill()
    --rect(self.frame.x, self.frame.x, self.frame.x + self.frame.w, self.frame.y + self.frame.h)
    
    if self.img then
        spriteMode(CENTER)
        local w,h = spriteSize(self.img)
        
        if self.fillMode == IMAGE_STRETCH then
            w = self.frame.w
            h = self.frame.h
        elseif self.fillMode == IMAGE_FIT then
            if self.frame.w >= self.frame.h then
                
            else
                
            end
        elseif self.fillMode == IMAGE_FILL then
            if self.frame.w >= self.frame.h then
                
            else
                
            end
        end

        -- 9 Patch Mode
        local t,r,b,l = self.inset.t, self.inset.r, self.inset.b, self.inset.l      
        if t > 0 or r > 0 or b > 0 or l > 0 then
            translate(self.frame.x, self.frame.y)
            
            self.model:clear()
            self.model.texture = self.img
            
            local sx, sy = spriteSize(self.img)

            -- Top
            local i = self.model:addRect(self.frame.w/2, self.frame.h - t/2, w - l - r, t)    
            self.model:setRectTex(i, l/sx,(sy-t)/sy,(sx-l-r)/sx,t/sy)
            
            -- Top Right
            i = self.model:addRect(self.frame.w - r/2, self.frame.h - t/2, r, t)    
            self.model:setRectTex(i, (sx-r)/sx,(sy-t)/sy,r/sx,t/sy)            
            
            -- Right
            i = self.model:addRect(self.frame.w - r/2, self.frame.h/2, r, h - t - b)    
            self.model:setRectTex(i, (sx-r)/sx,t/sy,r/sx,(sy - t - b)/sy)         
            
            -- Bottom Right
            i = self.model:addRect(self.frame.w - r/2, b/2, r, b)    
            self.model:setRectTex(i, (sx-r)/sx,0,r/sx,b/sy)
            
            -- Bottom
            local i = self.model:addRect(self.frame.w/2, b/2, w - l - r, b)    
            self.model:setRectTex(i, l/sx,0,(sx-l-r)/sx,t/sy)         
            
            -- Bottom Left
            i = self.model:addRect(l/2, b/2, l, b)    
            self.model:setRectTex(i, 0,0,l/sx,b/sy)
            
            -- Left
            i = self.model:addRect(l/2, self.frame.h/2, l, h - t - b)    
            self.model:setRectTex(i, 0,t/sy,l/sx,(sy - t - b)/sy)         
            
            -- Top Left
            i = self.model:addRect(l/2, self.frame.h - t/2, l, t)    
            self.model:setRectTex(i, 0,(sy-t)/sy,l/sx,t/sy) 
            
            -- Middle
            i = self.model:addRect(self.frame.w/2, self.frame.h/2, w-l-r, h-t-b)    
            self.model:setRectTex(i, l/sx,b/sy,(sx-l-r)/sx,(sy-b-t)/sy)          
            
            self.model:setColors(self.fill)
            
            self.model:draw()
        else
            translate(self.frame.x + self.frame.w/2, 
                      self.frame.y + self.frame.h/2)
            rotate(self.rotation or 0)
            
            if self.flipX then w = -w end
            if self.flipY then h = -h end
            tint(self.fill)
            sprite(self.img, 0, 0, w, h)
        end
        
    end
    
    popStyle() popMatrix()
end
