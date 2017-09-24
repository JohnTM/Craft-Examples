-- The shelf used to manipulate tool settings and access commands, such as UNDO

Shelf = class(UI.Panel)

function Shelf:init()
    -- you can accept and set parameters here
    UI.Panel.init(self, 0,0,270,HEIGHT-40)
    self.fill = color(55, 56, 56, 255)
    
    self:makeSection("mode", 
    {
        makeToolButton("add", TOOL_ADD),
        makeToolButton("rep", TOOL_REPLACE),
        makeToolButton("del", TOOL_ERASE),  
        makeToolButton("get", TOOL_GET),      
    })  
    
    self:makeSection("tool", 
    {
        makeToolTypeButton("point", TOOL_TYPE_POINT),
        makeToolTypeButton("line", TOOL_TYPE_LINE),
        makeToolTypeButton("box", TOOL_TYPE_BOX)    
    }) 

    self:makeSection("history", 
    {
        UI.Button(0, 0, 75, 30, "undo", function(b) undo() end)
    })  
    
    self:makeSection("mirror", 
    {
        UI.Button(0, 0, 75, 30, "x", function(b) 
            b.selected = not b.selected
            mirror.x = b.selected
        end),
        UI.Button(0, 0, 75, 30, "y", function(b) 
            b.selected = not b.selected
            mirror.y = b.selected
        end),
        UI.Button(0, 0, 75, 30, "z", function(b) 
            b.selected = not b.selected
            mirror.z = b.selected
        end)
    })  

    self:makeSection("options",
    {
        UI.Button(0,0,75,30,"outline", function(b)
            b.selected = not b.selected
            volume.model:getMaterial().showOutline = b.selected
        end)
    })
    
    self:makeSection("grid",
    {
        UI.Button(0,0,75,30,"sides", function(b)
            b.selected = not b.selected
            grids.left.enabled = b.selected
            grids.right.enabled = b.selected 
            grids.front.enabled = b.selected
            grids.back.enabled = b.selected                     
        end),
        UI.Button(0,0,75,30,"top", function(b)
            b.selected = not b.selected
            grids.top.enabled = b.selected
        end),
        UI.Button(0,0,75,30,"bottom", function(b)
            b.selected = not b.selected
            grids.bottom.enabled = b.selected
        end)
    })
    
    self:layoutVertical(5, false)
end

function Shelf:makeSection(name, items)
    self:addChild(UI.Label(5,0,75,20,name,LEFT))
    local container = UI.Panel(0, 0, self.frame.w, 30)
    for k,v in pairs(items) do
        container:addChild(v) 
    end
    container:layoutHorizontal(5, true)
    container.fill = nil
    self:addChild(container)
end

function makeToolButton(name, mode)
    local toolButton = UI.Button(0, 0, 75, 30, name)    

    if mode == toolMode then
        toolButton.selected = true
    end    

    toolButton.action = function(b) 
        for k,v in pairs(b.parent.children) do
            if v ~= toolButton then
                v.selected = false
            end
        end

        b.selected = not b.selected
        if b.selected then
            toolMode = mode
        else
            toolMode = nil
        end
    end

    return toolButton
end

function makeToolTypeButton(name, mode)
    local toolButton = UI.Button(0, 0, 75, 30, name)    

    if mode == toolType then
        toolButton.selected = true
    end    

    toolButton.action = function(b) 
        for k,v in pairs(b.parent.children) do
            v.selected = false
        end

        b.selected = true
        toolType = mode
    end

    return toolButton
end
