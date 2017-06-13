NavigationPad = class()

function NavigationPad:init()
    -- you can accept and set parameters here
    self.panel = ui.panel
    {
        x = WIDTH-300, 
        y = 0,
        w = 300,
        h = 300,
        pivot = vec2(1,0),
        align = {h = ui.RIGHT, v = ui.BOTTOM}
        --bg = readImage("Documents:grey_button11"),
        --fill = color(67, 67, 67, 107)
    }
    self.panel.interactive = true
    
    local icon = "UI:Grey Arrow Up Grey"
    local iconMiddle = readImage("UI:Grey Box Tick")
    
    self.buttons = 
    {
        forward = self:navButton(100,200,100,100,5,icon,0),
        right = self:navButton(200,100,100,100,5,icon,-90), 
        backward = self:navButton(100,0,100,100,5,icon,180),
        left = self:navButton(0,100,100,100,5,icon,90),
        middle = self:navButton(100,100,100,100,10,iconMiddle), 
        forwardLeft = self:navButton(0,200,100,100,15,icon,45),
        forwardRight = self:navButton(200,200,100,100,15,icon,-45)                                                                                                      
    }
end

function NavigationPad:navButton(x,y,w,h,border,icon,r)
    local button = ui.button
    {
        x=x-5,
        y=y-5,
        w=w+10,
        h=h+10,
        align = {h = ui.STRETCH, v = ui.STRETCH},
        normalBg = readImage("UI:Grey Button 02"),
        parent = self.panel,
        border = border + 5,
        normalFill = color(255, 255, 255, 138),
        highlightedFill = color(191, 191, 191, 138)
    }
    
    if icon then
        button.icon.img = icon
        button.icon.rotation = r
    end
    
    button.share = true
    
    return button
end

function NavigationPad:draw()
    self.panel:update()
    self.panel:draw()
end

