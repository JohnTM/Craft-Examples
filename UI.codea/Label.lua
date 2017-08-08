-- ** Label **

ui.label = class(ui.panel)

function ui.label:init(params)
    ui.panel.init(self, params)
    self.text = params.text
    self.alignment = params.alignment or CENTER
    self.fill = params.fill or color(255, 255, 255, 255)
    self.font = params.font or "SourceSansPro-Bold"
    self.fontSize = params.fontSize or 16
end

function ui.label:draw()
    if self.visible and self.text then
        pushStyle()
        
        font(self.font)
        
        textAlign(LEFT)
        textMode(CORNER)
        fontSize(self.fontSize)
        
        local w,h = textSize(self.text)
        
        fill(self.fill)
        
        local cx = self.frame.x + self.frame.w * 0.5 - w * 0.5
        if self.alignment == LEFT then
            cx = self.frame.x
        end
        
        local cy = self.frame.y + self.frame.h * 0.5 - h * 0.5
        text(self.text, cx, cy)
        
        popStyle()
    end
end