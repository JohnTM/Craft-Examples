-- ** Panel **

ui = {}

ui.LEFT = 1
ui.CENTER = 2
ui.RIGHT = 3
ui.TOP = 4
ui.BOTTOM = 5
ui.STRETCH = 6

ui.panel = class()

function ui.panel:init(params)
    assert(params)

    local x = params.x or 0
    local y = params.y or 0
    local w = params.w or 200
    local h = params.h or 100
    
    self.frame = {x = 0, y = 0, w = 0, h = 0}
    self.tframe = {x = 0, y = 0, w = 0, h = 0}
   
    self.pivot = params.pivot or vec2(0.5, 0.5)  
    self.anchor = vec2(0,0)
    self.size = vec2(1,1)
    
    if params.parent then
        params.parent:addChild(self)
    end
    
    self:setFrame(x,y,w,h)    
    self.anchor = params.anchor or self.anchor
    self.size = params.size or self.size
    
    self.fill = params.fill or color(76, 76, 76, 255)
    self.interactive = false
    self.visible = true
    self.opaque = params.opaque and true
    self.needsLayout = false
    self.children = {}
    self.align = params.align or {h = ui.LEFT, v = ui.BOTTOM}
    self.border = params.border or 0
    self.inset = params.inset or 10
    
    if params.bg then
        x,y,w,h = self:getFrame()
        self.bg = ui.image
        {
            parent = self,
            size = vec2(1-(2*self.border/w),1-(2*self.border/h)),
            anchor = vec2(0.5, 0.5),
            image=params.bg, 
            fillMode = IMAGE_STRETCH, 
            inset = params.inset, 
            align = {h = ui.STRETCH, v = ui.STRETCH}
        }
    end
   
    self:update()
end

function ui.panel:draw() 
    if not self.visible then return end    

    if self.bg then
        self.bg.fill = self.fill
    end
    
    pushStyle() pushMatrix()
    translate(self.frame.x, self.frame.y)

    for k,v in pairs(self.children) do
        v:draw()
    end

    popStyle() popMatrix()
end

-- Layout and positioning
function ui.panel:update()
    
    -- Check is parent size has changed
    local pw, ph = WIDTH, HEIGHT
    if self.parent then
        pw = self.parent.frame.w
        ph = self.parent.frame.h        
    end
   
    -- Adjust width and height depending on stretching
    if pw ~= self.pw then
        local w = self.size.x * self.pw
        local x = self.anchor.x * self.pw - self.pivot.x * w

        if self.align.h == ui.LEFT then
            x = x + self.pivot.x * w
            self.anchor.x = x / pw
        elseif self.align.h == ui.CENTER then
            x = x - self.pw/2 + pw/2 + self.pivot.x * w
            self.anchor.x = x / pw
        elseif self.align.h == ui.RIGHT then
            x = x - self.pw + pw + self.pivot.x * w
            self.anchor.x = x / pw            
        elseif self.align.h == ui.STRETCH then
            local left = x
            local right = x - self.pw + pw + w
            w = right - left
            self.anchor.x = (left + self.pivot.x * w) / pw
        end
        
        self.size.x = w / pw           
              
        self.pw = pw
    end 

    if ph ~= self.ph then      
        local h = self.size.y * self.ph
        local y = self.anchor.y * self.ph - self.pivot.y * h   
        
        if self.align.v == ui.BOTTOM then
            y = y + self.pivot.y * h
            self.anchor.y = y / ph
        elseif self.align.v == ui.CENTER then
            y = y - self.ph/2 + ph/2 + self.pivot.y * h
            self.anchor.y = y / ph
        elseif self.align.v == ui.TOP then
            y = y - self.ph + ph + self.pivot.y * h
            self.anchor.y = y / ph            
        elseif self.align.v == ui.STRETCH then
            local left = y
            local right = y - self.ph + ph + h
            h = right - left
            self.anchor.y = (left + self.pivot.y * h) / ph
        end
        
        self.size.y = h / ph           
        
        self.ph = ph
    end
    
    
    if self.parent then
        self.frame.w = self.parent.frame.w * self.size.x 
        self.frame.h = self.parent.frame.h * self.size.y
        self.frame.x = self.anchor.x * self.parent.frame.w - self.frame.w * self.pivot.x
        self.frame.y = self.anchor.y * self.parent.frame.h - self.frame.h * self.pivot.y
        
        self.tframe.x = self.parent.tframe.x + self.frame.x
        self.tframe.y = self.parent.tframe.y + self.frame.y           
    else
        self.frame.w = WIDTH * self.size.x
        self.frame.h = HEIGHT * self.size.y
        self.frame.x = self.anchor.x * WIDTH - self.frame.w * self.pivot.x
        self.frame.y = self.anchor.y * HEIGHT - self.frame.h * self.pivot.y
        
        self.tframe.x = self.frame.x
        self.tframe.y = self.frame.y
    end 
    
    self.tframe.w = self.frame.w
    self.tframe.h = self.frame.h 
    
    if self.needsLayout and self.layout then 
        self:layout() 
        self.needsLayout = false
    end

    for k,v in pairs(self.children) do
        v:update()
    end
