-------------------------------------------------------------------------------
-- FirstPersonViewer
-- Written by John Millard
-------------------------------------------------------------------------------
-- Description:
-- A basic viewer for first person cameras.
-- Attach to a camera's entity for basic first person controls:
-- i.e. scene.camera:add(FirstPersonViewer)
-------------------------------------------------------------------------------

FirstPersonViewer = class()

local IDLE = 1
local ROTATE = 2

function FirstPersonViewer:init(camera, tapHandler)
    self.camera = camera
    self.rx = 0
    self.ry = 0
    self.state = IDLE
    self.enabled = true
    self.tapHandler = tapHandler
    self.sensitivity = 0.25
    touches.addHandler(self, 0, false) 
end

function FirstPersonViewer:isActive()
    return self.state ~= IDLE
end

function FirstPersonViewer:update()
    if self.enabled then  
        -- clamp vertical rotation between -90 and 90 degrees (no upside down view)
        self.rx = math.min(math.max(self.rx, -90), 90)
        local rotation = quat.eulerAngles(self.rx,  self.ry, 0)
        self.camera.rotation = rotation
    end
end

function FirstPersonViewer:touched(touch)
    if self.state == IDLE then
        if touch.state == BEGAN then
            self.start = vec2(touch.x, touch.y)
        elseif touch.state == MOVING then
            local length = (vec2(touch.x, touch.y) - self.start):len()
            if length >= 5 then
                self.state = ROTATE
            end        
        end       
    elseif self.state == ROTATE then
        if touch.state == MOVING then
            self.rx = self.rx - touch.deltaY * self.sensitivity
            self.ry = self.ry - touch.deltaX * self.sensitivity
        elseif touch.state == ENDED then
            self.state = IDLE
        end           
    end
    
    return true
end
