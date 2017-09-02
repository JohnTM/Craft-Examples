-- ** Button **

ui.button = class(ui.panel)

function ui.button:init(params)
    params.bg = params.normalBg
    ui.panel.init(self, params)

    self.textFill = color(255, 255, 255, 255)
    self.selectedFill = color(29, 29, 29, 255)
    self.normalFill = params.normalFill or color(255, 255, 255, 255)
    self.highlightedFill = color(181, 181, 181, 255)

    self.normalBg = params.normalBg
    self.highlightedBg = params.highlightedBg or self.normalBg
    self.selectedBg = params.selectedBg or self.highlightedBg or self.selectedBg
    
    self.icon = ui.image 
    {
        anchor = vec2(0.5,0.5),
        size = vec2(1,1),
        align = {h = ui.STRETCH, v = ui.STRETCH},
        parent = self
    }
    
    self.label = ui.label
    {
        text = params.text,
        fontSize = params.fontSize
    }
    self:addChild(self.label)
    self.label.anchor = vec2(0.5, 0.5)
    self.label.size = vec2(1, 1)
    self.label.align = {h = ui.STRETCH, v = ui.STRETCH}
    
    self.highlighted = false
    self.selected = false
    self.onPressed = params.onPressed
    self.onReleased = params.onReleased
    self.interactive = true
    
    if touches then touches.addHandler(self,-2) end
end

function ui.button:draw()
    if not self.visible then return end

    self.fill = self.highlighted and self.highlightedFill or 
        (self.selected and self.selectedFill or self.normalFill)
    
    if self.bg then
        self.bg.img = self.highlighted and self.highlightedBg or 
            (self.selected and self.selectedBg or self.normalBg)
    end
    
    self.label.fill = self.textFill
    
    ui.panel.draw(self)
    
end

function ui.button:layout()
    self.label.frame.w = self.frame.w - 10
    self.label.frame.h = self.frame.h - 10
end

function ui.button:touched(touch)   
    if touch.state == BEGAN and ui.panel.touched(self, touch) then
        self.highlighted = true
        if self.onPressed then self.onPressed(self, touch) end
        return true
    elseif touch.state == MOVING then
        if self:hitTest(touch.x, touch.y) then
            self.highlighted = true
        elseif touches then
            if self.share then
                touches.share(self, touch, -2)
            end 
            self.highlighted = false
        end
        return true
    elseif touch.state == ENDED or touch.state == CANCELLED then
        self.highlighted = false
        if self:hitTest(touch.x, touch.y) then
            if self.onReleased then self.onReleased(self, touch) end
        end

        return true
    end

    return false
end