end

function ui.panel:setFrame(x,y,w,h)
    local pw, ph = WIDTH, HEIGHT
    if self.parent then
        pw = self.parent.frame.w
        ph = self.parent.frame.h        
    end
    
    self.anchor = vec2((x + self.pivot.x * w) / pw, (y + self.pivot.y * h) / ph)
    self.size = vec2(w / pw, h / ph)    
    self.pw = pw 
    self.ph = ph  
    
    self.frame.x = x
    self.frame.y = y   
    self.frame.w = w   
    self.frame.h = h         
end

function ui.panel:getFrame()
    if self.parent then
        local px,py,pw,ph = self.parent:getFrame()
        
        local w = self.size.x * pw
        local h = self.size.y * ph
        local x = self.anchor.x * pw - self.pivot.x * w
        local y = self.anchor.y * ph - self.pivot.y * h
        return x,y,w,h
    else
        local w = self.size.x * WIDTH
        local h = self.size.y * HEIGHT
        local x = self.anchor.x * WIDTH - self.pivot.x * w
        local y = self.anchor.y * HEIGHT - self.pivot.y * h
        return x,y,w,h
    end
end

function ui.panel:top(inside)
    local value = 0
    if inside then
        for k,v in pairs(self.children) do
            value = math.max(value, self.tframe.y + v.frame.y + v.frame.h)
        end
    else
        value = self.tframe.y + self.tframe.h 
    end
    return value
end

function ui.panel:bottom(inside)
    local value = self.tframe.y + self.tframe.h
    if inside then
        for k,v in pairs(self.children) do
            value = math.min(value, self.tframe.y + v.frame.y)
        end
    else
        value = self.tframe.y
    end
    return value
end

function ui.panel:right(inside)
    local value = 0
    if inside then
        for k,v in pairs(self.children) do
            value = math.max(value, self.tframe.x + v.frame.x + v.frame.w)
        end
    else
        value = self.tframe.x + self.tframe.w
    end
    return value
end

function ui.panel:layoutHorizontal(spacing, stretch)
    if stretch then
        local width = (self.frame.w - spacing * (#self.children+1)) / #self.children
        local x = spacing
        for k,v in pairs(self.children) do
            v.frame.x = x
            v.frame.w = width
            x = x + width + spacing
            v.needsLayout = true
        end
    else
        local x = spacing
        for k,v in pairs(self.children) do
            v.frame.x = x
            x = x + v.frame.w + spacing
            v.needsLayout = true
        end
    end
    self:update()
end

function ui.panel:layoutVertical(spacing, stretch)
    if stretch then
        local height = (self.frame.h - spacing * (#self.children+1)) / #self.children
        local y = self.frame.h - spacing
        for k,v in pairs(self.children) do
            v.frame.y = y - v.frame.h
            v.frame.h = height
            y = y - height - spacing
            v.needsLayout = true
        end
    else
        local y = self.frame.h - spacing
        for k,v in pairs(self.children) do
            v.frame.y = y - v.frame.h
            y = y - v.frame.h - spacing
            v.needsLayout = true
        end
    end
    self:update()
end


-- Hierarchy
function ui.panel:addChild(child)
    local x,y,w,h = child:getFrame()
    child.parent = self
    child:setFrame(x,y,w,h)
    
    table.insert(self.children, child)
end

-- Interaction
function ui.panel:hitTest(x,y)
    return x >= self.tframe.x and x <= self.tframe.x + self.tframe.w and
           y >= self.tframe.y and y <= self.tframe.y + self.tframe.h
end

function ui.panel:touched(touch)
    return self.interactive and self.visible and self:hitTest(touch.x, touch.y)
end



ui.swatch = class(ui.button)

function ui.swatch:init(x,y,w,h,c)
    ui.button.init(self,x,y,w,h)
    self.color = c
end

function ui.swatch:draw()
    if not self.visible then return end   

    pushStyle()
    pushMatrix()
    translate(self.frame.x, self.frame.y)
    ellipseMode(CORNER)
    fill(self.color)

    if self.selected then
        ellipse(0,0,self.frame.w,self.frame.h)
    else
        ellipse(5,5,self.frame.w-10, self.frame.h-10)
    end

    popMatrix()
    popStyle()
end

function rRect(w,h,r,c)
    strokeWidth(0)
    fill(c.r, c.g, c.b, c.a)
    ellipse(r/2,h-r/2,r) ellipse(w-r/2,h-r/2,r)
    ellipse(r/2,r/2,r) ellipse(w-r/2,r/2,r)
    rect(0,r/2,w,h-r) rect(r/2,0,w-r,h)
end