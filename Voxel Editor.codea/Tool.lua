-- The tools used to apply voxels in the ditor
TOOL_ADD = 1
TOOL_REPLACE = 2 
TOOL_ERASE = 3
TOOL_GET = 4

TOOL_TYPE_POINT = 1
TOOL_TYPE_LINE = 2
TOOL_TYPE_BOX = 3
TOOL_TYPE_FLOOD = 4

TOOL_STATE_IDLE = 1
TOOL_STATE_DRAG = 2

COLORS = {
    color(255, 255, 255, 255),
    color(42, 190, 217, 255),
    color(193, 80, 80, 255),
    color(237, 160, 41, 255),
    color(98, 45, 173, 255),
    color(69, 96, 208, 255),
    color(179, 204, 44, 255),
    color(52, 132, 124, 255),
    color(146, 194, 77, 255),
    color(27, 27, 27, 255),
    color(117, 65, 43, 255),
    color(193, 193, 193, 255)
}

Tool = class()

function Tool:init()
    self.state = TOOL_STATE_IDLE
end

function Tool:touched(touch)    
    if #snapshots > 0 then
        volume:loadSnapshot(snapshots[#snapshots])
    end
    
    local coord, id, face = raycast(touch.x, touch.y, false)
    
    if coord then
        if toolMode == TOOL_ADD then
            coord = coord + face
        end   
    end  
        
    if toolMode == nil then
        return false
    end
    
    if coord and touch.state == BEGAN and self.state == TOOL_STATE_IDLE then
        if viewer:isActive() then return false end
        self.startCoord = coord
        self.endCoord = coord
        self.state = TOOL_STATE_DRAG
        self.points = {}
        table.insert(self.points, coord)
        self:apply()
        return true
    elseif touch.state == MOVING and self.state == TOOL_STATE_DRAG then
        if coord then
            self.endCoord = coord
        end
        table.insert(self.points, coord)
        self:apply()
        return true
    elseif touch.state == ENDED and self.state == TOOL_STATE_DRAG then
        self.state = TOOL_STATE_IDLE
        self:apply()
        saveSnapshot()
        return true
    end

    return false
end

function Tool:mirrorX(x)
    return (sx-1) - x
end

function Tool:applyPoints(...)
    for k,v in pairs(self.points) do
        volume:set(v, ...)  
        if mirror.x then
            volume:set(self:mirrorX(v.x), v.y, v.z, ...)              
        end
    end    
end

function Tool:applyBox(...)
    local minX = math.min(self.startCoord.x, self.endCoord.x)
    local maxX = math.max(self.startCoord.x, self.endCoord.x)
    local minY = math.min(self.startCoord.y, self.endCoord.y)
    local maxY = math.max(self.startCoord.y, self.endCoord.y)
    local minZ = math.min(self.startCoord.z, self.endCoord.z)
    local maxZ = math.max(self.startCoord.z, self.endCoord.z)
    
    for x = minX, maxX do
        for y = minY, maxY do
            for z = minZ, maxZ do
                if toolMode == TOOL_REPLACE then
                    if volume:get(x, y, z, BLOCK_ID) ~= 0 then
                        volume:set(x, y, z, ...)                                           
                    end
                else
                    volume:set(x, y, z, ...)                   
                end                
            end
        end
    end
end

function Tool:applyLine(...)
    if self.endCoord == self.startCoord then
        volume:set(self.startCoord, ...)
        return
    end
    
    local dir = (self.endCoord-self.startCoord)
    local args = {...}
    volume:raycast(self.startCoord + vec3(0.5, 0.5, 0.5), dir:normalize(), dir:len(), function(coord, id, face) 
        if coord then
            volume:set(coord, table.unpack(args))
            return false
        else
            return true
        end
    end)    
end

function Tool:apply()
    if toolMode == TOOL_ADD or toolMode == TOOL_REPLACE then
        if toolType == TOOL_TYPE_POINT then
            self:applyPoints("name", "Solid", "color", toolColor)
        elseif toolType == TOOL_TYPE_BOX then
            self:applyBox("name", "Solid", "color", toolColor)
        elseif toolType == TOOL_TYPE_LINE then
            self:applyLine("name", "Solid", "color", toolColor)
        end
    elseif toolMode == TOOL_ERASE then
        if toolType == TOOL_TYPE_POINT then
            self:applyPoints(0)
        elseif toolType == TOOL_TYPE_BOX then
            self:applyBox(0)            
        end
    elseif toolMode == TOOL_GET then
        local s = volume:get(self.startCoord, BLOCK_STATE)
        local r = (s>>24) & 255
        local g = (s>>16) & 255   
        local b = (s>>8) & 255     
        toolColor = color(r,g,b)
        Color = toolColor
    end
end
    


