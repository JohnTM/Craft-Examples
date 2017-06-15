CubeMapViewer = class()

function CubeMapViewer:init(source)
    self.source = source
    self.mapList = {"colorMaps", "heightMaps", "normalMaps"}     
end

function CubeMapViewer:draw()

    pushStyle()
    noSmooth()
    spriteMode(CORNER)
    
    local s = WIDTH/4
    
    local maps = self.source[ self.mapList[Map] ]
    if maps then
        sprite(maps[1], s*2, HEIGHT/2 - s/2, s, s) 
        sprite(maps[2], 0, HEIGHT/2 - s/2, s, s)
        sprite(maps[3], s, HEIGHT/2 - s/2 - s, s, s)     
        sprite(maps[4], s, HEIGHT/2 - s/2 + s, s, s)         
        sprite(maps[5], s, HEIGHT/2 - s/2, s, s)   
        sprite(maps[6], s*3, HEIGHT/2 - s/2, s, s) 
    end 
    
    popStyle()
    
end
