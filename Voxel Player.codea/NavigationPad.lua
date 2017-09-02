NavigationPad = class()

NavigationPad.ButtonSize = 80

function NavigationPad:init()
    
    local bs = NavigationPad.ButtonSize
    
    -- you can accept and set parameters here
    self.panel = ui.panel
    {
        x = WIDTH - bs*3, 
        y = 0,
        w = bs*3,
        h = bs*3,
        pivot = vec2(1,0),
        align = {h = ui.RIGHT, v = ui.BOTTOM}
        --bg = readImage("Documents:grey_button11"),
        --fill = color(67, 67, 67, 107)
    }
    self.panel.interactive = true
    
    self.buttons = 
    {
        forward = self:navButton(bs, bs*2, bs, bs, 2, "UI:Arrow Button Up", 0),
        right = self:navButton(bs*2, bs, bs, bs, 2, "UI:Arrow Button Right", -90), 
        backward = self:navButton(bs, 0, bs, bs, 2, "UI:Arrow Button Down", 180),
        left = self:navButton(0, bs, bs, bs, 2 ,"UI:Arrow Button Left", 90),
        middle = self:navButton(bs, bs, bs, bs, 2, "UI:Arrow Button Up"), 
        forwardLeft = self:navButton(0, bs*2, bs, bs, 5, "UI:Arrow Button Up", 45),
        forwardRight = self:navButton(bs*2, bs*2, bs, bs, 5, "UI:Arrow Button Up", -45)                                                                                                      
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
        normalBg = readImage(icon),
        parent = self.panel,
        border = border + 5,
        normalFill = color(255, 255, 255, 255),
        highlightedFill = color(191, 191, 191, 255)
    }
    
    if icon then
        --button.icon.img = icon
        --button.icon.rotation = r
    end
    
    button.share = true
    
    return button
end

function NavigationPad:draw()
    self.panel:update()
    self.panel:draw()
end

