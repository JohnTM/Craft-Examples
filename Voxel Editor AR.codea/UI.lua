-- A basic UI library for the voxel editor (really just an early version of the UI library project)

UI = {}

UI.Panel = class()

function UI.Panel:init(x,y,w,h)
    self.frame = {x = x, y = y, w = w, h = h}
    self.tframe = {x = 0, y = 0, w = w, h = h}
    self.fill = color(76, 76, 76, 255)
    self.interactive = false
    self.children = {}
    self.cornerRadius = 0
    self.visible = true
    self.needsLayout = false
end

function UI.Panel:draw() 
    if not self.visible then return end    

    pushStyle() pushMatrix()
    translate(self.frame.x, self.frame.y)

    if self.fill then
        
        if self.cornerRadius == 0 then
            strokeWidth(0)
            noSmooth()
            fill(self.fill.r, self.fill.g, self.fill.b, self.fill.a)
            rect(0,0, self.frame.w, self.frame.h)
        else
            rRect(self.frame.w, self.frame.h, self.cornerRadius, self.fill)
        end
    end

    for k,v in pairs(self.children) do
        v:draw()
    end

    popStyle() popMatrix()
end

-- Layout and positioning
function UI.Panel:update()
    if self.parent then
        self.tframe.x = self.parent.tframe.x + self.frame.x
        self.tframe.y = self.parent.tframe.y + self.frame.y           
    else
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

function UI.Panel:setFrame(x,y,w,h)
    self.frame.x = x
    self.frame.y = y
    self.frame.w = w
    self.frame.h = h
end

function UI.Panel:top(inside)
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

function UI.Panel:bottom(inside)
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

function UI.Panel:right(inside)
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

function UI.Panel:layoutHorizontal(spacing, stretch)
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

function UI.Panel:layoutVertical(spacing, stretch)
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
function UI.Panel:addChild(child)
    child.parent = self
    table.insert(self.children, child)
end

-- Interaction
function UI.Panel:hitTest(x,y)
    return x >= self.tframe.x and x <= self.tframe.x + self.tframe.w and
           y >= self.tframe.y and y <= self.tframe.y + self.tframe.h
end

function UI.Panel:touched(touch)
    return self.interactive and self:hitTest(touch.x, touch.y)
end

UI.Button = class(UI.Panel)

function UI.Button:init(x,y,w,h,t,a)
    UI.Panel.init(self,x,y,w,h)

    self.textFill = color(255, 255, 255, 255)
    self.selectedFill = color(29, 29, 29, 255)
    self.unselectedFill = color(82, 82, 82, 255)
    self.highlightedFill = color(181, 181, 181, 255)
    self.cornerRadius = 10
    
    self.label = UI.Label(5,5,w-10,h-10,t or "")
    self:addChild(self.label)

    self.highlighted = false
    self.selected = false
    self.action = a or function() end 
    self.interactive = true
    
    touches.addHandler(self, -2, false)
end

function UI.Button:draw()
    if not self.visible then return end

    self.fill = self.highlighted and self.highlightedFill or 
        (self.selected and self.selectedFill or self.unselectedFill)   

    UI.Panel.draw(self)
end

function UI.Button:layout()
    self.label.frame.w = self.frame.w - 10
    self.label.frame.h = self.frame.h - 10
end

function UI.Button:touched(touch)
    if touch.state == BEGAN and UI.Panel.touched(self, touch) then
        self.highlighted = true
        return true
    elseif touch.state == MOVING then
        self.highlighted = self:hitTest(touch.x, touch.y)
        return true
    elseif touch.state == ENDED or touch.state == CANCELLED then
        self.highlighted = false
        if self:hitTest(touch.x, touch.y) then
            self.action(self)
        end

        return true
    end

    return false
end


UI.Label = class(UI.Panel)

function UI.Label:init(x,y,w,h,t,a)
    UI.Panel.init(self, x,y,w,h)
    self.text = t
    self.align = a or CENTER
end

function UI.Label:draw()
    pushStyle()
    
    font("SourceSansPro-Light")

    textAlign(LEFT)
    textMode(CORNER)
    
    local w,h = textSize(self.text)
    
    fill(255, 255, 255, 255)
    
    local cx = self.frame.x + self.frame.w * 0.5 - w * 0.5
    if self.align == LEFT then
        cx = self.frame.x
    end
    
    local cy = self.frame.y + self.frame.h * 0.5 - h * 0.5
    text(self.text, cx, cy)
    
    popStyle()
end


UI.Swatch = class(UI.Button)

function UI.Swatch:init(x,y,w,h,c)
    UI.Button.init(self,x,y,w,h)
    self.color = c
end

function UI.Swatch:draw()
    if not self.visible then return end   

    pushStyle()
    pushMatrix()
    translate(self.frame.x, self.frame.y)
    tint(self.color)
    --ellipseMode(CORNER)
    --fill(self.color)

    spriteMode(CORNER)
  
    local icon = scene.voxels.blocks:get("Solid").icon
      
    if self.selected then
        sprite(icon, 0, 0, self.frame.w, self.frame.h)
        --ellipse(0,0,self.frame.w,self.frame.h)
    else
        sprite(icon, 5, 5, self.frame.w-10, self.frame.h-10)        
        --ellipse(5,5,self.frame.w-10, self.frame.h-10)
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